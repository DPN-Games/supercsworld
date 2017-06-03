local npcParse = API.load("npcParse");
local colliders = API.load("colliders");
local pnpc = API.load("pnpc");
local npcconfig = API.load("npcconfig");

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

-- Finds the corresponding section for a point (x,y). (If the point is within 1000 pixel of the section boundary) 
local function getSection(x, y)
	for index,section in pairs(Section.get()) do
		local boundary = section.boundary;
		local sectionBox = colliders.Box( 
			boundary.left - 1000,
			boundary.top - 1000,
			boundary.right - boundary.left + 1000,  
			boundary.bottom - boundary.top + 1000
		)
	
		if colliders.collide(sectionBox, colliders.Point(x, y)) then
			return index-1; -- one-indexed --> zero-indexed
		end 
	end
	
	return nil;
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

rebound.frameStyle = {singleSprite = 0, leftRight = 1, rotate = 2};

--***************************************************************************************************
--                                                                                                  *
--              PRIVATE CONSTANTS                                                                   *
--                                                                                                  *
--***************************************************************************************************

local PODOBOO_NPCID = 297; 
local BOOSNAKE_NPCID = 298;

local direction = {up = 1, left = 2, right = 3, down = 4}

local MOUNT_TYPES = {shoe = 1, yoshi = 3};

local images = {};
images.podoboo       = Graphics.loadImage(Misc.resolveFile("diagonal podoboo.png") or Misc.resolveFile("graphics/luaResources/rebound/diagonal podoboo.png"));
images.booSnake      = Graphics.loadImage(Misc.resolveFile("boo snake.png")        or Misc.resolveFile("graphics/luaResources/rebound/boo snake.png"));
images.trail         = Graphics.loadImage(Misc.resolveFile("boo trail.png")        or Misc.resolveFile("graphics/luaResources/rebound/boo trail.png"));
images.messageSprite = Graphics.loadImage(Misc.resolveFile("gasp.png")             or Misc.resolveFile("graphics/luaResources/rebound/gasp.png"));

local cam = {Camera.get()[1], Camera.get()[2]};

local rebounders = {};

local _preset = {};
_preset.podoboo = {};
_preset.podoboo.width = 32;
_preset.podoboo.height = 32;
_preset.podoboo.velocity = {speed = 1.5, angle = math.pi * 1.25}; 
_preset.podoboo.speedX = 0;
_preset.podoboo.speedY = 0;
_preset.podoboo.spinjump = true;
_preset.podoboo.invincible = true;
_preset.podoboo.friendly = false;
_preset.podoboo.frameStyle = rebound.frameStyle.rotate;
_preset.podoboo.frames = 2; -- number of animation frames
_preset.podoboo.frameTime = 4; -- ticks spent per frame
_preset.podoboo.img = images.podoboo;
_preset.podoboo.spriteAngle = math.pi/4;

_preset.booSnake = {};
_preset.booSnake.width = 32;
_preset.booSnake.height = 32;
_preset.booSnake.speedX = -2;
_preset.booSnake.speedY = -2;
_preset.booSnake.spinjump = true;
_preset.booSnake.invincible = true;
_preset.booSnake.friendly = false;
_preset.booSnake.frameStyle = rebound.frameStyle.leftRight;
_preset.booSnake.frames = 1; -- number of animation frames
_preset.booSnake.img = images.booSnake;
_preset.booSnake.trail = {};
_preset.booSnake.trail.length = 5;
_preset.booSnake.trail.img = images.trail;
_preset.booSnake.trail.spawnrate = 8;
_preset.booSnake.trail.offsetIndex = 0;
_preset.booSnake.trail.sprites = 6;



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
--              CLASS: Rebounder                                                                    *
--                                                                                                  *
--***************************************************************************************************

local Rebounder = {};
Rebounder.__index = Rebounder;
Rebounder.isSpawned = false;
Rebounder.velocity = nil; 
Rebounder.speedX = 0;
Rebounder.speedY = 0;
Rebounder.animationFrame = 0;
Rebounder.animationTimer = 0;
Rebounder.spriteAngle = 0;
Rebounder.offscreenTimer = -1;
Rebounder.onScreen = false;
Rebounder.isHidden = false;


function Rebounder:setVelocity(velocity)
  self.velocity = velocity; 
  self.speedX = math.cos(velocity.angle) * velocity.speed;  
  self.speedY = math.sin(velocity.angle) * velocity.speed;
end
function Rebounder:getVelocity() return self.velocity end
function Rebounder:updateVelocity()
  self.velocity.angle = math.atan2(self.speedY, self.speedX);
  self.velocity.speed = math.sqrt(self.speedX*self.speedX + self.speedY*self.speedY);
end

function Rebounder:setSpeedX(speedX)
  self.speedX = speedX;
  self.velocity.angle = math.atan2(self.speedY, self.speedX);
  self.velocity.speed = math.sqrt(self.speedX*self.speedX + self.speedY*self.speedY);
end
function Rebounder:getSpeedX() return self.speedX end

function Rebounder:setSpeedY(speedY)
  self.speedY = speedY;
  self.velocity.angle = math.atan2(self.speedY, self.speedX);
  self.velocity.speed = math.sqrt(self.speedX*self.speedX + self.speedY*self.speedY);
end
function Rebounder:getSpeedY() return self.speedY end

function Rebounder:setSpeedXY(speedX, speedY)
  self.speedX = speedX;
  self.speedY = speedY;
  self.velocity.angle = math.atan2(self.speedY, self.speedX);
  self.velocity.speed = math.sqrt(self.speedX*self.speedX + self.speedY*self.speedY);
end

function Rebounder:initTrail()
  self.trail.frame = 0;
  self.trail.data = {};
  self.trail.cur = 0;
  for i=0, self.trail.length-1 do
    self.trail.data[i] = nil;
  end 
end

function Rebounder:reset()
  self.x = self.initial.x;
  self.y = self.initial.y;
  self:setVelocity(copy(self.initial.velocity));
  
  self.animationFrame = 0;
  self.animationTimer = 0;
  
  self.offscreenTimer = -1;
  
  if(self.trail ~= nil) then
    self:initTrail();
  end
end

function Rebounder.create(args)


  local newInstance = {}; -- our new object
  setmetatable(newInstance, Rebounder); -- make Rebounder handle lookup

  local preset;
  if(args.preset == nil) then 
    preset = _preset.podoboo;
  else
    assert(_preset[args.preset] ~= nil, "preset "..args.preset.." does not exist");
    preset = _preset[args.preset];
  end 
  
  assert(args.x ~= nil and type(args.x) == "number", "x coordinate must be a number");
  assert(args.y ~= nil and type(args.y) == "number", "y coordinate must be a number");
  newInstance.x = args.x;                                  
  newInstance.y = args.y;    
  
  newInstance.width  = args.width  or preset.width;
  newInstance.height = args.height or preset.height;
  
  newInstance.velocity = {};
  if(args.velocity ~= nil) then
    newInstance.velocity.speed = args.velocity.speed or preset.velocity.speed or 0;
    newInstance.velocity.angle = args.velocity.angle or args.velocity.angleRadian or preset.velocity.angle or 0;
    
    if(args.velocity.angleDegree ~= nil) then  
      newInstance.velocity.angle = args.velocity.angleDegree * math.pi / 180;
    end 
  
    newInstance:setVelocity(newInstance.velocity); -- calculate speedXY from velocity 
  elseif(args.speedX ~= nil or args.speedY ~= nil) then
    newInstance:setSpeedXY(args.speedX or 0, args.speedY or 0); --calculate velocity from speedXY
  elseif(preset.velocity ~= nil) then -- calculate speedXY from preset velocity 
    newInstance:setVelocity(copy(preset.velocity));
  elseif(preset.speedX ~= nil and preset.speedY ~= nil) then --calculate velocity from preset speedXY
    newInstance:setSpeedXY(preset.speedX, preset.speedY);
  else  
    newInstance:setVelocity(copy(newInstance.velocity));
  end 
  
  newInstance.section     = args.section     or getSection(newInstance.x,newInstance.y);
  newInstance.layer       = args.layer       or "Default";

  newInstance.spinjump    = args.spinjump    or preset.spinjump;
  newInstance.invincible  = args.invincible  or preset.invincible;
  newInstance.friendly    = args.friendly    or preset.friendly; 
  newInstance.message     = args.message     or {};
  
  newInstance.frameStyle  = args.frameStyle  or preset.frameStyle;
  newInstance.frames      = args.frames      or preset.frames;
  newInstance.frameTime   = args.frameTime   or preset.frameTime;
  
  newInstance.img         = images[args.img] or preset.img;
  newInstance.spriteAngle = args.spriteAngle or preset.spriteAngle or 0;
  
  -- create trail 
  
  newInstance.trail      = args.trail       or preset.trail;
  newInstance.trail = copy(newInstance.trail);
  
  if(args.trail ~= nil) then
    if(type(args.trail.img == "string")) then
      newInstance.trail.img = images[args.trail.img];
    end
  end
  if(newInstance.trail ~= nil) then
    newInstance:initTrail();
    
    newInstance.trail.width = newInstance.trail.width or newInstance.width;
    newInstance.trail.height = newInstance.trail.height or newInstance.height;
    
    newInstance.trail.vertexCoords = {};
    newInstance.trail.vertexCoords[0]  = -newInstance.trail.width/2; newInstance.trail.vertexCoords[1]  = -newInstance.trail.height/2;
    newInstance.trail.vertexCoords[2]  =  newInstance.trail.width/2; newInstance.trail.vertexCoords[3]  = -newInstance.trail.height/2;
    newInstance.trail.vertexCoords[4]  = -newInstance.trail.width/2; newInstance.trail.vertexCoords[5]  =  newInstance.trail.height/2;
    newInstance.trail.vertexCoords[6]  = -newInstance.trail.width/2; newInstance.trail.vertexCoords[7]  =  newInstance.trail.height/2;
    newInstance.trail.vertexCoords[8]  =  newInstance.trail.width/2; newInstance.trail.vertexCoords[9]  = -newInstance.trail.height/2;
    newInstance.trail.vertexCoords[10] =  newInstance.trail.width/2; newInstance.trail.vertexCoords[11] =  newInstance.trail.height/2;
  end

  
  
  newInstance.vertexCoords = {};
  newInstance.vertexCoords[0]  = -newInstance.width/2; newInstance.vertexCoords[1]  = -newInstance.height/2;
  newInstance.vertexCoords[2]  =  newInstance.width/2; newInstance.vertexCoords[3]  = -newInstance.height/2;
  newInstance.vertexCoords[4]  = -newInstance.width/2; newInstance.vertexCoords[5]  =  newInstance.height/2;
  newInstance.vertexCoords[6]  = -newInstance.width/2; newInstance.vertexCoords[7]  =  newInstance.height/2;
  newInstance.vertexCoords[8]  =  newInstance.width/2; newInstance.vertexCoords[9]  = -newInstance.height/2;
  newInstance.vertexCoords[10] =  newInstance.width/2; newInstance.vertexCoords[11] =  newInstance.height/2;

  -- reset to these initial values when entering/leaving a section
  newInstance.initial = {};
  newInstance.initial.x = newInstance.x;
  newInstance.initial.y = newInstance.y;
  newInstance.initial.velocity = copy(newInstance.velocity);
  
  
  table.insert(rebounders, newInstance);

  return newInstance;
end


function Rebounder.createFromJSON(npc)
  
  --[[
  --debug output of all pnpc.data for this npc
  file = io.open("output.txt", "a");
  io.output(file);
  debugOutput(npc.data, file, 0);
  io.close(file);
  ]]--
  
  local args = {};
  
  args.x = npc.x;
  args.y = npc.y;
  args.width = npc.width;
  args.height = npc.height;
  args.friendy = npc.friendy;
  args.section = npc:mem(0x146, FIELD_WORD); -- current section
  args.layer = tostring(npc.layerName);
  
  for k,v in pairs(npc.data.rebound) do
    args[k] = v;
    --TODO: velocity in radian or degree
  end 
  if(args.frameStyle ~= nil) then
    local fsString = args.frameStyle;
    args.frameStyle = rebound.frameStyle[args.frameStyle];
    if(args.frameStyle == nil) then
      error("No valid framestyle in JSON (\""..tostring(fsString).."\")",2);
    end 
  end
  
  return Rebounder.create(args);

end

function Rebounder:isOnscreen()
  local hitbox = colliders.Box(self.x,self.y,self.width,self.height);
  
  for k,v in pairs(cam) do 
  
    local cambox = colliders.Box(v.x, v.y, v.width, v.height);
    if (colliders.collide(hitbox, cambox) and Player.get()[k] ~= nil) then 
      return true; 
    end 
  end 
  
  return false;
end 

function Rebounder:setOffscreenTimer(offscreenTimer)
  local newTimer = math.max(offscreenTimer, -2);
  
  if(newTimer == 0 and self.offscreenTimer > 0) then 
    self:reset();
    if(self:isOnscreen()) then 
      newTimer = -2; -- prevents respawning until the player goes off screen once
    else 
      newTimer = -1; -- ready to respawn
    end 
  end
  
  self.offscreenTimer = newTimer;
end 

function Rebounder:updateIsHidden()
  local layerIsHidden = Layer.get(self.layer).isHidden;
  -- make hidden onscreen rebounder visible
  if(not layerIsHidden and self.isHidden and self:isOnscreen()) then 
    self:setOffscreenTimer(180);
    
  -- make visible rebounder invisible 
  elseif(layerIsHidden and self.offscreenTimer > 0) then 
    self:setOffscreenTimer(0);
  end 
  self.isHidden = layerIsHidden;
end 

function Rebounder:updateOnscreen()
  local onScreen = self:isOnscreen();
  
  -- offscreen rebounder gets onscreen 
  if(onScreen and (self.offscreenTimer >= -1)) then -- despawned or active offscreen rebounder gets onscreen 
    self:setOffscreenTimer(180);
  elseif(not onScreen and self.offscreenTimer > 0) then -- active rebounder is offscreen 
    if not(player.section == self.section 
	    or (player2 ~= nil and player2.section == self.section))  
    then -- active rebounder is not in player's section 
      self:setOffscreenTimer(0);
    else -- active rebounder is in player's section 
      self:setOffscreenTimer(self.offscreenTimer-1);
    end 
  elseif(self.offscreenTimer == -2 and not self:isOnscreen()) then 
    self:setOffscreenTimer(-1);
  end
  
  self.onScreen = onScreen;
end 

function Rebounder:update()
  
  self:updateOnscreen();
  self:updateIsHidden();
  
  if self.offscreenTimer <= 0 then return end 
  
  -- update the trail  

  if(self.trail ~= nil) then
    
    self.trail.frame = self.trail.frame + 1;
    if(self.trail.frame >= self.trail.spawnrate) then
      self.trail.frame = self.trail.frame % self.trail.spawnrate;
      
      self.trail.data[self.trail.cur] =
      {
        x = self.x,
        y = self.y,
        dir = self.speedX >= 0 and direction.right or direction.left,
        spriteOffset = self.trail.offsetIndex * self.trail.height;
      };
      self.trail.offsetIndex = (self.trail.offsetIndex + 1) % self.trail.sprites;
      self.trail.cur = (self.trail.cur + 1) % self.trail.length;
    end
  end 
  
  
  -- update the main body  
  
  local dirX = self.speedX >= 0 and direction.right or direction.left;
  local dirY = self.speedY >= 0 and direction.down or direction.up; 
  
  --advance the animation timers
  if(self.frames > 1) then
    self.animationTimer = self.animationTimer + 1;
    if(self.animationTimer >= self.frameTime) then
      self.animationTimer = self.animationTimer % self.frameTime;
      self.animationFrame = self.animationFrame + 1;
      if(self.animationFrame >= self.frames) then
        self.animationFrame = self.animationFrame % self.frames;
      end
    end
  end 
  
  -- check for block collision
  -- update position
  
  --Text.print("speedX "..self.speedX, 0, 60);
  --Text.print("speedY "..self.speedY, 0, 90);
  --Text.print("x "..self.x, 0, 120);
  --Text.print("y "..self.y, 0, 150);
  
  local HurtCollider =  colliders.Box(self.x+4,self.y+4,self.width-4,self.height-4);
  
  local collisionTable = {}
  --collisionTable.up    = colliders.Point(self.x + self.width/2, self.y                );
  --collisionTable.left  = colliders.Point(self.x               , self.y + self.height/2);
  --collisionTable.right = colliders.Point(self.x + self.width  , self.y + self.height/2);
  --collisionTable.down  = colliders.Point(self.x + self.width/2, self.y + self.height  );
  
  collisionTable.up    = colliders.Box(self.x+2,            self.y,            self.width-4,    1);
  collisionTable.left  = colliders.Box(self.x,              self.y+2,          1,               self.height-4);
  collisionTable.right = colliders.Box(self.x+self.width-1, self.y+2,          1,               self.height-4);
  collisionTable.down  = colliders.Box(self.x+2,            self.y+self.height-1, self.width-4, 1);
  
  local collisionResult = {up = false, left = false, right = false, down = false};
  
  for dir,col in pairs(collisionTable) do
    local _,_,list = colliders.collideBlock(col, colliders.BLOCK_SOLID..colliders.BLOCK_HURT..colliders.BLOCK_PLAYER)
    for _,q in ipairs(list) do
      if not q.isHidden then
        collisionResult[dir] = true;
      end
    end
  end
  
  if(collisionResult.up or collisionResult.left or collisionResult.right or collisionResult.down) then
    --Text.windowDebug("collision: "..(collisionResult.up and "up " or "") ..
    --                                (collisionResult.left and "left " or "") ..
    --                                (collisionResult.right and "right " or "") ..
    --                                (collisionResult.down and "down " or ""));
  end
  
  if(collisionResult.up   and dirY == direction.up and not collisionResult.down or
     collisionResult.down and dirY == direction.down and not collisionResult.up) then
     
    self.speedY = -self.speedY;
  end 
  
  
  if(collisionResult.left  and dirX == direction.left  and not collisionResult.right or
     collisionResult.right and dirX == direction.right and not collisionResult.left) then
     
     --if(collisionResult.right and not collisionResult.left) then
     -- Text.windowDebug("RIGHT NOT LEFT");
     --elseif(collisionResult.right and dirX < 0) then
     -- Text.windowDebug("RIGHT <----");
     --elseif(collisionResult.right and dirX > 0) then
     -- Text.windowDebug("RIGHT ---->");
     --end
     
    self.speedX = -self.speedX;
  end
  self:updateVelocity();

  self.x = self.x + self.speedX;
  self.y = self.y + self.speedY;
  
  -- player collision  
  local bouncebox = colliders.Box(self.x,self.y,self.width,self.height);
  local hitbox = colliders.Box(self.x+6,self.y+6,self.width-12,self.height-12);
  for _,p in pairs({player, player2}) do
  
    local bounce, spinjump = colliders.bounce(p,bouncebox);
    local downSlash = colliders.downSlash(p,hitbox);
    
    if(bounce and p.DeathTimer == 0 and not inStar) then -- bouncing off of the rebounder
      if(self.spinjump and (spinjump or downSlash or p.MountType == MOUNT_TYPES.yoshi or p.MountType == MOUNT_TYPES.shoe) ) then
        colliders.bounceResponse(p);
      else
        p:harm();
      end
    elseif(colliders.collide(p,hitbox)) then -- colliding with the rebounder
      --check for starman 
      if(not self.invincible and inStar) then  
        -- TODO: kill self
      else
        p:harm();
      end
    elseif(self.trail ~= nil) then -- check for trail collision
      local trailWidth = self.trail.img.width;
      local trailHeight = self.trail.img.height / self.trail.sprites;
      for _,trailObj in pairs(self.trail.data) do 
        local trailHitbox = colliders.Box(trailObj.x+6, trailObj.y+6, trailWidth-12, trailHeight-12);
        if(colliders.collide(p,trailHitbox) and not inStar) then 
          p:harm();
        end
      end 
    end 
    
  end
  

end

function Rebounder:draw()

  if self.offscreenTimer <= 0  then return end 

  --Calculate texture coordinates
  local top    = (0        + (self.animationFrame * self.height))/self.img.height;
  local bottom = (self.height + (self.animationFrame * self.height))/self.img.height;
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
  local vtx = {};
  
  if(self.frameStyle == rebound.frameStyle.rotate) then  
    vtx = translate(rotate(self.vertexCoords,self.velocity.angle - self.spriteAngle), self.x+self.width/2, self.y+self.height/2);  
  elseif(self.frameStyle == rebound.frameStyle.leftRight) then  
    vtx = translate((self.speedX < 0 and flipX(self.vertexCoords) or self.vertexCoords), self.x+self.width/2, self.y+self.height/2);
  elseif(self.frameStyle == rebound.frameStyle.singleSprite) then  
    vtx = translate(self.vertexCoords, self.x+self.width/2, self.y+self.height/2);
  else  
    error("No valid framestyle selected (\""..tostring(self.frameStyle).."\")",2);
  end
  
  Graphics.glDraw{
    texture = self.img,
    vertexCoords = vtx,
    textureCoords = texCoords,
    sceneCoords = true,
    priority = -15.0
  };
  
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
  if(self.trail ~= nil) then
    for i=self.trail.cur, #self.trail.data do
      local v = self.trail.data[i];
      if(v ~= nil) then
        drawTrailObj(v, self.trail); 
      end
    end 
    for i=0, self.trail.cur-1 do
      local v = self.trail.data[i];
      if(v ~= nil) then
        drawTrailObj(v, self.trail); 
      end
    end 
  end--(self.trail ~= nil)
  
  
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
    priority = -15.0
  }
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
  for i=0, trail.length-1 do
    trail.data[i] = nil;
  end 
end


function rebound.initialize(npc)


	
	--TODO: use these from npc instead of from npc.rebound
	--dataSource.x = npc.x; check
	--dataSource.y = npc.y; check 
	--dataSource.width = npc.width; check 
	--dataSource.height = npc.height; check 
	--dataSource.friendy = npc.friendy;
	--dataSource.section = npc:mem(0x146, FIELD_WORD); -- current section
	--dataSource.layer = tostring(npc.layerName);

	local dataSource = {};
	npc.data.rebound = {};

	-- read configuration from the npc message text
	for w in string.gmatch(tostring(npc.msg), "([^,]+)") do
		key, value = w:match("%s*(%S+)%s*=%s*(%S+)%s*");

    if(value:match("^\".*\"$") or value:match("^'.*'$")) then -- string surrounded by ' ' or " " 
      value = string.sub(value, 2, -2);
    elseif(value:match("%f[%.%d]%d*%.?%d*%f[^%.%d%]]")) then -- numbers/decimals
      value = tonumber(value);
    elseif(value:match("true")) then -- boolean
      value = true;
    elseif(value:match("false")) then 
      value = false;
    end 

		dataSource[key] = value;
	end --for

	local preset;
  if(dataSource.preset == nil) then 
    preset = _preset.podoboo;
  else
    assert(_preset[dataSource.preset] ~= nil, "preset "..dataSource.preset.." does not exist");
    preset = _preset[dataSource.preset];
  end 

  npc.width  = dataSource.width  or preset.width;
  npc.height = dataSource.height or preset.height;
  
  local velocity = {};
	local speedX;
	local speedY; 
  if(dataSource.velocity ~= nil) then
    dataSource.velocity.speed = dataSource.velocity.speed or preset.velocity.speed or 0;
    dataSource.velocity.angle = dataSource.velocity.angle * math.pi / 180 or dataSource.velocity.angleRadian or preset.velocity.angle or 0;
  
    dataSource.speedX, dataSource.speedY = velocityToSpeedXY(dataSource.velocity); -- calculate speedXY from velocity 
  elseif(dataSource.speedX ~= nil or dataSource.speedY ~= nil) then
		dataSource.speedX = dataSource.speedX or 0;
		dataSource.speedY = dataSource.speedY or 0;
    dataSource.velocity = speedXYToVelocity(dataSource.speedX, dataSource.speedY); --calculate velocity from speedXY
  elseif(preset.velocity ~= nil) then -- calculate speedXY from preset velocity 
		dataSource.velocity = copy(preset.velocity);
		dataSource.speedX, dataSource.speedY = velocityToSpeedXY(dataSource.velocity);
  elseif(preset.speedX ~= nil or preset.speedY ~= nil) then --calculate velocity from preset speedXY
		dataSource.speedX = preset.speedX or 0;
		dataSource.speedY = preset.speedY or 0;
		dataSource.velocity = speedXYToVelocity(dataSource.speedX, dataSource.speedY);
  else  
		dataSource.velocity = {speed = 0, angle = 0};
		dataSource.speedX, dataSource.speedY = velocityToSpeedXY(dataSource.velocity);
  end 
  

  dataSource.spinjump    = dataSource.spinjump    or preset.spinjump;
  dataSource.invincible  = dataSource.invincible  or preset.invincible;
  dataSource.message     = dataSource.message     or "";
  
  dataSource.frameStyle  = dataSource.frameStyle  or preset.frameStyle;
  dataSource.frames      = dataSource.frames      or preset.frames;
  dataSource.frameTime   = dataSource.frameTime   or preset.frameTime;
  
  dataSource.img         = images[dataSource.img] or preset.img;
  dataSource.spriteAngle = dataSource.spriteAngle or preset.spriteAngle or 0;

  -- create trail 
  
  dataSource.trail       = dataSource.trail       or preset.trail;
  dataSource.trail = copy(dataSource.trail);
  
  if(dataSource.trail ~= nil) then
		if(type(dataSource.trail.img == "string")) then
      dataSource.trail.img = images[dataSource.trail.img];
    end
    rebound.initTrail(dataSource.trail);
    
    dataSource.trail.width = dataSource.trail.width or npc.width;
    dataSource.trail.height = dataSource.trail.height or npc.height;
    
    dataSource.trail.vertexCoords = {};
    dataSource.trail.vertexCoords[0]  = -dataSource.trail.width/2; dataSource.trail.vertexCoords[1]  = -dataSource.trail.height/2;
    dataSource.trail.vertexCoords[2]  =  dataSource.trail.width/2; dataSource.trail.vertexCoords[3]  = -dataSource.trail.height/2;
    dataSource.trail.vertexCoords[4]  = -dataSource.trail.width/2; dataSource.trail.vertexCoords[5]  =  dataSource.trail.height/2;
    dataSource.trail.vertexCoords[6]  = -dataSource.trail.width/2; dataSource.trail.vertexCoords[7]  =  dataSource.trail.height/2;
    dataSource.trail.vertexCoords[8]  =  dataSource.trail.width/2; dataSource.trail.vertexCoords[9]  = -dataSource.trail.height/2;
    dataSource.trail.vertexCoords[10] =  dataSource.trail.width/2; dataSource.trail.vertexCoords[11] =  dataSource.trail.height/2;
  end

  
  
  dataSource.vertexCoords = {};
  dataSource.vertexCoords[0]  = -npc.width/2; dataSource.vertexCoords[1]  = -npc.height/2;
  dataSource.vertexCoords[2]  =  npc.width/2; dataSource.vertexCoords[3]  = -npc.height/2;
  dataSource.vertexCoords[4]  = -npc.width/2; dataSource.vertexCoords[5]  =  npc.height/2;
  dataSource.vertexCoords[6]  = -npc.width/2; dataSource.vertexCoords[7]  =  npc.height/2;
  dataSource.vertexCoords[8]  =  npc.width/2; dataSource.vertexCoords[9]  = -npc.height/2;
  dataSource.vertexCoords[10] =  npc.width/2; dataSource.vertexCoords[11] =  npc.height/2;

  -- reset to these initial values when despawning (offscreen too long, offsection, or hidden)
  dataSource.initial = {};
  dataSource.initial.velocity = copy(dataSource.velocity);
  
	npc.data.rebound = dataSource;
end

function rebound.draw(npc)

	--if not npc.frameStyle == 2 then return end;

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
    priority = -15.0
  };
  
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
  end--(npc.data.rebound.trail ~= nil)
  
  
end









local NPCMEM_OFFSCREEN_TIMER = 0x12A; --FIELD_WORD
local NPCMEM_PREVENT_RESPAWN = 0x124; --FIELD_WORD
local NPCMEM_GENERATOR = 0x64; --FIELD_WORD
local NPCMEM_IS_HIDDEN = 0x40; --FIELD_WORD

-- DEFAULT VALUES FOR THE NPC

local podobooGfxHeight = 32;
local podobooGfxWidth = 32;
local podobooWidth = 32;
local podobooHeight = 32;
local podobooFrameSpeed = 4;
local podobooFrames = 2;
local podobooFrameStyle = 2;
local podobooNoGravity = 1;

-- NPC CONFIGURATION FOR THE NPC

if Misc.resolveFile("npc-297.txt") ~= nil then
	local configFile = configFileReader.parseTxt("npc-297.txt");
	podobooGfxWidth   = configFile.gfxwidth       or podobooGfxHeight;
	podobooGfxHeight  = configFile.gfxheight      or podobooGfxWidth;
	podobooWidth      = configFile.width          or podobooWidth;
	podobooHeight     = configFile.height         or podobooHeight;
	podobooFrameSpeed = configFile.framespeed     or podobooFrameSpeed;
	podobooFrames     = configFile.frames         or podobooFrames;
	podobooFrameStyle = configFile.framestyle     or podobooFrameStyle;
  podobooNoGravity  = configFile.nogravity      or podobooNoGravity;
end

npcconfig[PODOBOO_NPCID].gfxwidth   = podobooGfxWidth;
npcconfig[PODOBOO_NPCID].gfxheight  = podobooGfxHeight;
npcconfig[PODOBOO_NPCID].width      = podobooWidth;
npcconfig[PODOBOO_NPCID].height     = podobooHeight;
npcconfig[PODOBOO_NPCID].frames     = podobooFrames;
npcconfig[PODOBOO_NPCID].framestyle = podobooFrameStyle;
npcconfig[PODOBOO_NPCID].framespeed = podobooFrameSpeed;
npcconfig[PODOBOO_NPCID].nogravity  = podobooNoGravity;


--npcconfig[1].framespeed = 16;


function rebound.onStart()
	--Graphics.sprites.npc[297].img = Graphics.loadImageResolved("luaResources/Shared/blankImage.png");
end 

function rebound.onTick()


	--Text.windowDebug(tostring(npcconfig[1].framespeed));

  --[[ PURE LUA NPC VERSION

  -- tranform NPCs with JSON tag "rebound" to Rebounder objects
  for _,v in pairs(NPC.get(PODOBOO_NPCID, -1)) do
    local npc = pnpc.wrap(v);
    
    if(npc.data.rebound ~= nil) then
      Rebounder.createFromJSON(npc);
      v:kill(9);
    end
  end
  
   update all Rebounders
  for _,v in pairs(rebounders) do
    v:update();
  end

  ]]-- PURE LUA NPC VERSION

  -- SMBX NPC VERSION
  
  for _,v in pairs(NPC.get(PODOBOO_NPCID, -1)) do --for each podoboo
    if v:mem(NPCMEM_GENERATOR,FIELD_WORD) ~= -1 and v:mem(NPCMEM_PREVENT_RESPAWN, FIELD_WORD) ~= 0 then
			local npc = pnpc.wrap(v);
    

			if(npc.data.rebound == nil) then
				rebound.initialize(npc);
			end 

			Text.print("timer:  "..tostring(npc.animationTimer),0,60);
			Text.print("frame:  "..tostring(npc.animationFrame),0,90);

			-- update movement

			-- check player/npc collision




    end
  end --for each podoboo

end


function rebound.onDraw()
	--[[ PURE LUA NPC VERSION
  for _,v in pairs(rebounders) do
    v:draw();
  end
	]]--
	
	-- SMBX NPC VERSION

	for _,v in pairs(NPC.get(PODOBOO_NPCID, -1)) do
		if v:mem(NPCMEM_GENERATOR,FIELD_WORD) ~= -1 and
		   v:mem(NPCMEM_PREVENT_RESPAWN, FIELD_WORD) ~= 0 and 
			 v:mem(NPCMEM_OFFSCREEN_TIMER, FIELD_WORD) > 0 
		then
			local npc = pnpc.wrap(v);
			--rebound.draw(npc);
		end 
  end


end

return rebound;

