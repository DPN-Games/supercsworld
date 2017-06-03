local marioChallenge = API.load("marioChallenge2")
local colliders = API.load("colliders")
local classExpander = API.load("classExpander")

local function loadMCImage(name)
	return Graphics.loadImage(Misc.resolveFile(name) or Misc.resolveFile("graphics/luaResources/marioChallenge/"..name))
end
local img_reroll = loadMCImage("mc-rerolls.png");
local img_life = loadMCImage("mc-lives.png");
local img_levels = loadMCImage("mc-stages.png");
local img_inf = loadMCImage("mc-infinite.png");

local img_mode_ohko = loadMCImage("mc-mode-ohko.png");
local img_mode_slippery = loadMCImage("mc-mode-slippery.png");
local img_mode_rinka = loadMCImage("mc-mode-rinka.png");
local img_mode_timer = loadMCImage("mc-timer.png");
local img_mode_shuffle = img_reroll;
local img_mode_mirror = loadMCImage("mc-mirror.png");


local modes = {
				"mariochallenge-onehitmode", 
				"mariochallenge-randomcharacters", 
				"mariochallenge-slippery", 
				"mariochallenge-timer", 
				"mariochallenge-rinkas",
				"mariochallenge-mirror"
			  };

local img_uparrow = loadMCImage("mc-up.png");
local img_downarrow = loadMCImage("mc-down.png");

local img_resetblock = Graphics.loadImage(Misc.resolveFile("reset-block.png"))

local c_levels = colliders.Box(-198288, -200192, 32, 32);
local c_lives = colliders.Box(-198064, -200192, 32, 32);
local c_reroll = colliders.Box(-197840, -200192, 32, 32);

local active_settings = nil;
local settingsTimer = 0;

local oldkeys = {up = false, down = false}
local holdkeys = { up = 0, down = 0 }

local arrowCounter = 0;

local firstFrame = true;
local switchMuteTimer;

local modemap = {
				  ["mariochallenge-onehitmode"] = {get = marioChallenge.getModeOHKO, set = marioChallenge.setModeOHKO, img = img_mode_ohko},
				  ["mariochallenge-randomcharacters"] = {get = marioChallenge.getModeShuffle, set = marioChallenge.setModeShuffle, img = img_mode_shuffle},
				  ["mariochallenge-rinkas"] = {get = marioChallenge.getModeRinka, set = marioChallenge.setModeRinka, img = img_mode_rinka},
				  ["mariochallenge-slippery"] = {get = marioChallenge.getModeSlippery, set = marioChallenge.setModeSlippery, img = img_mode_slippery},
				  ["mariochallenge-timer"] = {get = marioChallenge.getModeTimer, set = marioChallenge.setModeTimer, img = img_mode_timer},
				  ["mariochallenge-mirror"] = {get = marioChallenge.getModeMirror, set = marioChallenge.setModeMirror, img = img_mode_mirror}
				};
				
local sign;

local function MuteSwitches()
	Audio.sounds[32].muted = true;
	switchMuteTimer = 10;
end
				
function onStart()
	Audio.MusicVolume(42)
	
	MuteSwitches();
	
	--Convert the sign a lua object. Prevents collision bugs.
	for _,v in ipairs(Block.get(172)) do
		sign = {x=v.x,y=v.y};
		v:remove();
	end
	
	for _,v in ipairs(Block.get(283)) do
		local s = v:mem(0x0C, FIELD_STRING).str;
		if(modemap[s] ~= nil and modemap[s].get()) then
			v:hit();
			modemap[s].set(false); --Will be re-activated by hit
		end
	end
end

function onInputUpdate()
	if (mem(0x00B250E2, FIELD_BOOL) or Misc.isPausedByLua()) then
		oldkeys.up = player.upKeyPressing;
		oldkeys.down = player.downKeyPressing;
		
		return;
	end

	if(active_settings ~= nil) then
		
		if(player.upKeyPressing) then
			holdkeys.up = holdkeys.up + 1;
		else
			holdkeys.up = 0;
		end
		
		if(player.downKeyPressing) then
			holdkeys.down = holdkeys.down + 1;
		else
			holdkeys.down = 0;
		end
	
		player.leftKeyPressing = false;
		player.rightKeyPressing = false;
		player.speedX = (active_settings.x - player.width*0.5 - player.x)/5;
		player.speedY = 0;
		settingsTimer = 64;
		
		if(holdkeys.up > 48) then
			oldkeys.up = false;
		end
		if(holdkeys.down > 48) then
			oldkeys.down = false;
		end
		
		if(not oldkeys.up and player.upKeyPressing) then
			local newval = active_settings.getfunc()+1;
			if(newval >= 100 or newval == 0) then
				if(newval == 100) then
					Audio.playSFX(74);
				end
				newval = -1; --Unlimited
			else
					Audio.playSFX(74);
			end
			active_settings.setfunc(newval);
		end
		if(not oldkeys.down and player.downKeyPressing) then
			local newval = active_settings.getfunc()-1;
			if(newval < -1) then
				newval = 99;
				Audio.playSFX(74);
			elseif(newval < active_settings.minval) then
				newval = active_settings.minval;
			else
				Audio.playSFX(74);
			end
			active_settings.setfunc(newval);
		end
		oldkeys.up = player.upKeyPressing;
		oldkeys.down = player.downKeyPressing;
		
		player.upKeyPressing = false;
		player.downKeyPressing = false;
		arrowCounter = arrowCounter + 1;
	else
		oldkeys.up = player.upKeyPressing;
		oldkeys.down = player.downKeyPressing;
		arrowCounter = 0;
	end
end

local pipetimer = 0;
function onTick()
	if(switchMuteTimer > 0) then
		switchMuteTimer = switchMuteTimer-1;
		if(switchMuteTimer == 0) then
			Audio.sounds[32].muted = false;
		end
	end

	if player.y > -200000 then
		player.speedY = -20;
		player.y = player.y - 4;
		playSFX(24)
	end
	
	if(settingsTimer > 0) then
		settingsTimer = settingsTimer - 1;
	end
	
	if(settingsTimer == 0) then
		if(player:isGroundTouching()) then
			if(colliders.collide(player, c_reroll)) then
				active_settings = {x = c_reroll.x+c_reroll.width*0.5, setfunc = marioChallenge.setConfigRerolls, getfunc = marioChallenge.getConfigRerolls, minval = 0, img = img_reroll}
			elseif(colliders.collide(player, c_lives)) then
				active_settings = {x = c_lives.x+c_lives.width*0.5, setfunc = marioChallenge.setConfigLives, getfunc = marioChallenge.getConfigLives, minval = 0, img = img_life}
			elseif(colliders.collide(player, c_levels)) then
				active_settings = {x = c_levels.x+c_levels.width*0.5, setfunc = marioChallenge.setConfigLevels, getfunc = marioChallenge.getConfigLevels, minval = 1, img = img_levels}
			else
				active_settings = nil;
			end
		else
			active_settings = nil;
		end
	elseif(not player:isGroundTouching()) then
		active_settings = nil;
	end
	
	if(marioChallenge.LevelCount() == 0) then
		if(player:mem(0x15E, FIELD_WORD) == 1 and player:mem(0x122, FIELD_WORD) == 3 and player:mem(0x124, FIELD_DFLOAT) > 0) then
			if(pipetimer == 0) then
					Text.showMessageBox("Uh oh! You don't have any valid levels installed! Download some episodes and try again!")
					playSFX(17);
			end
			player:mem(0x124, FIELD_DFLOAT, 2);
			pipetimer = pipetimer + 1;
			if(pipetimer > player.height+8) then
				player:mem(0x122, FIELD_WORD, 0)
				player:mem(0x15E, FIELD_WORD, 0)
				player:mem(0x124, FIELD_DFLOAT,0)
				pipetimer = 0;
			end
		else
			pipetimer = 0;
		end
	end
end

function onExitLevel()
	Audio.MusicVolume(64)
end

local function drawUI(x, y, image, text, scene)
	if(scene == nil) then
		scene = false;
	end
	if(text ~= nil and text ~= "nil") then
		text = tostring(text);
		Graphics.draw{type = RTYPE_IMAGE, x=x, y=y, image=image, isSceneCoordinates = scene};
		Graphics.draw{type = RTYPE_IMAGE, x=x+24, y=y+1, image=Graphics.sprites.hardcoded["33-1"].img, isSceneCoordinates = scene};
		if(text == "-1") then
			Graphics.draw{type = RTYPE_IMAGE, x=x+64, y=y, image=img_inf, isSceneCoordinates = scene};
		else
			Graphics.draw{type = RTYPE_TEXT, x=x+82-(18*#text), y=y+1, text=text, fontType = 1, isSceneCoordinates = scene};
		end
	end
end

function onEvent(event)
	if(modemap[event] ~= nil) then
		modemap[event].set(not modemap[event].get());
	elseif(event == "mariochallenge-reset") then
		MuteSwitches();
		
		--Disable mode switches
		for _,v in ipairs(Block.get(282)) do
			local s = v:mem(0x0C, FIELD_STRING).str;
			if(modemap[s] ~= nil and modemap[s].get()) then
				v:hit();
			end
		end
		
		marioChallenge.resetConfigLevels();
		marioChallenge.resetConfigLives();
		marioChallenge.resetConfigRerolls();
		Audio.playSFX(61);
		Defines.earthquake = 4;
	end
end

function onDraw()
	--Draw hardcoded HUD elements properly
	if(firstFrame) then
		firstFrame = false;
		return;
	end
	
	if(sign) then
		Graphics.draw{type = RTYPE_IMAGE, x=sign.x, y=sign.y, image=Graphics.sprites.block[172].img, isSceneCoordinates = true, priority = -45};
	end
	
	for _,v in ipairs(Block.get({680,283,282})) do
		if(v.id == 680 and v:mem(0x0C, FIELD_STRING).str == "mariochallenge-reset") then --Reset block
			Graphics.draw{type = RTYPE_IMAGE, x=v.x, y=v.y+v:mem(0x56,FIELD_WORD), image=img_resetblock, isSceneCoordinates = true, priority = -10};
		elseif(v.id == 283 or v.id == 282 and modemap[v:mem(0x0C, FIELD_STRING).str]) then
			Graphics.draw{type = RTYPE_IMAGE, x=v.x+8, y=v.y+v:mem(0x56,FIELD_WORD)-20, image=modemap[v:mem(0x0C, FIELD_STRING).str].img, isSceneCoordinates = true, priority = -10};
		end
	end
	
	if(active_settings ~= nil) then
		local yoff = 8*math.sin(arrowCounter*0.1);
		Graphics.draw{type = RTYPE_IMAGE, x=active_settings.x-8, y=-200260+yoff, image=img_uparrow, isSceneCoordinates = true};
		Graphics.draw{type = RTYPE_IMAGE, x=active_settings.x-8, y=-200164-yoff, image=img_downarrow, isSceneCoordinates = true};
		drawUI(active_settings.x-41,-200228,active_settings.img,active_settings.getfunc(), true)
	end
	
	local x = 800-96;
	local y = 600-72;
	drawUI(x,y,img_reroll,marioChallenge.getConfigRerolls())
	drawUI(x,y+24,img_life,marioChallenge.getConfigLives())
	drawUI(x,y+48,img_levels,marioChallenge.getConfigLevels())
	
	x = 800-32;
	local xoff = 0;
	for i = #modes,1,-1 do
		if(modemap[modes[i]].get()) then
			Graphics.draw{type = RTYPE_IMAGE, x=x-xoff*20, y=600-96, image=modemap[modes[i]].img};
			xoff = xoff + 1;
		end
	end
end