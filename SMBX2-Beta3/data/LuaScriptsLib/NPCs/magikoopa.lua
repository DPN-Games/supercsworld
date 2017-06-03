local pnpc = API.load("pnpc")
local configFileReader = API.load("configFileReader")
local npcManager = API.load("npcManager")
local vectr = API.load("vectr")
local rng = API.load("rng")
local blockLists = API.load("expandedDefines")

local magikoopa = {}

--***************************************************************************************************
--                                                                                                  *
--              DEFAULTS AND NPC CONFIGURATION                                                      *
--                                                                                                  *
--***************************************************************************************************

local Kamek = {}

npcManager.registerHarmTypes(299, 	{HARM_TYPE_JUMP, HARM_TYPE_FROMBELOW, HARM_TYPE_NPC, HARM_TYPE_HELD, HARM_TYPE_TAIL, HARM_TYPE_SPINJUMP, HARM_TYPE_SWORD, HARM_TYPE_LAVA}, 
									{[HARM_TYPE_JUMP]=10,
									[HARM_TYPE_FROMBELOW]=10,
									[HARM_TYPE_NPC]=10,
									[HARM_TYPE_HELD]=10,
									[HARM_TYPE_TAIL]=10,
									[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5}});

Kamek.config = npcManager.setNpcSettings({
	id = 299, 
	gfxoffsety = 2,
	gfxwidth = 68, 
	gfxheight = 64, 
	width = 32, 
	height = 62, 
	frames = 3,
	framespeed = 8, 
	framestyle = 1,
	--lua only
	sparkleoffsetx = -0,
	sparkleoffsety = -21, -- -22 - 1 (offset) 
	magicoffsetx = 28,
	magicoffsety = 7, -- +6 - 1 (offset)
	preMagicTime = 48,
	postMagicTime = 64,
	appearTime = 32,
	disappearTime = 16,
	hiddenTime = 128
	--death stuff
})

Kamek.config.minFrameRight = Kamek.config.frames
Kamek.config.maxFrameRight = (Kamek.config.frames * 2) - 1
Kamek.config.minFrameLeft = 0
Kamek.config.maxFrameLeft = Kamek.config.frames - 1

-----------------------------------------------------------------------------------------------------

local Magic = {}

NPC.spinjumpSafe[300] = true

Magic.config = npcManager.setNpcSettings({
	id = 300, 
	gfxwidth = 42, 
	gfxheight = 42, 
	width = 38, 
	height = 38, 
	frames = 16, 
	framespeed = 3, 
	gfxoffsetx = 2, 
	gfxoffsety = 2, 
	nogravity = 1, 
	noblockcollision = 1, 
	nofireball = 1, 
	noiceball = 1,
	jumphurt = 1,
	--lua only
	movespeed = 3
})

--***************************************************************************************************
--                                                                                                  *
--              PRIVATE MEMBERS                                                                     *
--                                                                                                  *
--***************************************************************************************************

local MAX_VISIBLE_TIMER = Kamek.config.preMagicTime + Kamek.config.postMagicTime
local MAX_HIDDEN_TIMER = Kamek.config.hiddenTime + Kamek.config.appearTime + Kamek.config.disappearTime

local magikoopaDirection = {}
magikoopaDirection[-1] = Kamek.config.minFrameLeft
magikoopaDirection[1] = Kamek.config.minFrameRight

local teleportImage = Graphics.loadImage(Misc.resolveFile("teleportImage.png") or Misc.resolveFile("graphics/new_npcs/magikoopa/teleportImage.png"))
local green = Graphics.loadImage(Misc.resolveFile("green.png") or Misc.resolveFile("graphics/new_npcs/magikoopa/green.png")) --TODO: remove debug code

Magic.sfxFile = Misc.resolveFile("magikoopa-magic.ogg") or Misc.resolveFile("sound/extended/magikoopa-magic.ogg")

--***************************************************************************************************
--                                                                                                  *
--              PUBLIC MEMBERS                                                                      *
--                                                                                                  *
--***************************************************************************************************

magikoopa.turnIntoableNpcs = magikoopa.turnIntoableNpcs or {54, 112, 10}
magikoopa.teleportingKameks = magikoopa.teleportingKameks or {}
magikoopa.thrownNpcId = magikoopa.thrownNpcId or Magic.config.id

--***************************************************************************************************
--                                                                                                  *
--              LOCAL FUNCTIONS                                                                     *
--                                                                                                  *
--***************************************************************************************************

local function isOnscreen(kamek)
	local cam = Camera.get()[1];

	if kamek.x+kamek.width < cam.x then
		return false;
	elseif kamek.x > cam.x+800 then
		return false;
	elseif kamek.y+kamek.height < cam.y then
		return false;
	elseif kamek.y > cam.y+600 then
		return false;
	else
		return true;
	end
end

local function teleport(magikoopaNpc)
	local cam = Camera.get()[1]
	local availableBlocks = Block.getIntersecting(cam.x, cam.y, cam.x + cam.width, cam.y + cam.height)
	while #availableBlocks > 0 do
		local blockIndex = rng.randomInt(1, #availableBlocks)
		local someRandomBlock = availableBlocks[blockIndex]
		local middleOfBlock = someRandomBlock.x + 0.5 * (someRandomBlock.width - magikoopaNpc.width)
		
		if ((blockLists.BLOCK_SOLID_MAP[someRandomBlock.id] or blockLists.BLOCK_SEMISOLID_MAP[someRandomBlock.id] or blockLists.BLOCK_PLAYER_MAP[someRandomBlock.id]) and not someRandomBlock.isHidden) then
			
			local interruptingBlocks = Block.getIntersecting(middleOfBlock, someRandomBlock.y - magikoopaNpc.height, middleOfBlock + magikoopaNpc.width, someRandomBlock.y)
			
			local interruptIndex = 1
			while(interruptIndex <= #interruptingBlocks) do
				local v = interruptingBlocks[interruptIndex]
				if((not blockLists.BLOCK_SOLID_MAP[v.id] and not blockLists.BLOCK_PLAYER_MAP[v.id]) or v.isHidden) then
					table.remove(interruptingBlocks, interruptIndex)
				else
					interruptIndex = interruptIndex + 1
				end
			end
			
			if #interruptingBlocks == 0 and #Player.getIntersecting(middleOfBlock - (magikoopaNpc.width * 2), someRandomBlock.y - magikoopaNpc.height, middleOfBlock + (magikoopaNpc.width * 3), someRandomBlock.y) == 0 then
				magikoopaNpc.x = middleOfBlock
				magikoopaNpc.y = someRandomBlock.y - magikoopaNpc.height
				break
			end
		end
		table.remove(availableBlocks, blockIndex)
	end
end

local function spawnMagic(npc)

	local spawnX = npc.x + npc.width/2 + (Kamek.config.magicoffsetx * npc.direction)
	local spawnY = npc.y + npc.height/2 + (Kamek.config.magicoffsety)

	local theThrownNpc = pnpc.wrap(NPC.spawn(magikoopa.thrownNpcId, spawnX, spawnY, player.section, false, true))
	theThrownNpc.direction = npc.direction
end 

local function drawTeleportImage(kamek)
	if kamek.data.isHidden then

		if(MAX_HIDDEN_TIMER - kamek.data.visibilityTimer <= Kamek.config.disappearTime) then --disappearing
			kamek.data.opacity = 1 - (MAX_HIDDEN_TIMER - kamek.data.visibilityTimer) / Kamek.config.disappearTime
		elseif(kamek.data.visibilityTimer <= Kamek.config.appearTime) then --appearing
			kamek.data.opacity = 1 - kamek.data.visibilityTimer / Kamek.config.appearTime
		elseif(kamek.data.opacity > 0) then --spawning interrupted
			--TODO: if Mario touches a spawning magikoopa, prevent spawning and teleport somewhere else?
			kamek.data.opacity = math.max(kamek.data.opacity - 1/Kamek.config.disappearTime, 0)
		end 

		if(kamek.data.opacity > 0) then 

			local sourceY = (kamek.data.drawX+kamek.width/2 < player.x+player.width/2) and teleportImage.height/2 or 0 

			Graphics.drawImageToSceneWP(
				teleportImage, 
				kamek.data.drawX + (Kamek.config.gfxoffsetx or 0) - (Kamek.config.gfxwidth - kamek.width)/2, 
				kamek.data.drawY + (Kamek.config.gfxoffsety or 0) - (Kamek.config.gfxheight - kamek.height), 
				0, --sourceX
				sourceY, --sourceY
				teleportImage.width,
				teleportImage.height/2,
				kamek.data.opacity,
				-45.0 --render priority (-45 = all common SMBX NPCs)
			) 

		end 

	end
end 

local function sparkle(x,y) 
	local spawnX = x + rng.randomInt(-18, 18)
	local spawnY = y + rng.randomInt(-18, 18)
	local anim = Animation.spawn(80, spawnX, spawnY)
	anim.x = anim.x - anim.width/4
	anim.y = anim.y - anim.height/4

	--Graphics.drawImageToScene(green,x-2,y-2) --TODO: remove debug code
end 

local function despawn(kamek)
	kamek:mem(0x124, FIELD_WORD, 0)
	kamek:mem(0x128, FIELD_WORD, -1)
	kamek:mem(0x12A, FIELD_WORD, -1)
end 


local function despawnOnscreen(kamek)
	kamek:mem(0x124, FIELD_WORD, 0)
	kamek:mem(0x128, FIELD_WORD, 0)
	kamek:mem(0x12A, FIELD_WORD, -1)
end 


local function spawn(kamek)
	kamek:mem(0x124, FIELD_WORD, -1) 
	kamek:mem(0x128, FIELD_WORD, 0) 
	kamek:mem(0x12A, FIELD_WORD, 180) 
	kamek.animationFrame = magikoopaDirection[kamek.direction] -- first frame
end 

function Kamek.onCameraUpdate(cameraIndex)
	if cameraIndex == 1 then
		if doDespawn then 
			doDespawn = false;
			for _, v in pairs(NPC.get(Kamek.config.id, player.section)) do
				if v:mem(0x64, FIELD_WORD) ~= -1 then
					if(isOnscreen(v)) then 
						despawnOnscreen(v)
					else
						despawn(v)
					end
				end
			end 
		end 
		if not Defines.levelFreeze then 
			for k, v in pairs(magikoopa.teleportingKameks) do
				local kamek = pnpc.wrap(v)
				teleport(kamek)
				kamek.data.drawX = kamek.x
				kamek.data.drawY = kamek.y
				kamek.data.drawDir = kamek.direction
				magikoopa.teleportingKameks[k] = nil
			end
		end 
	end
end

local doDespawn = false;

function Kamek.onStart()
	doDespawn = true;
end 

function Kamek.onTick()

	for _, v in pairs(NPC.get(Kamek.config.id, -1)) do
		if v:mem(0x64, FIELD_WORD) ~= -1 then
			local kamek = pnpc.wrap(v)

			if(kamek:mem(0x146, FIELD_WORD) ~= player.section or v:mem(0x40, FIELD_WORD) == -1) then --in different section or on hidden layer
				if(kamek.data.initialized) then 
					kamek.data.initialized = false 
					kamek.x = kamek:mem(0xA8, FIELD_DFLOAT)
					kamek.y = kamek:mem(0xB0, FIELD_DFLOAT)
				end  
			elseif(not kamek.data.initialized and 
				(kamek:mem(0x12A, FIELD_WORD) == 180 or --oncsreen
				(kamek:mem(0x12A, FIELD_WORD) == -1 and kamek:mem(0x128, FIELD_WORD) == 0 and kamek:mem(0x124, FIELD_WORD) == 0))) --timer -1, oflag 0, prvnt 0
			then --onscreen, but not initialized		
				
				--[[ DEBUG	
				Text.windowDebug("timer "..tostring(v:mem(0x12A, FIELD_WORD))..
												 "\nprvnt "..tostring(v:mem(0x124, FIELD_WORD))..
												 "\noflag "..tostring(v:mem(0x128, FIELD_WORD)));		
				]]--
				kamek.data.initialized = true
				kamek.data.visibilityTimer = Kamek.config.appearTime - 1
				kamek.data.isHidden = true
				despawn(kamek)
				kamek.data.opacity = 0.0
				kamek.data.drawX = kamek:mem(0xA8, FIELD_DFLOAT)
				kamek.data.drawY = kamek:mem(0xB0, FIELD_DFLOAT)
			elseif(kamek.data.initialized and not Defines.levelFreeze) then --main magikoopa logic

				--disable vanilla smbx animation
				kamek.animationTimer = 1

				--Make the magikoopa face the player
				if kamek.x+kamek.width/2 < player.x+player.width/2 then -- facing right
					kamek.direction = 1
				else -- facing left
					kamek.direction = -1
				end

				--animate the magikoopa
				if(not kamek.data.isHidden) then 
					kamek:mem(0x12A, FIELD_WORD, 180) --prevent despawn TODO:  if offscreen before firing, teleport somewhere else?
					if(kamek.data.visibilityTimer > MAX_VISIBLE_TIMER - Kamek.config.preMagicTime) then 
						kamek.animationFrame = magikoopaDirection[kamek.direction]

						if(kamek.data.visibilityTimer % 4 == 0) then 
							sparkle(kamek.x+kamek.width/2+(Kamek.config.sparkleoffsetx*kamek.direction), kamek.y+kamek.height/2+(Kamek.config.sparkleoffsety))
						end 
					elseif(kamek.data.visibilityTimer == MAX_VISIBLE_TIMER - Kamek.config.preMagicTime) then 
						kamek.animationFrame = magikoopaDirection[kamek.direction]

						spawnMagic(kamek)
					elseif(kamek.data.visibilityTimer >= 0) then
						if(math.floor(kamek.data.visibilityTimer / Kamek.config.framespeed) % 2 == 0) then 
							kamek.animationFrame = magikoopaDirection[kamek.direction] + 1
						else 
							kamek.animationFrame = magikoopaDirection[kamek.direction] + 2
						end 
					end 
				elseif(kamek.data.visibilityTimer > 0) then 
					--force despawn
					despawn(kamek)
				end  

				--despawning, respawning and teleporting
				if(kamek.data.visibilityTimer == 0) then 
					if(not kamek.data.isHidden) then
						kamek.data.visibilityTimer = MAX_HIDDEN_TIMER
						kamek.data.drawX = kamek.x
						kamek.data.drawY = kamek.y
						kamek.data.drawDir = kamek.direction
						despawn(kamek)
						kamek.data.isHidden = true
					else 
						kamek.data.visibilityTimer = MAX_VISIBLE_TIMER
						kamek.x = kamek.data.drawX
						kamek.y = kamek.data.drawY
						spawn(kamek)
						kamek.data.isHidden = false
					end 
				elseif(kamek.data.isHidden and kamek.data.visibilityTimer == Kamek.config.appearTime) then
					table.insert(magikoopa.teleportingKameks, kamek)
				end

				kamek.data.visibilityTimer = kamek.data.visibilityTimer -1
			end
		end
	end
end

function Magic.onTick()
	for _, v in pairs(NPC.get(Magic.config.id, player.section)) do
		if v:mem(0x40, FIELD_WORD) == 0 and v:mem(0x124, FIELD_WORD) ~= 0 and v:mem(0x64, FIELD_WORD) ~= -1 and not Defines.levelFreeze then
			magic = pnpc.wrap(v)
			
			if not magic.data.initialized  then
				magic.data.initialized = true
				magic.data.sparkleTimer = 0
				magic.data.playerX = player.x+player.width/2
				magic.data.playerY = player.y+player.height/2
				magic.data.direction = vectr.v2(magic.data.playerX - (magic.x+magic.width/2), magic.data.playerY - (magic.y+magic.height/2)):normalise() * Magic.config.movespeed
				magic.data.sound = Audio.SfxPlayObj(Audio.SfxOpen(Magic.sfxFile), 0)
			else
				magic.speedX = magic.data.direction.x
				magic.speedY = magic.data.direction.y
				magic.data.sparkleTimer = (magic.data.sparkleTimer + 1) % 4
				if(magic.data.sparkleTimer == 0) then 
					sparkle(magic.x+magic.width/2, magic.y+magic.height/2)
				end 
			end
			for _, intersectingBlock in pairs(Block.getIntersecting(v.x, v.y, v.x + v.width, v.y + v.height)) do
				if intersectingBlock.id == 90 and intersectingBlock:mem(0x1C, FIELD_WORD) ~= -1 then
					spawnedNpc = pnpc.wrap(NPC.spawn(magikoopa.turnIntoableNpcs[rng.randomInt(1, table.getn(magikoopa.turnIntoableNpcs))], v.x, v.y, player.section))
					if spawnedNpc.id == 10 then
						spawnedNpc:mem(0xF0, FIELD_DFLOAT, 1)
					end
					spawnedNpc.direction = rng.randomInt(0, 1) * 2 - 1 -- either left (-1) or right (1)
					Animation.spawn(10, intersectingBlock.x, intersectingBlock.y)
					intersectingBlock:remove()
					v:kill()
					break
				elseif ((blockLists.BLOCK_SOLID_MAP[intersectingBlock.id] or blockLists.BLOCK_PLAYER_MAP[intersectingBlock.id]) and not intersectingBlock.isHidden) then
					v:kill()
				end
			end
		end
	end
end

function Kamek.onDraw()
	for _, v in pairs(NPC.get(Kamek.config.id, player.section)) do
		if v:mem(0x40, FIELD_WORD) == 0 and v:mem(0x64, FIELD_WORD) ~= -1 then
			local kamek = pnpc.wrap(v)
			drawTeleportImage(kamek)
		end
	end
end 

--***************************************************************************************************
--                                                                                                  *
--              API FUNCTIONS                                                                       *
--                                                                                                  *
--***************************************************************************************************

function magikoopa.onStart()
	Kamek.onStart()
end 

function magikoopa.onTick()


	if not Defines.levelFreeze then
		Kamek.onTick()
		Magic.onTick()
	end
end

function magikoopa.onDraw()
	Kamek.onDraw()
end 

function magikoopa.onCameraUpdate(eventObj, cameraIndex)
	Kamek.onCameraUpdate(cameraIndex)
end

function magikoopa.onNPCKill(eventObj,killedNPC,killReason)
	if(killedNPC.id == Magic.config.id) then 
		magic = pnpc.wrap(killedNPC)
		--magic.data.sound:Stop()
	end 
end 

function magikoopa.onInitAPI()
	registerEvent(magikoopa, "onStart", "onStart", false)
	registerEvent(magikoopa, "onTick", "onTick", false)
	registerEvent(magikoopa, "onDraw", "onDraw", false)
	registerEvent(magikoopa, "onCameraUpdate", "onCameraUpdate", false)
	registerEvent(magikoopa, "onNPCKill", "onNPCKill", false)
end

return magikoopa