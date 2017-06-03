local pnpc = API.load("pnpc")
local defs = API.load("expandedDefines")
local configFileReader = API.load("configFileReader")
local npcconfig = API.load("npcconfig")
local npcManager = API.load("npcManager")
local rng = API.load("rng")
local particles = API.load("particles")
local starmanMusicChunk = nil

local starman = {}

starman.inStar = false

local starmanSettings = {id=293, gfxheight = 32, gfxwidth = 32, width = 32, height = 32, framespeed = 8, frames = 2, framestyle = 0}

npcManager.setNpcSettings(starmanSettings)

starman.sfxFile = Misc.resolveFile("starman.ogg") or Misc.resolveFile("sound/extended/starman.ogg")
starman.loopCount = starman.loopCount or 4
starman.ignore = {};
starman.ignore[108] = true;
local starSoundObject
local starSparkleObject
local starSparkleObject2
local sparklesize = nil;
local used_donthurtme = Defines.cheat_donthurtme;

local musicvolcache;

function starman.stopTheStar()
	if not starman.inStar then
		return
	end
	starman.inStar = false
	--Audio.MusicResume()
	--Audio.ReleaseStream(-1)
	Audio.MusicVolume(musicvolcache);
	player:mem(0x02, FIELD_WORD, 0)
	
	Defines.cheat_donthurtme = used_donthurtme;
	
	if(starSparkleObject ~= nil) then
		starSparkleObject.enabled = false;
	end
	if(starSparkleObject2 ~= nil) then
		starSparkleObject2.enabled = false;
	end
	if starSoundObject ~= nil then
		starSoundObject:Stop()
	end
end

function starman.startTheStar()
	if starman.inStar then
		starman.stopTheStar()
	end
	used_donthurtme = Defines.cheat_donthurtme;
	Defines.cheat_donthurtme = true
	starman.inStar = true
	--Audio.SeizeStream(-1)
	
	
	--Audio.MusicPause()
	starSoundObject = Audio.SfxPlayObj(starmanMusicChunk, starman.loopCount)
	if(starSparkleObject == nil) then
		starSparkleObject = particles.Emitter(0,0,Misc.resolveFile("p_starman_sparkle.ini") or Misc.resolveGraphicsFile("luaResources\\starman\\p_starman_sparkle.ini"));
	else
		starSparkleObject.enabled = true;
	end
	if(starSparkleObject2 == nil) then
		starSparkleObject2 = particles.Emitter(0,0,Misc.resolveFile("p_starman_sparkle.ini") or Misc.resolveGraphicsFile("luaResources\\starman\\p_starman_sparkle.ini"));
		starSparkleObject2:setParam("blend","alpha");
		starSparkleObject2:setParam("col",particles.ColFromHexRGBA(0xFFFFFFFF));
	else
		starSparkleObject2.enabled = true;
	end
	
	starSparkleObject:Attach(player);
	starSparkleObject2:Attach(player);
end

local function checkStarStatus()
	if starSoundObject ~= nil then
		if (starSoundObject:IsPlaying()) then -- Star will stop if music stops
			if(Audio.MusicVolume() ~= 0) then
				musicvolcache = Audio.MusicVolume()
				Audio.MusicVolume(0);
			end
			if(not Defines.cheat_donthurtme) then
				used_donthurtme = not used_donthurtme;
			end
			
			Defines.cheat_donthurtme = true
			for _, w in pairs(NPC.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
				if defs.NPC_HITTABLE_MAP[w.id] and starman.ignore[w.id] ~= true then
					w:harm(HARM_TYPE_EXT_HAMMER)
				end
			end
		elseif (not starSoundObject:IsPlaying()) and (starman.inStar) then
			starman.stopTheStar()
		end
		if (player:mem(0x13C, FIELD_FLOAT) ~= 0) and (starman.inStar) then
			starman.inStar = false
			Audio.ReleaseStream(-1)
			if starSoundObject ~= nil then
				starSoundObject:Stop()
			end
		end
	end
end

function starman.onInitAPI()
	registerEvent(starman, "onTick", "onTick", false)
	registerEvent(starman, "onDraw", "onDraw", false)
	registerEvent(starman, "onExitLevel", "onExitLevel", false)
        starmanMusicChunk = Audio.SfxOpen(starman.sfxFile)
end

function starman.onDraw()
	if(starSoundObject ~= nil) then
		if(mem(0x00B250E2,FIELD_BOOL) or Misc.isPausedByLua()) then
			starSoundObject:Pause();
		else
			starSoundObject:Resume();
		end
	end
	if(starSparkleObject ~= nil and starSparkleObject2 ~= nil) then
		if(sparklesize == nil or player.width ~= sparklesize.w or player.height ~= sparklesize.h) then
			sparklesize = {w=player.width,h=player.height};
			local wid = "-"..(sparklesize.w*0.5)..":"..(sparklesize.w*0.5);
			local hei = "-"..(sparklesize.h*0.5)..":"..(sparklesize.h*0.5)
			starSparkleObject:setParam("xOffset",wid);
			starSparkleObject2:setParam("xOffset",wid);
			starSparkleObject:setParam("yOffset",hei);
			starSparkleObject2:setParam("yOffset",hei);
		end
		
		starSparkleObject:Draw(-24);
		starSparkleObject2:Draw(-26);
		
		if(not starSparkleObject.enabled and starSparkleObject:Count() == 0 and not starSparkleObject2.enabled and starSparkleObject2:Count() == 0) then
			starSparkleObject = nil;
			starSparkleObject2 = nil;
			sparklesize = nil;
		end
	end
end

function starman.onTick()
	if(not isOverworld) then
		for _, v in pairs(NPC.get(293, player.section)) do
			v.friendly = true
			if v:mem(0x40, FIELD_WORD) == 0 and v:mem(0x124, FIELD_WORD) ~= 0 and v:mem(0x64, FIELD_WORD) ~= -1 then
				starmanSpawn = pnpc.wrap(v)
				starmanSpawn.speedX = starmanSpawn.direction
				if starmanSpawn.collidesBlockBottom then
					starmanSpawn.speedY = -8
				elseif starmanSpawn.collidesBlockUp then
					starmanSpawn.speedY = 2
				end
			end
		end
		for _, w in pairs(NPC.getIntersecting(player.x, player.y, player.x + player.width, player.y + player.height)) do
			if w.id == 293 and w:mem(0x40, FIELD_WORD) == 0 and w:mem(0x124, FIELD_WORD) ~= 0 then
				w:kill(9)
				starman.startTheStar()
			end
		end
		checkStarStatus()
	end
end

function starman.onExitLevel()
	starman.stopTheStar();
end

return starman
