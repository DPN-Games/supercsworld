-- Filter character/powerup
function onLoad()
	if (player.isValid) then
		player:mem(0xF0,FIELD_WORD,5)
		player.powerup = PLAYER_SMALL
	end
end

-- Set hits of ice blocks in section 2, 3, and 6
iceblockflag1 = false
function onLoadSection1()
	iceblockflag1 = false
end
function onLoopSection1()
	if not iceblockflag1 then
		for i,block in pairs(findnpcs(208, player.section)) do
			block:mem(0x148,FIELD_FLOAT,8)
		end
		iceblockflag1 = true
	end
end
iceblockflag2 = false
function onLoadSection2()
	iceblockflag2 = false
end
function onLoopSection2()
	if not iceblockflag2 then
		for i,block in pairs(findnpcs(208, player.section)) do
			block:mem(0x148,FIELD_FLOAT,16)
		end
		iceblockflag2 = true
	end
end
iceblockflag5 = false
playerkilled = false
function onLoadSection5()
	iceblockflag5 = false
	-- Reset bomb count
	player:mem(0x08,FIELD_WORD,0)
end
function onLoopSection5()
	if not iceblockflag5 then
		for i,block in pairs(findnpcs(208, player.section)) do
			block:mem(0x148,FIELD_FLOAT,16)
		end
		iceblockflag5 = true
	end
	-- Kill if touching the lava
	if player.x >= -97680 and player.x <= -96624 then
		if player.y >= -98550 and not playerkilled then
			player:kill()
			playerkilled = true
		end
	end
end



-- Has the platform reached its destination?
destinationReached = false
function onLoopSection6()
	-- Check if the weight on floating platform 2 has been destroyed
	if not platform2WeightDestroyed then
		platform2WeightDestroyed = true
	end
	for i,block in pairs(findblocks(226)) do
		if block.layerName.str == "Floating Platform 2" then
			platform2WeightDestroyed = false
		end
	end	
	--Accelerate floating platform 2 if the weight is destroyed
	if platform2WeightDestroyed and not destinationReached then
		for i,npc in pairs(findnpcs(283, player.section)) do
			if npc.layerName.str == "Bubble 2" then
				npc.speedY = -2
				if npc.y <= -81195 then
					npc.speedY = 0
					destinationReached = true
				end
			end
		end
	end
	
	-- Find all bubbles, in the same section the player is currently in
	for i,bubble in pairs(findnpcs(283, player.section)) do
		-- Set bubbles to never de spawn
		bubble:mem(0x12A, FIELD_WORD, 360000)
		-- Make bubbles invincible
		bubble:mem(0x156,FIELD_WORD,2)
	end
end



-- Has the MB animation been set?
mbflag = false
function onLoopSection7()
	if not mbflag then
		-- Set size of Mother Brain death animation
		for i,anim in pairs(animations()) do
			if (anim.id == 112) then
				anim.height = 192
				anim.width = 128
				mbflag = true
				break
			end
		end
	end
	
	-- Thwomp AI
	thwomps = findnpcs(37,player.section)
	for i,thwomp in pairs(thwomps) do
		-- Follow the player if not falling
		if thwomp.speedY <= 0 then
			if player.x < thwomp.x then
				thwomp.speedX = thwomp.speedX - 0.02
			else
				thwomp.speedX = thwomp.speedX + 0.02
			end
		else
			thwomp.speedX = 0
		end
		-- Bounce off the walls
		if thwomp.x <= -59946 then
			thwomp.speedX = -thwomp.speedX
			thwomp.x = -59946
		elseif thwomp.x >= -59308 then
			thwomp.speedX = -thwomp.speedX
			thwomp.x = -59308
		end
		-- Make invincible
		thwomp:mem(0x156,FIELD_WORD,2)
	end
	-- Boss logic
	boss_logic()
end



function onLoadSection8()
	-- Reset bomb count
	player:mem(0x08,FIELD_WORD,0)
end


-- Invincibility frames and counter
INVINCIBLE_FRAMES = 30
inv_counter = 0
-- Health counter
MAX_HITS = 3
hits = 0
-- Frame speed of capsule closing animation
FRAME_SPEED = 2
-- Current frame of animation
anim_frame = 0
frame_counter = 0
-- Timer for open state
OPEN_TIME = 600
open_count = 0
-- Acceleration
accel = 0
-- States
KILLED = -2
PAUSED = -1
CLOSED = 0
OPENING = 1
OPEN = 2
CLOSING = 3
state = PAUSED
-- Is the boss music playing?
musicplay = false
function boss_logic()
	-- Search for boss NPC if not found
	if boss	== nil and bosslayer == nil and state ~= KILLED then
		boss = findnpcs(209,player.section)
		if boss[0] then
			bosslayer = findlayer("Boss")
		end
	end
	-- When unpaused, begin boss battle
	if state == PAUSED then
		if bosslayer then
			if bosslayer.speedY == 1 then
				bosslayer.speedY = 2
				bosslayer.speedX = 2
				state = CLOSING
			end
		end
	end
	-- If the boss exists and has not been killed or paused
	if boss[0] and state ~= KILLED and state ~= PAUSED then
		-- Play music
		if not musicplay then
			MusicOpen("Sonic 3 - Act 2 Boss.ogg")
			MusicPlay()
			musicplay = true
		end
		-- Prevent from advancing frames automatically
		boss[0]:mem(0xE8,FIELD_FLOAT,0)
		-- Make immune to sword
		boss[0]:mem(0x26,FIELD_WORD,2)
		
		-- Levitate up and down
		if bosslayer.speedY >= 2 then
			accel = -0.08
		elseif bosslayer.speedY <= -2 then
			accel = 0.08
		end
		bosslayer.speedY = bosslayer.speedY + accel
		
		-- Move side to side
		if boss[0].x <= -59938 then
			boss[0].x = -59938
			bosslayer.speedX = 2
		elseif boss[0].x >= -59346 then
			boss[0].x = -59346
			bosslayer.speedX = -2
		end
		
		-- Detect hits
		if boss[0]:mem(0x148,FIELD_FLOAT) > 0 then
			-- Reduce SMBX hit counter
			boss[0]:mem(0x148,FIELD_FLOAT,0)
			-- Increase hit counter if vulnerable
			if state == OPEN and inv_counter <= 0 then
				-- Increment hits
				hits = hits + 1
				state = CLOSING
				-- Set invincibility frames
				inv_counter = INVINCIBLE_FRAMES
				-- Spawn a heart
				triggerEvent("Spawn Heart")
			elseif state == CLOSED then
				-- Open the machine!
				state = OPENING
			end
		end
		
		printText("Sub Zero:",40,28)
		printText("HP: "..tostring(MAX_HITS-hits),40,50)
		
		-- Change frame depending on state
		if state == CLOSED then anim_frame = 9
		elseif state == OPEN then
			anim_frame = 0
			-- Stay open for a certain amount of time
			if open_count < OPEN_TIME then
				open_count = open_count + 1
			else
				open_count = 0
				state = CLOSING
			end
		-- If the pod is opening, but not shaking from being hit
		elseif state == OPENING and inv_counter <= 0 then
			if frame_counter == 0 then
				anim_frame = anim_frame - 1
				if anim_frame ~= 1 then
					frame_counter = FRAME_SPEED
				else
					frame_counter = 0
					state = OPEN
					anim_frame = 0
				end
			end
		elseif state == CLOSING then
			-- If the pod is open and shaking
			if inv_counter > 0 then anim_frame = 1
			-- Otherwise, close the pod
			else
				if frame_counter == 0 then
					anim_frame = anim_frame + 1
					if anim_frame == 1 then anim_frame = 2 end
					if anim_frame ~= 9 then
						frame_counter = FRAME_SPEED
					else
						frame_counter = 0
						state = CLOSED
						inv_counter = INVINCIBLE_FRAMES + 1
					end
				end
			end
		end
		boss[0]:mem(0xE4,FIELD_WORD,anim_frame)
		
		-- Decrement invincibility counter
		inv_counter = inv_counter - 1
		-- Decrement frame counter
		if frame_counter > 0 then
			frame_counter = frame_counter - 1
		end
		
		-- Check if dead
		if hits >= MAX_HITS then
			state = KILLED
			boss[0]:kill()
			MusicStop()
		end
	end
end

























