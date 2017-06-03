local klonoa = API.load("klonoa")
local pnpc = API.load("pnpc")
local colliders = API.load("colliders")

klonoa.ReplaceGrabbedNPC[1] = 89;
klonoa.ReplaceGrabbedNPC[27] = 242;

function onStart()
	player.character = 9
end

function onTick()
	--Manage effect sizes
	for _,v in ipairs(Animation.get()) do
		if(v.id == 4 or v.id == 53) then
			v.width,v.height = 60,56;
			v.animationFrame = 0;
			v.subTimer = 0;
		elseif(v.id == 22 or v.id == 127) then
			v.width,v.height = 64,64;
			v.animationFrame = 0;
			v.subTimer = 0;
		end
	end

	--Manage NPCs
	
	for _,v in ipairs(NPC.get({94,27},-1)) do
		if(v.id == 94) then --Lolo
			if(player.x > v.x) then
				v.direction = 1;
			else
				v.direction = -1;
			end
		elseif(v.id == 27 and v:mem(0x136,FIELD_WORD) == 0 and v:mem(0x64,FIELD_WORD) == 0) then --Flying Moo
			local n = pnpc.wrap(v);
			local s = 1;
			if(n.data.acc == nil) then
				n.data.spd = s;
				n.data.acc = true;
				n.data.passedzero = true;
			end
				if(n.data.passedzero and (n.data.spd < -s or n.data.spd > s)) then
					n.data.acc = n.data.spd < -s;
					n.data.passedzero = false;
				end
				if(n.data.acc) then
					n.data.spd = n.data.spd + 0.01;
				else
					n.data.spd = n.data.spd - 0.01;
				end
				if(n:mem(0x0A,FIELD_WORD) == 2 or n:mem(0x0E,FIELD_WORD) == 2) then -- collides with floor or ceiling
					n.data.acc = n:mem(0x0E,FIELD_WORD) == 2;
					n.data.spd = 0;
					n.data.passedzero = false;
				end
				if(n.data.acc and n.data.spd >= 0) or (not n.data.acc and n.data.spd <= 0) then
					n.data.passedzero = true;
				end
				n.speedY = n.data.spd;
		end
	end
end