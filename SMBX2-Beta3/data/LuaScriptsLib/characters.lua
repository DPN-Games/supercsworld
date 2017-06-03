--characters.lua
--v1.1.2
--Created by Horikawa Otane, 2015

local characters = {}

local intIds = {}
intIds["mario"] = 1
intIds["luigi"] = 2
intIds["peach"] = 3
intIds["toad"] = 4
intIds["link"] = 5

local playerCharacters = {"mario", "luigi", "peach", "toad", "link"}


local function resetCharacter(characterId, powerupId)
	Level.loadPlayerHitBoxes(characterId, powerupId, Misc.resolveFile("character_defaults\\" .. playerCharacters[characterId] .. "-" .. tostring(powerupId) .. ".ini"))
end

local function loadAllHitBoxes()
	for _, characterName in pairs(playerCharacters) do
		for i = 1, 7, 1 do
			local theIniFile = Misc.resolveFile(characterName .. "-" .. i .. ".ini")
			if  theIniFile ~= nil then
				Level.loadPlayerHitBoxes(intIds[characterName], i, theIniFile)
			else
				resetCharacter(intIds[characterName], i)
			end
		end
	end
end

function characters.onInitAPI()
	loadAllHitBoxes()
end

return characters