local keyhole = {}

-- Define the constant if loaded in non-2.0 project
CHARACTER_KLONOA = CHARACTER_KLONOA  or  9

keyhole.mask = false
keyhole.size = 0
local levelEnded = false
keyhole.counter = 0
keyhole.lockObj = nil
keyhole.lockOffsets = {}
keyhole.roundPoints = 21
keyhole.radius = 30
keyhole.circleMidY = -25

-- Frame buffer
local frameBuffer = Graphics.CaptureBuffer(800, 600)


function keyhole.onInitAPI () --Is called when the api is loaded by loadAPI.
	registerEvent(keyhole, "onStart", "onStart", true)
	registerEvent(keyhole, "onCameraUpdate", "onCameraUpdate", true)
end


function closest (val, others)
	local smallestDist = math.huge
	local returnVal = -1
	local returnIndex = nil
	for  k,v in pairs(others)  do
		local dist = math.abs(val-v)
		if  dist <= smallestDist  then
			smallestDist = dist
			returnIndex = k
			returnVal = v
		end
	end
	
	return returnVal, returnIndex
end

function furthest (val, others)
	local largestDist = -math.huge
	local returnVal = -1
	local returnIndex = nil
	for  k,v in pairs(others)  do
		local dist = math.abs(val-v)
		if  dist >= largestDist  then
			largestDist = dist
			returnIndex = k
			returnVal = v
		end
	end
	
	return returnVal, returnIndex
end

local function lerp (minVal, maxVal, percentVal)
	return (1-percentVal) * minVal + percentVal*maxVal;
end

local function worldToScreen (x,y, camNumber)
	camNumber = camNumber or 1

	local cam = Camera.get ()[camNumber]
	local b =  {left = cam.x, 
				right = cam.x + cam.width,
				top = cam.y,
				bottom = cam.y + cam.height}
	local x1 = x-b.left;
	local y1 = y-b.top;
	return x1,y1;
end	


-- Define the lock mesh offsets
function keyhole.onStart ()
	
	-- Bottom mid and bottom left
	keyhole.lockOffsets = {00,25, -30,25}
	
	-- Circular part
	local circleY, r = keyhole.circleMidY, 30
	for i = 0,keyhole.roundPoints do
		local degrees = lerp (180-45, 360+45, i/keyhole.roundPoints)
		local angle = degrees * math.pi / 180
		local ptx, pty = r * math.cos( angle ), circleY + r * math.sin( angle )
		table.insert (keyhole.lockOffsets, ptx)
		table.insert (keyhole.lockOffsets, pty)
	end
	
	-- Bottom right
	table.insert (keyhole.lockOffsets, 30)
	table.insert (keyhole.lockOffsets, 25)
end


-- Handle the rendering and stuff
function keyhole.onCameraUpdate (eventObj, cameraIndex)
	
	if  Level.winState () == 3  and  levelEnded == false  then
		levelEnded = true

		local nearbyObj
		local doStep2 = true
		
		-- If Link, warping is based on player position		
		if  player.character == CHARACTER_LINK  then
			nearbyObj = player
		
		-- If Klonoa, check EVERY KEY EVER IN THE SECTION for keyhole overlap
		elseif  player.character == CHARACTER_KLONOA  then
			
			for  k1,v1 in pairs(NPC.get(31, player.section))  do
				
				-- Non-hidden keys only
				if  not v1:mem(0x40, FIELD_BOOL)  then
					
					-- Get all intersecting BGOs
					for  k2,v2 in pairs (BGO.getIntersecting(v1.x, v1.y, v1.x+v1.width, v1.y+v1.height)) do
						
						-- If the BGO is a lock and not hidden, then that's the lock object and we can skip everything else
						if  v2.id == 35  and  not v2.isHidden  then
							keyhole.lockObj = v2
							doStep2 = false;
							break;
						end
					end				
					if  keyhole.lockObj ~= nil  then  break;  end;
				end
				if  keyhole.lockObj ~= nil  then  break;  end;
			end
		
		-- Otherwise, is based on the held key's position
		else
			nearbyObj = NPC.get()[player:mem (0x154, FIELD_WORD)]
			
		end
		
		-- Get the lock from the reference instance
		if  doStep2  then
			local minDist = math.huge
			for  k,v in pairs (BGO.getIntersecting(nearbyObj.x, nearbyObj.y, nearbyObj.x+nearbyObj.width, nearbyObj.y+nearbyObj.height))  do
				local w1,h1 = v.x-nearbyObj.x, v.y-nearbyObj.y
				local dist = math.sqrt(w1^2 + h1^2)
				if  dist < minDist  and  v.id == 35  and v.isHidden == false  then
					keyhole.lockObj = v
					minDist = dist
				end
			end
		end
	end
	
	if  levelEnded  then
		keyhole.counter = keyhole.counter + 1
		
		if      keyhole.counter < 60  then
			keyhole.size = 5*(keyhole.counter/60)
		elseif  keyhole.counter < 120  then
			keyhole.size = 5
		elseif  keyhole.counter == 120 then
			i = 1
			--for k,v in pairs(NPC.get(31, player.section))  do
			--	v.animationFrame = 9999
			--end
			
		elseif  keyhole.counter < 180  then
			keyhole.mask = true
			keyhole.lockObj.isHidden = true
			keyhole.size = 5 - 5*((keyhole.counter-120)/60)
		else
			keyhole.size = 0
		end
		
		frameBuffer:captureAt (-56)
		keyhole.render (keyhole.size, keyhole.mask)
	end
end

function keyhole.render (scale, mask)
	local lockObj = keyhole.lockObj or player

	-- Determine the keyhole position
	local midX,midY = worldToScreen (lockObj.x+0.5*lockObj.width, lockObj.y+0.5*lockObj.height)
	local midY2 = midY-30*scale
	
	-- Calculate the relative points of the lock
	local lockPoints = {}
	
		for  k,v in pairs (keyhole.lockOffsets)  do
			if  k%2 == 0  then
				lockPoints[k] = midY + v*scale
			else
				lockPoints[k] = midX + v*scale
			end
		end

		
	-- Update the mesh points	
	local meshPoints = {}
	
	-- Cut out the lock
	if  mask  then
		local l,r,t,b,mx,my = -800, 1600, -600, 1200, 400,300
		
		-- Get the bottom half of the lock
		meshPoints = {  r,t, lockPoints[#lockPoints-3],lockPoints[#lockPoints-2], r,b,
						r,b, lockPoints[#lockPoints-3],lockPoints[#lockPoints-2], lockPoints[#lockPoints-1],lockPoints[#lockPoints],
						r,b, lockPoints[#lockPoints-1],lockPoints[#lockPoints], lockPoints[1],lockPoints[2],
						r,b, lockPoints[1],lockPoints[2], l,b,
						l,b, lockPoints[1],lockPoints[2], lockPoints[3],lockPoints[4],
						l,b, lockPoints[3],lockPoints[4], lockPoints[5],lockPoints[6],
						l,b, lockPoints[5],lockPoints[6], l,t--,
					 }
		
		-- Attempt to automate the triangulation of the circular part
		local cmx, cmy = midX,  midY - (keyhole.circleMidY * scale)
		local ct,cb = cmy + (keyhole.circleMidY - keyhole.radius) * scale,  cmy + (keyhole.circleMidY + keyhole.radius) * scale
		local cl,cr = cmx - (keyhole.radius * scale), cmx + (keyhole.radius * scale)
		
		for  i=5, #lockPoints-5, 2  do
			
			-- Determine the corners
			local cornerX1 = l
			if  lockPoints[i] > cmx  then
				cornerX1 = r
			end
			local cornerY1 = t
			if  lockPoints[i+1] > cmy  then
				cornerY1 = b
			end
			local cornerX2 = l
			if  lockPoints[i+2] > cmx  then
				cornerX2 = r
			end
			local cornerY2 = t
			if  lockPoints[i+3] > cmy  then
				cornerY2 = b
			end

			-- Insert tri to fill the gap between switching corners if necessary
			if  cornerX1 ~= cornerX2  or  cornerY1 ~= cornerY2  then
				table.insert (meshPoints, cornerX1)
				table.insert (meshPoints, cornerY1)
				
				table.insert (meshPoints, lockPoints[i])
				table.insert (meshPoints, lockPoints[i+1])
				
				table.insert (meshPoints, cornerX2)
				table.insert (meshPoints, cornerY2)
			end

			
			-- Insert the tri with the line segment to the nearest corner
			table.insert (meshPoints, cornerX2)
			table.insert (meshPoints, cornerY2)
			
			table.insert (meshPoints, lockPoints[i])
			table.insert (meshPoints, lockPoints[i+1])
			
			table.insert (meshPoints, lockPoints[i+2])
			table.insert (meshPoints, lockPoints[i+3])
		end
	

	-- Draw just the lock
	else
		meshPoints = {lockPoints[1],lockPoints[2]}
		local i = 3
		while  i+1 <= #lockPoints  do
			table.insert (meshPoints, lockPoints[i])
			table.insert (meshPoints, lockPoints[i+1])
			table.insert (meshPoints, midX)
			table.insert (meshPoints, midY2)
			table.insert (meshPoints, lockPoints[i])
			table.insert (meshPoints, lockPoints[i+1])
			i = i+2
		end
		local cur = #meshPoints
		meshPoints[cur+1] = lockPoints[1]
		meshPoints[cur+2] = lockPoints[2]
	end	
	
	-- UVs
	local vertColors = {}
	local uvPoints = {}
	for  i=1,#meshPoints-1,2  do
		uvPoints[i] = meshPoints[i]/800
		uvPoints[i+1] = meshPoints[i+1]/600
	end
	
	-- vertex colors (for debugging)
	for i=1,#uvPoints  do
		vertColors[2*(i-1)+1] = math.random(10)/10
		vertColors[2*(i-1)+2] = math.random(10)/10
	end
	
	-- Draw the lock
	if  mask  then
		Graphics.glDraw {vertexCoords={0,0, 800,0, 0,600,  0,600, 800,600, 800,0}, color={0,0,0,1}, primitive=Graphics.GL_TRIANGLE_STRIP, priority=-56}
		if  scale > 0  then
			Graphics.glDraw {vertexCoords=meshPoints, texture=frameBuffer, textureCoords=uvPoints, primitive=Graphics.GL_TRIANGLE, priority=0}
		else
			Graphics.glDraw {vertexCoords={0,0, 800,0, 0,600,  0,600, 800,600, 800,0}, texture=frameBuffer, textureCoords={0,0, 1,0, 0,1,  0,1, 1,1, 1,0}, primitive=Graphics.GL_TRIANGLE, priority=0}
		end
	else
		Graphics.glDraw {vertexCoords=meshPoints, primitive=Graphics.GL_TRIANGLE_STRIP, color={0,0,0,1}, priority=-56}
		--Graphics.glDraw {vertexCoords=meshPoints, primitive=Graphics.GL_TRIANGLE_STRIP, vertexColors=vertColors, priority=-26}
	end
end

return keyhole