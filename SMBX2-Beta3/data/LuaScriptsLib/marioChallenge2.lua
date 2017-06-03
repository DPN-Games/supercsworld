local rng = API.load("rng")
local lunajson = API.load("ext/lunajson")
local pm = API.load("playerManager")

local marioChallenge = {}

local EP_LIST_PTR = mem(0x00B250FC, FIELD_DWORD)
local EP_LIST_COUNT = mem(0x00B250E8, FIELD_WORD)
local currentEpisodeIndex = mem(0x00B2C628, FIELD_WORD)

local rerollCount = 150;

local levelsPlayed = {}
local fullLevelList;

local topEpisodeName = "SMBX Mario Challenge"
local introLevel = "marioChallenge-intro.lvl"

local function loadMCImage(name)
	return Graphics.loadImage(Misc.resolveFile(name) or Misc.resolveFile("graphics/luaResources/marioChallenge/"..name))
end

local img_reroll;
local img_levels;
local img_lives;
local img_inf;
local img_slash;
local img_timer;
local img_congrats;
local img_results;
local img_deathmark;
local img_deathmark_large;


local img_mode_ohko;
local img_mode_slippery;
local img_mode_rinka;
local img_mode_timer;
local img_mode_shuffle;
local img_mode_mirror;

local audio_hurryup;

local mode_images;

local firstFrame = true;
local earlyDeathCheck = 3;

local dying = false;
local deathVisibleCount = 210;
local deathTimer = deathVisibleCount;

local mcData = Data(Data.DATA_GLOBAL, "marioChallengeData")
local mcSaveData = Data(Data.DATA_GLOBAL, "marioChallengeSaveData")

--Holds all data that will be held between levels
local mcTable = {};
local mcDeathTable = {};

local default_levels = 5;
local default_lives = 10;
local default_rerolls = 5;

local isIntro
local timer
local selectKeyDown
local defs
local textblox
local eventu;

local timer_deathTimer;
local timer_initscore;
local timer_hurry;

local rinka_exclude;
local rinka_counter;

local mirror_capture;

function marioChallenge.getConfigRerolls()
	return mcTable.config_rerolls;
end

function marioChallenge.setConfigRerolls(newValue)
	mcTable.config_rerolls = newValue;
	mcTable.rerolls = mcTable.config_rerolls;
end

function marioChallenge.resetConfigRerolls()
	marioChallenge.setConfigRerolls(default_rerolls);
end


function marioChallenge.getConfigLives()
	return mcTable.config_lives;
end

function marioChallenge.setConfigLives(newValue)
	mcTable.config_lives = newValue;
end

function marioChallenge.resetConfigLives()
	marioChallenge.setConfigLives(default_lives);
end


function marioChallenge.getConfigLevels()
	return mcTable.config_levels;
end

function marioChallenge.setConfigLevels(newValue)
	mcTable.config_levels = newValue;
end

function marioChallenge.resetConfigLevels()
	marioChallenge.setConfigLevels(default_levels);
end


function marioChallenge.getModeShuffle()
	return mcTable.mode_shuffle;
end
function marioChallenge.setModeShuffle(newValue)
	mcTable.mode_shuffle = newValue;
end

function marioChallenge.getModeSlippery()
	return mcTable.mode_slippery;
end
function marioChallenge.setModeSlippery(newValue)
	mcTable.mode_slippery = newValue;
end

function marioChallenge.getModeTimer()
	return mcTable.mode_timer;
end
function marioChallenge.setModeTimer(newValue)
	mcTable.mode_timer = newValue;
end

function marioChallenge.getModeOHKO()
	return mcTable.mode_onehit;
end
function marioChallenge.setModeOHKO(newValue)
	mcTable.mode_onehit = newValue;
end

function marioChallenge.getModeRinka()
	return mcTable.mode_rinka;
end
function marioChallenge.setModeRinka(newValue)
	mcTable.mode_rinka = newValue;
end

function marioChallenge.getModeMirror()
	return mcTable.mode_mirror;
end
function marioChallenge.setModeMirror(newValue)
	mcTable.mode_mirror = newValue;
end

local function cleanUp()
	mcTable = {}
end

local function isIntroLevel()
	return not isOverworld and mcTable.currentLevel.episodeName == topEpisodeName and Level.filename() == introLevel;
end

local function initCostumes()
	for i=1,18 do
		local c = mcTable.costumes[i];
		if(c == "") then
			c = nil;
		end
		pm.setCostume(i, nil, true);
		pm.setCostume(i, c, true);
	end
end

local function initData()
	local t = mcData:get("data");
	if(t == "" or mem(0x00B2C62A, FIELD_WORD) == 0) then
		--Set values for new Mario Challenge run here
		mcTable = {};
		
		mcTable.config_levels = default_levels;
		mcTable.config_rerolls = default_rerolls;
		mcTable.config_lives = default_lives;
		
		mcTable.playIndex = -2; -- 2 means loading up a new Mario Challenge
		mcTable.isIntro = true;
		mcTable.loadInProgress = true;
		mcTable.rerolls = mcTable.config_rerolls;
		mcTable.rerollCounter = 0;
		mcTable.hasWon = false;
		mcTable.hasLost = false;
		mcTable.hubLocation = 1;
		mcTable.levelsPlayed = {};
		mcTable.deaths = 0;
		mcTable.startingDeaths = 0;
		mcTable.hasSeenText = false;
		mcTable.currentLevel = {episodeNumber=1,levelFile="",episodeName=topEpisodeName};
		mcTable.character = CHARACTER_MARIO;
		
		mcTable.costumes = {};
		for i=1,18 do
			local c = pm.getCostumeFromData(i);
			if(c == nil) then
				c = "";
			end
			mcTable.costumes[i] = c;
		end
		
		mcTable.mode_shuffle = false;
		mcTable.mode_slippery = false;
		mcTable.mode_timer = false;
		mcTable.mode_onehit = false;
		mcTable.mode_rinka = false;
		mcTable.mode_mirror = false;
	else
		mcTable = lunajson.decode(t);
	end
	
	isIntro = mcTable.isIntro;
	mcTable.isIntro = false;
	
	mcData:set("data", "");
	mcData:save();
	
	local deathmarks = mcSaveData:get("Death_"..mcTable.currentLevel.episodeName..":"..mcTable.currentLevel.levelFile);
	if(deathmarks == nil or deathmarks == "") then
		mcDeathTable = {};
	else
		mcDeathTable = lunajson.decode(deathmarks);
	end
	
	if(isIntroLevel()) then
		local settings = mcSaveData:get("Settings");
		if(settings ~= nil and settings ~= "") then
			local settingstable = lunajson.decode(settings);
			if(settingstable.levels ~= nil) then
				marioChallenge.setConfigLevels(settingstable.levels);
			end
			if(settingstable.lives ~= nil) then
				marioChallenge.setConfigLives(settingstable.lives);
			end
			if(settingstable.rerolls ~= nil) then
				marioChallenge.setConfigRerolls(settingstable.rerolls);
			end
			if(settingstable.mode_shuffle ~= nil) then
				marioChallenge.setModeShuffle(settingstable.mode_shuffle);
			end
			if(settingstable.mode_onehit ~= nil) then
				marioChallenge.setModeOHKO(settingstable.mode_onehit);
			end
			if(settingstable.mode_rinka ~= nil) then
				marioChallenge.setModeRinka(settingstable.mode_rinka);
			end
			if(settingstable.mode_slippery ~= nil) then
				marioChallenge.setModeSlippery(settingstable.mode_slippery);
			end
			if(settingstable.mode_timer ~= nil) then
				marioChallenge.setModeTimer(settingstable.mode_timer);
			end
			if(settingstable.mode_mirror ~= nil) then
				marioChallenge.setModeMirror(settingstable.mode_mirror);
			end
		end
	end
end

local function flushData()
	if(isIntroLevel()) then
		local settings =
		{
			levels = mcTable.config_levels,
			lives = mcTable.config_lives,
			rerolls = mcTable.config_rerolls,
			mode_onehit = mcTable.mode_onehit,
			mode_rinka = mcTable.mode_rinka,
			mode_shuffle = mcTable.mode_shuffle,
			mode_slippery = mcTable.mode_slippery,
			mode_timer = mcTable.mode_timer,
			mode_mirror = mcTable.mode_mirror
		}
		mcSaveData:set("Settings", lunajson.encode(settings));
		mcSaveData:save();
		
		for i=1,18 do
			local c = pm.getCostume(i);
			if(c == nil) then
				c = "";
			end
			mcTable.costumes[i] = c;
		end
	end
	mcData:set("data", lunajson.encode(mcTable));
	mcData:set("active","1");
	mcData:save();
end

local function fillScreen()
	--Graphical irregularity can occur while loading new levels, so cover it in black so we can't see it.
	Graphics.glDraw{vertexCoords ={0,0,800,0,800,600,0,600}, color={0,0,0,1},primitive=Graphics.GL_TRIANGLE_FAN,priority=10};
end

local function loadLevel(filename, episodeIndex, warpIdx, dontFlush)
	fillScreen();
	
	if(dontFlush ~= true) then
		flushData();
	end
	-- 0 means default warp index
	if warpIdx == nil then
		warpIdx = 0
	end
	-- Set teleport destination
	mem(0x00B2C6DA, FIELD_WORD, warpIdx)    -- GM_NEXT_LEVEL_WARPIDX
	mem(0x00B25720, FIELD_STRING, filename) -- GM_NEXT_LEVEL_FILENAME
	mem(0x00B2C628, FIELD_WORD, episodeIndex) -- Index of the episode
	
	-- Force modes such that we trigger level exit
	mem(0x00B250B4, FIELD_WORD, 0)  -- GM_IS_EDITOR_TESTING_NON_FULLSCREEN
	mem(0x00B25134, FIELD_WORD, 0)  -- GM_ISLEVELEDITORMODE
	mem(0x00B2C89C, FIELD_WORD, 0)  -- GM_CREDITS_MODE
	mem(0x00B2C620, FIELD_WORD, 0)  -- GM_INTRO_MODE
	mem(0x00B2C5B4, FIELD_WORD, -1) -- GM_EPISODE_MODE (set to leave level)
end

local function getFullLevelList()
	local episodeData = {}
	local finalList = {}
	for indexer = 1, EP_LIST_COUNT do
		episodeData[indexer] = {}
		episodeData[indexer].episodeName = tostring(mem(EP_LIST_PTR + (indexer - 1) * 0x18 + 0x0, FIELD_STRING))
		episodeData[indexer].episodePath = tostring(mem(EP_LIST_PTR + ((indexer - 1) * 0x18) + 0x4, FIELD_STRING))
		if episodeData[indexer].episodeName == topEpisodeName then
			mcTable.hubLocation = indexer;
		end
		if(mcTable.levelData == nil) then
			for _, file in pairs(Misc.listFiles(episodeData[indexer].episodePath)) do
				if string.match(file, ".lvl") and episodeData[indexer].episodeName ~= topEpisodeName then
					local thisLevel = io.open(episodeData[indexer].episodePath .. "/" .. file, "r")
					local fileContents = thisLevel:read("*a")
					thisLevel:seek("set")
					local vNum = tonumber(thisLevel:read());
					
					--Invalid or unknown version! Don't try loading this level.
					if(vNum ~= nil) then
					
						--[[version number stuff:
							here goes line 1
							>= 17 adds line 2
							>= 60 adds line 3
							<8 loops 6 times, rest loops 21 times
							9 lines in the loop + ...
							>=1, 30 and 2 add 1 in the loop each
							following are 2 lines for x and y which we ignore, we only need the dimensions]]
						if tonumber(vNum) >= 17 then thisLevel:read() end
						if tonumber(vNum) >= 60 then thisLevel:read() end
						local sectionLoops = 21
						if tonumber(vNum) < 8 then
							sectionLoops = 6
						end
						for i=1, sectionLoops do
							for i=1,9 do
								thisLevel:read()
							end
							if tonumber(vNum) >= 1 then thisLevel:read() end
							if tonumber(vNum) >= 30 then thisLevel:read() end
							if tonumber(vNum) >= 2 then thisLevel:read() end
						end
						
						thisLevel:read()
						thisLevel:read()
						widthCheck, heightCheck = thisLevel:read(), thisLevel:read()
						
						local warpSkip = false;
						
						--None of the skip fields actually occur in versions lower than 3, so don't bother.
						if(tonumber(vNum) >= 3) then
						
							thisLevel:read()
							thisLevel:read()
							thisLevel:read()
							thisLevel:read()
							--End of header
							
							local l = thisLevel:read();
							
							--Read to end of blocks
							while(l ~= "\"next\"") do
								l = thisLevel:read();
							end
							
							l = thisLevel:read();
							--Read to end of BGOs
							while(l ~= "\"next\"") do
								l = thisLevel:read();
							end
							
							l = thisLevel:read();
							--Read to end of NPCs
							while(l ~= "\"next\"") do
								l = thisLevel:read();
							end
							
							local warpLocs = {}
							
							--Check for warps that could means level is incompletable on its own, or is a hub.
							--This excludes any levels that a) have star-locked warps or b) have more than one warp to a different .lvl file.
							l = thisLevel:read();
							while(l ~= "\"next\"") do
								thisLevel:read();
								thisLevel:read();
								thisLevel:read();
								thisLevel:read();
								thisLevel:read();
								thisLevel:read();
								local lvln = thisLevel:read();
								if(lvln == nil) then
									warpSkip = true;
									break;
								end
								thisLevel:read();
								local entrance = thisLevel:read() == "#TRUE#"
								if(not entrance and lvln ~= "\"\"") then --Warp is not an entrance
									warpLocs[lvln] = true;
								end
								local i = 0;
								for _,_ in pairs(warpLocs) do
									i = i + 1;
								end
								--More than one warp to another level (probably a hub)
								if(i > 1) then
									warpSkip = true;
									break;
								end
								if(tonumber(vNum) >= 4) then
									thisLevel:read();
									thisLevel:read();
									thisLevel:read();
								end
								if(tonumber(vNum) >= 7) then
									local stars = thisLevel:read();
									--A warp is locked by stars and level may not be beatable
									if(not entrance and tonumber(stars) ~= nil and tonumber(stars) > 0) then
										warpSkip = true;
										break;
									end
								end
								if(tonumber(vNum) >= 12) then
									thisLevel:read();
									thisLevel:read();
								end
								
								if(tonumber(vNum) >= 23) then
									thisLevel:read();
								end
								if(tonumber(vNum) >= 25) then
									thisLevel:read();
								end
								if(tonumber(vNum) >= 26) then
									thisLevel:read();
								end
									
								l=thisLevel:read();
							end
						end
						if not (warpSkip or string.match(fileContents, "excludeFromMarioChallenge") or tonumber(widthCheck) == 0 or tonumber(heightCheck) == 0) then
							table.insert(finalList, {episodeNumber = indexer, levelFile = file, episodeName = episodeData[indexer].episodeName})
						end
					end
				end
			end
		end
	end
	if(mcTable.levelData == nil) then
		mcTable.levelData = finalList;
	else
		finalList = mcTable.levelData;
	end
	return finalList
end

function marioChallenge.forceUpdateLevelList()
	mcTable.levelData = nil;
	getFullLevelList()
end

function marioChallenge.LevelCount()
	if(mcTable.levelData == nil) then
		getFullLevelList();
	end
	return #mcTable.levelData;
end


local function loadNextLevel(dontIncrement)
	if(dontIncrement == nil) then
		dontIncrement = false;
	end
	if not dontIncrement and mcTable.config_levels > 0 and mcTable.playIndex >= mcTable.config_levels then
		mcTable.hasWon = true;
		loadLevel("winner.lvl", mcTable.hubLocation)
	elseif not dontIncrement and mcTable.hasLost then
		mcData:set("data", "");
		mcData:save();
		loadLevel(introLevel, mcTable.hubLocation, nil, true);
	else	
		if(not dontIncrement) then
			mcTable.playIndex = mcTable.playIndex + 1;
		end
		
		if(not isOverworld) then
			mcTable.levelsPlayed[mcTable.currentLevel.episodeName..":"..Level.filename()] = true;
		end
		
		mcTable.hasSeenText = false;
		mcTable.startingDeaths = mcTable.deaths;
		
		fullLevelList = getFullLevelList();
		local levelList = {};
		
		local i = 1;
		for _,v in ipairs(fullLevelList) do
			if(not mcTable.levelsPlayed[v.episodeName..":"..v.levelFile]) then
				table.insert(levelList, v);
			end
		end
		
		if(#levelList == 0) then
			mcTable.levelsPlayed = {}
			levelList = fullLevelList;
		end
		
		local nextData = rng.irandomEntry(levelList);
		
		mcTable.currentLevel = nextData;
		
		loadLevel(nextData.levelFile, nextData.episodeNumber)
	end
end

local function isWinning()
	if tostring(mem(EP_LIST_PTR + (currentEpisodeIndex - 1) * 0x18 + 0x0, FIELD_STRING)) == topEpisodeName and not mcTable.hasWon and not mcTable.hasLost then
		return true
	else
		return false
	end
end

function marioChallenge.onExitLevel()
	if (not isOverworld and ((mcTable.hasWon and Level.filename() == "winner.lvl") or (mcTable.hasLost and Level.filename() == "exit.lvl"))) then
		return;
	end
	
	if(isIntroLevel()) then
		mcTable.character = player.character;
	end
	-- Flush our local data back to the data file before warping
	flushData();
end

local function drawValue(x,y,val)
		if(val == -1) then
			Graphics.draw{type = RTYPE_IMAGE, x=x, y=y, image=img_inf, priority=10};
		else
			local text = tostring(val);
			Graphics.draw{type = RTYPE_TEXT, x=x+18-(18*#text), y=y+1, text=text, fontType = 1, priority=10};
		end
end

local function drawUI(x, y, image, firstVal, secondVal)
		
		Graphics.draw{type = RTYPE_IMAGE, x=x, y=y, image=image, priority=10};
		Graphics.draw{type = RTYPE_IMAGE, x=x+24, y=y+1, image=Graphics.sprites.hardcoded["33-1"].img, priority=10};
		
		if(secondVal ~= nil) then
			drawValue(x+64,y,firstVal);
			Graphics.draw{type = RTYPE_IMAGE, x=x+82, y=y, image=img_slash, priority=10};
		else
			secondVal = firstVal;
		end
		drawValue(x+118,y,secondVal);
end

local function drawLevelName()
	local levelname = Level.name();
	if levelname == nil or levelname == "" then
		levelname = string.sub(Level.filename(), 0, -5);
	end
	local lineCount = math.ceil(#levelname / 44)
	textblox.printExt(mcTable.currentLevel.episodeName .. "<br>" .. levelname, {x = 16, y = 584, width=600, font = textblox.FONT_SPRITEDEFAULT3X2, halign = textblox.HALIGN_LEFT, valign = textblox.VALIGN_BOTTOM, z=10})
end

local victoryTimer = 0;

local function drawVictoryStat(x,y,image,text,value)
		
		Graphics.draw{type = RTYPE_IMAGE, x=x, y=y, image=image, priority=10};
		textblox.printExt(":", {x=x+16, y=y, width = 780, font = textblox.FONT_SPRITEDEFAULT3X2, halign = textblox.HALIGN_LEFT, valign = textblox.VALIGN_TOP, z=10})
		drawValue(x+16+(18*2),y,value);
		textblox.printExt(text, {x=x+16+(18*4), y=y, width = 780, font = textblox.FONT_SPRITEDEFAULT3X2, halign = textblox.HALIGN_LEFT, valign = textblox.VALIGN_TOP, z=10})
end

local function drawVictoryStats(stagesOffset)
	local y = 480;
	local x = 400;
	drawVictoryStat(x-140, y, img_levels, "stages cleared", mcTable.playIndex + stagesOffset);
	drawVictoryStat(x-140, y+30, img_reroll, "rerolls", mcTable.rerollCounter);
	drawVictoryStat(x-140, y+60, img_lives, "deaths", mcTable.deaths);
	
	local modelist = {}
	for _,v in ipairs(mode_images) do
		if(v.active()) then
			table.insert(modelist,v.img);
		end
	end
	
	x = 400-(10*#modelist);
	y = y + 90;
	for k,v in ipairs(modelist) do
		Graphics.draw{type = RTYPE_IMAGE, x=x+20*k, y=y, image=v, priority=10};
	end
	
end

local function drawVictory()
	if(img_congrats == nil) then
		img_congrats = loadMCImage("mc-congrats.png");
	end
	local maxtimer = 200;
	if(victoryTimer < maxtimer) then
		victoryTimer = victoryTimer + 1;
	end
	local x = 400;
	local y = 60;
	Graphics.glDraw{vertexCoords={x-256,y,x+256,y,x+256,y+256,x-256,y+256}, primitive=Graphics.GL_TRIANGLE_FAN, textureCoords={0,0,1,0,1,1,0,1}, texture = img_congrats, color = {1,1,1,victoryTimer/maxtimer}, priority=10};
	
	textblox.printExt("You beat the Mario Challenge!", {y = y+216, width = 780, font = textblox.FONT_SPRITEDEFAULT3X2, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_BOTTOM, z=10})
	
	drawVictoryStats(0);
end

local function drawResults()
	if(img_results == nil) then
		img_results = loadMCImage("mc-results.png");
	end
	local maxtimer = 200;
	if(victoryTimer < maxtimer) then
		victoryTimer = victoryTimer + 1;
	end
	local x = 400;
	local y = 100;
	Graphics.glDraw{vertexCoords={x-256,y,x+256,y,x+256,y+64,x-256,y+64}, primitive=Graphics.GL_TRIANGLE_FAN, textureCoords={0,0,1,0,1,1,0,1}, texture = img_results, color = {1,1,1,victoryTimer/maxtimer}, priority=10};
	
	--textblox.printExt("", {y = y+216, width = 780, font = textblox.FONT_SPRITEDEFAULT3X2, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_BOTTOM, z=10})
	
	drawVictoryStats(-1);
end

local deathmarkDrawData;

local function DrawDeathMarks(a)
	if(deathmarkDrawData == nil) then
		local halfwid = img_deathmark.width*0.5;
		local hei = img_deathmark.height;
		deathmarkDrawData = {verts = {}, uvs = {}};
		for k,v in ipairs(mcDeathTable) do
			if(k == #mcDeathTable) then
				--Skip the last element - it's actually our current death!
				break;
			end
			table.insert(deathmarkDrawData.verts, v.x-halfwid);
			table.insert(deathmarkDrawData.verts, v.y-hei);
			table.insert(deathmarkDrawData.uvs, 0);
			table.insert(deathmarkDrawData.uvs, 0);
			
			table.insert(deathmarkDrawData.verts, v.x+halfwid);
			table.insert(deathmarkDrawData.verts, v.y-hei);
			table.insert(deathmarkDrawData.uvs, 1);
			table.insert(deathmarkDrawData.uvs, 0);
			
			table.insert(deathmarkDrawData.verts, v.x-halfwid);
			table.insert(deathmarkDrawData.verts, v.y);
			table.insert(deathmarkDrawData.uvs, 0);
			table.insert(deathmarkDrawData.uvs, 1);
			
			table.insert(deathmarkDrawData.verts, v.x-halfwid);
			table.insert(deathmarkDrawData.verts, v.y);
			table.insert(deathmarkDrawData.uvs, 0);
			table.insert(deathmarkDrawData.uvs, 1);
			
			table.insert(deathmarkDrawData.verts, v.x+halfwid);
			table.insert(deathmarkDrawData.verts, v.y-hei);
			table.insert(deathmarkDrawData.uvs, 1);
			table.insert(deathmarkDrawData.uvs, 0);
			
			table.insert(deathmarkDrawData.verts, v.x+halfwid);
			table.insert(deathmarkDrawData.verts, v.y);
			table.insert(deathmarkDrawData.uvs, 1);
			table.insert(deathmarkDrawData.uvs, 1);
		end
	end
	
	--local a = (math.sin(lunatime.time())+0.5)*0.5;
	Graphics.glDraw{vertexCoords = deathmarkDrawData.verts, sceneCoords = true, textureCoords = deathmarkDrawData.uvs, primitive = Graphics.GL_TRIANGLES, texture = img_deathmark, color = {1,1,1,a}, priority = -1};
end

local function RunDeathEvent()
	if(deathTimer > 0) then
		player:mem(0x13E, FIELD_WORD, 198);
		deathTimer = deathTimer-1;
		local alpha = 1 - deathTimer/deathVisibleCount;
		DrawDeathMarks((alpha)*50);
		local starty = Camera.get()[1].y;
		local bounds = Section(player.section).boundary;
		local targy = math.min(bounds.bottom, player.y + player.height);
		
		local t = math.min(1, math.max(0, alpha*12 - 0.25));
		
		local y = starty*(1-t) + targy*(t)
		
		Graphics.draw{type=RTYPE_IMAGE, image = img_deathmark_large, x = player.x+(player.width-img_deathmark_large.width-1)*0.5, y = y - img_deathmark_large.height - 4, isSceneCoordinates = true, priority = -1}
	else
		mcTable.loadInProgress = true;
		if(mem(0x00B2C5AC, FIELD_FLOAT) > 0) then
			dying = false;
			if(mcTable.config_lives >= 0) then
				mem(0x00B2C5AC, FIELD_FLOAT, mem(0x00B2C5AC, FIELD_FLOAT) - 1)
			end
			loadLevel(mcTable.currentLevel.levelFile, mcTable.currentLevel.episodeNumber)
		else
			mcTable.hasLost = true;
			loadLevel("results.lvl", mcTable.hubLocation)
		end
	end
end

local function shouldFillScreen()
	return firstFrame or (mcTable.loadInProgress);
end

function marioChallenge.onCameraUpdate()
	if(mcTable.mode_mirror and mirror_capture ~= nil and not isIntroLevel() and not isOverworld and not shouldFillScreen()) then
		local mirrorPriority = 0;
		mirror_capture:captureAt(mirrorPriority);
		Graphics.glDraw{vertexCoords = {0,0,800,0,800,600,0,600}, textureCoords = {1,0,0,0,0,1,1,1}, primitive = Graphics.GL_TRIANGLE_FAN, texture=mirror_capture, priority = mirrorPriority};
	end
end

function marioChallenge.onHUDDraw()
	if(shouldFillScreen()) then
		fillScreen();
		firstFrame = false;
		return;
	end
	if (not isIntro) then
		if isWinning() or mcTable.hasWon then
			drawVictory();
		elseif mcTable.hasLost then
			drawResults();
		elseif not isOverworld then
			if(dying) then
				RunDeathEvent();
			end
			local x = 800-144;
			local y = 600-72;
			if(mcTable.mode_timer) then
				local t = math.ceil((timer_deathTimer/64) + (mem(0x00B2C8E4,FIELD_DWORD) - timer_initscore)/1000 --[[1000 points = 1 extra second]]);
				drawUI(x,y-24,img_timer,t);
				if(t <= 60 and not timer_hurry) then
					Audio.SfxPlayCh(-1,audio_hurryup,0);
					timer_hurry = true;
				end
				if(player:mem(0x13E,FIELD_WORD) == 0 and winState() == 0 and not(mem(0x00B250E2, FIELD_BOOL) or Misc.isPausedByLua())) then
					if(t == 0) then
						player:kill();
					elseif(player:mem(0x13E,FIELD_WORD) == 0) then
						timer_deathTimer = timer_deathTimer - 1;
					end
				end
			end
			if(mcTable.rerolls < 0) then
				drawUI(x,y,img_reroll,mcTable.rerolls);
			else
				drawUI(x,y,img_reroll,mcTable.rerolls,mcTable.config_rerolls);
			end
			
			if(mcTable.config_lives < 0) then
				drawUI(x,y+24,img_lives, mcTable.config_lives);
			else
				drawUI(x,y+24,img_lives,mem(0x00B2C5AC,FIELD_FLOAT), mcTable.config_lives);
			end
			
			local lvls = mcTable.playIndex;
			local boostIndex = 0;
			boostIndex = math.floor(lvls/100);
			lvls = lvls%100;
			
			for i = 1,boostIndex do
				Graphics.draw{type = RTYPE_IMAGE, x=x-(16*i), y=y+48, image=img_levels, priority=10};
			end
			
			drawUI(x,y+48,img_levels,lvls,mcTable.config_levels);
		end
		if timer > 0 then
			if not isWinning() and not mcTable.hasWon and not mcTable.hasLost then
				if not isOverworld and not mcTable.hasSeenText then
					drawLevelName();
				end
			end
			timer = timer - 1
		elseif timer == 0 and not mcTable.hasSeenText then
			timer = 0
			mcTable.hasSeenText = true;
		end
	end
end

function marioChallenge.onInputUpdate()
	if(mcTable.mode_mirror and mirror_capture ~= nil and not isIntroLevel() and not isOverworld and not shouldFillScreen() and not mem(0x00B250E2, FIELD_BOOL) and not Misc.isPausedByLua()) then
		local right = player.rightKeyPressing;
		player.rightKeyPressing = player.leftKeyPressing;
		player.leftKeyPressing = right;
	end
end

function marioChallenge.onTick()
	if(earlyDeathCheck > 0) then
		earlyDeathCheck = earlyDeathCheck - 1;
	end
	if(lunatime.tick() == 4 or lunatime.tick() == 2) then
		initCostumes();
	end
	
	if(mcTable.mode_slippery and not isIntroLevel()) then
		for _,v in ipairs(Block.get()) do
			v.slippery = true;
		end
	end
	
	if(mcTable.mode_onehit and not isIntroLevel()) then
		if(player:mem(0x140, FIELD_WORD) > 140 or player:mem(0x122,FIELD_WORD) == 2) then
			player:mem(0x140, FIELD_WORD, 0);
			player:kill();
		end
	end
	
	if(mcTable.mode_rinka and not isIntroLevel()) then
		rinka_counter = rinka_counter + 1;
			if rinka_counter >= 180 then
				rinka_counter = 0;
				for _,v in ipairs(NPC.get(defs.NPC_HITTABLE, player.section)) do
					if not v.friendly and not v.isHidden and rinka_exclude[v.id] == nil and v:mem(0x12C,FIELD_WORD) == 0 and v:mem(0x128,FIELD_WORD) ~= -1 and not v:mem(0x64,FIELD_BOOL) then
						local n = NPC.spawn(210,v.x+v.width*0.5,v.y+v.height*0.5, player.section);
						n.x = n.x-n.width*0.5;
						n.y = n.y-n.height*0.5;
					end
				end
			end
	end

	Defines.player_hasCheated = true
	if player.dropItemKeyPressing and player:mem(0x13E, FIELD_WORD) == 0 and not (isWinning() or mcTable.hasWon or mcTable.hasLost) then
		selectKeyDown = selectKeyDown + 1
	else
		selectKeyDown = 0
	end
	if selectKeyDown == rerollCount and (mcTable.rerolls > 0 or mcTable.rerolls == -1) then
		if(mcTable.rerolls > 0) then
			mcTable.rerolls = mcTable.rerolls - 1;
		end
		mcTable.rerollCounter = mcTable.rerollCounter+1;
		mcTable.loadInProgress = true;
		loadNextLevel(true);
	elseif selectKeyDown > 0 then
		if(mcTable.rerolls > 0 or mcTable.rerolls == -1) then
			local a = math.floor((selectKeyDown/rerollCount)*255);
			textblox.printExt("<wave>Rerolling Level...</wave>", {color = a+0xFFFFFF00, font = textblox.FONT_SPRITEDEFAULT3X2, halign = textblox.HALIGN_MID, valign = textblox.VALIGN_BOTTOM, z=10});
		end
		
		if(selectKeyDown > 25) then
			drawLevelName();
		end
	end
	
	if player:mem(0x13E, FIELD_WORD) >= 198 or (player.character == CHARACTER_NINJABOMBERMAN and player:mem(0x13E, FIELD_WORD) >= 1) then
		if(earlyDeathCheck > 0) then
			mcTable.loadInProgress = true;
			loadNextLevel();
		elseif not dying then
			player:mem(0x13E, FIELD_WORD, 198);
			
			mcTable.deaths = mcTable.deaths + 1;
			
			local bounds = Section(player.section).boundary;
			table.insert(mcDeathTable, {x=player.x+(player.width-1)*0.5, y = math.max(bounds.top + 4 + img_deathmark.height, math.min(bounds.bottom - 4, player.y + player.height - 4))})
			mcSaveData:set("Death_"..mcTable.currentLevel.episodeName..":"..mcTable.currentLevel.levelFile, lunajson.encode(mcDeathTable));
			mcSaveData:save();
		
			dying = true;
		end
	end
end

function marioChallenge.Activate()
	initData();
	fullLevelList = getFullLevelList();
	
	local juni = API.load("Characters/juni");
	juni.usesavestate = false;
	
	local nbm = API.load("Characters/ninjabomberman");
	nbm.usesavestate = false;
	nbm.deathDelay = deathVisibleCount;
	
	local mm = API.load("Characters/megaman");
	mm.playIntro = false;
		
	
	if(mcTable.mode_shuffle and isOverworld) then
		mcTable.character = rng.randomInt(1,18);
		
		--Princess Rinka sets lives to 0, which kind of sucks, so make it extra rare to randomly pick her.
		if(mcTable.character == CHARACTER_PRINCESSRINKA) then
			mcTable.character = rng.randomInt(1,18);
		end
	end
	
	player.character = mcTable.character;
	
	if(mcTable.mode_timer and not isOverworld) then
		timer_deathTimer = (180 + (mcTable.deaths-mcTable.startingDeaths) * 15) * 64; --3 minutes (180 seconds) base time
		timer_initscore = mem(0x00B2C8E4,FIELD_DWORD);
		img_timer = loadMCImage("mc-timer.png");
		audio_hurryup = Audio.SfxOpen(Misc.resolveFile("hurry-up.ogg") or Misc.resolveFile("sound/extended/hurry-up.ogg"));
		timer_hurry = false;
	end
	
	if(mcTable.mode_mirror) then
		mirror_capture = Graphics.CaptureBuffer(800,600);
	end
	
	img_reroll = loadMCImage("mc-rerolls.png");
	img_levels = loadMCImage("mc-stages.png");
	img_lives = loadMCImage("mc-lives.png");
	img_inf = loadMCImage("mc-infinite.png");
	img_slash = loadMCImage("mc-slash.png");
	img_deathmark = loadMCImage("mc-deathmark.png");
	img_deathmark_large = loadMCImage("mc-deathmark-large.png");
	
	
    img_mode_ohko = loadMCImage("mc-mode-ohko.png");
    img_mode_slippery = loadMCImage("mc-mode-slippery.png");
    img_mode_rinka = loadMCImage("mc-mode-rinka.png");
    img_mode_timer = img_timer or loadMCImage("mc-timer.png");
    img_mode_shuffle = img_reroll;
    img_mode_mirror = loadMCImage("mc-mirror.png");


    mode_images = {
				{active=marioChallenge.getModeOHKO,img=img_mode_ohko}, 
				{active=marioChallenge.getModeShuffle,img=img_mode_shuffle}, 
				{active=marioChallenge.getModeSlippery,img=img_mode_slippery}, 
				{active=marioChallenge.getModeTimer,img=img_mode_timer}, 
				{active=marioChallenge.getModeRinka,img=img_mode_rinka}, 
				{active=marioChallenge.getModeMirror,img=img_mode_mirror}
			  };
	
	if(mcTable.mode_rinka and not isOverworld) then
		rinka_exclude = {}
		rinka_exclude[210] = true;
		rinka_exclude[258] = true;
		rinka_exclude[138] = true;
		rinka_exclude[88] = true;
		rinka_exclude[33] = true;
		rinka_exclude[10] = true;
		rinka_exclude[103] = true;
		rinka_exclude[274] = true;
		rinka_exclude[152] = true;
		rinka_exclude[252] = true;
		rinka_exclude[251] = true;
		rinka_exclude[253] = true;
		rinka_exclude[278] = true;
		rinka_exclude[210] = true;
		rinka_counter = 0;
	end
	
	--Fresh Mario Challenge - load the intro level!
	if(isOverworld and isIntro and mcTable.playIndex == -2) then
		mcTable.playIndex = -1;
		mcTable.isIntro = true;
		loadLevel(introLevel, mcTable.hubLocation);
		return;
	end
	
	if(isOverworld) then
		flushData();
	end
	if not isOverworld and (Level.filename() == "intro.lvl" or Level.filename() == "outro.lvl") then
		cleanUp()
		return;
	end
	
	if isWinning() and isOverworld then
		if(mcTable.config_lives >= 0) then
			mem(0x00B2C5AC, FIELD_FLOAT, mcTable.config_lives)
		else
			mem(0x00B2C5AC, FIELD_FLOAT, 99)
		end
		loadNextLevel()
	else
		registerEvent(marioChallenge, "onExitLevel", "onExitLevel", false)
		registerEvent(marioChallenge, "onHUDDraw", "onHUDDraw", false)
		registerEvent(marioChallenge, "onCameraUpdate", "onCameraUpdate", false)
		registerEvent(marioChallenge, "onTick", "onTick", false)
		registerEvent(marioChallenge, "onInputUpdate", "onInputUpdate", true)
		
		timer = 400
		selectKeyDown = 0
		defs = API.load("expandedDefines")
		textblox = API.load("textblox")
		eventu = API.load("eventu")
		
		if not mcTable.loadInProgress then
			if isOverworld then
				-- We're going to trigger loading, so flag that it's in progress so we don't get stuck re-loading forever
				mcTable.loadInProgress = true;
				loadNextLevel()
			end
		else
			if (not isOverworld) then
				-- If we're not in the overworld anymore, loading finished and we can re-arm
				mcTable.loadInProgress = false;
			end
		end
	end
end

function marioChallenge.onInitAPI()
	if mcData:get("active") == "1" then
		mcData:set("active","");
		mcData:save();
		marioChallenge.Activate();
	end
end

return marioChallenge