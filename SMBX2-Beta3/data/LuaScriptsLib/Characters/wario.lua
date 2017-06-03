--[[
wario.lua
v1.2
Remade practically from scratch by arabslmon/ohmato, 2016
Original (the awful one) by Horikawa Otane

Things to do:
]]

local horikawaTools = loadSharedAPI("horikawaTools")
local colliders = loadSharedAPI("colliders")
local npcconfig = loadSharedAPI("npcconfig")
local pnpc = loadSharedAPI("pnpc")
local rng = loadSharedAPI("rng")
local pm = API.load("playerManager")
local wario = {}

-- Debug variables
local debugmode = false
if debugmode then mem(0x00B2C5AC, FIELD_FLOAT, 3) end
local CRATE_ID = 299
local LAKITUHELPER_TAG = -65456258

-- Custom lakitu management
local lakituArray = {}		-- Table of spawned custom lakitus
local lakituGraphics = {
	[3] = pm.registerGraphic(CHARACTER_WARIO, "lakitu_fire.png"),
	[4] = pm.registerGraphic(CHARACTER_WARIO, "lakitu_leaf.png"),
	[6] = pm.registerGraphic(CHARACTER_WARIO, "lakitu_hammer.png"),
	[7] = pm.registerGraphic(CHARACTER_WARIO, "lakitu_ice.png")
}

-- Store items
local store = {}

-- Store config
local STOREUI_ROWS = 3		-- Number of rows of items displayed
local STOREUI_COLS = 3		-- Number of columns of items displayed
local STOREUI_OPENTIME = 6	-- How many frames does the shop UI take to open/close?

local STATE_ERROR = -1		-- Error message displayed
local STATE_NONE = 0		-- Store is closed
local STATE_OPENING = 1		-- Store is opening
local STATE_SELECTING = 2	-- Store is open and cursor is responding
local STATE_CLOSING = 3		-- Store is closing
local STATE_SELECTED = 4	-- You bought something! Good job!

local selectpos = 1			-- Current position of shop cursor
local startpos = 1			-- Index range of items to show on the store menu
local endpos = 1

local storeAnimTimer = 0	-- Timer for store UI animation
local storeAnimState = 0	-- Animation state for store UI
local shoplakitu = nil		-- Has a shop lakitu already spawned?
local shopErrorMsg = ""		-- Error message to show if insufficient funds or delivery is blocked
local msgBlinkTimer = 0		-- Blink timer for error message text

-- Coin overflow management
local coins = 0				-- Coins collected as Wario
local coins_nonwario = 0	-- Coins when player was not Wario
local coins_display = 0		-- Number of coins to display on HUD
local lives = mem(0x00B2C5AC, FIELD_FLOAT)

-- Input management during Misc.pause
local uptap, downtap, lefttap, righttap, jumptap, runtap = false
local upwaspressed, downwaspressed, leftwaspressed, rightwaspressed, jumpwaspressed, runwaspressed = false

-- Graphical/audio assets
local HUD = {
	stars 	= pm.registerGraphic(CHARACTER_WARIO, "HUD\\wario_stars.png"),
	lives 	= pm.registerGraphic(CHARACTER_WARIO, "HUD\\wario_lives.png"),
	meter 	= pm.registerGraphic(CHARACTER_WARIO, "HUD\\HUD_meter.png")
}
local StoreUI = {
	card 	= pm.registerGraphic(CHARACTER_WARIO, "StoreUI\\StoreUI_card.png"),
	font 	= pm.registerGraphic(CHARACTER_WARIO, "StoreUI\\StoreUI_font.png"),
	frame 	= pm.registerGraphic(CHARACTER_WARIO, "StoreUI\\StoreUI_frame.png"),
	lakitu 	= pm.registerGraphic(CHARACTER_WARIO, "StoreUI\\StoreUI_lakitu.png"),
	frame2 	= pm.registerGraphic(CHARACTER_WARIO, "StoreUI\\StoreUI_nameframe.png"),
	hand 	= pm.registerGraphic(CHARACTER_WARIO, "StoreUI\\StoreUI_hand.png"),
	arrows	= pm.registerGraphic(CHARACTER_WARIO, "StoreUI\\StoreUI_arrows.png"),
	null	= pm.registerGraphic(CHARACTER_WARIO, "StoreUI\\StoreUI_null.png"),
	rednums	= pm.registerGraphic(CHARACTER_WARIO, "StoreUI\\StoreUI_rednums.png")
}
local shoplakitugraphic = pm.registerGraphic(CHARACTER_WARIO, "lakitu_shop.png")
local sfx = {
	buzzer = pm.registerSound(CHARACTER_WARIO, "sfx\\buzzer.ogg"),
	footstep = {}
}
for i = 1,3 do sfx.footstep[i] = pm.registerSound(CHARACTER_WARIO, "sfx\\footstep"..tostring(i)..".ogg") end

-- Dash-associated variables
local dashtimer = 0			-- Aggregate timer for dashing
local dashing = false		-- Is the player currently dashing?
local DASHCHARGETIME = 2.0	-- Time (seconds) required for the dash meter to fill
local DASHSPEED = 8			-- Speed while dashing
local DASHACCEL = 0.005		-- Acceleration to top speed while dashing

-- Crawling-associated variables
local crawling = false		-- Is the player currently crawling?
local CRAWLSPEED = 0.7		-- Speed while crawling
local crawltimer = 0		-- Timer for crawl frames

function wario.onInitAPI()
	registerEvent(wario, "onStart", "init", false)
	registerEvent(wario, "onKeyDown", "onKeyDown", false)
	registerEvent(wario, "onInputUpdate", "onInputUpdate", false)
	registerEvent(wario, "onTick", "onTick", false)
	registerEvent(wario, "onExitLevel", "onExitLevel", false)
	registerEvent(wario, "onDraw", "onDraw", false)
	if debugmode and Graphics.isOpenGLEnabled() then registerEvent(wario, "onTickEnd", "DebugDraw") end
end


-- Store methods
function wario.additem(args)
	-- Check typing
	if type(args.id) ~= "number" then error("Invalid NPC ID.", 2) end
	if type(args.price) ~= "number" then error("Invalid price value.", 2) end
	if type(args.name) == "nil" then args.name = ""
	elseif type(args.name) ~= "string" then args.name = tostring(args.name) end
	if type(args.container) == "number" then
		if not (args.container == 96 or args.container == 283 or args.container == 91 or args.container == 284 or args.container == CRATE_ID) then
			error("Specified ID is not a container.", 2)
		end
	else
		args.container = -1
	end
	
	--------------------------------------------------------
	-- 1)	NPC ID					(integer)
	-- 2)	Cost of store item		(integer)
	-- 3)	Display name			(string)
	-- 4)	Display icon			(LuaImageResource)
	-- 5)	Container				(integer)
	-- 6)	Lakitu helper?			(boolean)
	--------------------------------------------------------
	
	-- Check if values are valid
	if args.price < 0 or args.price > 999 then error("Price must be between 0 and 999 coins.", 2) end
	if string.len(args.name) > 16 then args.name = string.sub(args.name, 1, 16) end
	
	-- Add item to store
	store[#store + 1] = {math.floor(args.id), math.floor(args.price), args.name}
	
	-- Check custom icon path
	if type(args.iconpath) == "string" then
		if args.iconpath then
			local icon;
			pcall(function() icon = pm.registerGraphic(CHARACTER_WARIO, args.iconpath) end);
			if icon then
				store[#store][4] = icon
			end
		end
	end
	
	-- If a different icon is already included with the API (e.g. dumb Yoshis), and a custom one is unspecified, load it
	if not store[#store][4] then
		local path = "StoreUI\\icons\\npc-"..tostring(args.id)..".png"
		if path then
			
			local icon;
			pcall(function() icon = pm.registerGraphic(CHARACTER_WARIO, path) end);
			if icon then
				store[#store][4] = icon
			end
		end
	end
	
	-- Is the item in a container?
	if args.container ~= -1 then store[#store][5] = math.floor(args.container) end
	
	-- Is it a friendly lakitu helper?
	if type(args.isLakituHelper) == "boolean" and store[#store][1] == 284 and store[#store][5] == CRATE_ID then
		store[#store][6] = args.isLakituHelper
	else
		store[#store][6] = false
	end
	
	-- Change store cursor
	local selectpos = 1
	local startpos = 1;		local endpos = #store;
	if #store > STOREUI_ROWS*STOREUI_COLS then endpos = startpos + STOREUI_ROWS*STOREUI_COLS - 1 end
	
	return true
end
function wario.removeitem(id)
	-- Check typing
	if type(id) ~= "number" then error("Invalid NPC ID.", 2) end
	
	-- Check if the item exists
	for i,item in ipairs(store) do
		if item[1] == id then
			table.remove(store, i)
			
			-- Change store cursor
			local selectpos = 1
			local startpos = 1;		local endpos = #store;
			if #store > STOREUI_ROWS*STOREUI_COLS then endpos = startpos + STOREUI_ROWS*STOREUI_COLS - 1 end
			
			return true
		end
	end
	
	return false
end
function wario.enableLakituHelper()
	wario.additem {id=284, 	price=100, 	name="Lakitu Helper",	container=CRATE_ID,	isLakituHelper=true,	iconpath="wario\\StoreUI\\StoreUI_lakituHelperIcon.png"}
end
function wario.disableLakituHelper()
	for i,item in ipairs(store) do
		if item[1] == 284 and item[6] then
			table.remove(store, i)
			
			-- Change store cursor
			local selectpos = 1
			local startpos = 1;		local endpos = #store;
			if #store > STOREUI_ROWS*STOREUI_COLS then endpos = startpos + STOREUI_ROWS*STOREUI_COLS - 1 end
			
			return true
		end
	end
end


-- Key press management during Misc.pause
local function onKeyDownPaused()
	uptap = false; downtap = false;
	lefttap = false; righttap = false;
	jumptap = false; runtap = false;
	
	if player.upKeyPressing then
		if not upwaspressed then uptap = true end
		upwaspressed = true
	else upwaspressed = false end
	if player.downKeyPressing then
		if not downwaspressed then downtap = true end
		downwaspressed = true
	else downwaspressed = false end
	
	if player.leftKeyPressing then
		if not leftwaspressed then lefttap = true end
		leftwaspressed = true
	else leftwaspressed = false end
	if player.rightKeyPressing then
		if not rightwaspressed then righttap = true end
		rightwaspressed = true
	else rightwaspressed = false end
	
	if player.jumpKeyPressing then
		if not jumpwaspressed then jumptap = true end
		jumpwaspressed = true
	else jumpwaspressed = false end
	if player.runKeyPressing then
		if not runwaspressed then runtap = true end
		runwaspressed = true
	else runwaspressed = false end
end
-- Opening the store on SELECT
function wario.onKeyDown(keycode)
	-- If the player is Wario
	if player.character == CHARACTER_WARIO and player:mem(0x122, FIELD_WORD) == 0 then
		-- Press SELECT to bring up the store
		if keycode == KEY_SEL and shoplakitu == nil then
			storeAnimTimer = 0
			storeAnimState = STATE_OPENING
			if not Misc.isPausedByLua() then Misc.pause() end
			playSFX(30)
		end
	end
end
-- Input management for store UI and dashing
function wario.onInputUpdate()
	-- If the player is Wario
	if player.character == CHARACTER_WARIO then
		pm.winStateCheck()
		-- Increase the dash timer when running on the ground
		if player.powerup > 1 then
			if math.abs(player.speedX) > 2 and player.runKeyPressing and player:mem(0x122, FIELD_WORD) == 0 then
				if player:isGroundTouching() then dashtimer = dashtimer + 1 end
			else dashtimer = 0 end
			if dashtimer >= DASHCHARGETIME then dashing = true
			else dashing = false end
		end
		-- If holding something or on a mount, prevent dashing
		if player:mem(0x154, FIELD_WORD) ~= 0 or player:mem(0x108, FIELD_WORD) ~= 0 then dashtimer = 0 end
		
		-- Detect onKeyDown for when the game is paused
		onKeyDownPaused()
		
		-- Move selection in the store
		if storeAnimState == STATE_SELECTING then
			if lefttap then selectpos = selectpos - 1
			elseif righttap then selectpos = selectpos + 1 end
			if uptap and selectpos - STOREUI_COLS > 0 then selectpos = selectpos - STOREUI_COLS
			elseif downtap and math.ceil(selectpos/STOREUI_COLS) < math.ceil(#store/STOREUI_COLS) then selectpos = selectpos + STOREUI_COLS end
			if (uptap or downtap or lefttap or righttap) and storeAnimState == STATE_SELECTING then playSFX(26) end
		end
		
		-- Prevent selectpos from exiting bounds
		if selectpos < 1 then selectpos = 1
		elseif selectpos > #store then selectpos = #store end
		
		-- Exit the store when you hit the run button
		if runtap and storeAnimState == STATE_SELECTING then
			storeAnimTimer = STOREUI_OPENTIME
			storeAnimState = STATE_CLOSING
			if Misc.isPausedByLua() then Misc.unpause() end
			playSFX(30)
			shopErrorMsg = ""
		-- Purchase an item when you hit the jump button
		elseif jumptap and storeAnimState == STATE_SELECTING then
			-- Check if there is enough room for delivery
			canspawn = true
			for _, block in pairs(Block.getIntersecting(player.x - 32, player.y - 4*32 - npcconfig[store[selectpos][1]].height, player.x + player.width + 32, player.y)) do
				for _, id in pairs(colliders.BLOCK_SOLID) do
					if block.id == id then
						canspawn = false
						break
					end
				end
				if not canspawn then break end
			end
			local canSpawnHelper = (player.powerup > 2 and player.powerup ~= 5)
			if store[selectpos][6] and not canSpawnHelper then canspawn = false end
			
			-- If the item can be delivered
			if coins >= store[selectpos][2] and canspawn then
				-- Reduce coin count
				coins = coins - store[selectpos][2]
				playSFX(12)
				-- Cancel jump
				player:mem(0x11e, FIELD_WORD, 1)
				
				-- Spawn lakitu merchant
				shoplakitu = pnpc.wrap(NPC.spawn(284, Camera.get()[1].x - 56, player.y, player.section))
				shoplakitu.ai1 = store[selectpos][1]
				shoplakitu.friendly = true
				shoplakitu.data.t = -30
				shoplakitu.data.dropped = false
				shoplakitu.data.itemcheck = false
				shoplakitu.data.isYoshi = false
				
				-- Check if the delivered item is in a container
				if store[selectpos][5] then shoplakitu.data.inContainer = true
				else shoplakitu.data.inContainer = false end
				
				-- Check if the delivered item is a lakitu helper
				shoplakitu.data.isLakituHelper = store[selectpos][6]
				
				-- Exit store
				storeAnimTimer = 40
				storeAnimState = STATE_SELECTED
			else
				Audio.SfxPlayCh(-1, Audio.SfxOpen(pm.getSound(CHARACTER_WARIO,sfx.buzzer)), 0)
				storeAnimState = STATE_ERROR
				-- Send appropriate error message
				if coins < store[selectpos][2] then shopErrorMsg = "Not enough coins!"
				elseif not canspawn then
					if store[selectpos][6] and not canSpawnHelper then shopErrorMsg = "Helper not available!"
					else shopErrorMsg = "Delivery blocked!" end
				end
				msgBlinkTimer = 0
			end
		end
	end
end


-- Determines value of a coin NPC
local function coinval(id)
	if id == 152 or id == 88 or id == 138 or id == 10 or id == 33 or id == 251 or id == 274 then
										return 1
	elseif id == 103 then 				return 2
	elseif id == 252 or id == 258 then 	return 5
	elseif id == 253 then 				return 20
	else 								return 0
	end
end
-- Checks if an NPC is onscreen
local function onscreen(npc)
	-- Get camera boundaries
	local left = Camera.get()[1].x;		local right = left + Camera.get()[1].width;
	local top = Camera.get()[1].y;		local bottom = top + Camera.get()[1].height;
	-- Check if offscreen
	if npc.x + npc.width < left or npc.x > right then return false
	elseif npc.y + npc.height < top or npc.y > bottom then return false
	else return true end
end
-- Spawn a friendly Lakitu helper
local function spawnLakituHelper(x, y)
	if player.powerup > 2 and player.powerup ~= 5 then
		-- Spawn a friendly lakitu offscreen
		local lakitu = pnpc.wrap(NPC.spawn(284, x, y, player.section, false, true))
		lakitu.friendly = true
		
		-- Change what it throws depending on powerup
		if player.powerup == 3 then
			lakitu.ai1 = 13			-- Fire: throws fireball
		elseif player.powerup == 4 then
			lakitu.ai1 = 171		-- Leaf: throws hammer
		elseif player.powerup == 6 then
			lakitu.ai1 = 291		-- Hammer: throws bomb
		elseif player.powerup == 7 then
			lakitu.ai1 = 265		-- Ice: throws iceball
		end
		
		-- Set lifetime and graphic
		lakitu.data.graphic = lakituGraphics[player.powerup]
		lakitu.data.timeLeft = 65*12
		lakituArray[#lakituArray + 1] = lakitu
	end
end


-- Spawn coins when killing an enemy, coin counter management, and monitor Lakitu helper crates
function onNPCKill(eventObj, killedNPC, killReason)
	-- If the player is Wario
	if player.character == CHARACTER_WARIO then
		-- If the player kills an enemy, drop some coins (ignore death of projectiles, powerups, in lava, an iceball, or egg)
		if killReason <= 8 and killReason ~= 6 and killReason ~= 4 and killedNPC.id ~= 265 and killedNPC.id ~= 96 and killedNPC:mem(0x74, FIELD_WORD) == 0 then
			for i = 1, npcconfig[killedNPC.id].score do
				local coin = NPC.spawn(10, killedNPC.x, killedNPC.y, player.section)
				coin.speedX = rng.random(-2,2)
				coin.speedY = rng.random(-4)
				coin.ai1 = 1
				killedNPC:mem(0x74, FIELD_WORD, -1)
			end
		end
		
		-- Increment coin counter when a coin despawns
		if killReason == 9 and killedNPC:mem(0x74, FIELD_WORD) == 0 and onscreen(killedNPC) then
			local val = coinval(killedNPC.id)
			-- Collected a coin
			if val ~= 0 then
				coins = coins + val
			else
				-- If it's a crate, check for a lakitu helper
				if killedNPC.id == CRATE_ID then
					local crate = pnpc.wrap(killedNPC)
					if crate.data.cratedata then
						if crate.data.cratedata.tag == LAKITUHELPER_TAG then
							spawnLakituHelper(crate.x + crate.width/2, crate.y + crate.height - npcconfig[284].height/2)
						end
					end
				end
			end
			killedNPC:mem(0x74, FIELD_WORD, -1)
		end
	end
end


-- Initialize store
function wario.init()
	-- Add items to store
	wario.additem {id=9, 	price=20, 	name="Super Mushroom"}
	wario.additem {id=14, 	price=50, 	name="Fire Flower"}
	wario.additem {id=264, 	price=50, 	name="Ice Flower"}
	wario.additem {id=90, 	price=100, 	name="1-Up Mushroom"}
	wario.additem {id=170, 	price=100, 	name="Hammer Suit"}
	wario.additem {id=34, 	price=50, 	name="Super Leaf"}
	wario.additem {id=169, 	price=100, 	name="Tanooki Suit"}
	wario.additem {id=35, 	price=100, 	name="Kuribo's Shoe"}
	wario.additem {id=241, 	price=20, 	name="POW Block"}
	wario.additem {id=95, 	price=100, 	name="Yoshi (Green)",	container=96}
	wario.enableLakituHelper()
	
	-- Convert dash time
	DASHCHARGETIME = math.ceil(DASHCHARGETIME*2500/39)
end


-- Initialization and cleanup of Wario character data
function wario.initCharacter()
	coins_nonwario = mem(0x00B2C5A8, FIELD_WORD)
	Graphics.activateHud(false)
	
	-- Make Wario "heavier"
	Defines.player_runspeed = 4
	Defines.player_walkspeed = 2
	Defines.jumpheight = 18
	Defines.jumpheight_bounce = 18
	
	-- Adjust size of player-thrown fireball/iceball graphic
	npcconfig[13].gfxwidth = 32;	npcconfig[265].gfxwidth = 32;
	npcconfig[13].gfxheight = 32;	npcconfig[265].gfxheight = 32;
	npcconfig[13].height = 32;		npcconfig[265].height = 32;
	npcconfig[13].width = 32;		npcconfig[265].width = 32;
end
function wario.cleanupCharacter()
	mem(0x00B2C5A8, FIELD_WORD, coins_nonwario)
	Graphics.activateHud(true)
	
	-- Return physics to normal
	Defines.player_runspeed = nil
	Defines.player_walkspeed = nil
	Defines.jumpheight = nil
	Defines.jumpheight_bounce = nil
	
	-- Reset grabbing ability
	Defines.player_grabSideEnabled = nil
	Defines.player_grabShellEnabled = nil
	
	-- Reset dimensions for player-thrown fireball/iceball
	npcconfig[13].gfxwidth = 16;	npcconfig[265].gfxwidth = 16;
	npcconfig[13].gfxheight = 16;	npcconfig[265].gfxheight = 16;
	npcconfig[13].height = 16;		npcconfig[265].height = 16;
	npcconfig[13].width = 16;		npcconfig[265].width = 16;
	
	-- Clean up lakitus
	for _, lakitu in pairs(lakituArray) do
		Animation.spawn(63, lakitu.x + lakitu.width/2, lakitu.y + lakitu.height/2)
		lakitu:kill(9)
		playSFX(16)
	end
	if shoplakitu then
		Animation.spawn(63, shoplakitu.x + shoplakitu.width/2, shoplakitu.y + shoplakitu.height/2)
		shoplakitu:kill(9)
		playSFX(16)
	end
	lakituArray = {}
	shoplakitu = nil
end


-- Logic for shop manager Lakitu
local function shopLakituLogic()
	if shoplakitu and shoplakitu.isValid and storeAnimState == STATE_NONE then
		-- Prevent him from throwing anything
		if shoplakitu.ai5 < 148 then shoplakitu.ai5 = 0 end
		
		-- Kinematics
		local cam = Camera.get()[1]
		local hmax = 200; local xspeed = 8
		local left = player.x + player.width/2 - cam.x
		local dx = math.max(left, cam.width - left)
		local targetx = xspeed*shoplakitu.data.t - shoplakitu.width/2 - left
		local targety = -hmax/dx/dx*targetx*targetx + player.y + player.height + player.speedY*4 - npcconfig[store[selectpos][1]].height
		targetx = targetx + player.x + player.width/2 + player.speedX
		shoplakitu.data.t = shoplakitu.data.t + 1
		
		shoplakitu.x = shoplakitu.x + 0.03*(targetx - shoplakitu.x)
		shoplakitu.y = shoplakitu.y + 0.03*(targety - shoplakitu.y)
		
		-- Drop the item when above the player
		if not shoplakitu.data.dropped and shoplakitu.x + shoplakitu.width/2 + xspeed >= player.x + player.width/2 then
			shoplakitu.ai5 = 150
			shoplakitu.data.dropped = true
		end
		
		-- Set direction
		if shoplakitu.x + shoplakitu.width/2 + xspeed >= player.x + player.width/2 then shoplakitu.direction = -1
		else shoplakitu.direction = 1 end
		
		-- Stop the item from moving and contain a Yoshi within the egg
		if shoplakitu.data.dropped and not shoplakitu.data.itemcheck then
			for _,npc in pairs(NPC.getIntersecting(shoplakitu.x, shoplakitu.y, shoplakitu.x + shoplakitu.width, shoplakitu.y + shoplakitu.height)) do
				if npc.id == store[selectpos][1] then
					-- Check to make sure you haven't got a hold of the Shop Lakitu
					local isShopLakitu = false
					if npc.id == 284 then
						local wrapper = pnpc.getExistingWrapper(npc)
						if wrapper and wrapper.uid == shoplakitu.uid then isShopLakitu = true end
					end
					
					if not isShopLakitu then
						-- If it's in a container, spawn the container
						if shoplakitu.data.inContainer then
							local container = NPC.spawn(store[selectpos][5], shoplakitu.x + shoplakitu.width/2, shoplakitu.y, player.section, false, true)
							
							-- Bump up slightly if it's a bubble
							if container.id == 283 then container.y = container.y - 32 + shoplakitu.speedY end
							
							-- Check if it's a friendly lakitu helper
							if shoplakitu.data.isLakituHelper then
								local crate = pnpc.wrap(container)
								-- Spawning will be handled in onNPCKill
								crate.data.cratedata = { tag = LAKITUHELPER_TAG }
								crate.speedX = 0
								crate.speedY = -8
							else
								container.speedY = npc.speedY
								container.ai1 = store[selectpos][1]
							end
							
							-- Despawn the original NPC
							npc:kill(9)
						end
						
						-- Confirm item drop
						shoplakitu.data.itemcheck = true
						break
					end
				end
			end
		end
		
		-- Despawn when out of section boundaries
		if shoplakitu.data.dropped 
			and (shoplakitu.x > cam.x + cam.width or shoplakitu.x + shoplakitu.width < cam.x)
			and (shoplakitu.y > cam.y + cam.height or shoplakitu.y + shoplakitu.height < cam.y) then
			shoplakitu:kill(9)
			shoplakitu = nil
		end
	end
end


-- Per-frame logic
function wario.onTick()
	-- If the player is Wario
	if player.character == CHARACTER_WARIO then
		for _, lakitu in pairs(lakituArray) do
			if lakitu.isValid then
				-- Age all player-spawned lakitus
				lakitu.data.timeLeft = lakitu.data.timeLeft - 1
				if lakitu.data.timeLeft <= 0 then
					Animation.spawn(63, lakitu.x + lakitu.width/2, lakitu.y + lakitu.height/2)
					lakitu:kill(9)
					lakitu = nil
					playSFX(16)
				end
			else
				lakitu = nil
			end
		end
		
		-- Cap run/walk speed
		if not dashing then
			Defines.player_runspeed = 4
			Defines.player_walkspeed = 2
			Defines.player_grabSideEnabled = true
			Defines.player_grabShellEnabled = true
		else
			Defines.player_runspeed = DASHSPEED
			Defines.player_walkspeed = DASHSPEED
			Defines.player_grabSideEnabled = false
			Defines.player_grabShellEnabled = false
		end
		
		-- Remove reserve powerup
		player.reservePowerup = 0
		
		-- Check for Walakitu
		shopLakituLogic()
		
		-- Dash mechanic
		if dashing then
			-- Increase speed
			local direction = player:mem(0x106, FIELD_WORD)
			if direction < 0 then
				if player.speedX > -DASHSPEED then player.speedX = player.speedX - DASHACCEL end
			elseif direction > 0 then
				if player.speedX < DASHSPEED then player.speedX = player.speedX + DASHACCEL end
			end
			
			-- Destroy blocks when dashing
			local left = 0; local right = 0
			if direction < 0 then
				right = player.x
				left = right + player.speedX
			elseif direction > 0 then
				left = player.x + player.width
				right = left + player.speedX
			end
			for _,block in pairs(Block.getIntersecting(left, player.y, right, player.y + player.height)) do
				-- If block is visible
				if block:mem(0x1c, FIELD_WORD) == 0 and block:mem(0x5a, FIELD_WORD) == 0 then
					-- If the block should be broken, destroy it
					if (block.id == 60 or block.id == 188 or block.id == 4 or block.id == 226) and block.contentID == 0 then
						block:remove(true)
					else block:hit(true, player) end
				end
			end
			
			-- Visual effects if touching ground
			if player:isGroundTouching() then
				Animation.spawn(74, player.x + rng.random(player.width/2) + 4 + player.speedX, player.y + player.height + rng.random(-4, 4) - 4)
			end
		end
		
		-- Crawling
		crawling = false
		if player:mem(0x12e, FIELD_WORD) == -1 and player:isGroundTouching() and player:mem(0x108, FIELD_WORD) == 0 then
			if player.leftKeyPressing then
				player.speedX = -CRAWLSPEED
				crawling = true
			elseif player.rightKeyPressing then
				player.speedX = CRAWLSPEED
				crawling = true
			end
		end
		
		-- Watch for when getting a coin from a block
		for _, coinEffect in pairs(Animation.get(11)) do
			if coinEffect.timer == 46 then
				coins = coins + 1
			end
		end
		
		-- Zero coin amount
		mem(0x00B2C5A8, FIELD_WORD, 0)
	end
end


-- Rendering frame of shop UI
local function renderShopFrame(xpos, ypos, BOXWIDTH, BOXHEIGHT, m, n)
	-- Define rectangle
	local left 	= xpos + BOXWIDTH/2 - n*50/2 - 22;		local right		= left + n*50 + 2*22
	local top	= ypos + BOXHEIGHT/2 - m*45/2 - 22;		local bottom 	= top + m*45 + 2*22;
	
	-- Draw background box
	local box = {
		left + 12, top + 12,
		left + 12, bottom - 12,
		right - 12, bottom - 12,
		right - 12, top + 12
	}
	Graphics.glDraw {vertexCoords = box, color = {0,0,0,0.5}, primitive = Graphics.GL_TRIANGLE_FAN, priority = 3}
	
	-- Draw corners of frame
	Graphics.draw {	x = left, 			y = top, 			type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.frame),
					sourceX = 0, 		sourceY = 0, 		sourceWidth = 22, 	sourceHeight = 22}
	Graphics.draw {	x = left, 			y = bottom - 22, 	type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.frame),
					sourceX = 0, 		sourceY = 22 + 45,	sourceWidth = 22, 	sourceHeight = 22}
	Graphics.draw {	x = right - 22, 	y = top, 			type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.frame),
					sourceX = 22 + 50, 	sourceY = 0, 		sourceWidth = 22, 	sourceHeight = 22}
	Graphics.draw {	x = right - 22, 	y = bottom - 22, 	type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.frame),
					sourceX = 22 + 50, 	sourceY = 22 + 45,	sourceWidth = 22, 	sourceHeight = 22}
					
	-- Draw top and bottom of frame
	for i = 0, n-1 do
		Graphics.draw {	x = left + 22 + 50*i, 	y = top, 			type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.frame),
						sourceX = 22, 			sourceY = 0, 		sourceWidth = 50, 	sourceHeight = 22}
		Graphics.draw {	x = left + 22 + 50*i, 	y = bottom - 22, 	type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.frame),
						sourceX = 22, 			sourceY = 22 + 45, 	sourceWidth = 50, 	sourceHeight = 22}
	end
	-- Draw sides of frame
	for i = 0, m-1 do
		Graphics.draw {	x = left,		 	y = top + 22 + 45*i,	type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.frame),
						sourceX = 0, 		sourceY = 22, 			sourceWidth = 22, 	sourceHeight = 45}
		Graphics.draw {	x = right - 22,	 	y = top + 22 + 45*i,	type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.frame),
						sourceX = 22 + 50,	sourceY = 22, 			sourceWidth = 22, 	sourceHeight = 45}
	end
end
-- Rendering text using custom font
local function renderCustomText(xpos, ypos, str, fontimg, w, h)
	local srcx = 0; local srcy = 0;
	for i = 1, str:len() do
		local code = string.byte(str, i)
		local printchar = true
		-- Number
		if code >= 48 and code <= 57 then
			srcx = (code-48)*w;	srcy = 0*h;
		-- a-z
		elseif code >= 97 and code <= 122 then
			srcx = (code-97)*w;	srcy = 1*h;
		-- A-Z
		elseif code >= 65 and code <= 90 then
			srcx = (code-65)*w;	srcy = 2*h;
		-- !"#$%&'()*+,-./
		elseif code >= 33 and code <= 47 then
			srcx = (code-33)*w;	srcy = 3*h;
		-- :;<=>?
		elseif code >= 58 and code <= 63 then
			srcx = (code-58)*w;	srcy = 4*h;
		-- Space or anything else
		else
			printchar = false
		end
		
		-- Print the character
		if printchar then
			Graphics.draw {	x = xpos, y = ypos, type = RTYPE_IMAGE, priority = 3, image = fontimg,
							sourceX = srcx, sourceY = srcy, sourceWidth = w, sourceHeight = h}
		end
		
		-- Advance cursor
		xpos = xpos + w
	end
end
-- Rendering the item card for a particular store item
local function renderCard(xpos, ypos, item, selected)
	-- Gather item data
	local id = item[1]
	local price = item[2]
	local icon = item[4]
	if(icon) then
		icon = pm.getGraphic(CHARACTER_WARIO, icon);
	end
	local canSpawnHelper = (player.powerup > 2 and player.powerup ~= 5)

	-- Checkered background
	Graphics.draw {	x = xpos, y = ypos, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.card),
					sourceX = 0, sourceY = 0, sourceWidth = 84, sourceHeight = 52}
	
	-- Get item graphic data
	local gfxwidth = npcconfig[id].gfxwidth
	if gfxwidth == 0 then gfxwidth = npcconfig[id].width end
	local gfxheight = npcconfig[id].gfxheight
	if gfxheight == 0 then gfxheight = npcconfig[id].height end
	if icon then
		gfxwidth = icon.width
		gfxheight = icon.height
	end
	
	-- Card frame (top fringe)
	if selected then
		Graphics.draw {	x = xpos, y = ypos, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.card),
						sourceX = 0, sourceY = 52, sourceWidth = 84, sourceHeight = 12}
	end
	
	-- Source rectangle
	local srcx = 0; local srcy = 0;
	local srcw = gfxwidth
	local srch = gfxheight
	if gfxwidth > 68 then
		srcw = 68
		srcx = (gfxwidth - 68)/2
	end
	if gfxheight > 36 then
		if selected and coins >= price then
			srch = 36 + (gfxheight - 36)/2
			srcy = 0
		else
			srch = 36
			srcy = (gfxheight - 36)/2
		end
	end
	
	-- Render icon
	if not icon then icon = Graphics.sprites.npc[id].img end
	if gfxheight <= 36 then
		Graphics.draw {	x = xpos + 8 + (68 - srcw)/2, y = ypos + 8 + (36 - srch)/2, type = RTYPE_IMAGE, priority = 3, image = icon,
						sourceX = srcx, sourceY = srcy, sourceWidth = srcw, sourceHeight = srch}
	else
		Graphics.draw {	x = xpos + 8 + (68 - srcw)/2, y = ypos + 44 - srch, type = RTYPE_IMAGE, priority = 3, image = icon,
						sourceX = srcx, sourceY = srcy, sourceWidth = srcw, sourceHeight = srch}
	end
	
	-- Render null symbol if not enough coins, or invalid lakitu helper
	if coins < price or (item[6] and not canSpawnHelper) then
		Graphics.draw {	x = xpos, y = ypos, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.null), opacity = 0.7}
	end
	
	-- Card frame (top fringe) if not selected or price too high
	if not selected or coins < price or (item[6] and not canSpawnHelper) then
		Graphics.draw {	x = xpos, y = ypos, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.card),
						sourceX = 0, sourceY = 52, sourceWidth = 84, sourceHeight = 12}
	end
	-- Card frame (bottom)
	Graphics.draw {	x = xpos, y = ypos + 12, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.card),
					sourceX = 0, sourceY = 64, sourceWidth = 84, sourceHeight = 62}
					
	-- Price
	if coins >= price then
		Text.printWP(price, 1, xpos + 78 - tostring(price):len()*18 + 2, ypos + 55,3)
	else
		renderCustomText(xpos + 79 - tostring(price):len()*18, ypos + 55, tostring(price), pm.getGraphic(CHARACTER_WARIO, StoreUI.rednums), 18, 14)
	end
end
-- Rendering display name for currently selected item
local function renderName(xpos, ypos, str)
	-- Draw background box
	local width = (str:len() + 2)*16 + 8
	local box = {
		xpos + 12, ypos + 12,
		xpos + 12, ypos + 12 + 32,
		xpos + 12 + width, ypos + 12 + 32,
		xpos + 12 + width, ypos + 12
	}
	Graphics.glDraw {vertexCoords = box, color = {0,0,0,0.5}, primitive = Graphics.GL_TRIANGLE_FAN, priority = 3}
	
	-- Draw frame
	Graphics.draw {x = xpos, y = ypos, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO,StoreUI.frame2), sourceX = 0, sourceWidth = 16}
	for i = 1, str:len()+2 do
		Graphics.draw {x = xpos + i*16, y = ypos, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO,StoreUI.frame2), sourceX = 16, sourceWidth = 16}
	end
	Graphics.draw {x = xpos + (str:len() + 3)*16, y = ypos, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO,StoreUI.frame2), sourceX = 32, sourceWidth = 16}
	
	-- Print text
	renderCustomText(xpos + 2*16, ypos + 12, str, pm.getGraphic(CHARACTER_WARIO,StoreUI.font), 16, 32)
end


-- Render dash charge meter
local function renderDashMeter(xpos, ypos)
	Graphics.draw {x = xpos, y = ypos, type = RTYPE_IMAGE, priority = 5, image = pm.getGraphic(CHARACTER_WARIO, HUD.meter), sourceHeight = 18}
	if dashtimer < DASHCHARGETIME then
		Graphics.draw {x = xpos, y = ypos, type = RTYPE_IMAGE, priority = 5, image = pm.getGraphic(CHARACTER_WARIO, HUD.meter),
			sourceY = 18, sourceWidth = 10*math.floor(dashtimer/DASHCHARGETIME*8), sourceHeight = 18}
	else
		Graphics.draw {x = xpos, y = ypos, type = RTYPE_IMAGE, priority = 5, image = pm.getGraphic(CHARACTER_WARIO, HUD.meter),
			sourceY = 18, sourceWidth = 70, sourceHeight = 18}
		if math.floor(os.clock()*10)%2 == 0 then
			Graphics.draw {x = xpos + 70, y = ypos, type = RTYPE_IMAGE, priority = 5, image =pm.getGraphic(CHARACTER_WARIO,  HUD.meter),
				sourceX = 70, sourceY = 18, sourceWidth = 26, sourceHeight = 18}
		end
	end
end

-- Custom sprite and UI management
function wario.onDraw()
	-- If the player is Wario
	if player.character == CHARACTER_WARIO then
		-- Draw lakitu graphics
		for _, lakitu in pairs(lakituArray) do
			if lakitu.isValid then
				Graphics.draw {x = lakitu.x - 8, y = lakitu.y - 18, type = RTYPE_IMAGE, isSceneCoordinates = true, priority = -44,
							image = pm.getGraphic(CHARACTER_WARIO, lakitu.data.graphic), sourceY = lakitu.animationFrame*72, sourceHeight = 72}
			end
		end
		if shoplakitu and shoplakitu.isValid then
			Graphics.draw {x = shoplakitu.x - 8, y = shoplakitu.y - 18, type = RTYPE_IMAGE, isSceneCoordinates = true, priority = -44,
						image = pm.getGraphic(CHARACTER_WARIO, shoplakitugraphic), sourceY = shoplakitu.animationFrame*72, sourceHeight = 72}
		end
		
		-- Cap maximum coin amount
		if coins > 999 then coins = 999 end
		-- Render custom HUD
		Graphics.draw {x = 228, y = 26, type = RTYPE_IMAGE, priority = 5, image = pm.getGraphic(CHARACTER_WARIO, HUD.lives)}
		Graphics.draw {x = 274, y = 27, type = RTYPE_IMAGE, priority = 5, image = Graphics.sprites.hardcoded["33-1"].img}
		Graphics.draw {x = 470, y = 26, type = RTYPE_IMAGE, priority = 5, image = Graphics.sprites.hardcoded["33-2"].img}
		Graphics.draw {x = 494, y = 27, type = RTYPE_IMAGE, priority = 5, image = Graphics.sprites.hardcoded["33-1"].img}
		-- Show lives and stars
		Text.printWP(mem(0x00B2C5AC, FIELD_FLOAT), 1, 297, 27, 5)
		if mem(0x00B251E0, FIELD_WORD) > 0 then
			Graphics.draw {x = 250, y = 46, type = RTYPE_IMAGE, priority = 5, image = pm.getGraphic(CHARACTER_WARIO, HUD.stars)}
			Graphics.draw {x = 274, y = 47, type = RTYPE_IMAGE, priority = 5, image = Graphics.sprites.hardcoded["33-1"].img}
			Text.printWP(mem(0x00B251E0, FIELD_WORD), 1, 297, 47, 5)
		end
		-- Show coins and score
		if coins_display ~= coins then
			local TICK_AMOUNT = 4
			if math.abs(coins-coins_display) < TICK_AMOUNT then coins_display = coins
			elseif coins_display < coins then coins_display = coins_display + TICK_AMOUNT
			elseif coins_display > coins then coins_display = coins_display - TICK_AMOUNT end
		end
		Text.printWP(coins_display, 1, 568 - tostring(coins_display):len()*18 + 2, 27, 5)
		Text.printWP(mem(0x00B2C8E4, FIELD_DWORD), 1, 568 - tostring(mem(0x00B2C8E4, FIELD_DWORD)):len()*18 + 2, 47, 5)
		
		-- Render shop menu
		if storeAnimState ~= STATE_NONE then
			-- Dimensions of shop menu
			local width = 100*STOREUI_COLS + 44
			local height = 90*STOREUI_ROWS + 44
			-- Position of shop menu
			local x = (Camera.get()[1].width - width)/2
			local y = (Camera.get()[1].height - height)/2 - 16
			-- Rows and columns (x2, for rendering frame sections)
			local m = STOREUI_ROWS*2
			local n = STOREUI_COLS*2
			
			-- Render menu according to current visual state
			if storeAnimState == STATE_OPENING or storeAnimState == STATE_CLOSING then
				-- Frame matrix
				m = math.floor( storeAnimTimer/STOREUI_OPENTIME * STOREUI_ROWS*2)
				n = math.floor( storeAnimTimer/STOREUI_OPENTIME * STOREUI_COLS*2) 
				if n > STOREUI_COLS*2 then n = STOREUI_COLS*2 end
				if m > STOREUI_ROWS*2 then m = STOREUI_ROWS*2 end
				
				-- Render shop frame
				renderShopFrame(x, y, width, height, m, n)
			else
				-- If there are too many items to fit all at once
				if #store > STOREUI_ROWS*STOREUI_COLS then
					endpos = startpos + STOREUI_ROWS*STOREUI_COLS - 1
					while selectpos > endpos do
						startpos = startpos + STOREUI_COLS
						endpos = startpos + STOREUI_ROWS*STOREUI_COLS - 1
					end
					while selectpos < startpos do
						startpos = startpos - STOREUI_COLS
						endpos = startpos + STOREUI_ROWS*STOREUI_COLS - 1
					end
				end
				if startpos < 1 then startpos = 1 end
				if endpos > #store then endpos = #store end
				
				-- Position to render selected card
				local selectedCardx = 0;
				local selectedCardy = 0;
				-- Render unselected cards
				for i = startpos, endpos do
					-- Calculate card positions
					local cardx = x + 30 + ((i-1)%STOREUI_COLS)*100
					local cardy = y + 30 + math.floor((i - startpos)/STOREUI_COLS)*90
					
					if i ~= selectpos then
						-- Render card
						renderCard(cardx, cardy, store[i], false)
					else
						-- Save it for later
						selectedCardx = cardx
						selectedCardy = cardy
					end
				end
				
				-- Render shop frame
				renderShopFrame(x, y, width, height, m, n)
				
				-- Render selected card and picker glove
				renderCard(selectedCardx, selectedCardy, store[selectpos], true)
				local tick = math.floor(os.clock()*2)%2
				if storeAnimState == STATE_SELECTED then
					-- Thumbs up! You did it!
					Graphics.draw {	x = selectedCardx - 24, y = selectedCardy + 37, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.hand),
									sourceX = 0, sourceY = 32, sourceWidth = 32, sourceHeight = 32}
					storeAnimTimer = storeAnimTimer - 1
					if storeAnimTimer <= 0 then
						storeAnimTimer = STOREUI_OPENTIME
						storeAnimState = STATE_CLOSING
						if Misc.isPausedByLua() then Misc.unpause() end
						playSFX(30)
						shopErrorMsg = ""
					end
				else
					Graphics.draw {	x = selectedCardx - 24 - 4*tick, y = selectedCardy + 37, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.hand),
									sourceX = 0, sourceY = 0, sourceWidth = 32, sourceHeight = 32}
				end
								
				-- Render lakitu mascot
				Graphics.draw {	x = x + width - 81, y = y - 58, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.lakitu) }
				-- Render scroll arrows
				if math.ceil(startpos/STOREUI_COLS) > 1 then
					Graphics.draw {	x = x + width/2 - 9, y = y + 13 + 2*tick, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.arrows),
									sourceX = 0, sourceY = 0, sourceWidth = 18, sourceHeight = 14}
				end
				if math.ceil(endpos/STOREUI_COLS) < math.ceil(#store/STOREUI_COLS) then
					Graphics.draw {	x = x + width/2 - 9, y = y + height - 27 - 2*tick, type = RTYPE_IMAGE, priority = 3, image = pm.getGraphic(CHARACTER_WARIO, StoreUI.arrows),
									sourceX = 0, sourceY = 14, sourceWidth = 18, sourceHeight = 14}
				end
				
				-- Show name of item
				if storeAnimState == STATE_ERROR then
					if msgBlinkTimer < 9*6 then
						if msgBlinkTimer%(2*6) < 6 or msgBlinkTimer > 4*6 then
							renderName(x + width/2 - (shopErrorMsg:len() + 4)*16/2, y + height + 4, shopErrorMsg)
						end
						msgBlinkTimer = msgBlinkTimer + 1
					else
						msgBlinkTimer = 0
						renderName(x + width/2 - (shopErrorMsg:len() + 4)*16/2, y + height + 4, shopErrorMsg)
						storeAnimState = STATE_SELECTING
					end
				elseif storeAnimState == STATE_SELECTED then
					local thanks = "Thank you!"
					renderName(x + width/2 - (thanks:len() + 4)*16/2, y + height + 4, thanks)
				else
					local name = store[selectpos][3]
					renderName(x + width/2 - (name:len() + 4)*16/2, y + height + 4, name)
				end
			end
			
			-- Increment/decrement timer
			if storeAnimState == STATE_OPENING then
				storeAnimTimer = storeAnimTimer + 1
				if storeAnimTimer >= STOREUI_OPENTIME then
					storeAnimTimer = STOREUI_OPENTIME
					storeAnimState = STATE_SELECTING
				end
			elseif storeAnimState == STATE_CLOSING then
				storeAnimTimer = storeAnimTimer - 1
				if storeAnimTimer <= 0 then
					storeAnimTimer = 0
					storeAnimState = STATE_NONE
				end
			end
		end
		
		-- Render dash charge meter
		renderDashMeter(352, 35)
		
		-- Show dashing frames when dashing and not on a mount
		if dashing and player:mem(0x108, FIELD_WORD) == 0 then
			if dashtimer - DASHCHARGETIME < 5 then
				player:mem(0x114, FIELD_WORD, 32)
			elseif dashtimer - DASHCHARGETIME < 5*2 then
				player:mem(0x114, FIELD_WORD, 33)
			else
				dashtimer = DASHCHARGETIME
				player:mem(0x114, FIELD_WORD, 32)
			end
			if not player:isGroundTouching() then player:mem(0x114, FIELD_WORD, 33) end
			if dashtimer-DASHCHARGETIME == 0 then Audio.SfxPlayCh(-1, Audio.SfxOpen(pm.getSound(CHARACTER_WARIO, rng.irandomEntry(sfx.footstep))), 0) end
		end
		
		-- Show crawling frames
		if crawling then
			if crawltimer < 10 then player:mem(0x114, FIELD_WORD, 22)
			elseif crawltimer < 10*2 then player:mem(0x114, FIELD_WORD, 23)
			else
				crawltimer = 0
				player:mem(0x114, FIELD_WORD, 22)
			end
			crawltimer = crawltimer + 1
		else crawltimer = 0 end
	end
end


-- Debug drawing, for showing hitboxes in debug mode
local function DrawRect(x1, y1, x2, y2, clr)
	x1 = x1 - Camera.get()[1].x
	y1 = y1 - Camera.get()[1].y
	x2 = x2 - Camera.get()[1].x
	y2 = y2 - Camera.get()[1].y

	left = {
		x1,y1, x1+1,y1, x1+1,y2,
		x1,y1, x1,y2, x1+1,y2
	}
	right = {
		x2-1,y1, x2,y1, x2,y2,
		x2-1,y1, x2-1,y2, x2,y2
	}
	top = {
		x1,y1, x2,y1, x2,y1+1,
		x1,y1, x1,y1+1, x2,y1+1
	}
	bottom = {
		x1,y2-1, x2,y2-1, x2,y2,
		x1,y2-1, x1,y2, x2,y2
	}
	
	Graphics.glDraw {vertexCoords = left, color = clr}
	Graphics.glDraw {vertexCoords = right, color = clr}
	Graphics.glDraw {vertexCoords = top, color = clr}
	Graphics.glDraw {vertexCoords = bottom, color = clr}
end
function wario.DebugDraw()
	DrawRect(player.x, player.y, player.x + player.width, player.y + player.height, {0,1,0})
	--colliders.getHitbox(player):Draw(0xff00007f)
end

return wario














