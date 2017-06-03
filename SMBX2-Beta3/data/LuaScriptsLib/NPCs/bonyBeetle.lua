local rng = API.load("rng",true)
local npcconfig = API.load("npcconfig",true)
local pnpc = API.load("pnpc",true)
local npcManager = API.load("npcManager")

local bonyBeetles = {}

local useCamera = Camera.get()[1]

local bonyBeetleSettings = {id = 296, gfxheight = 32, gfxwidth = 32, width = 32, height = 32, frames = 4, framestyle = 0, jumphurt = 0, nofireball=1,noyoshi=1}
local configFile = npcManager.setNpcSettings(bonyBeetleSettings)

npcManager.registerHarmTypes(296, 	{HARM_TYPE_JUMP, HARM_TYPE_FROMBELOW, HARM_TYPE_HELD,HARM_TYPE_NPC, HARM_TYPE_LAVA, HARM_TYPE_SWORD}, 
									{[HARM_TYPE_JUMP] = 160, [HARM_TYPE_FROMBELOW]=10, [HARM_TYPE_HELD]=10, [HARM_TYPE_NPC]=10, [HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5}});

local canHurt = configFile.nohurt or -1
local jumpHurt = configFile.jumphurt or -1

function bonyBeetles.onInitAPI()
	registerEvent(bonyBeetles, "onTick", "onTick", false)
	registerEvent(bonyBeetles, "onDraw", "onDraw", false)
	registerEvent(bonyBeetles, "onNPCKill", "onNPCKill", false)
end

local function initialise(beetle)
	beetle.data.startX = beetle.x;
	beetle.data.startY = beetle.y;
	if beetle.friendly == false then
		beetle.speedX = 0;
	else
		beetle.speedX = 1 * beetle.direction;
	end
	beetle.data.tick = 0;
	beetle.data.timer = 340;
	if beetle.direction == -1 then
		beetle.ai1 = 0;
	else
		beetle.ai1 = 4;
	end
	beetle.animationTimer = 0;
	beetle.data.state = 0;
	beetle.data.ticker = -1;
	beetle.data.butt = beetle.x;
	beetle.data.directionCooldown = 0;
	beetle.data.friendlyBeforeThat = beetle.friendly
end

function bonyBeetles.onTick()
	for _, v in ipairs(NPC.get(296,-1)) do
		if v:mem(0x64,FIELD_WORD) ~= -1 and not Defines.levelFreeze then
			local beetle = pnpc.wrap(v)
			if (v:mem(0x12A, FIELD_WORD) ~= -1) then
				if(beetle:mem(0x12C, FIELD_WORD) ~= 0 or beetle:mem(0x12E, FIELD_WORD) ~= 0) then
					beetle.data.state = 0;
					beetle.data.timer = 0;
					beetle.ai1 = 0;
				else
					if beetle.data.startX == nil then
						initialise(beetle)
					end
					if v:mem(0x40, FIELD_WORD) == 0 and v:mem(0x124, FIELD_WORD) ~= 0 then
						-- collision and speed
						
						if beetle.data.state == 1 then
							v.speedX = 0 --added to prevent sliding corpses and stuff. If this breaks stuff, shout at me. ~Enjl
						end
					
						if v:mem(0x0A,FIELD_WORD) == 2 then
							if v.speedY > 0.8 then
								v.y = v.y - v.speedY;
							end
							v.speedY = 0;
						end
					
						if (v:mem(0x0C,FIELD_WORD) == 2 or v:mem(0x10,FIELD_WORD) == 2) and beetle.data.directionCooldown == 0 then
							--v.direction = -v.direction;
							v.speedX = -v.speedX;
							beetle.data.directionCooldown = 5;
							if v.ai1 == 0 or v.ai1 == 1 then
								v.ai1 = 4;
							elseif v.ai1 == 4 or v.ai1 == 5 then
								v.ai1 = 0;
							end
						end
					
						beetle.data.tick = beetle.data.tick + 1;
					
						-- walking, falling apart, shaking
						if beetle.data.state > 0 then
							if beetle.data.timer > 0 then
								beetle.data.timer = beetle.data.timer - 1;
							end
						else
							if beetle.data.timer == 0 then
								beetle.friendly = beetle.data.friendlyBeforeThat
							end
							beetle.data.timer = beetle.data.timer + 1;
						end
						if beetle.data.ticker > 0 then
							beetle.data.ticker = beetle.data.ticker - 1;
						end

						if beetle.data.timer < 50 and beetle.data.state == 1 and beetle.data.ticker == -1 then
							beetle.data.ticker = 2;
							beetle.data.butt = v.x;
						end
						if beetle.data.timer <= 8 and beetle.data.state > 0 then
							local frameswitch = {}
							frameswitch[9] = 8;
							frameswitch[11] = 10;
							frameswitch[3] = 2;
							frameswitch[7] = 6;
							
							if frameswitch[v.ai1] ~= nil then
								v.ai1 = frameswitch[v.ai1]
							end
						end
						if beetle.data.timer == 0 and beetle.data.state > 0 then
							beetle.data.tick = 0;
							beetle.data.state = 0;
							beetle.data.ticker = -1;
							if v.direction == -1 then
								v.ai1 = 0;
								v.speedX = -1;
							elseif v.direction == 1 then
								v.ai1 = 4;
								v.speedX = 1;
							end
						end
						if beetle.data.ticker > 0 and beetle.data.state == 1 then
							if beetle.data.ticker%2 == 0 then
								v.x = v.x + 2
							else
								v.x = v.x - 2
							end
						end
						if beetle.data.ticker == 0 and beetle.data.state == 1 then
							v.x = beetle.data.butt;
							beetle.data.ticker = 2;
						end
						if beetle.data.directionCooldown > 0 then
							beetle.data.directionCooldown = beetle.data.directionCooldown - 1;
						end
					
						if beetle.data.tick%8 == 0 then
							local frameswitch = {}
							frameswitch[0] = 1;
							frameswitch[1] = 0;
							frameswitch[2] = 3;
							frameswitch[4] = 5;
							frameswitch[5] = 4;
							frameswitch[6] = 7;
							frameswitch[8] = 9;
							frameswitch[10] = 11;
							
							if frameswitch[v.ai1] ~= nil then
								v.ai1 = frameswitch[v.ai1]
							end
						end
					
						-- spikes and turning
						if (beetle.data.timer == 128 or beetle.data.timer == 256) and beetle.data.state == 0 then
							if player.x < v.x and v.direction ~= -1 then
								v.direction = -1;
								v.speedX = -1;
								local frameswitch = {}
								frameswitch[4] = 0;
								frameswitch[5] = 1;
								if frameswitch[v.ai1] ~= nil then
									v.ai1 = frameswitch[v.ai1]
								end
							elseif player.x >= v.x and v.direction ~= 1 then
								v.direction = 1;
								v.speedX = 1;
								local frameswitch = {}
								frameswitch[0] = 4;
								frameswitch[1] = 5;
								if frameswitch[v.ai1] ~= nil then
									v.ai1 = frameswitch[v.ai1]
								end
							end
						end
						if beetle.data.timer >= 352 and v.friendly == false then
							v.speedX = 0;
							beetle.data.tick = -666;
						end
						if beetle.data.timer >= 408 and beetle.data.state == 0 and v.friendly == false then
							beetle.data.timer = 104;
							beetle.data.state = 2;
							beetle.data.tick = 0;
							if v.direction == -1 then
								v.ai1 = 2;
							elseif v.direction == 1 then
								v.ai1 = 6;
							end
						end
					
						local negativeForceFrame = {}
						negativeForceFrame[4] = 0;
						negativeForceFrame[5] = 1;
						negativeForceFrame[6] = 2;
						negativeForceFrame[7] = 3;
						negativeForceFrame[10] = 8;
						negativeForceFrame[11] = 9;
					
						if (v.direction == -1 and negativeForceFrame[v.ai1] ~= nil) then
							v.ai1 = negativeForceFrame[v.ai1]
						end	
					
						local positiveForceFrame = {}
						positiveForceFrame[0] = 4;
						positiveForceFrame[1] = 5;
						positiveForceFrame[2] = 6;
						positiveForceFrame[3] = 7;
						positiveForceFrame[8] = 10;
						positiveForceFrame[9] = 11;
					
						if v.direction == 1 and positiveForceFrame[v.ai1] ~= nil then
							v.ai1 = positiveForceFrame[v.ai1]
						end
					
					else
						v.x = beetle.data.startX
						v.y = beetle.data.startY
						beetle.data.state = 0;
						beetle.data.ticker = -1;
						beetle.data.timer = 340;
						beetle.data.tick = 0;
						v.ai1 = 0;
					end
				end
			else
				initialise(beetle)
			end
		end
	end
end

function bonyBeetles.onDraw()
	for _,v in ipairs(NPC.get(296,-1)) do
		v.animationTimer = 666;
		v.animationFrame = v.ai1;
	end
end

function bonyBeetles.onNPCKill(eventObj,npc,killReason)
	if killReason == 1 and npc.id == 296 then
		local beetle = pnpc.wrap(npc)
		eventObj.cancelled = true;
		if beetle.data.state == 2 then
			player:harm()
			npc.speedX = 0;
		else
			playSFX(57)
			beetle.data.friendlyBeforeThat = beetle.friendly
			beetle.friendly = true
			beetle.data.state = 1;
			beetle.data.timer = 180;
			npc.speedX = 0;
			beetle.data.tick = 0;
			beetle.data.butt = npc.x;
			if jumpHurt == 1 then
				player:harm()
			end
			if npc.direction == -1 then
				npc.ai1 = 8;
			else
				npc.direction = 1;
				npc.ai1 = 10;
			end
		end
	end
	if killReason == 10 and npc.id == 296 and not npc.friendly then
		eventObj.cancelled = true
		beetle = pnpc.wrap(npc)
		playSFX(57)
		beetle.data.friendlyBeforeThat = beetle.friendly
		beetle.friendly = true
		beetle.data.state = 1;
		beetle.data.timer = 180;
		npc.speedX = 0;
		beetle.data.tick = 0;
		beetle.data.butt = npc.x;
		if jumpHurt == 1 then
			player:harm()
		end
		if npc.direction == -1 then
			npc.ai1 = 8;
		else
			npc.direction = 1;
			npc.ai1 = 10;
		end
	end
end

return bonyBeetles;
