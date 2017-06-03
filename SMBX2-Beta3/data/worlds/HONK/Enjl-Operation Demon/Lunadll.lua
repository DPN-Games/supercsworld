local ninjabomberman = API.load("ninjabomberman")
local lightcircle = Graphics.loadImage("circle.png")
local lightcircle2 = Graphics.loadImage("circle2.png")
local lightbeam = Graphics.loadImage("beam.png")
local colliders = API.load("colliders");
local countdownForToads = 15 --in seconds
local isWinning = false

function onStart()
	player.character = 10
end

function onEvent(calledEvent)
	if(calledEvent == "princess dead") then
		tickerForCountdown = 0
	end
	if(calledEvent == "combo +1") then
		comboMeter = comboMeter + 1
	end
	if(calledEvent == "end") then
		Audio.MusicStop()
		isWinning = true
	end
end

function onTick()
	if(player.section == 5) then
		if(player.y >= -100190 or comboMeter == nil) then
			comboMeter = 0
		end
		Text.printWP("Combo: " .. tostring(comboMeter), 16, 550,5)
	end
	if (Audio.MusicIsPlaying() == false and not isWinning) then
		Audio.MusicOpen("The Heist.ogg")
		Audio.MusicPlay()
	end
	if (countdownForToads < 0) then
		triggerEvent("reposition")
		countdownForToads = 15
		tickerForCountdown = nil
	end
end

local function notDead()
	return player:mem(0x13C, FIELD_WORD) == 0 and player:mem(0x13E, FIELD_WORD) <= 0;
end

function onHUDDraw()
	local tableofToads = NPC.get({1, 110, 122}, -1)
	for k,v in pairs(tableofToads) do
		if (v:mem(0x40, FIELD_WORD) == 0) then
			v:mem(0x12A, FIELD_WORD, 180)
			Graphics.drawImageToSceneWP(lightcircle, (v.x - 61),(v.y - 52),-45)
			if(notDead()) then
				local circle = colliders.Circle((v.x + 20),(v.y + 30), 70);
				if(colliders.collide(player, circle)) then
					player:kill()
				end
			end
		end
	end	
	if(player:mem(0x160, FIELD_WORD) > 0 and player.powerup == PLAYER_FIREFLOWER) then
		player.powerup = PLAYER_BIG
	end
	if(tickerForCountdown ~= nil and countdownForToads >= 0) then
		tickerForCountdown = tickerForCountdown + 1
		if (tickerForCountdown >= 65) then
			tickerForCountdown = 0
			countdownForToads = countdownForToads - 1
		end
		Text.printWP("Seconds until the guards notice: " .. tostring(countdownForToads), 16, 520,5)
		local newtoads = sortPerLayer(tableofToads, "repositioned people")
		for k,v in pairs(newtoads) do
			Graphics.drawImageToSceneWP(lightcircle2, v.x - 61, v.y - 52, -1 * ((countdownForToads * 6.67) - 100)/ 100,-45)
		end
	end
	
	local tableofBeams = NPC.get(216, -1)
	for k,v in pairs(tableofBeams) do
		if (v:mem(0x40, FIELD_WORD) == 0) then
			Graphics.drawImageToSceneWP(lightbeam, v.x - 4,v.y,-45)
			if(notDead()) then
				local box = colliders.Box(v.x - 8,v.y, 32, 32)
				if(colliders.collide(player, box)) then
					player:kill()
				end
			end
		end
	end
end

function sortPerLayer(tableNPC, layerName)
	local sortedNPC = {}
	for _,v in pairs(tableNPC) do
		if(v.layerName.str == layerName)then
			table.insert(sortedNPC, v)
		end
	end
	return sortedNPC
end