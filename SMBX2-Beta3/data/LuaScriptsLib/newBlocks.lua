-- Gotta have those new blocks woaaahhh
-- created by pyro

local newBlocks = {}

function newBlocks.onInitAPI()
	registerEvent(newBlocks, "onStart", "onStart", false)
	registerEvent(newBlocks, "onTick", "onTick", false)
	registerEvent(newBlocks, "onDraw", "onDraw", false)
	registerEvent(newBlocks, "onNPCKill", "onNPCKill", false)
end

newBlocks.meltTable = {13,108,246,276,85,87,260,12,210,259,206,282}
newBlocks.kirbyTable =  {666, 667, 686}

----------
-- APIS --
----------
local colliders = API.load("colliders",true)
local pnpc = API.load("pnpc",true)
local inputs = API.load("inputs",true)
local rng = API.load("rng",true)
local playerManager = API.load("playerManager")
local defs = API.load("expandedDefines")


local bowser = API.load("characters\\bowser")
local megaman = API.load("characters\\megaman")


-----------
-- SETUP --
-----------

local postUpdateFunctions = {}

local block665 = {}

local useCamera = Camera.get()[1]

local allNPCs = {}
for i=1,300 do
	table.insert(allNPCs,i)
end

local sound682 = {}
sound682[1] = Audio.SfxOpen(Misc.resolveFile("tnt.ogg") or Misc.resolveFile("sound/extended/tnt.ogg"));

local data682 = {timer = 192, ticks={ 191,
									  125, 90,
									  60, 45, 30, 15}};
									  
local sound666= {}
sound666[1] = Audio.SfxOpen(Misc.resolveFile("kirbybomb.ogg") or Misc.resolveFile("sound/extended/kirbybomb.ogg"));
local sound666Objs = {}

--Used for Costume Change block.
local oldCostume = {}
local costumes = {}

----------------------
-- CUSTOM FUNCTIONS --
----------------------
local function returnOnscreen(x,y)
	if x < useCamera.x-48 then
		return false;
	elseif x > useCamera.x+800+48 then
		return false;
	elseif y < useCamera.y then
		return false;
	elseif y > useCamera.y+600 then
		return false;
	else
		return true;
	end
end

local function parsePerEvents(whenToActivate, dataHandoff)
	for _, perEventCheatData in pairs(cheatArray) do
		if perEventCheatData.hasPerEvent and perEventCheatData.perEventActivated and perEventCheatData.whenToActivate == whenToActivate then
			perEventCheatData.perEventFunction(unpack(dataHandoff))
		end
	end
end

-----------------------
-- GENERAL FUNCTIONS --
-----------------------

local function icontains(t,v)
	for _,w in ipairs(t) do
		if(v == w) then
			return true;
		end
	end
	return false;
end

local function hiddenFilter(v)
	return not v.isHidden;
end

local function zeroContainedID(v)
	v.contentID = 0;
end

local function puffRemove(v)
	if(sound666Objs[1] ~= nil) then
		sound666Objs[1]:Stop();
	end
	sound666Objs[1]=Audio.SfxPlayObj(sound666[1],0)
	Animation.spawn(10,v.x,v.y);
	v:remove();
end

local function kirbyDetonate(v)
	local _,_,cs1 = colliders.collideBlock(colliders.Box(v.x-2,v.y+2,v.width+4,v.height-4), newBlocks.kirbyTable, hiddenFilter);
	local _,_,cs2 = colliders.collideBlock(colliders.Box(v.x+2,v.y-2,v.width-4,v.height+4), newBlocks.kirbyTable, hiddenFilter);
	for _,w in ipairs(cs1) do
		if(w ~= v) then
			w.contentID = -13;
		end
	end
	for _,w in ipairs(cs2) do
		if(w ~= v) then
			w.contentID = -13;
		end
	end
	puffRemove(v);
	Defines.earthquake = 2
end

local function hitExplosion(v)
	if(v.isHidden) then
		return false;
	end
	for _,w in ipairs(Animation.get({69})) do
		if(w.timer >= 59 and colliders.collide(v,colliders.Box(w.x-21,w.y-21,w.width+42,w.height+42))) then
			return true;
		end
	end
end

local function detonate(v)
	Misc.doBombExplosion(v.x+v.width*0.5,v.y+v.height*0.5,2);
	v:remove();
end

local function zeroBump(v)
	v:mem(0x54,FIELD_WORD,0)
	v:mem(0x52,FIELD_WORD,0)
	v:mem(0x56,FIELD_WORD,0)
end

local function bumpDuringTimefreeze(v)
	if(Defines.levelFreeze) then
		
		v:mem(0x56,FIELD_WORD,-(v:mem(0x52,FIELD_WORD)+v:mem(0x54,FIELD_WORD)));
		
		if(v:mem(0x52,FIELD_WORD) < 0) then
			v:mem(0x52,FIELD_WORD,math.min(v:mem(0x52,FIELD_WORD)+4,0));
		elseif(v:mem(0x54,FIELD_WORD) > 0) then
			v:mem(0x54,FIELD_WORD,math.max(v:mem(0x54,FIELD_WORD)-4,0));
		end
	end
end

local function setBlockFrame(id,frame)
	local frameLoc = mem(0x00B2BEA0,FIELD_DWORD)+(2*(id-1));
	mem(frameLoc,FIELD_WORD,frame);
end

local function getBlockFrame(id)
	local frameLoc = mem(0x00B2BEA0,FIELD_DWORD)+(2*(id-1));
	return mem(frameLoc,FIELD_WORD);
end

local powerSounds = {}
powerSounds[1] = 5;
powerSounds[2] = 6;
powerSounds[3] = 6;
powerSounds[4] = 6;
powerSounds[7] = 6;

local powerNPCs = {}
powerNPCs[3] = 14;
powerNPCs[4] = 34;
powerNPCs[5] = 169;
powerNPCs[6] = 170;
powerNPCs[7] = 264;

local powerTimers = {}
powerTimers[2] = 48;
powerTimers[3] = 48;
powerTimers[4] = 0;
powerTimers[5] = 0;
powerTimers[6] = 0;
powerTimers[7] = 48;

local function setPowerup(p, power)
	if p:mem(0x140,FIELD_WORD) == 0 and p:mem(0x13E,FIELD_WORD) == 0 and (p.powerup ~= power or (p.character==CHARACTER_BOWSER and power == 2 and bowser.getHP() == 1)) then
		Animation.spawn(10,p.x,p.y+p.height-16)
		
		if(powerNPCs[power] == nil) then
			if(powerSounds[power] ~= nil) then
					if(p.powerup > 2 and power == 2)  then
						playSFX(5)
					else
						playSFX(powerSounds[power])
					end
			else
				playSFX(34)
			end
			if(power == 2) then
				if(p.character==CHARACTER_BOWSER) then
					bowser.setHP(2);
				elseif(p.character==CHARACTER_MEGAMAN) then
					megaman.resetPowerups();
					megaman.resetHealth();
				end
			elseif(power == 1) then
				p.reservePowerup = 0
				if(p.character==CHARACTER_MEGAMAN) then
					megaman.resetPowerups();
					megaman.makeSmall();
				end
			end
			p.powerup = power;
			p:mem(0x140,FIELD_WORD,32)
		else
			local n = pnpc.wrap(NPC.spawn(powerNPCs[power],p.x,p.y,p.section));
			n.data._fromPowerBlock = powerTimers[power];
		end
	end
	--Reset the reserve PW if one exists and on reset block.
	if p:mem(0x140,FIELD_WORD) == 0 and p:mem(0x13E,FIELD_WORD) == 0 and p.reservePowerup ~= 0 and power == 1 then
		p:mem(0x140,FIELD_WORD,32)
		p.reservePowerup = 0
		playSFX(powerSounds[power])
	end
end

local function makePowerFunction(power)
	return  function(v)
				setPowerup(player,power);
			end
end

-------------------------
-- NEW BLOCK FUNCTIONS --
-------------------------

-- Block 665 --
local function onStartBlock665(v)
	v:remove()
end

local function onTickBlock665(v)
	local npcCollider = colliders.Box(v.x,v.y,32,1)
		
	local _,_,list = colliders.collideNPC(npcCollider, allNPCs)
	for _,q in ipairs(list) do
		if not q.layerObj.isHidden and q.y+q.height <= v.y+8 and q.speedY > 0 then
			q.y = q.y - q.speedY;
			q.speedY = 1;
		end
	end
	
	v.x = v.x + v.layerObj.speedX;
	v.y = v.y + v.layerObj.speedY;
end

local function onDrawBlock665(v)
	if returnOnscreen(v.x,v.y) then
		Graphics.draw{type=RTYPE_IMAGE,x=v.x,y=v.y,isSceneCoordinates=true,priority=-65,image=Graphics.sprites.block[665].img}
	end
end

-- Block 666 --

local function onTickBlock666(v)
	if(v.contentID < 0) then
		v.contentID = v.contentID + 1;
		if(v.contentID == 0) then
			kirbyDetonate(v);
		end
	end
end

function onCollideBlock666(v,n)
	if(n.__type == "NPC") then
		if(n:mem(0x136,FIELD_BOOL)) then
			if(defs.NPC_SHELL_MAP[n.id] and n.y + n.height > v.y) then
				puffRemove(v);
			elseif(not defs.NPC_SHELL_MAP[n.id]) then
				puffRemove(v);
			end
		end
	end
end

-- Block 667 --

local function onTickBlock667(v)
	if(v.contentID < 0) then
		v.contentID = v.contentID + 1;
		if(v.contentID == 0) then
			kirbyDetonate(v);
		end
	elseif(v.contentID == 0 and v:mem(0x54,FIELD_WORD) == 12) then
			kirbyDetonate(v);
	end
end

function onCollideBlock667(v,n)
	if(n.__type == "NPC") then
		if(defs.NPC_SHELL_MAP[n.id] and ((n:mem(0x136,FIELD_BOOL) or n.speedX ~= 0) and n.y + n.height > v.y)) then
			kirbyDetonate(v);
		end
	end
end

-- Block 668 --
function onCollideBlock668(v,n)
	if(n.__type == "Player") then
		v:remove(true)
		if n.jumpKeyPressing then
			n.speedY = -6;
		else
			n.speedY = -3.5;
		end
	end
end

-- Block 669 --
function onTickBlock669(v)
	if v.contentID ~= 0 then
		v:mem(0x62,FIELD_WORD,v.contentID)
		v.contentID = 0;
	end
	
	local noblockCollider = colliders.Box(v.x-4,v.y-4,40,40)
	local _,_,list1 = colliders.collideNPC(13,noblockCollider)
	local _,_,list2 = colliders.collideNPCBlock(newBlocks.meltTable,v)
	--[[local list = list1, list2
	for _,q in ipairs(list) do
	end]]
	
	for _,q in ipairs(list1) do
		meltIce(v,q)
	end
	for _,q in ipairs(list2) do
		meltIce(v,q)
	end
end

function meltIce(v,q)
	if v.isHidden == false then
		Animation.spawn(10,v.x,v.y)
		if v:mem(0x62,FIELD_WORD) > 1000 then
			NPC.spawn(v:mem(0x62,FIELD_WORD)-1000,v.x,v.y,player.section)
		elseif v:mem(0x62,FIELD_WORD) >= 1 and v:mem(0x62,FIELD_WORD) < 100 then
			for i=1,v:mem(0x62,FIELD_WORD) do
				local butt = NPC.spawn(10,v.x,v.y,player.section)
				butt.speedX = rng.randomInt(-3,3)
				butt.speedY = rng.randomInt(-5,-1)
				butt.ai1 = 1;
			end
		end
		v:remove()
		playSFX(3)
		if q.id == 13 or q.id == 85 or q.id == 246 or q.id == 276 then
			q:kill(9)
		end
	end
end

-- Block 670 --
function onHitBlock670(v)
	if(not Defines.levelFreeze) then
		playSFX(32)
		table.insert(postUpdateFunctions, {f = function() Misc.doPSwitch() end} );
	end
end

-- Block 671 --
function onHitBlock671(v)
	playSFX(32)
	Defines.levelFreeze = not Defines.levelFreeze;
end

-- Block 672 --
function onCollideBlock672(v,n)
	if(n.__type == "Player") then
		if n:mem(0x140,FIELD_WORD) == 0 and n:mem(0x13E,FIELD_WORD) == 0 then
			n:harm()
		end
	end
end

-- Block 673 --
function onCollideBlock673(v,n)
	if(n.__type == "Player") then
		if n:mem(0x140,FIELD_WORD) == 0 and n:mem(0x13E,FIELD_WORD) == 0 then
			n:kill()
		end
	end
end

-- Block 681 --
function onHitBlock681(v)
	if(costumes[player.character] == nil) then
		costumes[player.character] = playerManager.getCostumes(player.character);
	end
	--If costume is default then find which one we are using, or if we can't assume 0 (default).
	if oldCostume[player.character] == nil then 
		local current = playerManager.getCostume(player.character);
		oldCostume[player.character] = 0 
		if(current ~= nil) then
			for k,v in ipairs(costumes[player.character]) do
				if(v == current) then
					oldCostume[player.character] = k;
					break;
				end
			end
		end
	end
	local newCostume = (oldCostume[player.character]+1) % (#costumes[player.character] + 1);
	playerManager.setCostume(player.character,costumes[player.character][newCostume])
	oldCostume[player.character] = newCostume
	
	Animation.spawn(10,player.x+player.width*0.5-16,player.y+player.height*0.5);
	Audio.playSFX(32)
end

-- Block 682 --

function onDrawBlock682(v)
	if(v.contentID < -data682.timer or (v.contentID < 0 and v.contentID > -data682.timer+8)) then
		zeroBump(v);
	end
	if(v.contentID < 0 and v:mem(0x56, FIELD_WORD) == 0) then
		Graphics.draw{type=RTYPE_IMAGE,x=v.x,y=v.y,isSceneCoordinates=true,priority=-65,image=Graphics.sprites.block[682].img,sourceY=32*(math.floor(3*(1+v.contentID/data682.timer))+1),sourceWidth=32,sourceHeight=32}
	else
		local yoff = v:mem(0x56,FIELD_WORD);
			
		Graphics.draw{type=RTYPE_IMAGE,x=v.x,y=v.y+yoff,isSceneCoordinates=true,priority=-65,image=Graphics.sprites.block[682].img,sourceY=0,sourceWidth=32,sourceHeight=32}
	end
end

function onHitBlock682(v)
	if(v.contentID == 0) then
		v.contentID = -data682.timer;
	end
end

function onTickBlock682(v)
	if(hitExplosion(v)) then
		if(v.contentID <= 0 and v.contentID >= -data682.timer) then
			v.contentID = -data682.timer-10;
		end
	else
		if(v.contentID < 0) then
			zeroBump(v);
			v.contentID = v.contentID+1;
			if(icontains(data682.ticks,-v.contentID)) then
				Audio.SfxPlayCh(-1,sound682[1],0);
			end
			if(v.contentID == 0 or v.contentID == -data682.timer) then
				detonate(v);
			end
		elseif(v.contentID == 0 and v:mem(0x54,FIELD_WORD) == 12) then
			onHitBlock682(v)
		end
	end
	
	--TODO: Replace with better bouncing
	if(v.contentID == 0) then
		for _,w in ipairs(Player.get()) do
			if(colliders.bounce(w,colliders.Box(v.x+1,v.y,v.width-2,v.height))) then
				colliders.bounceResponse(w);
				onHitBlock682(v)
			end
		end
	end
end

function onCollideBlock682(v,n)
	if(n.__type == "NPC") then
		if(n:mem(0x136,FIELD_BOOL)) then
			if(defs.NPC_SHELL_MAP[n.id] and n.y + n.height > v.y) then
				onHitBlock682(v)
			elseif(not defs.NPC_SHELL_MAP[n.id]) then
				onHitBlock682(v)
			end
		end
	end
end

function onGlobalDraw682()
	mem(mem(0x00B2BEA0,FIELD_DWORD)+(2*681),FIELD_WORD,4)
end

-- Block 683 --
function onTickBlock683(v)
	if(hitExplosion(v)) then
		if(v.contentID >= 0) then
			v.contentID = -10;
		end
	end
	if(v.contentID < 0) then
		zeroBump(v);
		v.contentID = v.contentID + 1;
		if(v.contentID == 0) then
			detonate(v);
		end
	elseif(v.contentID == 0 and v:mem(0x54,FIELD_WORD) == 12) then
		detonate(v);
	end
end
		
function onDrawBlock683(v)
	if(v.contentID < 0) then
		zeroBump(v);
	end
end

-- Block 684 --
function onTickBlock684(v)
	local lspd = 0;
	local lyr = v.layerObj;
	if(lyr ~= nil) then
		lspd = lyr.speedX;
	end
	v.speedX=3+lspd;
end

-- Block 685 --
function onTickBlock685(v)
	local lspd = 0;
	local lyr = v.layerObj;
	if(lyr ~= nil) then
		lspd = lyr.speedX;
	end
	v.speedX=-3+lspd;
end

-- Block 686 --

local function onTickBlock686(v)
	if(v.contentID < 0) then
		v.contentID = v.contentID + 1;
		if(v.contentID == 0) then
			kirbyDetonate(v);
		end
	end
end

-- Block 687 --

local function onTickBlock687(v)
	if(v:mem(0x5E, FIELD_WORD) == 0) then
		v:mem(0x5E, FIELD_WORD, 1)
	end
end

-----------------
-- BLOCK TABLE --
-----------------
local blockTable = {}

blockTable[665] = {onStartFunction = onStartBlock665, onTickFunction = onTickBlock665, onDrawFunction = onDrawBlock665, alwaysTick = true, alwaysDraw = true}
blockTable[666] = {onTickFunction = onTickBlock666, onCollideFunction = onCollideBlock666, onHitFunction = puffRemove, bumpable = true, data={contentID = 0}}
blockTable[667] = {onTickFunction = onTickBlock667, onCollideFunction = onCollideBlock667, onHitFunction = kirbyDetonate, bumpable = true, data={contentID = 0}}
blockTable[668] = {onCollideFunction = onCollideBlock668}
blockTable[669] = {onTickFunction = onTickBlock669}
blockTable[670] = {onHitFunction = onHitBlock670, bumpable = true}
blockTable[672] = {onCollideFunction = onCollideBlock672}
blockTable[673] = {onCollideFunction = onCollideBlock673}
blockTable[674] = {onHitFunction = makePowerFunction(2), onLateTickFunction = bumpDuringTimefreeze, bumpable = true}
blockTable[675] = {onHitFunction = makePowerFunction(3), onLateTickFunction = bumpDuringTimefreeze, bumpable = true}
blockTable[676] = {onHitFunction = makePowerFunction(4), onLateTickFunction = bumpDuringTimefreeze, bumpable = true}
blockTable[677] = {onHitFunction = makePowerFunction(5), onLateTickFunction = bumpDuringTimefreeze, bumpable = true}
blockTable[678] = {onHitFunction = makePowerFunction(6), onLateTickFunction = bumpDuringTimefreeze, bumpable = true}
blockTable[679] = {onHitFunction = makePowerFunction(7), onLateTickFunction = bumpDuringTimefreeze, bumpable = true}
blockTable[680] = {onHitFunction = makePowerFunction(1), onLateTickFunction = bumpDuringTimefreeze, bumpable = true}
blockTable[681] = {onHitFunction = onHitBlock681, onLateTickFunction = bumpDuringTimefreeze, bumpable = true}
blockTable[682] = {onTickFunction = onTickBlock682, onDrawFunction = onDrawBlock682, onCollideFunction = onCollideBlock682, onHitFunction = onHitBlock682, onGlobalDrawFunction = onGlobalDraw682, bumpable = true, data={contentID = 0}}
blockTable[683] = {onTickFunction = onTickBlock683, onCollideFunction = detonate, onHitFunction = detonate, onDrawFunction = onDrawBlock683, bumpable = true, data={contentID = 0}}
blockTable[686] = {onTickFunction = onTickBlock686, data={contentID = 0}}
blockTable[687] = {onTickFunction = onTickBlock687, animFrames = 3}

local blockKeys = {}
for k,_ in pairs(blockTable) do
	table.insert(blockKeys,k)
end

-----------
-- HOOKS --
-----------

local function collidingNPCFilter(n)
	return not n.isHidden and (n.collidesBlockBottom or n.collidesBlockUp or n.collidesBlockLeft or n.collidesBlockDown or n:mem(0x120,FIELD_BOOL));
end

function newBlocks.onStart()
	for k,v in ipairs(Block.get(blockKeys)) do
		if blockTable[v.id].onStartFunction ~= nil then
			blockTable[v.id].onStartFunction(v)
		end
		if(blockTable[v.id].data ~= nil) then
			for l,w in pairs(blockTable[v.id].data) do
				if(v[l] ~= nil and (type(w) == "number" or type(w)=="boolean")) then
					v[l] = blockTable[v.id].data[l];
				end
			end
		end
	end
	for k,v in ipairs(blockKeys) do
		if blockTable[v].bumpable then
			Block.bumpable[v] = true;
		end
		
		--Initialise animation timers
		if(blockTable[v].animFrames ~= nil and blockTable[v].animFrames > 1) then
			if(blockTable[v].animSpeed == nil) then
				blockTable[v].animSpeed = 8;
			end
			local timerLoc = mem(0x00B2BEBC,FIELD_DWORD)+(2*(v-1));
			mem(timerLoc,FIELD_WORD,blockTable[v].animSpeed);
			setBlockFrame(v,0);
		end
	end
end

function newBlocks.onTick()
	for k,v in ipairs(blockKeys) do
		if(blockTable[v].onGlobalTickFunction ~= nil) then
			blockTable[v].onGlobalTickFunction();
		end
	end
	for k,v in ipairs(Block.get(blockKeys)) do
		if blockTable[v.id] ~= nil then
			if blockTable[v.id].onTickFunction ~= nil and (not v.isHidden or blockTable[v.id].alwaysTick) then
				blockTable[v.id].onTickFunction(v)
			end
			if blockTable[v.id].onHitFunction ~= nil and v:mem(0x52,FIELD_WORD) == -12 and v:mem(0x54,FIELD_WORD) == 12 and v:mem(0x56,FIELD_WORD) == 0 and not v.isHidden then
					if (v:mem(0x5A,FIELD_BOOL)) then
						v:mem(0x5A,FIELD_BOOL,false);
					end
					blockTable[v.id].onHitFunction(v)
					
					v:mem(0x52,FIELD_WORD,-8)
					v:mem(0x54,FIELD_WORD,8)
			end
			if blockTable[v.id].onCollideFunction ~= nil and v.isHidden == false then
				for _,w in ipairs(Player.get()) do
					if(w.isValid and v:collidesWith(w) ~= 0) then
						blockTable[v.id].onCollideFunction(v, w);
					end
				end
				local _,_,c = colliders.collideNPC(colliders.Box(v.x-0.1,v.y-0.1,v.width+0.2,v.height+0.2),defs.NPC_HITTABLE..defs.NPC_MULTIHIT..defs.NPC_SHELL..defs.NPC_POWERUP, collidingNPCFilter);
				for _,w in ipairs(c) do
					blockTable[v.id].onCollideFunction(v, w);
				end
			end
			if blockTable[v.id].onLateTickFunction ~= nil and (not v.isHidden or blockTable[v.id].alwaysTick) then
				blockTable[v.id].onLateTickFunction(v)
			end
		end

		for _,postUpdate in ipairs(postUpdateFunctions) do
			postUpdate.f(postUpdate.args);
		end
		postUpdateFunctions = {};

	end
	
	--[[ todo:
	- mario bros. pow block]]
end

function newBlocks.onDraw()
	for k,v in ipairs(blockKeys) do
		if(blockTable[v].animFrames ~= nil and blockTable[v].animFrames > 1 and blockTable[v].animSpeed ~= nil) then
			local timerLoc = mem(0x00B2BEBC,FIELD_DWORD)+(2*(v-1));
			local frameLoc = mem(0x00B2BEA0,FIELD_DWORD)+(2*(v-1));
			mem(timerLoc,FIELD_WORD,mem(timerLoc,FIELD_WORD)-1);
			if(mem(timerLoc,FIELD_WORD) == 0) then
				mem(frameLoc,FIELD_WORD,(mem(frameLoc,FIELD_WORD)+1)%blockTable[v].animFrames);
				mem(timerLoc,FIELD_WORD,blockTable[v].animSpeed)
			end
		end
		if(blockTable[v].onGlobalDrawFunction ~= nil) then
			blockTable[v].onGlobalDrawFunction();
		end
	end
	for k,v in ipairs(Block.get(blockKeys)) do
		if blockTable[v.id].onDrawFunction ~= nil and ((not v.isHidden and not v:mem(0x5A, FIELD_BOOL)) or blockTable[v.id].alwaysDraw) then
			blockTable[v.id].onDrawFunction(v)
		end
	end
end

function newBlocks.onNPCKill(eventobj, npc, reason)
	local n = pnpc.getExistingWrapper(npc);
	if(n == nil) then return; end
	if(n.data._fromPowerBlock ~= nil) then
		player:mem(0x124,FIELD_DFLOAT,n.data._fromPowerBlock)
	end
end

return newBlocks;