function onStart()
	player.character = 8
	player.speedX = -1
end

function onTick()
	local peach = NPC.get(121, -1)
	for k, v in pairs(peach) do
		v.speedY = v.speedY * 0.98
	end
	local foroze = NPC.get(43, -1)
	for k, v in pairs(foroze) do
		v.speedY = v.speedY * 1.02
		if(v.y <= -61342) then
			v.speedY = v.speedY * 0.95
		end
	end
end