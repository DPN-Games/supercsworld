--booBuddies.lua 
--v1.0.2
--Created by S1eth, 2016

local pnpc = API.load("pnpc")
local colliders = API.load("colliders");
local configFileReader = API.load("configFileReader");
local rng = API.load("rng");
local starman = API.load("starman");

local booBuddies = {};

function booBuddies.onInitAPI()
  registerEvent(booBuddies, "onStart", "onStart", false) -- Reigster the start event 
  registerEvent(booBuddies, "onTick", "onTick", true); --Register the loop event
  registerEvent(booBuddies, "onDraw", "onDraw", true); --Register the draw event
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
--              PRIVATE CONSTANTS                                                                   *
--                                                                                                  *
--***************************************************************************************************

local BOOCIRCLE_NPCID = 294;

-- boo types used in SMW's boo buddies
local BOO_TYPES_SMW = {0, 1, 2, 0}; --repeats when more than 4 boos are used

-- load spritesheet for the boos 
local DEFAULT_IMG_PATH = Misc.resolveFile("booCircle.png") or Misc.resolveFile("graphics/luaResources/booCircle/booCircle.png");

local images = {};
images[DEFAULT_IMG_PATH] = Graphics.loadImage(DEFAULT_IMG_PATH);

local MOUNT_TYPES = {shoe = 1, yoshi = 3};

local style = {SMW = 0, SMB3 = 1, SMB1 = 2, SMM_SMW = 3};

local direction = {right = 0, left = 1};

local angularDirection = {clockwise = 1, CW = 1, counterclockwise = -1, CCW = -1};

local _preset = {};
_preset.SMW = {};
_preset.SMW.style            = "SMW";
_preset.SMW.numberOfBoos     = 10;
_preset.SMW.booSpacing       = 0.483321947;
_preset.SMW.circleRadius     = 5 * 32;
_preset.SMW.angularSpeed     = math.pi / 275;
_preset.SMW.angularDirection = angularDirection.clockwise;
_preset.SMW.diesTo           = {shoe = false, starman = false};
_preset.SMW.canSpinjump      = false;
_preset.SMW.frameTime        = 8;

_preset.SMM = {};
_preset.SMM.style            = "SMM_SMW";
_preset.SMM.numberOfBoos     = 8;
_preset.SMM.booSpacing       = math.pi / 4.5;
_preset.SMM.circleRadius     = 3 * 32;
_preset.SMM.angularSpeed     = math.pi / 240;
_preset.SMM.angularDirection = angularDirection.clockwise;
_preset.SMM.diesTo           = {shoe = true, starman = true};
_preset.SMM.canSpinjump      = true;
_preset.SMM.frameTime        = 8;

_preset.CONFIG = copy(_preset.SMW);


--***************************************************************************************************
--                                                                                                  *
--              PUBLIC MEMBERS                                                                      *
--                                                                                                  *
--***************************************************************************************************


booBuddies.booNPCID = {SMW = 43, SMB3 = 38, SMB1 = 38, SMM_SMW = 43};

--***************************************************************************************************
--                                                                                                  *
--              CLASS: Boo                                                                          *
--                                                                                                  *
--***************************************************************************************************

local Boo = {};
Boo.__index = Boo;
Boo.isAlive = true;

function Boo.create()
  local newInstance = {};
  setmetatable(newInstance, Boo);
  
	newInstance.dir = rng.irandomEntry{direction.left,direction.right}

  return newInstance;
end 

-- get the graphic rectangle for a specific boo animation frame 
function getBooRectangle(styleIndex, direction, booIndex, frameIndex)
  local rectangle = { width = 32, height = 32};  
  rectangle.left = style[styleIndex] * 96 + ((styleIndex == "SMW") and booIndex * 32 or 0); -- only SMW has multiple boo types (for now?) 
	rectangle.top  = direction * 64         + ((styleIndex == "SMW") and frameIndex * 32 or 0); -- only SMW has animation frames (for now?)
  return rectangle;
end

--***************************************************************************************************
--                                                                                                  *
--              CLASS: BooCircle                                                                    *
--                                                                                                  *
--***************************************************************************************************

local booCircleTable = {};

local BooCircle = {}
BooCircle.__index = BooCircle;
BooCircle.isActive = false;
BooCircle.toBeDeleted = false;
BooCircle.toBeKilled = false;
BooCircle.initial = {};

function BooCircle.create(args)
  local newInstance = {} -- our new object
  setmetatable (newInstance, BooCircle) -- make BooCircle handle lookup
  
  local preset;
  if(args.preset == nil) then 
    preset = _preset.CONFIG;
  else
    assert(_preset[args.preset] ~= nil, "preset "..tostring(args.preset).." does not exist");
    preset = _preset[args.preset];
  end 

	

	if(args.style) then  
		assert(style[args.style] ~= nil, "style "..tostring(args.style).." does not exist");
		newInstance.style = args.style;
	else
		newInstance.style = preset.style;	
	end 
  
  assert(args.x ~= nil and type(args.x) == "number", "x coordinate must be a number");
  assert(args.y ~= nil and type(args.y) == "number", "y coordinate must be a number");
  newInstance.x                 = args.x                                  
  newInstance.y                 = args.y                                   

  newInstance.section           = args.section                            or getSection(newInstance.x,newInstance.y);
  newInstance.layer             = args.layer                              or "Default";

  newInstance.circleRadius      = args.circleRadius                       or preset.circleRadius;
  newInstance.angularSpeed      = args.angularSpeed                       or preset.angularSpeed;
  newInstance.angularDirection  = angularDirection[args.angularDirection] or preset.angularDirection;
  newInstance.numberOfBoos      = args.numberOfBoos                       or preset.numberOfBoos;
  newInstance.booRadius         = args.booRadius                          or 10;
  newInstance.frameTime         = args.frameTime                          or preset.frameTime;
  newInstance.frame             = args.frame                              or 0;
  newInstance.booSpacing        = args.booSpacing                         or preset.booSpacing; 
  newInstance.angle             = args.angle                              or math.pi*1.5 - (newInstance.booSpacing * (newInstance.numberOfBoos-1)/2); 

	newInstance.diesTo            = copy(args.diesTo)                       or copy(preset.diesTo);
	newInstance.canSpinjump       = args.canSpinjump                        or preset.canSpinjump;

	newInstance.image             = args.image                              or images[DEFAULT_IMG_PATH];

	newInstance.friendly          = args.friendly														or false;

  -- reset to these initial values when entering/leaving a section
  newInstance.initial.angle = newInstance.angle;  
  newInstance.initial.frame = newInstance.frame; 
  
  newInstance.boos = {};
  for i=1,newInstance.numberOfBoos,1 do
    table.insert(newInstance.boos, Boo.create()); 
  end 
  
  table.insert (booCircleTable, newInstance)
  return newInstance;
end

function BooCircle:update()

  -- Deactivate if not on a visible layer or current section
  -- reset the cycle
  if Layer.get(self.layer).isHidden 
  or not(player.section == self.section 
         or (player2 ~= nil and player2.section == self.section)) 
  then 
    if (self.isActive) then 
      self.isActive = false;
      self.angle = self.initial.angle;
      self.frame = self.initial.frame;
    end 
    return; 
  end
  
  -- Reactivate 
  if not self.isActive then 
    self.isActive = true;
  end

	if not Defines.levelFreeze then 
		--update position
		self.angle = self.angle + self.angularSpeed * self.angularDirection;
		self.frame = (self.frame + 1) % (self.frameTime * 2);

		for i,boo in pairs(self.boos) do
			if(boo.isAlive) then
				local booX = round(self.x + self.circleRadius * math.cos(self.angle + (i-1) * self.booSpacing));
				local booY = round(self.y + self.circleRadius * math.sin(self.angle + (i-1) * self.booSpacing));
    
				if(self.style ~= "SMW") then 
					if(player.x + player.width/2 <= booX) then  
						boo.dir = direction.left;
					else
						boo.dir = direction.right;
					end
				end 

			end
		end -- for i,boo in pairs(self.boos)
	end 

  --check collision with player
	if(not self.friendly) then 

		for i,boo in pairs(self.boos) do
    
			if(boo.isAlive) then
				local booX = round(self.x + self.circleRadius * math.cos(self.angle + (i-1) * self.booSpacing));
				local booY = round(self.y + self.circleRadius * math.sin(self.angle + (i-1) * self.booSpacing));
    
				local hitbox = colliders.Circle(booX, booY, self.booRadius);
				for _,p in pairs({player, player2}) do
      
					local bounce, spinjump = colliders.bounce(p,hitbox);
					local downSlash = colliders.downSlash(p,hitbox);

					if(bounce and p.DeathTimer == 0 and not starman.inStar) then
						if(self.canSpinjump and (spinjump or downSlash or p.MountType == MOUNT_TYPES.yoshi or p.MountType == MOUNT_TYPES.shoe) or 
							 self.diesTo.shoe and p.MountType == MOUNT_TYPES.shoe) then
							colliders.bounceResponse(p);
							if(self.diesTo.shoe and p.MountType == MOUNT_TYPES.shoe) then 
								self:killBoo(boo, booX, booY); 
							end 
						else
							p:harm();
						end
					elseif(colliders.collide(p,hitbox)) then
						--check for starman 
						if(self.diesTo["starman"] and starman.inStar) then 
							self:killBoo(boo, booX, booY);
						else
							p:harm();
						end
					end
        
				end
			end
 
		end -- for i,boo in pairs(self.boos)

	end   
end -- BooCircle:update()

function BooCircle:draw()

  if not self.isActive  then return end 


  for i,boo in pairs(self.boos) do
    if(boo.isAlive) then
      local booX = round(self.x + self.circleRadius * math.cos(self.angle + (i-1) * self.booSpacing));
      local booY = round(self.y + self.circleRadius * math.sin(self.angle + (i-1) * self.booSpacing));
      
      local booRect;
      if (self.frame < self.frameTime) then
        booRect = getBooRectangle(self.style, boo.dir, BOO_TYPES_SMW[1+((i-1) % 4)], 0);
      else
        booRect = getBooRectangle(self.style, boo.dir, BOO_TYPES_SMW[1+((i-1) % 4)], 1);
      end
      
      Graphics.drawImageToSceneWP(self.image, booX-16, booY-16, booRect.left, booRect.top, booRect.width, booRect.height, -45.0);
    end
  end -- for i,boo in pairs(self.boos)
  
end -- BooCircle:draw()

function BooCircle:delete()
  self.toBeDeleted = true; -- delete during next onTick()  
end

function BooCircle:kill()
  self.toBeKilled = true; -- kill during next onTick()  
end

function BooCircle:killBoos()
  for i,boo in pairs(self.boos) do
    if(boo.isAlive) then
      local booX = round(self.x + self.circleRadius * math.cos(self.angle + (i-1) * self.booSpacing));
      local booY = round(self.y + self.circleRadius * math.sin(self.angle + (i-1) * self.booSpacing));
    
      self:killBoo(boo, booX, booY); 
    end
  end -- for i,boo in pairs(self.boos)
end

function BooCircle:killBoo(boo, x, y)
  boo.isAlive = false;
  
  NPC.spawn(booBuddies.booNPCID[self.style], x-16, y-16, self.section):kill();
end

function booBuddies.create(args)
  return BooCircle.create(args);
end

function booBuddies.onStart()
  if Misc.resolveFile("npc-294.txt") ~= nil then
    local booSettings = configFileReader.parseTxt("npc-294.txt");

		if(booSettings["style"]            ~= nil) then _preset.CONFIG.style            = booSettings["style"] end 
		if(booSettings["numberOfBoos"]     ~= nil) then _preset.CONFIG.numberOfBoos     = booSettings["numberOfBoos"] end 
		if(booSettings["booSpacing"]       ~= nil) then _preset.CONFIG.booSpacing       = booSettings["booSpacing"] end 
		if(booSettings["circleRadius"]     ~= nil) then _preset.CONFIG.circleRadius     = booSettings["circleRadius"] end 
		if(booSettings["angularSpeed"]     ~= nil) then _preset.CONFIG.angularSpeed     = booSettings["angularSpeed"] end 
		if(booSettings["angularDirection"] ~= nil) then _preset.CONFIG.angularDirection = booSettings["angularDirection"] end 
		if(booSettings["frameSpeed"]       ~= nil) then _preset.CONFIG.frameTime        = booSettings["frameSpeed"] end 
		if(booSettings["diesToShoe"]       ~= nil) then _preset.CONFIG.diesTo.shoe      = booSettings["diesToShoe"] end 
    if(booSettings["diesToStarman"]    ~= nil) then _preset.CONFIG.diesTo.starman   = booSettings["diesToStarman"] end 
    if(booSettings["canSpinjump"]      ~= nil) then _preset.CONFIG.canSpinjump      = booSettings["canSpinjump"] end 
  end
end 

function booBuddies.onTick()

	--replace dummy NPCs with BooCircle objects
	for _, v in pairs(NPC.get(BOOCIRCLE_NPCID, player.section)) do
		local npc = pnpc.wrap(v);
		if npc:mem(0x64, FIELD_WORD) == 0 then
			if(npc.data.booCircle == nil) then -- use npcParse result as data source
				npc.data.booCircle = {};
			end

			if(npc.data.booCircle["layer"] == '') then npc.data.booCircle["layer"] = "Default" end 
			if(npc.data.booCircle["image"] ~= nil) then 
				npc.data.booCircle["image"] = Misc.resolveFile(npc.data.booCircle["image"]);
				if(images[npc.data.booCircle["image"]] == nil) then -- image not loaded
					images[npc.data.booCircle["image"]] = Graphics.loadImage(npc.data.booCircle["image"]); -- load image
				end
			end 

			booBuddies.create({
				x = npc.x+npc.width/2, 
				y = npc.y+npc.height/2, 
				preset = npc.data.booCircle["preset"], 
				style = npc.data.booCircle["style"], 
				circleRadius = npc.data.booCircle["circleRadius"], 
				angularSpeed = npc.data.booCircle["angularSpeed"], 
				angularDirection = npc.data.booCircle["angularDirection"], 
				numberOfBoos = npc.data.booCircle["numberOfBoos"], 
				booRadius = npc.data.booCircle["booRadius"], 
				frameTime = npc.data.booCircle["frameTime"], 
				booSpacing = npc.data.booCircle["booSpacing"], 
				angle = npc.data.booCircle["angle"], 
				layer = npc.data.booCircle["layer"], 
				section = player.section, 
				image = images[npc.data.booCircle["image"]],
				friendly = npc.friendly
			});

			npc:kill(9);
		end
	end

  
  for i=#booCircleTable,1,-1 do
    --delete circles with the toBeKilled flag 
    if(booCircleTable[i].toBeKilled == true) then
      booCircleTable[i]:killBoos();
    end
    --delete circles with the toBeKilled flag 
    if(booCircleTable[i].toBeDeleted == true) then
      table.remove(booCircleTable, i);
    end
  end

  for _,booCircle in pairs (booCircleTable) do
    booCircle:update();
  end
end

function booBuddies.onDraw() 
  for _,booCircle in pairs (booCircleTable) do
    booCircle:draw();
  end
end

return booBuddies;