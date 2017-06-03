function onStart()
	player.character = 13
end

function onTick()
    tableofRinkaShooters = NPC.get (211, -1)
	for k,v in pairs (NPC.get(211, -1)) do
		if(v.ai1 == 0) then
			v.ai1 = 199
		end
	end
	for k,v in pairs(NPC.get(39, -1)) do
		if(v.ai2 == 0) then
			v.ai2 = 249
		end
	end
end

function onEventDirect(butt, calledEvent)
	if (calledEvent == "Fairy Talk") then
		Audio.playSFX("hey.ogg");
	end
	if (calledEvent == "Fairy Talk 2") then
		Audio.playSFX("listen.ogg");
	end
	if (calledEvent == "Fairy Talk 3") then
		Audio.playSFX("hello.ogg");
	end
	if (calledEvent == "Fairy Talk 4") then
		Audio.playSFX("look.ogg");
	end
	if (calledEvent == "Fairy Talk 6") then
		Audio.playSFX("watchout.ogg");
	end	
	if (calledEvent == "Fairy Talk 7") then
		Audio.playSFX("listen.ogg");
	end
	if (calledEvent == "Fairy Talk 8") then
		Audio.playSFX("hello.ogg");
	end
	if (calledEvent == "dwagon coins") then
		Audio.playSFX("xenosecret.ogg");
	end	
end