local pNPC = loadSharedAPI("pnpc")

local npcGfx = {}

function npcGfx.onInitAPI()
	registerEvent(npcGfx, "onLoop", "onLoop", false)
	registerEvent(npcGfx, "onHUDDraw", "onHUDDraw", false)
end



do	
	npcGfx.debug = true
	npcGfx.exAnimated = {}
	npcGfx.imageWidths = {}
	npcGfx.imageHeights = {}
	
	function npcGfx.setExGfx (pnpcRef, properties)

		-- Initialize the exGfx data if it hasn't already been set up
		if pnpcRef.data.exGfx == nil  then
			pnpcRef.data.exGfx = {}
		end
		
	
		-- Load the image file
		if  	properties["imagePath"] ~= nil  and  properties["image"] == nil  then
			properties["image"] = Graphics.loadImage(Misc.resolveFile(properties["imagePath"]))
		end
		
		if properties["image"] == nil  then
			windowDebug ("ERROR, INVALID IMAGE")
			return;
		end
		
		local imageRef = properties["image"]
		
		if  npcGfx.imageWidths[imageRef] == nil  then
			_, npcGfx.imageWidths[imageRef], npcGfx.imageHeights[imageRef] = Graphics.getPixelData(imageRef);
		end

		pnpcRef.data.exGfx["image"] = imageRef or pnpcRef.data.exGfx["image"] or nil
		
		
		-- Load overwrite
		if  properties["overwrite"] ~= nil  then
			pnpcRef.data.exGfx["overwrite"] = properties["overwrite"]
		elseif  pnpcRef.data.exGfx["overwrite"] == nil  then
			pnpcRef.data.exGfx["overwrite"] = true
		end
	

		-- Load two-dir
		if  properties["twoDir"] ~= nil  then
			pnpcRef.data.exGfx["twoDir"] = properties["twoDir"]
		elseif  pnpcRef.data.exGfx["twoDir"] == nil  then
			pnpcRef.data.exGfx["twoDir"] = true
		end

	
		-- Load everything else in as-is
		pnpcRef.data.exGfx["frames"] = properties["frames"] or pnpcRef.data.exGfx["frames"] or 1
		pnpcRef.data.exGfx["states"] = properties["states"] or pnpcRef.data.exGfx["states"] or 1
		pnpcRef.data.exGfx["offsetX"] = properties["offsetX"] or pnpcRef.data.exGfx["offsetX"] or 0
		pnpcRef.data.exGfx["offsetY"] = properties["offsetY"] or pnpcRef.data.exGfx["offsetY"] or 0
		pnpcRef.data.exGfx["alpha"] = properties["alpha"] or pnpcRef.data.exGfx["alpha"] or 1
		
		pnpcRef.data.exGfx["anim"] = properties["anim"] or pnpcRef.data.exGfx["anim"] or {}
		
		pnpcRef.data.exGfx["currentFrame"] = pnpcRef.data.exGfx["currentFrame"] or 0
		pnpcRef.data.exGfx["currentAnimStep"] = pnpcRef.data.exGfx["currentAnimStep"] or 0
		pnpcRef.data.exGfx["currentState"] = pnpcRef.data.exGfx["currentState"] or 0
		
		
		if  pnpcRef.data.exGfx["init"] == nil  then
			table.insert (npcGfx.exAnimated, pnpcRef)
			pnpcRef.data.exGfx["init"] = true
		end
	end

	
	function npcGfx.updateAnim (pnpcRef)
		-- Don't bother if the animSequence is nil or empty
		if  pnpcRef.data.exGfx["anim"] == nil  or  pnpcRef.data.exGfx["anim"] == {}  then
			return;
		end
		
		-- If overwrite, hide the NPC's graphics
		if  pnpcRef.data.exGfx["overwrite"] == true  then
			pnpcRef:mem(0xE4, FIELD_WORD, 255)
			--pnpcRef:mem(0xE8, FIELD_DFLOAT, 0)
		end
		
		-- Cycle through with the regular animation timer
		if pnpcRef:mem (0xE8,FIELD_FLOAT) == 0  then
			local seqCount = #pnpcRef.data.exGfx["anim"]
			pnpcRef.data.exGfx["currentAnimStep"] = (pnpcRef.data.exGfx["currentAnimStep"] + 1)  %  seqCount
			pnpcRef.data.exGfx["currentFrame"] = pnpcRef.data.exGfx["anim"] [pnpcRef.data.exGfx["currentAnimStep"]+1]
		end

		
		-- Set state by direction if in two-dir mode
		if pnpcRef.data.exGfx["twoDir"] == true  then
			npcGfx.debugPrintToScene(tostring(pnpcRef.data.exGfx["currentState"]), 4, pnpcRef.x, pnpcRef.y-48)
		
			if  pnpcRef.data.exGfx["currentState"] % 2 == 0  and  pnpcRef.direction == DIR_RIGHT  then
				pnpcRef.data.exGfx["currentState"] = pnpcRef.data.exGfx["currentState"] + 1
				--windowDebug ("turn right")
			end
			
			if  pnpcRef.data.exGfx["currentState"] % 2 == 1  and  pnpcRef.direction == DIR_LEFT  then
				pnpcRef.data.exGfx["currentState"] = pnpcRef.data.exGfx["currentState"] - 1				
				--windowDebug ("turn left")
			end
		end
	end
	
	
	function npcGfx.draw (pnpcRef)
		local image = pnpcRef.data.exGfx["image"]
		
		local frameW = npcGfx.imageWidths[image] / pnpcRef.data.exGfx["states"]
		local frameH = npcGfx.imageHeights[image] / pnpcRef.data.exGfx["frames"]
		
		local stateX = (pnpcRef.data.exGfx["currentState"]) * frameW
		local frameY = (pnpcRef.data.exGfx["currentFrame"] - 1) * frameH
		
		local offX = pnpcRef.data.exGfx["offsetX"]
		local offY = pnpcRef.data.exGfx["offsetY"]
		
		Graphics.drawImageToSceneWP (image, 
									 pnpcRef.x + offX, pnpcRef.y + offY, 
									 stateX, frameY,
									 frameW, frameH, 
									 pnpcRef.data.exGfx["alpha"],
									 0.5)
	end

	
	function npcGfx.onHUDDraw ()
		local deleteQueue = {}
	
		for  k,v in pairs (npcGfx.exAnimated)  do
			-- Remove broken references
			if  v.isValid == false  then
				table.insert (deleteQueue, k)
			else
				--Text.print (tostring(k), 4, 4, 40+20*k)
				npcGfx.updateAnim (v)
				npcGfx.draw (v)
			end
		end
		
		for  k,v in pairs (deleteQueue)  do
			table.remove(npcGfx.exAnimated, v)
		end
	end

end





--***************************************************************************************************
--                                                                                                  *
--              DEBUG STUFF                                                                         *
--                                                                                                  *
--***************************************************************************************************

do
	function npcGfx.debugPrint (text, font, x,y)
		if  npcGfx.debug == true  then
			--textblox.print (text, x,y, testFont)
			Text.print (text, font, x, y)
		end
	end

	function npcGfx.debugPrintToScene (text, font, x,y)
		if  npcGfx.debug == true  then
			local x1,y1 = worldToScreen (x,y)
			--textblox.print (text, x1,y1, testFont)
			Text.print (text, font, x1, y1)
		end
	end
	
	
	function getScreenBounds()
		local h = (player:mem(0xD0, FIELD_DFLOAT));
		local b = { left = player.x-400+player.speedX, right = player.x+400+player.speedX, top = player.y-260+player.speedY, bottom = player.y+340+player.speedY };
		
		local sect = Section(player.section);
		local bounds = sect.boundary;

		if(b.left < bounds.left - 10) then
			b.left = bounds.left - 10;
			b.right = b.left + 800;
		end
		
		if(b.right > bounds.right - 10) then
			b.right = bounds.right - 10;
			b.left = b.right - 800;
		end
		
		if(b.top < bounds.top+40-h) then
			b.top = bounds.top+40-h;
			b.bottom = b.top + 600;
		end
		
		if(b.bottom > bounds.bottom+40-h) then
			b.bottom = bounds.bottom+40-h;
			b.top = b.bottom - 600;
		end
		
		return b;
		
	end	
	
	function worldToScreen(x,y)
		local b = getScreenBounds();
		local x1 = x-b.left;
		local y1 = y-b.top-(player:mem(0xD0, FIELD_DFLOAT))+30;
		return x1,y1;
	end
end

return npcGfx