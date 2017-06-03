local playerManager = API.load("playerManager")
local marioChallenge = API.load("marioChallenge2")
local helpfulCheats = API.load("helpfulCheats")

if (not isOverworld) then
	local newBlocks = API.load("newBlocks")
	local starman = API.load("NPCs/starman")
	local bonyBeetle = API.load("NPCs/bonyBeetle")
	local maverickThwomp = API.load("NPCs/maverickThwomp")
	local booCircle = API.load("NPCs/booCircle")
	local rebound = API.load("NPCs/rebound")
	local magikoopa = API.load("NPCs/magikoopa")
	local keyhole = API.load("Tweaks/keyhole")
	local tweaks = API.load("tweaks")
end

local firstTick = true
local globalData = Data(Data.DATA_GLOBAL, "systemData")

if firstTick then
	--Do stuff that has to be done on the VERY first tick of all time here
	if isOverworld and Audio.MusicTitle() == globalData:get("loadedIntroSong") then
		Audio.MusicStop()
		Audio.ReleaseStream(-1)
	end
	if not isOverworld then
		if Section(player.section).musicID == 0 then
			Audio.MusicStop()
			Audio.ReleaseStream(-1)
		end
	end
	firstTick = false
end
