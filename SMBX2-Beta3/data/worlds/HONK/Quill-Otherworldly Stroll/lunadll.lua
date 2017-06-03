local rng = API.load("rng")

function onStart()
	player.character = 11
	Defines.coin5Value = 1
end

function onTick()
    random = rng.randomInt(1,5)
	for _, bubble in pairs(NPC.get(202, player.section)) do
		if random == 1 then
			bubble.id = 210
		end
		if random > 2 then
			bubble.id = 0
		end
	end
end