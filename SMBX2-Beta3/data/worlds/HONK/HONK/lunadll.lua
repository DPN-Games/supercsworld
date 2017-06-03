local pm = API.load("playerManager");

local characterLevels = {}
characterLevels["Enjl-Operation Demon.lvl"] = Graphics.loadImage("challengers\\ninjabomberman.png")
characterLevels["Enjl-Revenge Of The King.lvl"] = Graphics.loadImage("challengers\\dedede.png")
characterLevels["Enjl-Super Bowser Bros.lvl"] = Graphics.loadImage("challengers\\bowser.png")
characterLevels["Hoeloe-Gaseous Lizard.lvl"] = Graphics.loadImage("challengers\\snake.png")
characterLevels["Quill-Return to Zebes.lvl"] = Graphics.loadImage("challengers\\samus.png")
characterLevels["Quill-Otherworldly Stroll.lvl"] = Graphics.loadImage("challengers\\rosalina.png")
characterLevels["Quill-Zelda's Super Sexy Pyramid Trip.lvl"] = Graphics.loadImage("challengers\\zelda.png")
characterLevels["Willhart-HeavyAndMetal.lvl"] = Graphics.loadImage("challengers\\megaman.png")
characterLevels["Willhart-GuidanceRocks.lvl"] = Graphics.loadImage("challengers\\wario.png")
characterLevels["Hoeloe-Dream Traveller.lvl"] = Graphics.loadImage("challengers\\klonoa-alt-2.png")
characterLevels["Willhart-Calm.lvl"] = Graphics.loadImage("challengers\\juni.png")
characterLevels["Pyro-ReturnOfTheRinka.lvl"] = Graphics.loadImage("challengers\\ultimaterinka.png")
characterLevels["Willhart-Shogun.lvl"] = Graphics.loadImage("challengers\\example-1.png")
characterLevels["Willhart-ForestSanctuary.lvl"] = Graphics.loadImage("challengers\\broadsword.png")

local characterMap = {}
characterMap["Enjl-Operation Demon.lvl"] = 10
characterMap["Enjl-Super Bowser Bros.lvl"] = 8
characterMap["Hoeloe-Gaseous Lizard.lvl"] = 12
characterMap["Quill-Otherworldly Stroll.lvl"] = 11
characterMap["Quill-Return to Zebes.lvl"] = 18
characterMap["Quill-Zelda's Super Sexy Pyramid Trip.lvl"] = 13
characterMap["Willhart-GuidanceRocks.lvl"] = 7
characterMap["Willhart-HeavyAndMetal.lvl"] = 6
characterMap["Hoeloe-Dream Traveller.lvl"] = 9
characterMap["Willhart-Calm.lvl"] = 17
characterMap["Pyro-ReturnOfTheRinka.lvl"] = 14
characterMap["Willhart-Shogun.lvl"] = 1
characterMap["Willhart-ForestSanctuary.lvl"] = 16

local showFavourites = true
local isViewingFav = false

function onStart()
	if(player.section == 0) then
		pm.setCostume(CHARACTER_MARIO,nil);
	end
end

function onTick()
	hasDetectedAWarp = false
	for _, warp in pairs(Warp.getIntersectingEntrance(player.x - .5 * player.width, player.y - .5 * player.height, player.x + 1.5 * player.width, player.y + 1.5 * player.height)) do
		hasDetectedAWarp = true
		if characterLevels[warp.levelFilename] ~= nil and showFavourites then
			isViewingFav = true
			Graphics.drawImageWP(characterLevels[warp.levelFilename], 0, 0, 6)
			Text.printWP("Press Tanooki to Toggle View", 148, 568, 7)
			if(warp.levelFilename == "Willhart-Shogun.lvl") then
				pm.setCostume(CHARACTER_MARIO,"Talkhaus-Horikawa");
			end
		end
		if warp.levelFilename ~= "" then
			player.powerup = PLAYER_SMALL --no powerups
			player.reservePowerup = 0
			playerStruct = Player.getTemplates()
			for _, i in pairs(playerStruct) do
				i.powerup = PLAYER_SMALL
				i.reservePowerup = 0
			end
			player:mem(0x108, FIELD_WORD, 0) --no yoshi or boots
			for _, i in pairs(playerStruct) do
				i:mem(0x108, FIELD_WORD, 0)
			end
		end
		if characterMap[warp.levelFilename] ~= nil then
			lastChar = player:mem(0xF0, FIELD_WORD)
			newChar = characterMap[warp.levelFilename]
			-- If this warp has a character specified, and it's not the character that we already are
			if (newChar ~= nil) and (newChar ~= false) and (newChar ~= lastChar) then
				-- Set character
				player:mem(0xF0, FIELD_WORD, newChar)
				-- Start powerup blinking, just because
				player:mem(0x140, FIELD_WORD, 30)
			end
		end
	end
	if not hasDetectedAWarp then
		showFavourites = true
		isViewingFav = false
	end
end

function onKeyDown(keycode)
	if keycode == KEY_RUN and isViewingFav then
		showFavourites = not showFavourites
	end
end