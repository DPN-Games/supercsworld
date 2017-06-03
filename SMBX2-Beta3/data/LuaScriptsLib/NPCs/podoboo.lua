--[[
---------------------
---- Podoboo.lua ----
-- Created by Pyro --
---- Version 2.0 ----
---------------------

-------------------------
-- Quick Documentation --
-------------------------
podoboo.lua is a Lua library you can use to create the Bouncing Podoboos/Diagonal Podoboos from some castle levels in Super Mario World.
The podoboo itself is fairly customizable.
To enable it, load the API like you would any other api. THEN, in the NPC message of a Podoboo (NPC ID 12) type in 'bounce=1' anywhere.
You also have some customization options that you can also access by typing in stuff in the message. For example, if you wanted to make the podoboo have a very
slow speed, you would type in 'speed=.5' anywhere in the message. Here are some options you can use:
	speed - The general speed, affecting both X speed and Y speed. Default is 1.5.
	speedXMod - X speed modifier. Default is 0.
	speedYMod - Y speed modifier. Default is 0.
	framespeed - The animation speed. The higher the number is, the slower the podoboo flickers. Default is 4.
	width - The width of the sprite. Use if you want to resprite the podoboo. Default is 32.
	height - The height of the sprite. Use if you want to resprite the podoboo. Default is 32.
	flicker - If this is set to 0, then the podoboo will not flicker.
	invincible - If this is set to 1, then the podoboo will not be killable.
	spinjump - If this is set to 0, then the podoboo will not be able to be spinjumped on.
	message - The message of the podoboo. Format it like this - message="your message goes here"
	friendly - Just like normal friendliness. Set to 1 and the podoboo will be friendly.
]]--

-- Load APIs
local colliders = API.load("colliders")
local pnpc = API.load("pnpc")

-- Set up podoboo tables
podoboo = {}
local tableOfPodoboos = {}

-- Sprite stuff
local podobooSprite = 0;

local beetleGraphic = Graphics.loadImage((Misc.resolveFile("podoboo.png") or Misc.resolveFile("graphics/new_npcs/podoboo.png")))

local messageSprite = Graphics.loadImage((Misc.resolveFile("hardcoded-43.png") or Misc.resolveFile("graphics/hardcoded/hardcoded-43.png")))

local useCamera = Camera.get()[1]
 
-- Draw the podoboo

local function drawPodobooSprite(npc)
	Graphics.drawImageToSceneWP(podobooSprite, npc.x, npc.y, 0, (npc.offset*64) + (npc.flicker*32), 32, 32, 1, -15.0)
end

-- THE ACTUAL CODE --

function podoboo.onInitAPI()
	-- Register onTick and onDraw for use
    registerEvent(podoboo, "onTick", "onTick", false)
	registerEvent(podoboo, "onDraw", "onDraw", false)
end
 
function podoboo.onTick()
	-- Check if any podoboos have certain keywords in their message. If so, kill the podoboo and insert some settings into a table
    for _,v in ipairs(NPC.get(12,-1)) do
		if string.find(v.msg.str, "bounce=1") ~= nil then
			local entry = {}
			entry.x = v.x;
			entry.y = v.y;
			if string.match(v.msg.str, 'width=(%-?%d*%.?%d+)') ~= nil then
				entry.width = tonumber(string.match(v.msg.str, 'width=(%-?%d*%.?%d+)'))
			else
				entry.width = 32;
			end
			if string.match(v.msg.str, 'height=(%-?%d*%.?%d+)') ~= nil then
				entry.height = tonumber(string.match(v.msg.str, 'height=(%-?%d*%.?%d+)'))
			else
				entry.height = 32;
			end
			entry.ticker = 0;
			entry.offset = 0;
			entry.flicker = 0;
			if string.match(v.msg.str, 'framespeed=(%-?%d*%.?%d+)') ~= nil then
				entry.framespeed = tonumber(string.match(v.msg.str, 'framespeed=(%-?%d*%.?%d+)'))
			else
				entry.framespeed = 4;
			end
			entry.direction = v.direction;
			if string.match(v.msg.str, 'speed=(%-?%d*%.?%d+)') ~= nil then
				entry.speed = tonumber(string.match(v.msg.str, 'speed=(%-?%d*%.?%d+)'))
			else
				entry.speed = 1.5;
			end
			entry.willFlicker = tonumber(string.match(v.msg.str, 'flicker=(%-?%d*%.?%d+)'))
			entry.invincible = tonumber(string.match(v.msg.str, 'invincible=(%-?%d*%.?%d+)'))
			entry.spinjump = tonumber(string.match(v.msg.str, 'spinjump=(%-?%d*%.?%d+)'))
			entry.invisible = false;
			entry.friendly = tonumber(string.match(v.msg.str, 'friendly=(%-?%d*%.?%d+)'))
			entry.message = string.match(v.msg.str, 'message=(.+)')
			if string.match(v.msg.str, 'speedXMod=(%-?%d*%.?%d+)') ~= nil then
				entry.speedXMod = tonumber(string.match(v.msg.str, 'speedXMod=(%-?%d*%.?%d+)'))
			else
				entry.speedXMod = 0;
			end
			if string.match(v.msg.str, 'speedYMod=(%-?%d*%.?%d+)') ~= nil then
				entry.speedYMod = tonumber(string.match(v.msg.str, 'speedYMod=(%-?%d*%.?%d+)'))
			else
				entry.speedYMod = 0;
			end
			table.insert(tableOfPodoboos,entry)
			
			v:kill(9)
		end
	end
	
	-- Run code on new Lua diagonal podoboos
	
	for butt,v in ipairs(tableOfPodoboos) do
		-- colliders
		
		local podobooHurtCollider = colliders.Box(v.x+4,v.y+4,v.width-4,v.height-4)
		local podobooUpCollider = colliders.Box(v.x + (v.width/2),v.y,2,1)
		local podobooLeftCollider = colliders.Box(v.x,v.y + (v.height/2),2,1)
		local podobooDownCollider = colliders.Box(v.x + (v.width/2),v.y+(v.height-2),2,1)
		local podobooRightCollider = colliders.Box(v.x+(v.width-2),v.y + (v.height/2),2,1)
		
		-- speed stuff
		
		local speedModifierX = {}
		speedModifierX[0] = -1;
		speedModifierX[1] = -1;
		speedModifierX[2] = 1;
		speedModifierX[3] = 1;
		local speedModifierY = {}
		speedModifierY[0] = -1;
		speedModifierY[1] = 1;
		speedModifierY[2] = -1;
		speedModifierY[3] = 1;
		
		if v.x > useCamera.x-64 and v.x < useCamera.x+864 and v.y > useCamera.y-64 and v.y < useCamera.y+664 then
			v.y = v.y + v.speedYMod + (v.speed * speedModifierY[v.offset]);
			v.x = v.x + v.speedXMod + (v.speed * speedModifierX[v.offset]);
		end
		if (v.x < useCamera.x-64) or (v.x > useCamera.x+865) or (v.y < useCamera.y-64) or (v.y > useCamera.y+664) then
			if v.invisible == true then
				v.invisible = false;
			end
		end
		
		-- flicker animation
		
		v.ticker = v.ticker + 1;
		if v.ticker%v.framespeed == 0 and v.willFlicker ~= 0 then
			if v.flicker == 0 then
				v.flicker = 1;
			else
				v.flicker = 0;
			end
			v.ticker = 0;
		end
		
		-- collision
		
		local collisionTables = {}
		collisionTables[1] = {collider=podobooUpCollider,offsetBegin1=0,offsetEnd1=1,offsetBegin2=2,offsetEnd2=3}
		collisionTables[2] = {collider=podobooLeftCollider,offsetBegin1=0,offsetEnd1=2,offsetBegin2=1,offsetEnd2=3}
		collisionTables[3] = {collider=podobooRightCollider,offsetBegin1=2,offsetEnd1=0,offsetBegin2=3,offsetEnd2=1}
		collisionTables[4] = {collider=podobooDownCollider,offsetBegin1=1,offsetEnd1=0,offsetBegin2=3,offsetEnd2=2}
		
		for i=1,4 do
			local _,_,list = colliders.collideBlock(collisionTables[i].collider, colliders.BLOCK_SOLID..colliders.BLOCK_HURT..colliders.BLOCK_PLAYER)
			for _,q in ipairs(list) do
				if q.isHidden == false and v.invisible == false then
					if v.offset == collisionTables[i].offsetBegin1 then
						v.offset = collisionTables[i].offsetEnd1;
					elseif v.offset == collisionTables[i].offsetBegin2 then
						v.offset = collisionTables[i].offsetEnd2;
					end
				end
			end
		end
		
		-- player harming + projectile kills and stuff woah radicola and oijfiojdifjsdlfkjsdfksdfsd
		if colliders.collide(podobooHurtCollider,player) and v.invisible == false and v.friendly ~= 1 then
			if player:mem(0x50,FIELD_WORD) == -1 and player.y <= v.y and v.spinjump ~= 0 then
				if player.altJumpKeyPressing then
					player.speedY = -10;
				else
					player.speedY = -6;
				end
				Animation.spawn(75,v.x,v.y)
				playSFX(2)
			else
				player:harm()
			end
		end
		if colliders.downSlash(player,podobooHurtCollider) and v.spinjump ~= 0 and v.invisible == false and v.friendly ~= 1 then
			if player.y <= v.y then
				if player.jumpKeyPressing then
					player.speedY = -10;
				else
					player.speedY = -6;
				end
				Animation.spawn(75,v.x,v.y)
				playSFX(2)
			end
		end
		if colliders.collideNPC(podobooHurtCollider,{171,237,291,292,266}) and v.invincible ~= 1 and v.invisible == false and v.friendly ~= 1 then
			Animation.spawn(10,v.x,v.y)
			v.invisible = true;
			playSFX(9)
		end
		if colliders.collide(podobooHurtCollider,player) and v.message ~= nil then
			Graphics.drawImageToScene(messageSprite,v.x+(v.width/2)-6,v.y-32)
			if player.upKeyPressing == true then
				Text.showMessageBox(tostring(v.message))
			end
		end
	end
end

function podoboo.onDraw()
	-- Draw podoboo
	for _,v in ipairs(tableOfPodoboos) do
		if v.invisible == false then
			drawPodobooSprite(v)
		end
	end
end
 
return podoboo