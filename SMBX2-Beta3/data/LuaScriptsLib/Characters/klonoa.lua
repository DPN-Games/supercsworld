--[[
Things to fix:
- See clean up notes.
]]

local klonoa = {};

local colliders = API.load("colliders")
local horikawaTools = API.load("horikawaTools")
local xmem = API.load("xmem");
local pnpc = API.load("pnpc");
local npcconfig = API.load("npcconfig");
local eventu = API.load("eventu");
local playerManager = API.load("playerManager");

local grabbed = 0;
local grabbedNPC;
local pressedGrab = false;
local runspeed = 6;

function klonoa.onInitAPI()
	registerEvent(klonoa, "onInputUpdate", "onInputUpdate", false)
	registerEvent(klonoa, "onLoop", "onLoop", true)
	registerEvent(klonoa, "onNPCKill", "onNPCKill", true)
	registerEvent(klonoa, "onLevelExit", "onLevelExit", true)
	registerEvent(klonoa, "onDraw", "onDraw", true)
	registerEvent(klonoa, "onHUDDraw", "onHUDDraw", true)
end

local ringbox = colliders.Box(0, 0, 32, 32);

playerManager.registerGraphic(CHARACTER_KLONOA, "ringshot", "ringShot.png");
local sprite = {sheet = "ringshot", width = 64, height = 64}

playerManager.registerGraphic(CHARACTER_KLONOA, "ringflash", "ringFlash.png");
local flash = {sheet = "ringflash", width = 64, height = 64}

playerManager.registerSound(CHARACTER_KLONOA, "ringshot", "klonoa_ring.ogg");
playerManager.registerSound(CHARACTER_KLONOA, "die", "klonoa_die.ogg");
playerManager.registerSound(CHARACTER_KLONOA, "flutter", "klonoa_flutter.ogg");
playerManager.registerSound(CHARACTER_KLONOA, "grab", "klonoa_grab.ogg");
playerManager.registerSound(CHARACTER_KLONOA, "hurt", "klonoa_hurt.ogg");
playerManager.registerSound(CHARACTER_KLONOA, "throw", "klonoa_throw.ogg");
playerManager.registerSound(CHARACTER_KLONOA, "wahoo", "klonoa_wahoo.ogg");
playerManager.registerSound(CHARACTER_KLONOA, "yah", "klonoa_yah.ogg");

function sprite:drawFrame(x,y,i,j)
	Graphics.drawImageToSceneWP(playerManager.getGraphic(CHARACTER_KLONOA, self.sheet), x, y, self.width*i, self.height*j, self.width, self.height, -24);
end

flash.drawFrame = sprite.drawFrame;

local ringEffectFrame = -1;
local ringEffectDir = 0;
local effectFrame = -1;

local thrown = {};
local throwTimer = -1;
local vthrowTimer = -1;
local icecooldown = {};

local jumped = false;

local flaptimer = 0;
local flapped = false;
local flapdir = 1;

local function contains(tbl,val)
	for _,v in ipairs(tbl) do
		if(v == val) then
			return true;
		end
	end
	return false;
end

local function sign(a)
	if(a > 0) then return 1;
	elseif(a < 0) then return -1;
	else return 0; end
end

local grabNPCs = {31,32,238,22,158,159,45,279,278,134,241,195,26,49,154,155,156,157,96,263,35,193,191,40,296};
local ungrabNPCs = {284,47,18,44,21,39,199,15,200,86,181,84,85,87,189,72,208,71,164,74,162,210,203,180,37,275,205,93,8,52,51,74,245};
local veggies = {139,142,143,146,147,145,144,141,140,92};
local containers = {283}
local grass = {91}

klonoa.GrabableNPCs = {};
klonoa.UngrabableNPCs  = {};
klonoa.ReplaceGrabbedNPC = {};
for _,v in ipairs(grabNPCs) do
	klonoa.GrabableNPCs[v] = true;
end
for _,v in ipairs(ungrabNPCs) do
	klonoa.UngrabableNPCs[v] = true;
end

do --Replace koopas with their respective shells, and paragoombas with regular goombas
klonoa.ReplaceGrabbedNPC[176] = 172;
klonoa.ReplaceGrabbedNPC[173] = 172;

klonoa.ReplaceGrabbedNPC[76] = 5;
klonoa.ReplaceGrabbedNPC[4] = 5;

klonoa.ReplaceGrabbedNPC[177] = 174;
klonoa.ReplaceGrabbedNPC[175] = 174;

klonoa.ReplaceGrabbedNPC[161] = 7;
klonoa.ReplaceGrabbedNPC[6] = 7;

klonoa.ReplaceGrabbedNPC[123] = 115;
klonoa.ReplaceGrabbedNPC[111] = 115;

klonoa.ReplaceGrabbedNPC[122] = 114;
klonoa.ReplaceGrabbedNPC[110] = 114;

klonoa.ReplaceGrabbedNPC[124] = 116;
klonoa.ReplaceGrabbedNPC[112] = 116;

klonoa.ReplaceGrabbedNPC[109] = 113;
klonoa.ReplaceGrabbedNPC[121] = 113;

klonoa.ReplaceGrabbedNPC[167] = 166;
klonoa.ReplaceGrabbedNPC[244] = 1;
klonoa.ReplaceGrabbedNPC[243] = 242;
klonoa.ReplaceGrabbedNPC[3] = 2;
end

klonoa.forceHearts = true; --Convert super mushrooms into hearts
klonoa.forceRupees = true; --Convert coins into rupees

function klonoa.isHoldingObject()
	return player:xmem(0x154) > 0 and grabbedNPC ~= nil and grabbedNPC.isValid;
end

function klonoa.isOnGround()
	return player:xmem(0x146) ~= 0 or player:xmem(0x48) ~= 0 or player:xmem(0x176) ~= 0;
end

function klonoa.canFly()
	return player:xmem(0x16E) == -1 or player:xmem(0x16C) == -1;
end

function klonoa.isMovementLocked()
	return not (player:mem(0x122,FIELD_WORD) == 0 or player:mem(0x122,FIELD_WORD) == 7 or player:mem(0x122,FIELD_WORD) == 500);
end

local function replaceNPC(npc,id)
	npc:transform(id);
--[[
	npc.id = id;
	local w = npcconfig[npc.id].width;
	local h = npcconfig[npc.id].height;
	npc:xmem(0x90, w);
	npc:xmem(0x88, h);
	if(npcconfig[npc.id].gfxwidth ~= 0) then
		w = npcconfig[npc.id].gfxwidth;
	end
	if(npcconfig[npc.id].gfxheight ~= 0) then
		h = npcconfig[npc.id].gfxheight;
	end
	npc:xmem(0xB8, w);
	npc:xmem(0xC0, h);
	npc:xmem(0xE4, 0);]]
end

local function onGrab(npc)
	Audio.playSFX(playerManager.getSound(CHARACTER_KLONOA,"grab"));
	if(player.powerup == PLAYER_ICE) then
		if(npc.id ~= 263 and contains(horikawaTools.hittableNPCs,npc.id)) then
			npc:xmem(0xF0,npc.id);
			npc.id = 263
		end
	end
end

local fireballs = {};

local function onThrow(npc)
	if(npc.id == 263) then
		npc:xmem(0x100,1);
	end
end

local lastPlayerID = 0;
local shooting = false;

local climbing = false;
--local climbableNPC = {221,217,215,213,214,216,224,222,223,227,226,225,220,218,219};
--local climbableBGO = {186,185,184,183,182,181,180,179,178,177,176,175,174};

local function throwGrabbed(x,y,xspeed,yspeed)
	throw = true;
	grabbedNPC.x = x;
	grabbedNPC.y = y;
	grabbedNPC:xmem(0x12C,0);
	local x_s = nil;
	if(xspeed == 0) then x_s = grabbedNPC.x; end
	local y_s = nil;
	if(yspeed == 0) then y_s = grabbedNPC.y; end
	table.insert(thrown,{npc = grabbedNPC, speedx = xspeed, speedy = yspeed, x = x_s, y = y_s, power = player.powerup});
	Audio.playSFX(playerManager.getSound(CHARACTER_KLONOA,"throw"))
	onThrow(grabbedNPC);
	
	if(player.powerup == PLAYER_FIREFLOWER) then
		playSFX(42)
		local dir = player:xmem(0x106);
		local sx,sy;
		local vx,vy;
		local bx,by;
		if(xspeed ~= 0 and yspeed == 0) then
			sx = player.x+player.width/2 + (player.width/2)*dir
			sy = player.y + 8;
			vx = 3;
			vy = 0;
			by = sy;
		elseif(yspeed ~= 0 and xspeed == 0) then
			sx = player.x+player.width/2;
			sy = player.y + player.height;
			vx = 0;
			vy = 3;
			bx = sx;
		end
		local angle = math.sin(math.pi*0.25);
		eventu.setFrameTimer(12,function()
				table.insert(fireballs, {npc = pnpc.wrap(NPC.spawn(13,sx,sy,player.section)),speedx = dir*vx, speedy = vy, x = bx, y = by})
				table.insert(fireballs, {npc = pnpc.wrap(NPC.spawn(13,sx,sy,player.section)),speedx = dir*vx + vy*angle, speedy = vy+vx*angle})
				table.insert(fireballs, {npc = pnpc.wrap(NPC.spawn(13,sx,sy,player.section)),speedx = dir*vx + vy*-angle, speedy = vy+vx*-angle})
		end);
	end
	
	player:xmem(0xFE, 0);
	grabbedNPC = nil;
	grabbed = 0;
end

local dead = false;

function klonoa.onInputUpdate()
	--player:memdump(0x106,0x106)
	if(xmem.xmem(0x00B250E2) == -1) then pressedGrab = true; return end; --pause menu
	
	if(player.character ~= lastPlayerID) then
		jumped = true;
		flapped = true;
	end
	
	lastPlayerID = player.character;
	if(player.character == CHARACTER_KLONOA) then
		playerManager.winStateCheck()
		
		player:xmem(0x160, 2);
		player:xmem(0x162, 2);
		player:xmem(0x164, -1);
		
		ringbox.x = player.x + player.width/2 - ringbox.width/2 + player:xmem(0x106)*48;
		ringbox.y = player.y + 16;
		
		if(grabbedNPC ~= nil and not grabbedNPC.isValid) then
			grabbedNPC = nil;
			grabbed = 0;
			player:xmem(0x154,0)
		end		
		
		--update grabbed value
		if(grabbedNPC ~= nil) then
			for k,v in ipairs(NPC.get()) do
				if(grabbedNPC.__ref == v) then
					grabbed = k;
					player:xmem(0x154,k)
					break;
				end
			end
		end
	 
		--ringbox:Draw();
		--colliders.getHitbox(player):Draw();
		
	if(shooting or throwTimer >= 0 or dead or klonoa.isMovementLocked()) then
		player:xmem(0xF2,0);
		player:xmem(0xF4,0);
		player:xmem(0xF6,0);
		player:xmem(0xF8,0);
		player:xmem(0xFA,0);
		player:xmem(0xFC,0);
		player:xmem(0xFE,-1);
		player:xmem(0x100,0);
		player:xmem(0x144,1);	
		if(grabbedNPC ~= nil and grabbedNPC.isValid) then
			grabbedNPC:xmem(0x12C,1);
		end
		player:xmem(0x154, grabbed) 
		return;
	end
		
		if(player:xmem(0xFC) == -1 and player:xmem(0x108) == 0) then --Disable spinjump
			player:xmem(0xFC,0);
			player:xmem(0xFA,-1);
		end
		
		--[[
		local climbBGO = false;
		for _,v in ipairs(BGO.getIntersecting(player.x,player.y,player.x+player.width,player.y+player.height)) do
			if(contains(climbableBGO,v.id)) then
				climbBGO = true;
				break;
			end
		end
		local climbBGOTop = false;
		for _,v in ipairs(BGO.getIntersecting(player.x,player.y-player.height,player.x+player.width,player.y)) do
			if(contains(climbableBGO,v.id)) then
				climbBGOTop = true;
				break;
			end
		end
		
		local climbHit = climbBGO or colliders.collideNPC(player,climbableNPC);
		local climbTop = climbBGOTop or colliders.collideNPC(colliders.Box(player.x,player.y-player.height,player.width,player.height),climbableNPC);
		if((climbing or player:xmem(0xF2) == -1 or player:xmem(0xF4) == -1) and not klonoa.isHoldingObject() and (climbHit and (climbTop or climbing))) then
			player:xmem(0x40,3);
			climbing = true;
			jumped = false;
			flapped = false;
		elseif (not climbhit and not climbTop) then
			climbing = false;
		end
		
		if(climbHit and not climbTop and climbing) then
				player:xmem(0x40,2);
		end
				
		if(jumped) then
			climbing = false;
		end
	
		if(not climbing) then
			--player:xmem(0xF4,0) --Disable ducking
		end]]
		
		if(player:xmem(0x40) == 3 or player:xmem(0x40)==2) then
			jumped = false;
			flapped = false;
			climbing = true;
		else
			climbing = false;
		end
		
		player:xmem(0x00,0); --disable leaf double jump
		
		local throw = false;
		
		if(player:xmem(0xFA) ~= -1) then
			jumped = false;
		end
		
		if(klonoa.isOnGround() or player:mem(0x34, FIELD_WORD) == 2) then
			jumped = false;
			flapped = false;
		end
		
		if(player:xmem(0x108) ~= 0) then
			jumped = true;
		end
		
		if(player:xmem(0xFA) == -1 and not jumped) then --press jump key
			if(not klonoa.isOnGround() and not climbing and player:xmem(0x34) ~= 2 and not klonoa.canFly() and player:xmem(0x108) == 0) then --airborne and not climbing and not swimming and not flying and not riding anything
				if(klonoa.isHoldingObject()) then
					player.speedY = -9;
					vthrowTimer = 15;
					throwGrabbed(grabbedNPC.x, player.y+player.height-grabbedNPC.height, 0, 8)
					player:xmem(0xFE, -1);
					Audio.playSFX(playerManager.getSound(CHARACTER_KLONOA,"wahoo"))
					pressedGrab = true;
				elseif not flapped then
					Audio.playSFX(playerManager.getSound(CHARACTER_KLONOA,"flutter"));
					flaptimer = 40;
					flapped = true;
					flapdir = player:xmem(0x106);
				end
			end
			jumped = true;
		end
		
		if(flaptimer > 0) then
			throw = true;
			player.speedY = -((40-flaptimer)/15);
			if(player.powerup == PLAYER_LEAF or player.powerup == PLAYER_TANOOKIE) then
				player.speedY = player.speedY*1.75;
			end
			player:xmem(0x11C,player.speedY)
			flaptimer = flaptimer-1;
		end
		
		if(player:xmem(0xFE) == -1) then
			Defines.player_runspeed = runspeed;
		else
			Defines.player_runspeed = Defines.player_walkspeed;
		end
		
		if(player:xmem(0xFE) == -1 and player:xmem(0x108) == 0) then
			if not pressedGrab then 
				if(mem(0xB250E2, FIELD_WORD) ~= -1) then -- if messagebox not open 
					if(klonoa.isHoldingObject()) then
						throwGrabbed(player.x + (1+player:xmem(0x106))*player.width/2 + ((player:xmem(0x106)-1)/2)*grabbedNPC.width, player.y + 40 - grabbedNPC.height, 4*player:xmem(0x106), 0)
						throwTimer = 15;
						Audio.playSFX(playerManager.getSound(CHARACTER_KLONOA,"yah"));
					else
						throw = true;
						player:xmem(0xFE,0)
						
						if(not climbing and flaptimer <= 0 and player:xmem(0x16E) ~= -1 and (player:xmem(0x122) == 0 or player:xmem(0x122) == 7 or player:xmem(0x122) == 500)) then --if not climbing, not flapping, not flying and not being hurt/powering up
						
							eventu.setFrameTimer(1,function ()
								if(not klonoa.isHoldingObject()) then
									effectFrame = 0;
									ringEffectFrame = 0;
									ringEffectDir = player:xmem(0x106);
									eventu.setFrameTimer(3, 
										function() 
											effectFrame = effectFrame + 1;
											if(effectFrame >= 7 or effectFrame <= 0) then
												effectFrame = -1;
												eventu.breakTimer();
											end
										end, true)
										
									eventu.setFrameTimer(5, 
										function() 
											ringEffectFrame = ringEffectFrame + 1;
											if(ringEffectFrame >= 4) then
												ringEffectFrame = -1;
												eventu.breakTimer();
											end
										end, true)
									Audio.playSFX(playerManager.getSound(CHARACTER_KLONOA,"ringshot"));
								end
							end);
					
						end
					end
				else
					throw = true;
					player:xmem(0xFE,0)
				end
				pressedGrab = true;
			end
		else
			pressedGrab = false;
		end
		
		if not throw then 
			player:xmem(0xFE, -1);
		end
		
		if(grabbedNPC ~= nil and grabbedNPC.isValid) then
			grabbedNPC:xmem(0x12C,1);
		end
		player:xmem(0x154, grabbed)
	end
end

local cancelPowerupAnim = false;

local killednpcs = {}

function klonoa.onNPCKill(obj,npc,reason)
	if(player.character == CHARACTER_KLONOA) then
		if(reason == 9 and player.powerup == PLAYER_SMALL and contains({250,249,185,184,9},npc.id)) then
			cancelPowerupAnim = true;
			if(npc.id == 250) then
				playSFX(79)
			else
				playSFX(12)
			end
		end
	end
end

local hp = 1;

function klonoa.onLoop()
	if(player.character == CHARACTER_KLONOA) then
		if(player:xmem(0x13E) > 0) then
			if(not dead) then
				Audio.playSFX(playerManager.getSound(CHARACTER_KLONOA,"die"));
			end
			dead = true;
			return;
		else 
			dead = false; 
		end
		
		if(player:xmem(0x16) < hp and hp > 1 and not dead) then
			Audio.playSFX(playerManager.getSound(CHARACTER_KLONOA,"hurt"))
			if(hp == 2) then
				player:xmem(0x124,49);
			end
		end		
		
		hp = player:xmem(0x16);
		
		if(cancelPowerupAnim and player:xmem(0x122) == 1) then
			player:xmem(0x124,49);
			cancelPowerupAnim = false;
		end
		
		local winstate = Level.winState()
		
		
		-- THROW KEYS AT LOCKS MAKE THEM OPEN AND END LEVELS
		for _,trn in ipairs(thrown) do
			local v = trn.npc;
			if(v ~= nil and v.isValid and v.id == 31) then --KEYS ONLY PL0X
				local w = v.width*0.5;
				local h = v.height*0.5;
				
				if(w <= 0) then w = 1; end
				if(h <= 0) then h = 1; end
				
				for _, q in ipairs(BGO.getIntersecting(v.x+w*0.5, v.y + h * 0.5, v.x + w*1.5, v.y + h*1.5)) do
					if q.id == 35 and not q.isHidden and winstate == 0 then
						Level.winState(3)
						Audio.SeizeStream(-1)
						Audio.MusicStop()
						playSFX(31)
					end
				end
			end
		end
		
		local i = 1;
		while(i <= #thrown) do
			local v = thrown[i];
		
			if v == nil or not v.npc.isValid or v.npc.data.shouldRemove or v.npc:xmem(0x12A) < 1 then
				table.remove(thrown,i);
			else
				if(v.npc.data.shouldKill) then
					local bx = v.npc.x+v.npc.width/2;
					local by = v.npc.y+v.npc.height/2;
					local powr = v.power;
					local bnpc = v.npc;
					eventu.setFrameTimer(1, function()
						if(bnpc.isValid) then
							bnpc.data.shouldKill = false;
							bnpc:kill(8);
						end	
						if(powr == PLAYER_HAMMER) then
							Misc.doBombExplosion(bx,by,2);
						end
					end);
				end
				i = i + 1;
				v.npc.speedX = v.speedx;
				
				if(v.x ~= nil) then
					v.npc.x = v.x;
				else
					v.npc.x = v.npc.x + v.speedx;
				end
				v.npc.speedY = v.speedy;
				if(v.y ~= nil) then
					v.npc.y = v.y;
				else
					--v.npc.y = v.npc.y + v.speedy;
				end
				
				if(v.power ~= PLAYER_HAMMER or not contains(horikawaTools.hittableNPCs,v.npc.id)) then
					v.npc:xmem(0x12E,30);
					v.npc:xmem(0x136,-1);
				else
					v.npc:xmem(0x136,0);
					v.npc.x = v.npc.x + v.speedx;
				end
				
				if(v.npc.id == 263) then --is ice
					v.speedx = v.speedx*0.9;
					v.speedy = v.speedy*0.9;
					
					if(math.abs(v.speedx) < 0.1 and math.abs(v.speedy) < 0.1) then
						v.npc.speedX = 0;
						v.npc.speedY = 0;
						v.npc:xmem(0x136,0);
						v.npc:xmem(0x12C,0);
						v.npc:xmem(0x100,1);
						v.npc.data.shouldRemove = true;
						if(not contains(icecooldown,v.npc)) then
							table.insert(icecooldown, v.npc)
						end
					end
				end
				
				if(contains(veggies,v.npc.id)) then
					local _,_,hits = colliders.collideBlock(v.npc, colliders.BLOCK_SOLID..colliders.BLOCK_LAVA..colliders.BLOCK_NONSOLID..colliders.BLOCK_HURT..colliders.BLOCK_PLAYER);
					local j = 1;
					while j <= #hits do
						if(hits[j].isHidden) then
							table.remove(hits,j);
						else
							j = j+1;
						end
					end
					if(#hits > 0) then
						v.npc.data.shouldKill = true;
						playSFX(36);
					end
				end
				
				
				local b,_,ps = colliders.collideNPC(v.npc,horikawaTools.hittableNPCs,player.section);
				if(b) then
					local p = nil;
					for _,n in ipairs(ps) do
						if(not n.friendly and n:xmem(0x64) ~= -1 and n ~= v.npc.__ref) then
							p = n;
							break;
						end
					end
					if(p ~= nil) then
						if(not klonoa.GrabableNPCs[v.npc.id]) then
							v.npc.data.shouldKill = true;
						elseif (v.npc.id ~= 263) then --Don't remove ice on contact
							v.npc.data.shouldRemove = true;
						end
						if(not contains(horikawaTools.multiHitNPCs,p.id)) then
							local pn = pnpc.wrap(p);
							eventu.setFrameTimer(1, function()
									if(pn.isValid) then
										pn:kill(8);
									end
								end);
						end
					end
				end
				
				if(v.npc:xmem(0x0A) == 2 or v.npc:xmem(0x0C) == 2 or v.npc:xmem(0x0E) == 2 or v.npc:xmem(0x10) == 2) then
					if(not klonoa.GrabableNPCs[v.npc.id]) then
						v.npc.data.shouldKill = true;
					elseif (v.npc.id ~= 263) then --Don't remove ice on contact
						v.npc.data.shouldRemove = true;
					end
				else
					local _,_,hits = colliders.collideBlock(v.npc, colliders.BLOCK_SOLID..colliders.BLOCK_LAVA..colliders.BLOCK_NONSOLID..colliders.BLOCK_HURT..colliders.BLOCK_PLAYER);
					local j = 1;
					while j <= #hits do
						if(hits[j].isHidden) then
							table.remove(hits,j);
						else
							j = j+1;
						end
					end
					if(#hits > 0) then
						if(not klonoa.GrabableNPCs[v.npc.id]) then
							v.npc.data.shouldKill = true;
						elseif (v.npc.id ~= 263) then --Don't remove ice on contact
							v.npc.data.shouldRemove = true;
						end
					end
				end
			end
		end
		
		i = 1;
		
		while i <= #fireballs do
			local v = fireballs[i];
			if(not v.npc.isValid) then
				table.remove(fireballs,i);
			else
				v.npc.speedX = v.speedx;
				v.npc.speedY = v.speedy;
				local sx,sy = v.npc.x,v.npc.y;
				if(v.x ~= nil) then
					sx = v.x;
				end
				if(v.y ~= nil) then
					sy = v.y;
				end
				v.npc.x = sx + v.speedx;
				v.npc.y = sy + v.speedy;
			i = i+1;
			end
		end
		
		--Make ice take longer to despawn than normal
		i = 1;
		while i <= #icecooldown do
			local v = icecooldown[i];
			if(not v.isValid) then
				table.remove(icecooldown,i);
			else
				if(v:xmem(0x128) ~= -1) then
					v:xmem(0x12A, 720);
				end
				i = i+1;
			end
		end
		
		if(throwTimer >= 0) then
			throwTimer = throwTimer - 1;
		end
		
		if(vthrowTimer >= 0) then
			vthrowTimer = vthrowTimer - 1;
		end
		
		if klonoa.isHoldingObject() then
			effectFrame = -1;
			shooting = false;
		end
		
		shooting = effectFrame >= 0 and not klonoa.isHoldingObject() 
		
		
		if (shooting) then
							local ps = NPC.getIntersecting(ringbox.x, ringbox.y, ringbox.x+ringbox.width, ringbox.y+ringbox.height);
							local p;
							for _,v in ipairs(ps) do
								if(not v.friendly and v:xmem(0x64) ~= -1 and v:xmem(0x12A) >= 0 and ((contains(horikawaTools.hittableNPCs,v.id) and not contains(horikawaTools.multiHitNPCs,v.id)) or klonoa.GrabableNPCs[v.id] or contains(veggies,v.id)) and not klonoa.UngrabableNPCs[v.id]) then
									p = v;
									break;
								end
								if(not v.friendly and v:xmem(0x64) ~= -1 and contains(containers,v.id)) then
									replaceNPC(v, v:xmem(0xF0));
									v:xmem(0xDC, 0);
									v:xmem(0xF0, 0);
									--v:xmem(0xE2, v.id);
									v.y = v.y - v.height - 16;
									v.speedY = -2
								end
							end
							if(p ~= nil) then
								for k,v in ipairs(NPC.get()) do
									if(v == p) then
										grabbedNPC = pnpc.wrap(v);
										if(klonoa.ReplaceGrabbedNPC[grabbedNPC.id] ~= nil) then
											replaceNPC(grabbedNPC, klonoa.ReplaceGrabbedNPC[grabbedNPC.id]);
										end
										grabbedNPC:xmem(0x12C,1);
										grabbedNPC.data.shouldKill = false;
										grabbedNPC.data.shouldRemove = false;
										grabbedNPC:xmem(0x136,-1)	
										Animation.spawn(80,player.x+player.width/2,player.y)
										Animation.spawn(80,player.x,player.y)
										Animation.spawn(80,player.x+player.width,player.y)
										onGrab(grabbedNPC);
										grabbed = k;
										break;
									end
								end
							else
								ps = NPC.getIntersecting(ringbox.x, ringbox.y+32, ringbox.x+ringbox.width, ringbox.y+32+ringbox.height);
								for _,v in ipairs(ps) do
									if(not v.friendly and v:xmem(0x64) ~= -1 and contains(grass,v.id)) then
										replaceNPC(v, v:xmem(0xF0));
										v:xmem(0xDC, 0);
										v:xmem(0xF0, 0);
										--v:xmem(0xE2, v.id);
										v.y = v.y - v.height - 16;
										v.speedY = -2
										playSFX(88)
									end
								end
								
								--Dig up sand
								ps = Block.getIntersecting(ringbox.x, ringbox.y+32, ringbox.x+ringbox.width, ringbox.y+32+ringbox.height);
								for _,v in ipairs(ps) do
									if(v.id == 370 and not v.isHidden) then
										v:remove();
										effectFrame = -1;
										playSFX(88)
										break;
									end
								end
							end
			
		end
		
		
		
	end
	
end

function klonoa.onHUDDraw()
end

local function isJumping()
	return not klonoa.isOnGround() and not climbing and not klonoa.canFly() and (player:xmem(0x114) == 4 or player:xmem(0x114) == 5 or player:xmem(0x114) == 9  or player:xmem(0x114) == 10) and player:xmem(0x34) ~= 2;
end


function klonoa.onDraw()
	if(ringEffectFrame >= 0) then
		flash:drawFrame(player.x + player.width/2 - 32 + 32*ringEffectDir, ringbox.y - 20, ringEffectFrame, 1-((ringEffectDir+1)/2));
	end
	
	if(effectFrame >= 0) then
		sprite:drawFrame(ringbox.x + ringbox.width/2 - 32 - 16*player:xmem(0x106), ringbox.y - 20, effectFrame, 1-((player:xmem(0x106)+1)/2));
	end
	
	if(player.character == CHARACTER_KLONOA) then

			if(klonoa.forceHearts) then
				for _,v in ipairs(NPC.get({9,185,184},player.section)) do
					if(v:xmem(0x124) == -1) then
						replaceNPC(v,250)
					end
				end
			end
			
			if(klonoa.forceRupees) then
				for _,v in ipairs(NPC.get({138,88,33,10},player.section)) do
					if(v:xmem(0x124) == -1) then
						replaceNPC(v,251)
					end
				end
			end
			
		if(player:mem(0x34, FIELD_WORD) == 2) then
			if(not klonoa.isOnGround()) then
				if(player:xmem(0x114) == 1) then
					player:xmem(0x114,34);
				elseif(player:xmem(0x114) == 2) then
					player:xmem(0x114,33);
				elseif(player:xmem(0x114) == 5) then
					player:xmem(0x114,32);
				elseif(player:xmem(0x114) == 10) then
					player:xmem(0x114,30);
				end
			end
		else
			if(flaptimer>0 and isJumping()) then --flapping animation
				player:xmem(0x114,31+math.floor(flaptimer/6)%4)
				player:xmem(0x106,flapdir)
			elseif(shooting and not klonoa.isHoldingObject()) then
				player:xmem(0x114,35);
			elseif(throwTimer > 0 and not klonoa.isHoldingObject()) then
				player:xmem(0x114,14);
			elseif(vthrowTimer > 0 and not klonoa.isHoldingObject() and isJumping()) then
				player:xmem(0x114,36);
			elseif(player:xmem(0x34) == 2) then--swimming
				local offset = 0;
				if(klonoa.isHoldingObject()) then offset = 6 end;
				
				player:xmem(0x114,22+offset+math.floor(3*player:xmem(0x38)/16));
				
			elseif(isJumping()) then
				local offset = 0;
				if(klonoa.isHoldingObject()) then offset = 6 end;
				if(player.speedY <= -2) then
					player:xmem(0x114,22+offset);
				elseif(player.speedY >= 2) then
					player:xmem(0x114,24+offset);
				else
					player:xmem(0x114,23+offset);
				end
			end
		end
	end
end

local function disableGrab()
	-- Disable side grab
	mem(0x009AD622, FIELD_WORD, 0xE990)
	--mem(0x009AD622, FIELD_WORD, 0x850F)
	
	-- Disable top grab
	mem(0x009CC392, FIELD_WORD, 0xE990)
	--mem(0x009CC392, FIELD_WORD, 0x850F)
	
	-- Disable shell side grab
	mem(0x009ADA63, FIELD_WORD, 0x9090)
	--mem(0x009ADA63, FIELD_WORD, 0x1474)
	
	 -- Disable shell top grab
	mem(0x009AC6C4, FIELD_WORD, 0xE990)
	--mem(0x009AC6C4, FIELD_WORD, 0x850F)
	
end

local function enableGrab()
	-- side grab
	mem(0x009AD622, FIELD_WORD, 0x850F)

	-- top grab
	mem(0x009CC392, FIELD_WORD, 0x850F)

	--  shell side grab
	mem(0x009ADA63, FIELD_WORD, 0x1474)

	-- shell top grab
	mem(0x009AC6C4, FIELD_WORD, 0x850F)
end

function klonoa.initCharacter()
	-- CLEANUP NOTE: This is not safe if a level makes it's own use jumpheight
	Defines.jumpheight = 12
	Defines.jumpheight_bounce = 12
	
	-- CLEANUP NOTE: This should be replaced with a better hook in core LunaLua
	disableGrab()
	
	--Not valid if this value is set mid level
	runspeed = Defines.player_runspeed;
	Defines.player_runspeed = Defines.player_walkspeed;
end

function klonoa.cleanupCharacter()
	-- CLEANUP NOTE: This is not safe if a level makes it's own use jumpheight
	Defines.jumpheight = nil
	Defines.jumpheight_bounce = nil
	player:xmem(0x164, 0);
	
	-- CLEANUP NOTE: This should be replaced with a better hook in core LunaLua
	enableGrab()
	
	--Not valid if this value is set mid level
	Defines.player_runspeed = runspeed;
end

return klonoa;
