Audio.SeizeStream(1)
Audio.MusicOpen("EpicBattleFantasyIII-Wings.spc")
Audio.MusicVolume(0)

local timer=0

function onInputUpdate() --onTick does not seem to work for some reason.
	timer=timer+1
	if Audio.MusicTitleTag() ~= "wings.txt" then
	Audio.SeizeStream(1)
	Audio.MusicOpen("EpicBattleFantasyIII-Wings.spc")
	Audio.MusicVolume(64)
	end
	if timer > 5340 then
		Audio.MusicStopFadeOut(4200)
	else
		Audio.MusicPlay()
	end
	if timer > 5740 then
		Audio.MusicStop()
	end
	local myPlayer = Player(4)
	if myPlayer:mem(0x10A, FIELD_WORD) == 3 then
		myPlayer:mem(0x10A, FIELD_WORD, 2)
	end
end