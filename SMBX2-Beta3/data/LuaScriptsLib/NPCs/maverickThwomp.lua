local colliders = API.load("colliders", true)
local npcconfig = API.load("npcconfig", true)
local pnpc = API.load("pnpc", true)
local npcManager = API.load("npcManager")

local maverickThwomps = {}

local thwompSettings = {id = 295, gfxheight = 64, gfxwidth = 48, width = 48, height = 64, frames = 3, framestyle = 0, jumphurt = 1, nogravity = 1, noblockcollision = 1,nofireball=1,noiceball=1,noyoshi=1}

npcManager.registerHarmTypes(295, 	{HARM_TYPE_FROMBELOW, HARM_TYPE_HELD,HARM_TYPE_NPC, HARM_TYPE_LAVA}, 
									{[HARM_TYPE_FROMBELOW]=10, [HARM_TYPE_HELD]=10, [HARM_TYPE_NPC]=10, [HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5}});

NPC.spinjumpSafe[thwompSettings.id] = true

local configFile = npcManager.setNpcSettings(thwompSettings)

local canHurt = configFile.nohurt or -1
local blockCollision = configFile.noblockcollision or 0

local useCamera = Camera.get()[1]

function maverickThwomps.onInitAPI()
	registerEvent(maverickThwomps, "onStart", "onStart", false)
	registerEvent(maverickThwomps, "onTick", "onTick", false)
	registerEvent(maverickThwomps, "onDraw", "onDraw", false)
	registerEvent(maverickThwomps, "onNPCKill", "onNPCKill", false)
end

function maverickThwomps.onTick()
	for _,v in ipairs(NPC.get(295,-1)) do
		if v:mem(0x64,FIELD_WORD) ~= -1 and not Defines.levelFreeze then
			local thwomp = pnpc.wrap(v)
			
			if thwomp.data.startX == nil then
				thwomp.data.startX = v.x
				thwomp.data.startY = v.y
				thwomp.data.state = 0
				thwomp.data.timer = 0
				thwomp.data.zeroDirectionDummy = -1
				thwomp.data.direction = v.direction
				thwomp.data.trackCollider = colliders.Box(v.x,v.y+16,400,thwomp.height-16)
				thwomp.data.selfCollider = colliders.Box(v.x,v.y+4,thwomp.width,thwomp.height-16)
				thwomp.data.warningCollider = colliders.Box(v.x,v.y-thwomp.width,600,thwomp.height+thwomp.width+thwomp.width)
				v.ai1 = 1
			end
			
			thwomp.data.trackCollider.y = v.y+16;
			thwomp.data.warningCollider.y = v.y-thwomp.width;
			thwomp.data.selfCollider.x = v.x;
			thwomp.data.selfCollider.y = v.y+4;
			
			-- If despawned, reset state
			if v:mem(0x124, FIELD_WORD) == 0 then
				thwomp.data.state = 0
				thwomp.data.timer = 0
			end
			
			if (not v.isHidden) and (v:mem(0x124, FIELD_WORD) ~= 0) then
				if thwomp.data.direction == -1 then
					thwomp.data.trackCollider.x = v.x-400; thwomp.data.trackCollider.width = 400;
				elseif thwomp.data.direction == 0 then
					thwomp.data.trackCollider.x = v.x-400; thwomp.data.trackCollider.width = 800;
				else
					thwomp.data.trackCollider.x = v.x; thwomp.data.trackCollider.width = 400;
				end
			
				if thwomp.data.direction == 0 then
					if colliders.collide(player,thwomp.data.trackCollider) and player.x > v.x+(thwompSettings.width/2) and thwomp.data.state == 0 then
						v.speedX = 6
						thwomp.data.zeroDirectionDummy = 1
						thwomp.data.state = 1
					elseif colliders.collide(player,thwomp.data.trackCollider) and player.x <= v.x+(thwompSettings.width/2) and thwomp.data.state == 0 then
						v.speedX = -6
						thwomp.data.zeroDirectionDummy = -1
						thwomp.data.state = 1
					end
				end

				if thwomp.data.direction == -1 then
					thwomp.data.warningCollider.x = v.x-500
				else
					thwomp.data.warningCollider.x = v.x;
				end
				--warningCollider:Debug(true)
		
				if (v.speedX > 0 and thwomp.data.direction == 1) or (v.speedX < 0 and thwomp.data.direction == -1) or (v.speedX ~= 0 and thwomp.data.direction == 0) then
					v.ai1 = 3
				elseif (colliders.collide(player,thwomp.data.trackCollider) and thwomp.data.direction ~= 0) then
					v.ai1 = 3
				elseif colliders.collide(player,thwomp.data.warningCollider) then
					v.ai1 = 2
				else
					v.ai1 = 1
				end
			
				if colliders.collide(player,thwomp.data.trackCollider) and thwomp.data.state == 0 and thwomp.data.direction ~= 0 then
					thwomp.data.state = 1
					v.speedX = 6 * thwomp.data.direction
				end
		
				if thwomp.data.timer > 0 then
					thwomp.data.timer = thwomp.data.timer - 1
				end
				if thwomp.data.timer == 0 and thwomp.data.state == 2 then
					thwomp.data.state = 3
					if thwomp.data.direction == 0 then
						v.speedX = -2 * thwomp.data.zeroDirectionDummy
					else
						v.speedX = -2 * thwomp.data.direction
					end
					thwomp.data.timer = 20
				end
				
				if v.speedY ~= 0 then
					v.y = v.y - 0.01
				end
		
				if thwomp.data.direction == -1 then
					if v.x > thwomp.data.startX then
						thwomp.data.state = 0
						v.speedX = 0
						v.x = thwomp.data.startX
						v.direction = thwomp.data.direction
					end
				end
				if thwomp.data.direction == 1 then
					if v.x < thwomp.data.startX then
						thwomp.data.state = 0
						v.speedX = 0
						v.x = thwomp.data.startX
						v.direction = thwomp.data.direction
					end
				end
				if thwomp.data.direction == 0 then
					if ((v.speedX > 0 and v.x > thwomp.data.startX) or (v.speedX < 0 and v.x < thwomp.data.startX)) and (thwomp.data.state == 3) then
						thwomp.data.state = 0
						v.speedX = 0
						v.x = thwomp.data.startX
						v.direction = thwomp.data.direction
					end
				end
		
				local _,_,list = colliders.collideBlock(thwomp.data.selfCollider, colliders.BLOCK_SOLID..colliders.BLOCK_HURT..colliders.BLOCK_PLAYER)
				for _,q in ipairs(list) do
					if q.isHidden == false and v.speedX ~= 0 and blockCollision ~= 1 then
						if thwomp.data.state == 1 then
							playSFX(37)
							thwomp.data.state = 2
							thwomp.data.timer = 60
							v.speedX = 0
						elseif thwomp.data.state == 3 and thwomp.data.timer == 0 then
							thwomp.data.state = 0
							v.speedX = 0
							if thwomp.data.direction == 0 then
								v.x = v.x + (8 * thwomp.data.zeroDirectionDummy)
							else
								v.x = v.x + (8 * thwomp.data.direction)
							end
						end
					end
				end
				
				local _,_,list = colliders.collideNPC(v,13)
				for _,g in ipairs(list) do
					g:kill(7)
				end
			else
				v.x = thwomp.data.startX
				v.speedX = 0
				thwomp.data.state = 0
				thwomp.data.timer = 0
			end
		end
	end
end

function maverickThwomps.onDraw()
	for _,v in ipairs(NPC.get(295,-1)) do
		v.animationTimer = 666
		if npcconfig[295].framestyle ~= 0 and v.direction == 1 then
			v.animationFrame = v.ai1 + 2
		else
			v.animationFrame = v.ai1 - 1
		end
	end
end

function maverickThwomps.onNPCKill(eventObj,npc,killReason)
	if npc.id == 295 then
		local _,_,list = colliders.collideNPC(npc,13)
		for _,q in ipairs(list) do
			q:kill(1)
			eventObj.cancelled = true;
		end
	end
end
	
return maverickThwomps
