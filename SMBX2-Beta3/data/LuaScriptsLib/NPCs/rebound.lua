--rebound.lua 
--v0.1.0
--Created by S1eth, 2016

local configFileReader = API.load("configFileReader");
local npcParse = API.load("npcParse");
local colliders = API.load("colliders");
local pnpc = API.load("pnpc");
local npcconfig = API.load("npcconfig");
local npcManager = API.load("npcManager");

rebound = {};

function rebound.onInitAPI()
  -- Register onTick and onDraw for use
	registerEvent(rebound, "onStart", "onStart", false);
  registerEvent(rebound, "onTick", "onTick", false);
  registerEvent(rebound, "onDraw", "onDraw", false);
end

--***************************************************************************************************
--                                                                                                  *
--              DEBUG FUNCTIONS                                                                     *
--                                                                                                  *
--***************************************************************************************************

function indentString(indent)  
  local str = "";
  for i=0, indent do
    str = str.."  ";
  end
  return str;
end


function debugOutput(tableName, file, indent)
  if(indent == 0) then
    io.write("DATA {\n");
  end
  for k,v in pairs(tableName) do
      
      io.write(indentString(indent));
      if(type(v) == "table") then
        io.write("\""..tostring(k).."\" {\n");
        debugOutput(v, file, indent+1);
        io.write(indentString(indent).."}\n");
      else
        if(type(v) == "string") then
          io.write("\""..tostring(k).."\" = \""..tostring(v).."\"\n");
        else
          io.write("\""..tostring(k).."\" = "..tostring(v).."\n");
        end
      end
    end
    if(indent == 0) then
      io.write("}\n");
    end
end

--***************************************************************************************************
--                                                                                                  *
--              UTILITY FUNCTIONS                                                                   *
--                                                                                                  *
--***************************************************************************************************

local function round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5);
end

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

--***************************************************************************************************
--                                                                                                  *
--              PUBLIC MEMBERS                                                                      *
--                                                                                                  *
--***************************************************************************************************

rebound.animationStyle = {singleSprite = 0, leftRight = 1, rotate = 2};

--***************************************************************************************************
--                                                                                                  *
--              PRIVATE CONSTANTS                                                                   *
--                                                                                                  *
--***************************************************************************************************

local PODOBOO_NPCID = 297; 
local BOOSNAKE_NPCID = 298;

local NPCMEM_OFFSCREEN_TIMER = 0x12A; --FIELD_WORD
local NPCMEM_PREVENT_RESPAWN = 0x124; --FIELD_WORD
local NPCMEM_GENERATOR = 0x64; --FIELD_WORD
local NPCMEM_IS_HIDDEN = 0x40; --FIELD_WORD

local direction = {up = 1, left = 2, right = 3, down = 4} --graphics\new_npcs\podoboo

local images = {};
images.podoboo       = Graphics.loadImage(Misc.resolveFile("diagonal podoboo.png") or Misc.resolveFile("graphics/new_npcs/diagonalpodoboo/diagonal podoboo.png"));
images.booSnake      = Graphics.loadImage(Misc.resolveFile("boo snake.png")        or Misc.resolveFile("graphics/new_npcs/boosnake/boo snake.png"));
images.trail         = Graphics.loadImage(Misc.resolveFile("boo trail.png")        or Misc.resolveFile("graphics/new_npcs/boosnake/boo trail.png"));

--***************************************************************************************************
--                                                                                                  *
--              TRANSFORMATION FUNCTIONS                                                            *
--                                                                                                  *
--***************************************************************************************************

function rotate(coordArray, angle)
  local resultArray = {};  
  for i=0,11,1 do
    if (i % 2 == 0) then
      --x coordinate
      resultArray[i] = coordArray[i] * math.cos(angle) - coordArray[i+1] * math.sin(angle);
    else
      --y coordinate
      resultArray[i] = coordArray[i] * math.cos(angle) + coordArray[i-1] * math.sin(angle);
    end
  end
  return resultArray;
end

function translate(coordArray, x, y)
  local resultArray = {};
  for i=0,11,1 do
    if (i % 2 == 0) then
      --x coordinate
      resultArray[i] = coordArray[i] + x;
    else
      --y coordinate
      resultArray[i] = coordArray[i] + y;
    end
  end
  return resultArray;
end

function flipX(coordArray)
  local resultArray = {};
  for i=0,11,1 do
    if (i % 2 == 0) then
      --x coordinate
      resultArray[i] = -coordArray[i];
    else
      --y coordinate
      resultArray[i] = coordArray[i];
    end
  end
  return resultArray;
end

--***************************************************************************************************
--                                                                                                  *
--              DEFAULTS AND NPC CONFIGURATION                                                      *
--                                                                                                  *
--***************************************************************************************************

local podobooSettings = {
	id = PODOBOO_NPCID,
	gfxwidth = 32,
	gfxheight = 32,
	width = 32,
	height = 32,
	frames = 2,
	framespeed = 4,
	framestyle = 0,
	jumphurt=1,
	nogravity = 1,
	noblockcollision = 1,
	noyoshi = 1,
	nofireball = 1
}

NPC.spinjumpSafe[PODOBOO_NPCID] = true;

local podobooLuaSettings = {
	velocity = {speed = 1.5, angle = math.pi * 1.25},
	animationStyle = rebound.animationStyle.rotate,
	img = images.podoboo,
	spriteAngle = math.pi/4
}

npcManager.setNpcSettings(podobooSettings);

if Misc.resolveFile("npc-"..PODOBOO_NPCID..".txt") ~= nil then
	local configFile = configFileReader.parseTxt("npc-"..podobooLuaSettings_NPCID..".txt");
	-- lua fields
	if(configFile.velocity_angle ~= nil or configFile.velocity_speed ~= nil) then
		podobooLuaSettings.velocity.speed = configFile.velocity_speed                 or podobooLuaSettings.velocity.speed;
		podobooLuaSettings.velocity.angle = configFile.velocity_angle * math.pi / 180 or podobooLuaSettings.velocity.angle;
	end 
	podobooLuaSettings.speedX         = configFile.speedX                      or podobooLuaSettings.speedX;
	podobooLuaSettings.speedY         = configFile.speedY                      or podobooLuaSettings.speedY;
	podobooLuaSettings.animationStyle = configFile.animationStyle              or podobooLuaSettings.animationStyle;
	podobooLuaSettings.img            = images[configFile.img]		             or podobooLuaSettings.img;
	podobooLuaSettings.spriteAngle    = configFile.spriteAngle * math.pi / 180 or podobooLuaSettings.spriteAngle;
end

-----------------------------------------------------------------------------------------------------

local booSnakeSettings = {
	id = BOOSNAKE_NPCID,
	gfxwidth = 32,
	gfxheight = 32,
	width = 32,
	height = 32,
	frames = 2,
	framespeed = 8,
	framestyle = 1,
	jumphurt = 1,
	nogravity = 1,
	blocknpc = 0,
	noblockcollision = 1,--required for blocknpc
	noiceball = 1,
	noyoshi=1,
	nofireball = 1
}

NPC.spinjumpSafe[BOOSNAKE_NPCID] = true

local booSnakeLuaSettings = {
	speedX = -2,
	speedY = -2,
	animationStyle = rebound.animationStyle.leftRight,
	img = images.booSnake,
	trail = {
		length = 5,
		img = images.trail,
		spawnrate = 8,
		sprites = 6
	} 
}

npcManager.setNpcSettings(booSnakeSettings);

if Misc.resolveFile("npc-"..BOOSNAKE_NPCID..".txt") ~= nil then
	local configFile = configFileReader.parseTxt("npc-"..BOOSNAKE_NPCID..".txt");
	if(configFile.velocity_angle ~= nil or configFile.velocity_speed ~= nil) then
		booSnakeLuaSettings.velocity = {};
		booSnakeLuaSettings.velocity.speed = configFile.velocity_speed                 or booSnakeLuaSettings.velocity.speed;
		booSnakeLuaSettings.velocity.angle = configFile.velocity_angle * math.pi / 180 or booSnakeLuaSettings.velocity.angle;
	end 
	booSnakeLuaSettings.speedX         = configFile.speedX         or booSnakeLuaSettings.speedX;
	booSnakeLuaSettings.speedY         = configFile.speedY         or booSnakeLuaSettings.speedY;
	booSnakeLuaSettings.animationStyle = configFile.animationStyle or booSnakeLuaSettings.animationStyle;
	booSnakeLuaSettings.img            = images[configFile.img]	 	 or booSnakeLuaSettings.img;
	
	booSnakeLuaSettings.trail.length      = configFile.trail_length      or booSnakeLuaSettings.trail.length;
	--booSnakeLuaSettings.trail.img         = configFile.trail_img         or booSnakeLuaSettings.trail.img; --TODO: either remove, or implement custom trail image loading
	booSnakeLuaSettings.trail.spawnrate   = configFile.trail_spawnrate   or booSnakeLuaSettings.trail.spawnrate;
	booSnakeLuaSettings.trail.sprites     = configFile.trail_sprites     or booSnakeLuaSettings.trail.sprites;
end

--***************************************************************************************************
--                                                                                                  *
--              API functions                                                                       *
--                                                                                                  *
--***************************************************************************************************

  
local function speedXYToVelocity(speedX, speedY) --return {speed, angle}
	return {speed = math.sqrt(speedX*speedX + speedY*speedY),
					angle = math.atan2(speedY, speedX)};
end 

local function velocityToSpeedXY(velocity) --return speedX, speedY
	return math.cos(velocity.angle) * velocity.speed, math.sin(velocity.angle) * velocity.speed; 
end 

function rebound.initTrail(trail)
  trail.frame = 0;
  trail.data = {};
  trail.cur = 0;
	trail.offsetIndex = 0;
  for i=0, trail.length-1 do
    trail.data[i] = nil;
  end 
end

local function initVelocity(reboundData, defaults)
  if(reboundData.velocity ~= nil) then
		-- use custom velocity
    reboundData.velocity.speed = reboundData.velocity.speed or defaults.velocity.speed or 0;
    reboundData.velocity.angle = reboundData.velocity.angle * math.pi / 180 or reboundData.velocity.angleRadian or defaults.velocity.angle or 0;
  
    reboundData.speedX, reboundData.speedY = velocityToSpeedXY(reboundData.velocity);
  elseif(reboundData.speedX ~= nil or reboundData.speedY ~= nil) then
		-- use custom speedXY
		reboundData.speedX = reboundData.speedX or 0;
		reboundData.speedY = reboundData.speedY or 0;
    reboundData.velocity = speedXYToVelocity(reboundData.speedX, reboundData.speedY); 
  elseif(defaults.velocity ~= nil) then 
	  -- use defaults velocity 
		reboundData.velocity = copy(defaults.velocity);
		reboundData.speedX, reboundData.speedY = velocityToSpeedXY(reboundData.velocity);
  elseif(defaults.speedX ~= nil or defaults.speedY ~= nil) then 
	  -- use defaults speedXY
		reboundData.speedX = defaults.speedX or 0;
		reboundData.speedY = defaults.speedY or 0;
		reboundData.velocity = speedXYToVelocity(reboundData.speedX, reboundData.speedY);
  else  
		-- no movement
		reboundData.velocity = {speed = 0, angle = 0};
		reboundData.speedX, reboundData.speedY = velocityToSpeedXY(reboundData.velocity);
  end 
end 

function rebound.initialize(npc)


	--[[
	Initialize the npc's field values. 

	priority:  

	1. custom data (read from message field)
	2. npcconfig data (read from npc-xxx.txt)
	3. global default values
	]]--

	-- global settings for the npc (default changed by npcconfig data)
	local defaults;
	if(npc.id == PODOBOO_NPCID) then 
		defaults = podobooLuaSettings;
	elseif(npc.id == BOOSNAKE_NPCID) then 
		defaults = booSnakeLuaSettings;
	else
		error("invalid npc id: "..npc.id);
	end 
	
	if(npc.data.rebound == nil) then 
		npc.data.rebound = {};
	end 


	--[[ lua fields
		velocty
		speedX
		speedY
		img
		animationStyle
		spriteAngle
		trail
	]]--

	initVelocity(npc.data.rebound, defaults);
	npc.speedX = npc.data.rebound.speedX;
	npc.speedY = npc.data.rebound.speedY;
	npc.data.rebound.img            = images[npc.data.rebound.img] or defaults.img;  --TODO: either remove, or implement custom trail image loading
	npc.data.rebound.animationStyle = npc.data.rebound.animationStyle or defaults.animationStyle;
	npc.data.rebound.spriteAngle    = npc.data.rebound.spriteAngle or defaults.spriteAngle or 0;

  --trail 
  if(defaults.trail ~= nil or npc.data.rebound.trail ~= nil) then
		if(npc.data.rebound.trail == nil) then 
			npc.data.rebound.trail = {};
		end

		if(type(npc.data.rebound.trail.img) == "string") then
			assert(images[npc.data.rebound.trail.img] ~= nil, "Cannot find image for "..npc.data.rebound.trail.img);
      npc.data.rebound.trail.img = images[npc.data.rebound.trail.img];
    end
    		
    npc.data.rebound.trail.width     = npc.data.rebound.trail.width     or npc.width;
    npc.data.rebound.trail.height    = npc.data.rebound.trail.height    or npc.height;
		npc.data.rebound.trail.length    = npc.data.rebound.trail.length    or defaults.trail.length;
		npc.data.rebound.trail.img       = npc.data.rebound.trail.img       or defaults.trail.img;
		npc.data.rebound.trail.spawnrate = npc.data.rebound.trail.spawnrate or defaults.trail.spawnrate;
		npc.data.rebound.trail.sprites   = npc.data.rebound.trail.sprites   or defaults.trail.sprites;

		rebound.initTrail(npc.data.rebound.trail);
    
    npc.data.rebound.trail.vertexCoords = {};
    npc.data.rebound.trail.vertexCoords[0]  = -npc.data.rebound.trail.width/2; npc.data.rebound.trail.vertexCoords[1]  = -npc.data.rebound.trail.height/2;
    npc.data.rebound.trail.vertexCoords[2]  =  npc.data.rebound.trail.width/2; npc.data.rebound.trail.vertexCoords[3]  = -npc.data.rebound.trail.height/2;
    npc.data.rebound.trail.vertexCoords[4]  = -npc.data.rebound.trail.width/2; npc.data.rebound.trail.vertexCoords[5]  =  npc.data.rebound.trail.height/2;
    npc.data.rebound.trail.vertexCoords[6]  = -npc.data.rebound.trail.width/2; npc.data.rebound.trail.vertexCoords[7]  =  npc.data.rebound.trail.height/2;
    npc.data.rebound.trail.vertexCoords[8]  =  npc.data.rebound.trail.width/2; npc.data.rebound.trail.vertexCoords[9]  = -npc.data.rebound.trail.height/2;
    npc.data.rebound.trail.vertexCoords[10] =  npc.data.rebound.trail.width/2; npc.data.rebound.trail.vertexCoords[11] =  npc.data.rebound.trail.height/2;
  end
  
  npc.data.rebound.vertexCoords = {};
  npc.data.rebound.vertexCoords[0]  = -npc.width/2; npc.data.rebound.vertexCoords[1]  = -npc.height/2;
  npc.data.rebound.vertexCoords[2]  =  npc.width/2; npc.data.rebound.vertexCoords[3]  = -npc.height/2;
  npc.data.rebound.vertexCoords[4]  = -npc.width/2; npc.data.rebound.vertexCoords[5]  =  npc.height/2;
  npc.data.rebound.vertexCoords[6]  = -npc.width/2; npc.data.rebound.vertexCoords[7]  =  npc.height/2;
  npc.data.rebound.vertexCoords[8]  =  npc.width/2; npc.data.rebound.vertexCoords[9]  = -npc.height/2;
  npc.data.rebound.vertexCoords[10] =  npc.width/2; npc.data.rebound.vertexCoords[11] =  npc.height/2;

  -- reset to these initial values when despawning (offscreen too long, offsection, or hidden)
  npc.data.rebound.initial = {};
  npc.data.rebound.initial.velocity = copy(npc.data.rebound.velocity);

	npc.data.rebound.toBeReset = false;
	npc.data.rebound.initialized = true;
end

function rebound.reset(npc)
	npc.data.rebound.isDespawned = false;

	npc.speedX = npc.data.rebound.speedX;
	npc.speedY = npc.data.rebound.speedY;
  npc.data.rebound.velocity = copy(npc.data.rebound.initial.velocity);
	npc.data.rebound.speedX, npc.data.rebound.speedY = velocityToSpeedXY(npc.data.rebound.velocity);

  if(npc.data.rebound.trail ~= nil) then
    rebound.initTrail(npc.data.rebound.trail);
  end
end

function rebound.update(npc)
  
  -- update the trail  

  if(npc.data.rebound.trail ~= nil and not Defines.levelFreeze) then
    
		--create new trail objects, delete old trail objects
    npc.data.rebound.trail.frame = npc.data.rebound.trail.frame + 1;

    if(npc.data.rebound.trail.frame >= npc.data.rebound.trail.spawnrate) then
      npc.data.rebound.trail.frame = npc.data.rebound.trail.frame % npc.data.rebound.trail.spawnrate;
      
      npc.data.rebound.trail.data[npc.data.rebound.trail.cur] =
      {
        x = npc.x,
        y = npc.y,
        dir = npc.speedX >= 0 and direction.right or direction.left,
        spriteOffset = npc.data.rebound.trail.offsetIndex * npc.data.rebound.trail.height;
      };
      npc.data.rebound.trail.offsetIndex = (npc.data.rebound.trail.offsetIndex + 1) % npc.data.rebound.trail.sprites;
      npc.data.rebound.trail.cur = (npc.data.rebound.trail.cur + 1) % npc.data.rebound.trail.length;
    end
  end 

  -- update the main body  
	
	local dirX = npc.speedX >= 0 and direction.right or direction.left;
  local dirY = npc.speedY >= 0 and direction.down  or direction.up; 

	local collisionTable = {}
  
  collisionTable.up    = colliders.Box(npc.x+2,           npc.y,              npc.width-4, 1);
  collisionTable.left  = colliders.Box(npc.x,             npc.y+2,            1,           npc.height-4);
  collisionTable.right = colliders.Box(npc.x+npc.width-1, npc.y+2,            1,           npc.height-4);
  collisionTable.down  = colliders.Box(npc.x+2,           npc.y+npc.height-1, npc.width-4, 1);
  
  local collisionResult = {up = false, left = false, right = false, down = false};
  
  for dir,col in pairs(collisionTable) do
    local _,_,list = colliders.collideBlock(col, colliders.BLOCK_SOLID..colliders.BLOCK_HURT..colliders.BLOCK_PLAYER)
    for _,block in ipairs(list) do
      if not block.isHidden then
        collisionResult[dir] = true;
      end
    end
  end
  
  if(collisionResult.up   and dirY == direction.up and not collisionResult.down or
     collisionResult.down and dirY == direction.down and not collisionResult.up) then
     
    npc.speedY = -npc.speedY;
  end 
  
  if(collisionResult.left  and dirX == direction.left  and not collisionResult.right or
     collisionResult.right and dirX == direction.right and not collisionResult.left) then
     
    npc.speedX = -npc.speedX;
  end
  npc.data.rebound.velocity = speedXYToVelocity(npc.speedX, npc.speedY);

	-- check player collision
	if (not npc.friendly) then 
		for _,p in pairs({player, player2}) do
		
			if(npc.data.rebound.trail ~= nil) then
				local trailWidth = npc.data.rebound.trail.img.width;
				local trailHeight = npc.data.rebound.trail.img.height / npc.data.rebound.trail.sprites;
				for _,trailObj in pairs(npc.data.rebound.trail.data) do 
					local trailHitbox = colliders.Box(trailObj.x+6, trailObj.y+6, trailWidth-12, trailHeight-12); 
					--TODO: remove hardcoded numbers
					if(colliders.collide(p,trailHitbox) and not inStar) then 
						p:harm();
					end
				end 
			end 
		end 
	end 

end

function rebound.draw(npc)
	if npc.data.rebound.animationStyle == rebound.animationStyle.rotate then 
		--Calculate texture coordinates
		local top    = (0          + (npc.animationFrame * npc.height))/npc.data.rebound.img.height;
		local bottom = (npc.height + (npc.animationFrame * npc.height))/npc.data.rebound.img.height;
		local left   = 0;
		local right  = 1;

		local texCoords = {};
		texCoords[0]  = left;  texCoords[1]  = top;
		texCoords[2]  = right; texCoords[3]  = top;
		texCoords[4]  = left;  texCoords[5]  = bottom;
		texCoords[6]  = left;  texCoords[7]  = bottom;
		texCoords[8]  = right; texCoords[9]  = top;
		texCoords[10] = right; texCoords[11] = bottom;
  
		--Calculate vertex coordinates
		local vtx = 
		translate(
			rotate(
				npc.data.rebound.vertexCoords,
				npc.data.rebound.velocity.angle - npc.data.rebound.spriteAngle --angle rotate
			), 
			npc.x+npc.width/2, --x translate
			npc.y+npc.height/2 --y translate
		); 
  
  
		Graphics.glDraw{
			texture = npc.data.rebound.img,
			vertexCoords = vtx,
			textureCoords = texCoords,
			sceneCoords = true,
			priority = -45
		};

	end 
  
  --[[ draw the trail
  draws the objects in the trail from oldest to newest.
  starts from the current oldest (cur) and iterates until the end of the table.  
  then, starts from 0, and iterates until the index of the current oldest.
 
  e.g. trail length = 5
  
  table:
           cur 
  | 0 | 1 | 2 | 3 | 4 |  
  
  for i=2 to 4  
  for i=0 to (2-1)
  
  drawing order
  | 2 | 3 | 4 | 0 | 1 | 
  ]]--
  if(npc.data.rebound.trail ~= nil) then
    for i=npc.data.rebound.trail.cur, #npc.data.rebound.trail.data do
      local v = npc.data.rebound.trail.data[i];
      if(v ~= nil) then
        drawTrailObj(v, npc.data.rebound.trail); 
      end
    end 
    for i=0, npc.data.rebound.trail.cur-1 do
      local v = npc.data.rebound.trail.data[i];
      if(v ~= nil) then
        drawTrailObj(v, npc.data.rebound.trail); 
      end
    end 
  end--if(npc.data.rebound.trail ~= nil)
  
end

function drawTrailObj(obj, trail) 
  
  --Calculate texture coordinates
  local top    = (0            + obj.spriteOffset)/trail.img.height;
  local bottom = (trail.height + obj.spriteOffset)/trail.img.height;
  local left   = 0;
  local right  = 1;

  local texCoords = {};
  texCoords[0]  = left;  texCoords[1]  = top;
  texCoords[2]  = right; texCoords[3]  = top;
  texCoords[4]  = left;  texCoords[5]  = bottom;
  texCoords[6]  = left;  texCoords[7]  = bottom;
  texCoords[8]  = right; texCoords[9]  = top;
  texCoords[10] = right; texCoords[11] = bottom;
  
  Graphics.glDraw{
    texture = trail.img,
    vertexCoords = translate(
      (obj.dir == direction.left and flipX(trail.vertexCoords) or trail.vertexCoords), 
      obj.x+trail.width/2, obj.y+trail.height/2),
    textureCoords = texCoords,
    sceneCoords = true,
    priority = -45.1
  }
end 











function rebound.onStart()
	Graphics.sprites.npc[297].img = Graphics.loadImageResolved("luaResources/Shared/blankImage.png");
end 

function rebound.onTick()
  for _,v in pairs(NPC.get({PODOBOO_NPCID,BOOSNAKE_NPCID}, -1)) do --for each podoboo
    if v:mem(NPCMEM_GENERATOR,FIELD_WORD) ~= -1 and v:mem(NPCMEM_PREVENT_RESPAWN, FIELD_WORD) ~= 0 then 
			local npc = pnpc.wrap(v);

			if(npc.data.rebound == nil or not npc.data.rebound.initialized) then
				rebound.initialize(npc);
			end 
			if(npc.data.rebound.isDespawned == true) then
				rebound.reset(npc);
			end 

			rebound.update(npc);

    elseif v:mem(NPCMEM_GENERATOR,FIELD_WORD) ~= -1 then 
			local npc = pnpc.wrap(v);

			if(npc.data.rebound ~= nil) then 
				npc.data.rebound.isDespawned = true;
			end
		end 
  end --for each podoboo
end

function rebound.onDraw()

	for _,v in pairs(NPC.get({PODOBOO_NPCID,BOOSNAKE_NPCID}, -1)) do
		if v:mem(NPCMEM_GENERATOR,FIELD_WORD) ~= -1 and
		   v:mem(NPCMEM_PREVENT_RESPAWN, FIELD_WORD) ~= 0 and 
			 v:mem(NPCMEM_OFFSCREEN_TIMER, FIELD_WORD) > 0 
		then
			local npc = pnpc.wrap(v);
			if(npc.data.rebound ~= nil and not npc.data.rebound.isDespawned) then 
				rebound.draw(npc);
			end
		end 
  end
end

return rebound;

