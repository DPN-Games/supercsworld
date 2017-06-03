--playerManager.lua
--v1.0.0
--Created by Horikawa Otane, 2016
--Edited by Rednaxela, because why not
local playerManager = {}

-- Local function definitions
local playerManagerInit
local configCharacter
local loadCharacterAPIs
local prepareCharacterSwaps
local loadCharacterSwaps
local unloadCharacterSwaps
local cleanupCharacter
local initCharacter
local updateCharacterHitbox
local updateCurrentCharacter

-- State variables
local currentCharacterId = nil
local characters = {}
local costumes = {}
local costumeswaps = {}
local characterAssets = {};
local costumeLua = {};
local lastCharacters = {};
characterAssets.graphics = {};
characterAssets.sounds = {};

local costumeData = Data(Data.DATA_WORLD, "Costumes", true);
					 
playerManager.overworldCharacters = nil;
					 
-----------------------------------------
------ LOCAL FUNCTION DECLERATIONS ------
-----------------------------------------

function playerManagerInit()
	-- Define the characters
	configCharacter{id= 1, name="mario",           base=1, switchBlock=622, filterBlock=626, deathEffect=3}
	configCharacter{id= 2, name="luigi",           base=2, switchBlock=623, filterBlock=627, deathEffect=5}
	configCharacter{id= 3, name="peach",           base=3, switchBlock=624, filterBlock=628, deathEffect=129}
	configCharacter{id= 4, name="toad",            base=4, switchBlock=625, filterBlock=629, deathEffect=130}
	configCharacter{id= 5, name="link",            base=5, switchBlock=631, filterBlock=632, deathEffect=134}
	configCharacter{id= 6, name="megaman",         base=4, switchBlock=639, filterBlock=640, deathEffect=149}
	configCharacter{id= 7, name="wario",           base=1, switchBlock=641, filterBlock=642, deathEffect=150}
	configCharacter{id= 8, name="bowser",          base=2, switchBlock=643, filterBlock=644, deathEffect=151}
	configCharacter{id= 9, name="klonoa",          base=4, switchBlock=645, filterBlock=646, deathEffect=152}
	configCharacter{id=10, name="ninjabomberman",  base=3, switchBlock=647, filterBlock=648, deathEffect=153}
	configCharacter{id=11, name="rosalina",        base=3, switchBlock=649, filterBlock=650, deathEffect=154}
	configCharacter{id=12, name="snake",           base=5, switchBlock=651, filterBlock=652, deathEffect=155}
	configCharacter{id=13, name="zelda",           base=2, switchBlock=653, filterBlock=654, deathEffect=156}
	configCharacter{id=14, name="ultimaterinka",   base=4, switchBlock=655, filterBlock=656, deathEffect=157}
	configCharacter{id=15, name="princessrinka",   base=4, switchBlock=657, filterBlock=658, deathEffect=158}
	configCharacter{id=16, name="unclebroadsword", base=1, switchBlock=659, filterBlock=660, deathEffect=159}
	configCharacter{id=17, name="juni",            base=4, switchBlock=661, filterBlock=662, deathEffect=160}
	configCharacter{id=18, name="samus",           base=5, switchBlock=663, filterBlock=664, deathEffect=161}
	
	-- Load Character APIs if this is not the overworld
	if not isOverworld then
		loadCharacterAPIs()
	end
	
	-- Update hitboxes early if possible
	if (characters[player.character] ~= nil) then
		local characterName = characters[player.character].name
		local baseId = characters[player.character].base
		updateCharacterHitbox(characterName, baseId)
	end
	
	initOverworldCharacters();
end

-- Function to declare a character
function configCharacter(params)
	-- A few sanity checks
	if (type(params)~='table') then error("Invalid character parameters") end
	if (type(params.id)~='number') then error("Invalid character.id parameter") end
	if (type(params.name)~='string') then error("Invalid character.name parameter") end
	if (type(params.base)~='number') then error("Invalid character.base parameter") end
	if (params.id <= 5) and (params.id ~= params.base) then error("Default character must have same id as base") end
	if (params.id <= 0) or (params.id > 0x7FFF) then error("Invalid character.id") end
	if (params.base <= 0) or (params.base > 5) then error("Invalid character.base") end
	
	-- Record character settings in a table
	characters[params.id] = params
	
	-- If it's not a built-in character, take further steps
	if (params.id ~= params.base) then
		-- Register character with LunaLua core
		Misc.registerCharacterId(params)
		
		-- Set character id constant
		_G["CHARACTER_" .. string.upper(params.name)] = params.id
	end
end

-- Function to load all character APIs
function loadCharacterAPIs()
	for id, params in pairs(characters) do
		-- Load the API and store a reference to it
		if (params.id ~= params.base) and (params.api == nil) then
			params.api = API.load("Characters/" .. params.name)
		end
		
		-- Also attempt to load custom NPC graphics overrides
		if (params.swaps == nil) then
			params.swaps = prepareCharacterSwaps(params)
		end
	end
end

function prepareCharacterSwaps(params, path)
	local swapTypes = {'npc', 'effect', 'sound'}
	local swapPattern = {npc='^npc%-(%d+)%.png$', effect='^effect%-(%d+)%.png$', sound='^sound%-(%d+)%.ogg$'}
	local swaps = {}
	local characterDir = path
	if(path == nil) then
		characterDir = Misc.resolveDirectory("graphics\\" .. params.name)
	end
	local fileList = Misc.listFiles(characterDir)
	for _,v in ipairs(fileList) do
		for _,swapType in ipairs(swapTypes) do
			local swapId = v:lower():match(swapPattern[swapType])
			if swapId ~= nil then
				swapId = tonumber(swapId)
				local fn = characterDir .. "\\" .. v
				local res
				if (swapType == 'sound') then
					res = Audio.SfxOpen(fn)
				else
					res = Graphics.loadImage(fn)
				end
				if (res ~= nil) then
					if (swaps[swapType] == nil) then
						swaps[swapType] = {}
					end
					swaps[swapType][swapId] = res
				end
				break
			end
		end
	end
	return swaps;
end

local defaultCharacterSwaps = {}
function loadCharacterSwaps(params)
	if(params ~= nil) then
		local swaps = params.swaps;
		if(swaps == nil) then
			swaps = {}
		end
		if (swaps ~= nil) then
			for swapType, items in pairs(swaps) do
				for swapId, swapRes in pairs(items) do
					
					if defaultCharacterSwaps[swapType] == nil then
						defaultCharacterSwaps[swapType] = {}
					end
					
					if (swapType == 'sound') then
						defaultCharacterSwaps[swapType][swapId] = Audio.sounds[swapId].sfx
						Audio.sounds[swapId].sfx = swapRes
					else
						defaultCharacterSwaps[swapType][swapId] = Graphics.sprites[swapType][swapId].img
						Graphics.sprites[swapType][swapId].img = swapRes
					end
				end
			end
		end
	end
end

function unloadCharacterSwaps()
	for defType, items in pairs(defaultCharacterSwaps) do
		for defId, defRes in pairs(items) do
			if (defType == 'sound') then
				Audio.sounds[defId].sfx = defRes
			else
				Graphics.sprites[defType][defId].img = defRes
			end
		end
	end
	defaultCharacterSwaps = {}
end

function cleanupCharacter(characterId, player)
	-- Unload character graphics swaps
	unloadCharacterSwaps()
	
	if (characters[characterId] ~= nil) then
		local api = characters[characterId].api
		
		-- Revert old character API tweaks
		if (api ~= nil) and (api.cleanupCharacter ~= nil) then
			api.cleanupCharacter(player)
		end
	end
end

function initCharacter(characterId, player)
	if (characters[characterId] ~= nil) then
		local api = characters[characterId].api
		
		-- Load character graphics swaps
		loadCharacterSwaps(characters[characterId])
		
		-- Configure character API tweaks
		if (api ~= nil) and (api.initCharacter ~= nil) then
			api.initCharacter(player)
		end
	end
end

function playerManager.resolveIni(file, path)
	if(path == nil) then
		path = "";
	else
		path = path.."\\";
	end
		local iniFilePath = Misc.resolveFile(path..file) or Misc.resolveFile("character_defaults\\" .. file)
		if (iniFilePath == nil) then
			Text.warn("Cannot find: " .. iniFileName)
		end
		return iniFilePath;
end

function updateCharacterHitbox(characterName, baseId, path)
	-- Set hitboxes
	if(path == nil) then
		path = "";
	else
		path = path.."\\";
	end
	for i = 1, 7, 1 do
		local iniFileName = characterName .. "-" .. i .. ".ini"
		local iniFilePath = Misc.resolveFile(path..iniFileName) or Misc.resolveFile("character_defaults\\" .. iniFileName)
		if (iniFilePath == nil) then
			Text.warn("Cannot find: " .. iniFileName)
		else
			Misc.loadCharacterHitBoxes(baseId, i, iniFilePath)
		end
	end
end

function playerManager.getHitboxPath(characterName, power)
		local path = nil;
		if(costumes[newCharacterId] ~= nil) then
			path = "graphics\\costumes\\"..characterName.."\\"..costumes[newCharacterId];
		end
		
		if(path == nil) then
			path = "";
		else
			path = path.."\\";
		end
		
		local iniFileName = characterName .. "-" .. power .. ".ini"
		local iniFilePath = Misc.resolveFile(path..iniFileName) or Misc.resolveFile("character_defaults\\" .. iniFileName)
		if (iniFilePath == nil) then
			Text.warn("Cannot find: " .. iniFileName)
		else
			return iniFilePath;
		end
end

function playerManager.winStateCheck()
	if Level.winState() ~= 0 or player:mem(0x13E,FIELD_WORD) > 0 then
		player.leftKeyPressing = false
		player.rightKeyPressing = false
		player.upKeyPressing = false
		player.downKeyPressing = false
		player.jumpKeyPressing = false
		player.altJumpKeyPressing = false
		player.runKeyPressing = false
		player.altRunKeyPressing = false
		player.pauseKeyPressing = false
		player.dropItemKeyPressing = false
	end
end

-- Function to update things based on current character
function updateCurrentCharacter()
	local newCharacterId = player.character
	
	if (currentCharacterId ~= newCharacterId) and (characters[newCharacterId] ~= nil) then
		local characterName = characters[newCharacterId].name
		local baseId = characters[newCharacterId].base
		
		-- Revert old character API adjustments
		cleanupCharacter(currentCharacterId, player)
		
		local path = nil;
		if(costumes[newCharacterId] ~= nil) then
			path = "graphics\\costumes\\"..characterName.."\\"..costumes[newCharacterId];
		end
		
		-- Set hitboxes
		updateCharacterHitbox(characterName, baseId, path)
		
		-- Init new character API adjustments
		initCharacter(newCharacterId, player)
		
		-- Set new character id marker
		currentCharacterId = newCharacterId
	end
end

local function getUID(assetlist)
	local i = #assetlist + 1;
	while(assetlist[i] ~= nil) do
		i = i+1;
	end
	return i;
end

function playerManager.registerGraphic(characterID, key, filename)
	if(characterAssets.graphics[characterID] == nil) then
		characterAssets.graphics[characterID] = {__default = {}}
	end
	if(filename == nil) then
		filename = key;
		key = getUID(characterAssets.graphics[characterID].__default);
	end
	characterAssets.graphics[characterID].__default[key] = {path = filename, file = Graphics.loadImage(Misc.resolveGraphicsFile(characters[characterID].name.."\\"..filename))};
	return key;
end

function playerManager.registerSound(characterID, key, filename)
	if(characterAssets.sounds[characterID] == nil) then
		characterAssets.sounds[characterID] = {__default = {}}
	end	
	if(filename == nil) then
		filename = key;
		key = getUID(characterAssets.sounds[characterID].__default);
	end
	characterAssets.sounds[characterID].__default[key] = {path = filename, file = Misc.resolveGraphicsFile(characters[characterID].name.."\\"..filename)};
	return key;
end

local function getAsset(assetlist,characterID,key)
	if assetlist[characterID] == nil or
	   assetlist[characterID][costumes[characterID]] == nil or
	   assetlist[characterID][costumes[characterID]][key] == nil or
	   assetlist[characterID][costumes[characterID]][key].file == nil then
		return assetlist[characterID].__default[key].file;
	else
		return assetlist[characterID][costumes[characterID]][key].file;
	end
end

function playerManager.getGraphic(characterID, key)
	return getAsset(characterAssets.graphics,characterID,key)
end

function playerManager.getSound(characterID, key)	
	return getAsset(characterAssets.sounds,characterID,key)
end

function initOverworldCharacters()
	if(playerManager.overworldCharacters == nil) then
		playerManager.overworldCharacters = {}
		for k,v in pairs(characters) do
			if(k ~= CHARACTER_ULTIMATERINKA and k~= CHARACTER_PRINCESSRINKA) then --Exclude certain rinka-based characters
				table.insert(playerManager.overworldCharacters, k);
			end
		end
	end
end

local function resolveCostumeFile(characterID, costumeName, filename)
	return Misc.resolveGraphicsFile("costumes\\"..costumeName.."\\"..filename) or Misc.resolveGraphicsFile(costumeName.."\\"..filename) or Misc.resolveGraphicsFile("costumes\\"..characters[characterID].name.."\\"..costumeName.."\\"..filename);
end

local function cleanupCostumeResidue(characterID)	
	if(costumeswaps[characterID] ~= nil and costumeswaps[characterID].residual ~= nil) then
		for swapType, items in pairs(costumeswaps[characterID].residual) do
			for swapId, swapRes in pairs(items) do
				if (swapType == 'sound') then
					Audio.sounds[swapId].sfx = swapRes
				else
					Graphics.sprites[swapType][swapId].img = swapRes
				end
			end
		end
	end
	costumeswaps[characterID] = nil;
end

local function loadCostumeLua(path, plr)
	local luafile = nil;
	local func, err = loadfile(path)
    if(func)then
        luafile = func()
		if(type(luafile) ~= "table")then
            error("Costume Lua file \""..path.."\" did not return the table (got "..type(luafile)..")", 2)
        end
    else
        if(not err:find("such file"))then
            error(err,2)
        end
    end
            
    if(not luafile) then error("Costume Lua file failed to load correctly: \""..path.."\"",2) end
   
    if(luafile.onInit ~= nil and type(luafile.onInit) == "function")then
		luafile.onInit(plr);
    end
	return luafile;
end

local function updateCostumeLua(index, costumeName)
	if(isOverworld) then
		return;
	end
	local plr = Player(index);
	if(plr == nil) then
		return;
	end
	if(costumeLua[index] ~= nil) then
		local sharedCostume = false;
		for k,v in pairs(costumeLua) do
			if(k ~= index and v == costumeLua[index]) then --Another player is using the costume, so don't clean it update
				sharedCostume = true;
				break;
			end
		end
		
		if(costumeLua[index].onCleanup ~= nil and type(costumeLua[index].onCleanup) == "function") then
			costumeLua[index].onCleanup(plr);
		end
		
		if(not sharedCostume) then
			clearEvents(costumeLua[index]);
		end
	end
	local pth = nil;
	if(costumeName ~= nil) then
		pth = resolveCostumeFile(plr.character, costumeName, "costume.lua");
		if(pth ~= nil) then
			costumeLua[index] = loadCostumeLua(pth, plr);
		else
			costumeLua[index] = {};
		end
	else
		costumeLua[index] = {};
	end
end

local function updateCostumeSwaps(plr)
		if(plr == nil) then
			return;
		end
		if(costumeswaps[plr.character] ~= nil) then
			for swapType, items in pairs(costumeswaps[plr.character].swaps) do
				for swapId, swapRes in pairs(items) do
					if(costumeswaps[plr.character].residual[swapType] == nil) then
						costumeswaps[plr.character].residual[swapType] = {}
					end
					if (swapType == 'sound') then
						costumeswaps[plr.character].residual[swapType][swapId] = Audio.sounds[swapId].sfx;
						Audio.sounds[swapId].sfx = swapRes
					else
						costumeswaps[plr.character].residual[swapType][swapId] = Graphics.sprites[swapType][swapId].img;
						Graphics.sprites[swapType][swapId].img = swapRes
					end
				end
			end
		end
end

function playerManager.setCostume(characterID, costumeName, volatile)
	
	local savedata = volatile ~= true;
	--Quick exit if the costume we're changing to is the current costume.
	if((costumeName ~= nil and costumes[characterID] == costumeName:upper()) or (costumeName == nil and costumes[characterID] == nil)) then
		if(savedata) then
			if(costumeData:get(tostring(characterID)) ~= costumeName) then
				if(costumeName == nil) then
					costumeName = "";
				end
				costumeData:set(tostring(characterID), costumeName);
				costumeData:save();
			end
		end
		return;
	end

	local shouldCallChangeEvent = false;
	cleanupCostumeResidue(characterID);
	
	local objs = {};
		  objs.switchBlock = "block";
		  objs.filterBlock = "block";
		  objs.deathEffect = "effect";
	
	if(costumeName == nil or costumeName == "" or Misc.resolveDirectory("graphics\\costumes\\"..characters[characterID].name.."\\"..costumeName:upper()) == nil) then 
	
		if(savedata) then
			costumeData:set(tostring(characterID), "");
		end
		if(characterID == player.character) then
			updateCharacterHitbox(characters[characterID].name,characters[characterID].base);
		end
		for i = 1, 7, 1 do
			Graphics.sprites[characters[characterID].name][i].img = nil;
		end
		for index,objType in pairs(objs) do
			if(characters[characterID][index] ~= nil) then
				Graphics.sprites[objType][characters[characterID][index]].img = nil;
			end
		end
		
		Graphics.sprites.player[characterID].img = nil;
		
		shouldCallChangeEvent = costumes[characterID] ~= nil;
		costumes[characterID] = nil;
	else
		costumeName = costumeName:upper();
		if(savedata) then
			costumeData:set(tostring(characterID), costumeName);
		end
		local path = "graphics\\costumes\\"..characters[characterID].name.."\\"..costumeName;
		if(characterID == player.character) then
			updateCharacterHitbox(characters[characterID].name,characters[characterID].base,path);
		end
		for i = 1, 7, 1 do
			local filename = characters[characterID].name.."-"..i..".png";
			local path = resolveCostumeFile(characterID, costumeName, filename);
			if(path ~= nil) then
				Graphics.sprites[characters[characterID].name][i].img = Graphics.loadImage(path);
			else
				Graphics.sprites[characters[characterID].name][i].img = nil;
			end
		end
		
		for index,objType in pairs(objs) do
			if(characters[characterID][index] ~= nil) then
				local filename = objType.."-"..characters[characterID][index]..".png";
				local path = resolveCostumeFile(characterID, costumeName, filename);
				if(path ~= nil) then
					Graphics.sprites[objType][characters[characterID][index]].img = Graphics.loadImage(path);
				else
					Graphics.sprites[objType][characters[characterID][index]].img = nil;
				end
			end
		end
		
		if(costumeswaps[characterID] == nil) then
			costumeswaps[characterID] = {};
			costumeswaps[characterID].residual = {};
			costumeswaps[characterID].swaps = prepareCharacterSwaps({}, Misc.resolveDirectory("graphics\\costumes\\"..characters[characterID].name.."\\"..costumeName));
		end
		
		for i=1,Player.count() do
			local plr = Player(i);
			if(plr ~= nil) then
				if(characterID == plr.character) then
					updateCostumeSwaps(plr);
					break;
				end
			end
		end
		
		for assetType,assets in pairs(characterAssets) do
			if(assets[characterID] == nil) then
				assets[characterID] = {__default = {}};
			end
			if(assets[characterID][costumeName] == nil) then
				assets[characterID][costumeName] = {}
				for k,v in pairs(assets[characterID].__default) do
					local f = resolveCostumeFile(characterID,costumeName,v.path);
					if(f ~= nil) then
						if(assetType ~= "sounds") then
							f = Graphics.loadImage(f);
						end
					else
						f = assets[characterID].__default[k].file;
					end
					assets[characterID][costumeName][k] = {path = v.path, file = f};
				end
			end
		end
		local owpath = resolveCostumeFile(characterID,costumeName,"player-"..characterID..".png");
		if(owpath == nil) then
			Graphics.sprites.player[characterID].img = nil;
		else
			Graphics.sprites.player[characterID].img = Graphics.loadImage(owpath);
		end
		
		shouldCallChangeEvent = costumes[characterID] ~= costumeName;
		costumes[characterID] = costumeName;
	end
	if(savedata) then
		costumeData:save();
	end
	if(shouldCallChangeEvent) then
		for k,v in pairs(Player.get()) do
			if(v.character == characterID) then
				updateCostumeLua(k, costumeName);
			end
		end
		
		playerManager.onCostumeChange(characterID, costumes[characterID]);
	end
end

local function listDirs(path)
	if(path == nil) then
		return {};
	end
	return Misc.listDirectories(path) or {};
end

local function icontains(v,tbl)
	for v2 in ipairs(tbl) do
		if(v2 == v) then
			return true;
		end
	end
	return false;
end

function playerManager.getCostumes(characterID)
	local lists = {listDirs(Misc.resolveDirectory("costumes")), listDirs(Misc.resolveDirectory("costumes\\"..characters[characterID].name)), listDirs(Misc.resolveDirectory("\\graphics\\costumes\\"..characters[characterID].name))}
	local t = {}
	for _,list in ipairs(lists) do
		for _,v in ipairs(list) do
			v = v:upper();
			if(not icontains(v,t)) then
				table.insert(t,v);
			end
		end
	end
	return t;
end

function playerManager.getCostumeFromData(characterID)
	local c = costumeData:get(tostring(characterID));
	if (c == "") then
		c = nil;
	end
	return c;
end

function playerManager.getCostume(characterID)
	return costumes[characterID];
end

local function vanillaCostumeInit()

	for k,v in pairs(costumeData:get()) do
		if(tonumber(k) ~= nil and tonumber(k) < 6 and characters[tonumber(k)] ~= nil) then
			playerManager.setCostume(tonumber(k),(v:match'^()%s*$' and '' or v:match'^%s*(.*%S)'))
		end
	end
end

local function newCostumeInit()

	for k,v in pairs(costumeData:get()) do
		if(tonumber(k) ~= nil and tonumber(k) >= 6 and characters[tonumber(k)] ~= nil) then
			playerManager.setCostume(tonumber(k),(v:match'^()%s*$' and '' or v:match'^%s*(.*%S)'))
		end
	end
end

local function costumeInit()
	vanillaCostumeInit();
	newCostumeInit();
end

---------------------------
------ API CALLBACKS ------
---------------------------
function playerManager.onInitAPI()
	registerEvent(playerManager, "onStart", "onStart", false)
	registerEvent(playerManager, "onLoop", "onLoop", false)
	registerEvent(playerManager, "onTick", "onTick", false)
	registerEvent(playerManager, "onDraw", "onDraw", false)
	registerEvent(playerManager, "onInputUpdate", "onInputUpdate", false)
	registerEvent(playerManager, "onLevelExit", "onLevelExit", true)
	
	registerCustomEvent(playerManager, "onCostumeChange");
	
	vanillaCostumeInit();
	-- Try to load hitboxes early if we can
	playerManagerInit()
	newCostumeInit();
	
	--Reset costume array so we can run the change again to ensure everything is ready.
	costumes = {};
end

function playerManager.onStart()
	-- Also load hitboxes in onStart
	updateCurrentCharacter()
	
	for k,v in pairs(Player.get()) do
		lastCharacters[k] = v.character;
	end
	--Make sure things like blocks are correctly changed too.
	costumeInit();
end

function playerManager.onTick()
	-- Also load hitboxes in onStart
	updateCurrentCharacter()
	
	for k,v in pairs(Player.get()) do
		if(lastCharacters[k] == nil) then
			lastCharacters[k] = v.character;
		elseif(v.character ~= lastCharacters[k]) then
			updateCostumeLua(k, costumes[v.character]);
			updateCostumeSwaps(v, costumes[v.character]);
			lastCharacters[k] = v.character;
		end
	end
end

local pressedKeys = {};

function playerManager.onInputUpdate()
	--Set up the world map to support changing to all 18 characters via the pause menu
	if(isOverworld) then
		if(not player.rightKeyPressing) then
			pressedKeys.right = false;
		end
		if(not player.leftKeyPressing) then
			pressedKeys.left = false;
		end
		

		if(mem(0x00B250E2, FIELD_BOOL)) then
			if(player.rightKeyPressing and not pressedKeys.right) then
				pressedKeys.right = true;
				local index = 1;
				for k,v in ipairs(playerManager.overworldCharacters) do
					if(v == player.character) then
						index = playerManager.overworldCharacters[(k%#playerManager.overworldCharacters) + 1];
					end
				end
				player.character = index;
				updateCharacterHitbox(characters[player.character].name, characters[player.character].base)
				local ps = PlayerSettings.get(characters[player.character].base, player.powerup);
				player.height = ps.hitboxHeight;
				player.width = ps.hitboxWidth;
				Audio.playSFX(26);
			elseif(player.leftKeyPressing and not pressedKeys.left) then
				pressedKeys.left = true;
				local index = 1;
				for k,v in ipairs(playerManager.overworldCharacters) do
					if(v == player.character) then
						index = playerManager.overworldCharacters[((k-2)%#playerManager.overworldCharacters) + 1];
					end
				end
				player.character = index;
				updateCharacterHitbox(characters[player.character].name, characters[player.character].base)
				local ps = PlayerSettings.get(characters[player.character].base, player.powerup);
				player.height = ps.hitboxHeight;
				player.width = ps.hitboxWidth;
				Audio.playSFX(26);
			end
		world:mem(0x112,FIELD_WORD,player.character)
		player.rightKeyPressing = false;
		player.leftKeyPressing = false;
		end
	end
end

function playerManager.onLoop()
	-- Also at this point too just in case
	updateCurrentCharacter()
end

function playerManager.onDraw()
	-- Just in case to avoid a rendering glitch
	updateCurrentCharacter()
end

function playerManager.onLevelExit()
	cleanupCharacter(currentCharacterId, player)
end

return playerManager