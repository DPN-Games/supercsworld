local samus = API.load("samus")
local horikawaTools = API.load("horikawaTools")
local firstRun = true
local start = true
local rng = API.load("rng")
local colliders = API.load("colliders")
local i = 0 
local j = 0

function onStart()
	if (player.isValid) then
		player:mem(0xF0, FIELD_WORD, 18)
		player:mem(0x16, FIELD_WORD, 2)
	end
end

function onTick()
	if (firstRun == true) then
		firstRun = false
		player:mem(0xF0, FIELD_WORD, 18)
		player:mem(0x16, FIELD_WORD, 2)
	end
	
	tableofrupee1 = NPC.get (249, -1)
	for i = 1, table.getn(tableofrupee1) do
		tableofrupee1[i].id = 0
	end
	
	tableofrupee3 = NPC.get (251, -1)
	for i = 1, table.getn(tableofrupee3) do
		tableofrupee3[i].id = 0
	end
	
	tableofrupee4 = NPC.get (252, -1)
	for i = 1, table.getn(tableofrupee4) do
		tableofrupee4[i].id = 0
	end
	
	tableofrupee5 = NPC.get (253, -1)
	for i = 1, table.getn(tableofrupee5) do
		tableofrupee5[i].id = 0
	end

	tableofGreenDoors = NPC.get (255, -1)
	for k, v in pairs (tableofGreenDoors) do
		local greendoor = colliders.Box(v.x, v.y, v.width, v.height);
		if (colliders.collideNPC(greendoor, 171)) then
			v:kill()
		end
	end
	
	tableofSuperMissileBlock = NPC.get (1, -1)
	for k, v in pairs (tableofSuperMissileBlock) do
		local smb = colliders.Box(v.x, v.y, v.width, v.height);
		if (colliders.collideNPC(smb, 171)) then
			v:kill()
		end
	end
	
	tableofRedDoors = NPC.get (69, -1)
	for k, v in pairs (tableofRedDoors) do
		local reddoor = colliders.Box(v.x - 4, v.y - 4, v.width + 8, v.height + 8);
		if (colliders.collideNPC(reddoor, 13)) then
			v:kill()
		end
	end

	tableofMother = NPC.get(209,-1)
	for k, v in pairs (tableofMother) do		
		local mother = colliders.Box(v.x - 4, v.y - 4, v.width + 8, v.height + 8);
		if i > 50 then
			v:kill()
		elseif (colliders.collideNPC(mother, 266)) then
			i = i + 0.05
			v.ai1 = 1
			playSFX(68)
		elseif colliders.collideNPC(mother, 13) then
			i = i + 2
			v.ai1 = 1
			playSFX(68)
		elseif colliders.collideNPC(mother, 265) then
			i = i + 3
			v.ai1 = 1
			playSFX(68)
		elseif colliders.collideNPC(mother, 171) then
			i = i + 0.125
			v.ai1 = 1
			playSFX(68)
		end
		if colliders.collide(player, mother) then
			player:harm()
		end
	end	
	
	tableofMetroid = NPC.get(76,-1)
	for k, v in pairs (tableofMetroid) do		
		local metroid = colliders.Box(v.x - 8, v.y - 8, v.width + 16, v.height + 16);
		if j > 10 then
			v:kill()
			playSFX(68)
			j = 0
		end
		if (colliders.collideNPC(metroid, 265)) then
			j = j + 1
		end
		if colliders.collide(player, metroid) then
			player:harm()
		end
	end	
end

function onEventDirect(butt, calledEvent)
	if (calledEvent == "start1") then
		if (start == true) then
			Audio.playSFX("samusappearance.ogg")
			start = false
		end
	end
end

function onNPCKill(eventObj, killingNPC, killReason)
	if (killReason == 10 or killReason == 1 or killReason == 2 or killReason == 3) then
		randValue = rng.randomInt(1, 10)
		if (randValue == 1) and (horikawaTools.npcList[killingNPC.id] == true or horikawaTools.npcList[killingNPC.id] == 2) then
			NPC.spawn (250, killingNPC.x, killingNPC.y, player.section)
		end
	end
end
	