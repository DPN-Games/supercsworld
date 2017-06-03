--helpfulCheats.lua
--version 1.0
--Created by Horikawa and Pyro, 2015-2016

local rng = API.load("rng")
local expandedDefines = API.load("expandedDefines")
local playerManager = API.load("playerManager")
local starman = API.load("NPCs/starman")
local lunajson = API.load("ext/lunajson")
local globalData = Data(Data.DATA_GLOBAL, "systemData")
local theRawGlobalDataString = globalData:get("lunaActivatedCheatData")
local lunaActivatedCheatData

if theRawGlobalDataString ~= "" then
	lunaActivatedCheatData = lunajson.decode(theRawGlobalDataString)
else
	lunaActivatedCheatData = {}
end

local currentEpisodeNameIndexer
local isInIntroLevelOrSomething = true

if (mem(0x00B2C62A, FIELD_WORD) ~= 0) and (mem(0x00B250E8, FIELD_WORD) ~= 0) and (getSMBXPath() .. "\\" ~= tostring(mem(0x00B2C61C, FIELD_STRING))) then
	isInIntroLevelOrSomething = false
	currentEpisodeNameIndexer = (mem(0x00B2C61C, FIELD_STRING) .. "lunaActivatedCheatData"):gsub('%W','')
	if not lunaActivatedCheatData[currentEpisodeNameIndexer] then
		lunaActivatedCheatData[currentEpisodeNameIndexer] = {}
	end
end

local helpfulCheats = {}
helpfulCheats.cheatArray = {} or helpfulCheats.cheatArray

function helpfulCheats.swapDefines(tableOfDefines, turnStatus)
	local hasFoundANegative = false
	for _, someDefine in ipairs(tableOfDefines) do
		if not Defines[someDefine] then
			hasFoundANegative = true
		end
	end
	if turnStatus ~= nil then
		hasFoundANegative = turnStatus
	end
	for _, someDefine in ipairs(tableOfDefines) do
		Defines[someDefine] = hasFoundANegative
	end
end

local function triggerPerEventStatus(cheatName, turnStatus)
	local activationStatus, hasBeenTurned
	if helpfulCheats.cheatArray[cheatName] then
		for _, lunaLuaEvent in ipairs(expandedDefines.LUNALUA_EVENTS) do
			if helpfulCheats.cheatArray[cheatName][lunaLuaEvent] then
				if turnStatus ~= nil then
					helpfulCheats.cheatArray[cheatName].perEventActivated = turnStatus
				else
					if not hasBeenTurned then
						helpfulCheats.cheatArray[cheatName].perEventActivated = not helpfulCheats.cheatArray[cheatName].perEventActivated
						hasBeenTurned = true
					end
				end
				activationStatus = helpfulCheats.cheatArray[cheatName].perEventActivated
			end
		end
		if not isInIntroLevelOrSomething then
			if activationStatus then
				lunaActivatedCheatData[currentEpisodeNameIndexer][cheatName] = true
			else
				lunaActivatedCheatData[currentEpisodeNameIndexer][cheatName] = nil
			end
		end
	end
end

function helpfulCheats.triggerCheat(cheatName, saveCheatStatus, turnStatus)
	if turnStatus == true or turnStatus == nil then
		if helpfulCheats.cheatArray[cheatName].playerCharacter then
			Audio.playSFX(34)
			player:mem(0x140, FIELD_WORD, 30)
			if(not isOverworld) then
				Animation.spawn(10, player.x, player.y)
			end
			player.character = helpfulCheats.cheatArray[cheatName].playerCharacter
		end
		triggerPerEventStatus(cheatName, turnStatus)
		if helpfulCheats.cheatArray[cheatName].cheatFunction ~= nil then
			helpfulCheats.cheatArray[cheatName].cheatFunction(turnStatus)
		end
	elseif turnStatus == false then
		triggerPerEventStatus(cheatName, turnStatus)
	end
	if saveCheatStatus then
		Misc.cheatBuffer("")
		Defines.player_hasCheated = true
		if not isInIntroLevelOrSomething then
			globalData:set("lunaActivatedCheatData", lunajson.encode(lunaActivatedCheatData))
			globalData:save()
		end
	end
end

--One-Time Activation Functions with Additional Per-Event Functions are Declared Here

local function perEventHorikawaIsRadicola()
	player:mem(0x108, FIELD_WORD, 1) 
	player:mem(0x10A, FIELD_WORD, 1)
	for i = 1, 91 do
		Audio.sounds[i].sfx = helpfulCheats.cheatArray["horikawaisradicola"].kyaaFile
	end
end

local function horikawaIsRadicola()
	if(not isOverworld) then
		earthquake(10)
	end
	Audio.playSFX(34)
	if not helpfulCheats.cheatArray["horikawaisradicola"].perEventActivated then
		for i = 1, 91 do
			Audio.sounds[i].sfx = nil
		end
	end
end

local function perEventRinkaMania(junkData, killedNPC, killReason)
	if killReason ~= 9 then
		NPC.spawn(210, killedNPC.x, killedNPC.y, player.section)
	end
end

local function rinkaMania()
	player:mem(0x140, FIELD_WORD, 30)
	Audio.playSFX(65)
end

local function perEventJumpForRinka(keycode)
	if keycode == KEY_JUMP then
		NPC.spawn(210, player.x, player.y + player.height * 2, player.section)
	end
end

local function jumpForRinka()
	player:mem(0x140, FIELD_WORD, 30)
	Audio.playSFX(65)
end

local function perEventRinkaMadness()
	if(not isOverworld) then
		if rng.randomInt(1, 20) == 20 then
			NPC.spawn(210, player.x + rng.randomInt(-800, 800), player.y + rng.randomInt(-600, 600), player.section)
		end
	end
end

local function rinkaMadness()
	player:mem(0x140, FIELD_WORD, 30)
	Audio.playSFX(65)
end

local function perEventWorldpeaceTick()
	local tableOfAnimation = Animation.get()
	
	if helpfulCheats.cheatArray["worldpeace"].tableLengthPrevFrame < #tableOfAnimation then
		Audio.playSFX((Misc.resolveFile("yeah.ogg") or Misc.resolveFile("sound/extended/yeah.ogg")))
	end
	
	if(not isOverworld) then
		for k, v in ipairs(Animation.get()) do
			v.speedY = -2
			v.speedX = 0
		end
	end
	
	helpfulCheats.cheatArray["worldpeace"].tableLengthPrevFrame = #tableOfAnimation
end

local function worldpeace()
	Audio.playSFX((Misc.resolveFile("yeah.ogg") or Misc.resolveFile("sound/extended/yeah.ogg")))
end

local function getDemStarsOnTick()
	if(isOverworld) then
		return;
	end
	local theNextStar, spawnedBlock
	Defines.cheat_donthurtme = true
	local demStarList = {[97]={}, [196]={}}
	
	local starList = NPC.get({97, 196}, -1)
	for _, v in ipairs(starList) do
		if v:mem(0xF0, FIELD_DFLOAT) ~= 1 and not v:mem(0x64, FIELD_BOOL) and v.friendly == false then
			table.insert(demStarList[v.id], v)
		end
	end
	if (#demStarList[196] >= 1 or #demStarList[97] >= 1) then
		theNextStar = table.remove(demStarList[196], 1) or table.remove(demStarList[97], 1)
		if tostring(theNextStar.layerName) ~= "" then
			Layer.get(tostring(theNextStar.layerName)):show(false)
		end
		player:mem(0x15A, FIELD_WORD, theNextStar:mem(0x146, FIELD_WORD))
		player.x = theNextStar.x
		player.y = theNextStar.y
		if (#demStarList[97] >= 1) then
			mem(0x00B2C59E, FIELD_WORD, 0)
		end
	else
		player.speedX = 0
		player.speedY = 0
		player:mem(0x15A, FIELD_WORD, helpfulCheats.cheatArray["getdemstars"].initialSection)
		player.x = helpfulCheats.cheatArray["getdemstars"].initialX
		player.y = helpfulCheats.cheatArray["getdemstars"].initialY
		helpfulCheats.triggerCheat("getdemstars", true, false)
		Defines.cheat_donthurtme = helpfulCheats.cheatArray["getdemstars"].initialImmortalState
		Defines.cheat_shadowmario = helpfulCheats.cheatArray["getdemstars"].initialShadowState
	end
end

local function getDemStars()
	if(isOverworld) then
		return;
	end
	helpfulCheats.cheatArray["getdemstars"].initialX = player.x
	helpfulCheats.cheatArray["getdemstars"].initialY = player.y
	helpfulCheats.cheatArray["getdemstars"].initialSection = player.section
	helpfulCheats.cheatArray["getdemstars"].initialImmortalState = Defines.cheat_donthurtme
	helpfulCheats.cheatArray["getdemstars"].initialShadowState = Defines.cheat_shadowmario
	for _, block in ipairs(Block.get()) do
		if block.contentID == 1097 or block.contentID == 1196 then
			block:hit()
		end
	end
	for _, lakitu in ipairs(NPC.get(284, -1)) do
		local lakituThrownId = lakitu:mem(0xF0, FIELD_DFLOAT)
		if lakituThrownId == 97 or lakituThrownId == 196 then
			NPC.spawn(lakituThrownId, lakitu.x, lakitu.y, lakitu:mem(0x146, FIELD_WORD))
		end
	end
	for _, v in ipairs(NPC.get({97, 196}, -1)) do
		if v:mem(0x64, FIELD_BOOL) then
			NPC.spawn(v.id, v.x, v.y, v:mem(0x146, FIELD_WORD))
		end
	end
end

--Simple, Single-Activation Cheats Go Here

local function suicide()
	player:kill()
	if(not isOverworld) then
		Misc.doBombExplosion(player.x, player.y, 3)
		earthquake(10)
	end
	Audio.playSFX(22)
end

local function holyTrinity(turnStatus)
	local toToggle = {"cheat_donthurtme", "cheat_ahippinandahoppin", "cheat_shadowmario"}
	helpfulCheats.swapDefines(toToggle, turnStatus)
	player:mem(0x140, FIELD_WORD, 30)
	Audio.playSFX(34)
end

local function theEssentials(turnStatus)
	local toToggle = {"cheat_donthurtme", "cheat_sonictooslow", "cheat_ahippinandahoppin", "cheat_shadowmario"}
	helpfulCheats.swapDefines(toToggle, turnStatus)
	player:mem(0x140, FIELD_WORD, 30)
	Audio.playSFX(34)
end

local function jumpMan(turnStatus)
	local toToggle = {"cheat_ahippinandahoppin"}
	helpfulCheats.swapDefines(toToggle, turnStatus)
	player:mem(0x140, FIELD_WORD, 30)
	Audio.playSFX(6)
end

local function liveForever()
	mem(0x00B2C5AC, FIELD_FLOAT, 99)
	player:mem(0x140, FIELD_WORD, 30)
	Audio.playSFX(15)
end

local function gdiRedigit()
	Defines.player_hasCheated = false
	Audio.playSFX((Misc.resolveFile("kyaa.ogg") or Misc.resolveFile("sound/extended/kyaa.ogg")))
end

local function launchMe()
	player.speedY = -30
	Audio.playSFX(61)
end

local function boomTheRoom()
	Misc.doPOW()
	Audio.playSFX(34)
end

local function instantSwitch()
	Misc.doPSwitch()
	Audio.playSFX(34)
end

local function murder()
	if(isOverworld) then
		return;
	end
	for _, v in ipairs(NPC.get(expandedDefines.NPC_HITTABLE, player.section)) do
		if v:mem(0x128, FIELD_WORD) ~= -1 then
			v:kill()
		end
	end
	Audio.playSFX(22)
	earthquake(50)
end

local function dressMeUp()
	local listOfCostumes = playerManager.getCostumes(player.character)
	if table.getn(listOfCostumes) > 1 then
		for k, v in ipairs(listOfCostumes) do
			if v == playerManager.getCostume(player.character) then
				listOfCostumes[k] = nil
			end
		end
	end
	Audio.playSFX(41)
	player:mem(0x140, FIELD_WORD, 30)
	if(not isOverworld) then
		Animation.spawn(10, player.x, player.y)
	end
	playerManager.setCostume(player.character, rng.randomEntry(listOfCostumes))
end

local function undress()
	Audio.playSFX(41)
	player:mem(0x140, FIELD_WORD, 30)
	if(not isOverworld) then
		Animation.spawn(10, player.x, player.y)
	end
	playerManager.setCostume(player.character, nil)
end

local function laundryday()
	Audio.playSFX(41)
	player:mem(0x140, FIELD_WORD, 30)
	if(not isOverworld) then
		Animation.spawn(10, player.x, player.y)
	end
	--Change the value here, if there are more than 18 playable characters(or if there is a way to get their number later).
	for i=1, 18 do
		playerManager.setCostume(i, nil)
	end
end

local function theStarMen()
	starman.startTheStar()
end

local function getDown()
	player.y = player.y + player.height * 3
end

local function foundMyCarKeys()
	if(isOverworld) then
		return;
	end
	local toTeleportData = {}
	for sectionId, section in pairs(Section.get()) do
		if not toTeleportData["section"] then
			for _, v in ipairs(BGO.getIntersecting(section.boundary.left, section.boundary.top, section.boundary.right, section.boundary.bottom)) do
				if v.id == 35 then
					toTeleportData["section"] = sectionId - 1
					toTeleportData["x"] = v.x
					toTeleportData["y"] = v.y
					break
				end
			end
		else
			break
		end
	end
	if toTeleportData["section"] then
		theNpc = NPC.spawn(31, toTeleportData.x, toTeleportData.y, toTeleportData.section)
		player.HeldNPCIndex = theNpc.idx + 1
		player.x = toTeleportData.x
		player.y = toTeleportData.y
		helpfulCheats.cheatArray["foundmycarkeys"].fart = player:mem(0x8E, FIELD_WORD)
		theNpc:mem(0x12C, FIELD_WORD, 1)
		player:mem(0x15A, FIELD_WORD, toTeleportData.section)
	end
end

local function myLifeGoals()
	if(isOverworld) then
		return;
	end
	local theNewGoal = NPC.spawn(197, player.x, player.y, player.section)
	theNewGoal.x = player.x - theNewGoal.width
end

local function mysteryBall()
	if(isOverworld) then
		return;
	end
	NPC.spawn(16, player.x, player.y, player.section)
end

local function itsVegas()
	if(isOverworld) then
		return;
	end
	NPC.spawn(11, player.x, player.y, player.section)
end

local function getMeOuttaHere()
	if(isOverworld) then
		return;
	end
	Level.exit()
end

local function rosebud()
	mem(0x00B2C5A8, FIELD_WORD, 99)
	Audio.playSFX(14)
end

--The Master Cheat Table

--Put simple cheats here

helpfulCheats.cheatArray["suicide"] = {cheatFunction = suicide}
helpfulCheats.cheatArray["holytrinity"] = {cheatFunction = holyTrinity}
helpfulCheats.cheatArray["theessentials"] = {cheatFunction = theEssentials}
helpfulCheats.cheatArray["jumpman"] = {cheatFunction = jumpMan}
helpfulCheats.cheatArray["liveforever"] = {cheatFunction = liveForever}
helpfulCheats.cheatArray["gdiredigit"] = {cheatFunction = gdiRedigit}
helpfulCheats.cheatArray["launchme"] = {cheatFunction = launchMe}
helpfulCheats.cheatArray["boomtheroom"] = {cheatFunction = boomTheRoom}
helpfulCheats.cheatArray["instantswitch"] = {cheatFunction = instantSwitch}
helpfulCheats.cheatArray["murder"] = {cheatFunction = murder}
helpfulCheats.cheatArray["dressmeup"] = {cheatFunction = dressMeUp}
helpfulCheats.cheatArray["undress"] = {cheatFunction = undress}
helpfulCheats.cheatArray["laundryday"] = {cheatFunction = laundryday}
helpfulCheats.cheatArray["thestarmen"] = {cheatFunction = theStarMen}
helpfulCheats.cheatArray["getdown"] = {cheatFunction = getDown}
helpfulCheats.cheatArray["foundmycarkeys"] = {cheatFunction = foundMyCarKeys}
helpfulCheats.cheatArray["mylifegoals"] = {cheatFunction = myLifeGoals}
helpfulCheats.cheatArray["mysteryball"] = {cheatFunction = mysteryBall}
helpfulCheats.cheatArray["itsvegas"] = {cheatFunction = itsVegas}
helpfulCheats.cheatArray["getmeouttahere"] = {cheatFunction = getMeOuttaHere}
helpfulCheats.cheatArray["rosebud"] = {cheatFunction = rosebud}

--Put player cheats here

helpfulCheats.cheatArray["superfightingrobot"] = {playerCharacter = 6}
helpfulCheats.cheatArray["eternalgreed"] = {playerCharacter = 7}
helpfulCheats.cheatArray["kingofthekoopas"] = {playerCharacter = 8}
helpfulCheats.cheatArray["dreamtraveler"] = {playerCharacter = 9}
helpfulCheats.cheatArray["dreamtraveller"] = {playerCharacter = 9} --brits yo
helpfulCheats.cheatArray["bombingrun"] = {playerCharacter = 10}
helpfulCheats.cheatArray["cosmicpower"] = {playerCharacter = 11}
helpfulCheats.cheatArray["metalgear"] = {playerCharacter = 12}
helpfulCheats.cheatArray["ocarinaoftime"] = {playerCharacter = 13}
helpfulCheats.cheatArray["densenuclearenergy"] = {playerCharacter = 14}
helpfulCheats.cheatArray["hardmode"] = {playerCharacter = 15}
helpfulCheats.cheatArray["unclesam"] = {playerCharacter = 16}
helpfulCheats.cheatArray["imtiny"] = {playerCharacter = 17}
helpfulCheats.cheatArray["samusisagirl"] = {playerCharacter = 18}

--Put perEvent cheats here

helpfulCheats.cheatArray["rinkamania"] = {cheatFunction = rinkaMania, onNPCKill = perEventRinkaMania}
helpfulCheats.cheatArray["horikawaisradicola"] = {cheatFunction = horikawaIsRadicola, kyaaFile = Audio.SfxOpen((Misc.resolveFile("kyaa.ogg") or Misc.resolveFile("sound/extended/kyaa.ogg"))), onTick = perEventHorikawaIsRadicola}
helpfulCheats.cheatArray["jumpforrinka"] = {cheatFunction = jumpForRinka, onKeyDown = perEventJumpForRinka}
helpfulCheats.cheatArray["rinkamadness"] = {cheatFunction = rinkaMadness, onTick = perEventRinkaMadness}
helpfulCheats.cheatArray["worldpeace"] = {cheatFunction = worldpeace, onTick = perEventWorldpeaceTick, excludeWorldPeace = {1, 3, 5, 10, 11, 12, 13, 21, 26, 30, 51, 54, 55, 56, 57, 58, 59, 71, 73, 74, 75, 76, 77, 78, 79, 80, 82, 100, 101, 102, 103, 104, 107, 113, 114, 129, 130, 131, 132, 133, 134, 135, 136, 139, 144, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161}, tableLengthPrevFrame = 0}
helpfulCheats.cheatArray["getdemstars"] = {cheatFunction = getDemStars, onTick = getDemStarsOnTick, initialImmortalState, initialShadowState, initialX, initialY, initialSection}

-- Let's restore the old settings between levels...

if not isInIntroLevelOrSomething then
	for cheatName, _ in pairs(lunaActivatedCheatData[currentEpisodeNameIndexer]) do
		triggerPerEventStatus(cheatName)
	end
else
	globalData:set("lunaActivatedCheatData", "")
	globalData:save()
end

--Main

local function parsePerEvents(whenToActivate, dataHandoff)
	for _, perEventCheatData in pairs(helpfulCheats.cheatArray) do
		if perEventCheatData[whenToActivate] and perEventCheatData.perEventActivated then
			perEventCheatData[whenToActivate](unpack(dataHandoff))
		end
	end
end

local registeredEvents = { onTick = { }}

local function createEvent(func)
	return function(...) 
		local args = {...}
		for n, f in pairs(registeredEvents[func]) do
			if (helpfulCheats.cheatArray[n].perEventActivated) then
				f(unpack(args))
			end
		end
	end
end

local parseOnTick = createEvent("onTick")

function helpfulCheats.onTick(...)
	cheatBuffer = Misc.cheatBuffer()
	if #cheatBuffer > 0 then
		for cheatCode, _ in pairs(helpfulCheats.cheatArray) do
			if string.find(cheatBuffer, cheatCode) then
				helpfulCheats.triggerCheat(cheatCode, true)
				break
			end
		end
	end
	parseOnTick(...)
end

local function updateSingleRegisteredEvent(cheatName, k, v)
	if (expandedDefines.LUNALUA_EVENTS_MAP[k] and type(v) == "function") then
		if (registeredEvents[k] == nil) then
			registeredEvents[k] = {}
			local func = k
			helpfulCheats[func] = createEvent(func)
			registerEvent(helpfulCheats, k, k, false)
		end
		registeredEvents[k][cheatName] = v
	end
end

local function updateRegisteredEvents(cheatName, cheatData)
	for k, v in pairs(cheatData) do
		updateSingleRegisteredEvent(cheatName, k, v)
	end
end

local function makeCheatMT(cheatName)
	local cheatMT = {}
	cheatMT.__newindex = function(tbl, key, val)
		if (type(val) == "function") then
			updateSingleRegisteredEvent(cheatName, key, val)
		end
		rawset(tbl, key, val)
	end
	return cheatMT
end

local cheatsTableMT = {}
cheatsTableMT.__newindex = function(tbl, key, val)
	if (type(val) == "table") then
		setmetatable(val, cheatMT)
		updateRegisteredEvents(key, val)
	end
	rawset(tbl, key, val)
end

function helpfulCheats.onInitAPI()
	--Only register events we actually need
	registerEvent(helpfulCheats, "onTick", "onTick", false)
	for cheatName, cheatData in pairs(helpfulCheats.cheatArray) do
		setmetatable(cheatData, makeCheatMT(cheatName))
		updateRegisteredEvents(cheatName, cheatData)
	end
	
end

setmetatable(helpfulCheats.cheatArray, cheatsTableMT)

return helpfulCheats