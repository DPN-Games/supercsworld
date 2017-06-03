--[[
Things to fix:
- Prevent CLimbing sound effect.
- Custom hud that shows power-ups you have.
]]

--LOCALS

-- Declare our API object
local juni = {}

local colliders = API.load("colliders")
local savestate = API.load("savestate")
local playeranim = API.load("playeranim")
local inputs = API.load("inputs")
local pm = API.load("playerManager")

juni.highjump = false
juni.wallclimb = true
juni.running = true
juni.doublejump = true
juni.parasol = false
juni.hologram = false

juni.usesavestate = true;

local junijump = -2
local jumpo = 0
local jumped = false
local climb = false
local jumpmax = 1
local parasolopen = false
local umbrellR = pm.registerGraphic(CHARACTER_JUNI, "UmbrellaR.png")
local umbrLa =  pm.registerGraphic(CHARACTER_JUNI, "UmbrellaL.png")
local holographic = pm.registerGraphic(CHARACTER_JUNI, "Holoplayer_0_stopped_1.png")
local holostart = false
local junistarted = 0

local sfx_holo = pm.registerSound(CHARACTER_JUNI, "Hologram A.wav");
local sfx_doublejump = pm.registerSound(CHARACTER_JUNI, "Knytt Double Jump.wav");
local sfx_jump = pm.registerSound(CHARACTER_JUNI, "Knytt Jump.wav");
local sfx_land = pm.registerSound(CHARACTER_JUNI, "Knytt Land.wav");
local sfx_save = pm.registerSound(CHARACTER_JUNI, "Savepoint.wav");
local sfx_umbrella1 = pm.registerSound(CHARACTER_JUNI, "Umbrella A.wav");
local sfx_umbrella2 = pm.registerSound(CHARACTER_JUNI, "Umbrella B.wav");

-----------------
---ON INIT API---
-----------------

function juni.onInitAPI()
	registerEvent(juni, "onInputUpdate", "onInputUpdate")
	registerEvent(juni, "onTick", "onTick")
	registerEvent(juni, "onKeyDown", "onKeyDown")
end

function juni.initCharacter()
	-- Default Movement
	Defines.player_runspeed = 2.2
	Defines.player_walkspeed = 2
	Defines.jumpheight = 12
	Defines.jumpheight_bounce = 13
	-- CLEANUP NOTE: This is not safe if a level makes it's own use of activateHud
	hud(false)
	hasTurnedHudOn = false
	Audio.sounds[1].muted = true
	Audio.sounds[71].muted = true
end

function juni.cleanupCharacter()
	-- Return physics to normal
	Defines.player_runspeed = nil
	Defines.player_walkspeed = nil
	-- CLEANUP NOTE: This is not safe if a level makes it's own use jumpheight
	Defines.jumpheight = nil
	Defines.jumpheight_bounce = nil
	hud(true)
	hasTurnedHudOn = true
	Audio.sounds[1].muted = false
	Audio.sounds[71].muted = false
end

-------------------
---ONLOOP STARTS---
-------------------

function juni.onTick()

	--ONLOOP CONTENTS
	if  player.character == CHARACTER_JUNI then
	
		--ON LEVEL START
		if (player.isValid) then
			if junistarted == 0 then
				juniPowerupSave1, juniPowerupSave2, juniPowerupSave3, juniPowerupSave4, juniPowerupSave5, juniPowerupSave6 = juni.doublejump, juni.running, juni.highjump, juni.hologram, juni.parasol, juni.wallclimb
				junisave = savestate.save(savestate.STATE_ALL)
				junistarted = 1
			end
		end
		
		--die on water
		if player:mem(0x34, FIELD_WORD) == 2 then
			player:kill() 
		end
		
		--Prevent freezing when collecting power-ups.
		if player:mem(0x122, FIELD_WORD) > 0 and not player:mem(0x122, FIELD_WORD) == 3 and not player:mem(0x122, FIELD_WORD) == 7 then
			player:mem(0x122, FIELD_WORD, 0)
			player:mem(0x124, FIELD_WORD, 0)
		end
		
		--change player small
		if player.powerup ~= PLAYER_SMALL and player:mem(0x122, FIELD_WORD) == 0 then
			player.powerup = PLAYER_SMALL
		end
		
		
		--VERTICAL MOVEMENT.
		
		--no spinjump
		player:mem(0x50, FIELD_WORD, 0)
		player:mem(0x52, FIELD_WORD, 0)
		player:mem(0x120, FIELD_WORD, 0)

		--Wall Climb
		 if juni.wallclimb and (player:mem(0x148, FIELD_WORD) > 0 or player:mem(0x14C, FIELD_WORD) > 0) then
			jumpo = 0
			jumped=true
			climb = true
		else
			climb = false
		end
		
		--IF HIGHJUMP
		if juni.highjump then
			Defines.jumpheight = 17
			Defines.jumpheight_bounce = 18
		else 
			Defines.jumpheight = 9.2
			Defines.jumpheight_bounce = 10.2
		end
		
		--IF DOUBLEJUMP
		if juni.doublejump then 
			jumpmax = 2
		else 
			jumpmax = 1
		end

		--IF PARASOL
		if juni.parasol and parasolopen then
		
			if player.speedY > 0.86 then 
				player.speedY = 0.86
			end
			
			if player:mem(0x106, FIELD_WORD) == -1 then
				Graphics.drawImageToSceneWP(pm.getGraphic(CHARACTER_JUNI,umbrLa),player.x-6,player.y-20,-25)
			else 
				Graphics.drawImageToSceneWP(pm.getGraphic(CHARACTER_JUNI,umbrellR),player.x-14,player.y-20,-25)
			end
		end


		--COLLECTING POWERS
		
		if colliders.collideNPC(player, 184) then
			juni.highjump = true

		end
		if colliders.collideNPC(player,14) then
			juni.doublejump = true

		end
		if colliders.collideNPC(player, 34)  then
			juni.wallclimb = true

		end
		if colliders.collideNPC(player,170)  then
			juni.parasol = true

		end
		if colliders.collideNPC(player,169)  then
			juni.hologram = true

		end
		if colliders.collideNPC(player,9)  then
			juni.running = true

		end
		if colliders.collideNPC(player, 192) then
			junisave = savestate.save(savestate.STATE_ALL)
			juniPowerupSave1, juniPowerupSave2, juniPowerupSave3, juniPowerupSave4, juniPowerupSave5, juniPowerupSave6 = juni.doublejump, juni.running, juni.highjump, juni.hologram, juni.parasol, juni.wallclimb
		end

		--Hologram flash
		if player:mem(0x140, FIELD_WORD) > 0 and holostart then
			Graphics.drawImageToSceneWP(pm.getGraphic(CHARACTER_JUNI,holographic),holox,holoy,-25)
		end

		--IF RUNNING
		if juni.running == false then 
			Defines.player_runspeed = 2.2
			Defines.player_walkspeed = 2.2
		else
			Defines.player_runspeed = 4
			Defines.player_walkspeed = 2.2
		end 
		
		--IF PLAYER DEATH ANIMATION--
		if player:mem(0x13E, FIELD_WORD) > 0 then
				if(juni.usesavestate) then
					Audio.SeizeStream(player.section)
					Audio.SfxStop(player.section)
					savestate.load(junisave, savestate.STATE_ALL)
					juni.doublejump, juni.running, juni.highjump, juni.hologram, juni.parasol, juni.wallclimb = juniPowerupSave1, juniPowerupSave2, juniPowerupSave3, juniPowerupSave4, juniPowerupSave5, juniPowerupSave6
					Audio.ReleaseStream(player.section)
					playMusic(player.section)
				else
					player:mem(0x13E, FIELD_WORD, 198);
				end
		end
	end
	--Text.print(tostring(player.speedX), 0, 20)
end


	----------------
	---ONKEY DOWN---
	----------------

function juni.onKeyDown(keycode, playerIndex)
	if player.character == CHARACTER_JUNI then
		--SAVEPOINTS
		if keycode == KEY_DOWN and colliders.collideNPC(player, 182) then
			junisave = savestate.save(savestate.STATE_ALL)
			Audio.playSFX(pm.getSound(CHARACTER_JUNI,sfx_save))
			juniPowerupSave1, juniPowerupSave2, juniPowerupSave3, juniPowerupSave4, juniPowerupSave5, juniPowerupSave6 = juni.doublejump, juni.running, juni.highjump, juni.hologram, juni.parasol, juni.wallclimb
		end

		--HOLOGRAM
		if keycode== KEY_SPINJUMP and player:mem(0x140, FIELD_WORD) == 0 then

			if juni.hologram then
				--if on ground
				if  player:mem(0x146,FIELD_WORD) ~= 0 or player:mem(0x48,FIELD_WORD) ~= 0 or player:mem(0x176,FIELD_WORD) ~= 0 then 
					Audio.playSFX(pm.getSound(CHARACTER_JUNI,sfx_holo))
					holox, holoy = player.x, player.y
					player:mem(0x140, FIELD_WORD, 150)
					holostart = true
				end
			end
		end
	end
end


--------------------
---ONINPUT UPDATE---
--------------------

function juni.onInputUpdate()
	if player.character == CHARACTER_JUNI then
		pm.winStateCheck()
		--DOUBLEJUMP
		if not climb then
			if inputs.state["jump"] == inputs.PRESS and Level.winState() == 0 then
				jumped=false
				if  player:mem(0x146,FIELD_WORD) == 0 or player:mem(0x48,FIELD_WORD) == 0 or player:mem(0x176,FIELD_WORD) == 0 or player:mem(0x40, FIELD_WORD) == 3 then 
					jumpo = jumpo+1
				end
				if jumpo == 1 then
					if  player:mem(0x146,FIELD_WORD) ~= 0 or player:mem(0x48,FIELD_WORD) ~= 0 or player:mem(0x176,FIELD_WORD) ~= 0 or player:mem(0x40, FIELD_WORD) == 3 then 
						Audio.playSFX(pm.getSound(CHARACTER_JUNI,sfx_jump))
					else
						if juni.doublejump then
							Audio.playSFX(pm.getSound(CHARACTER_JUNI,sfx_doublejump))
						end
					end
				end
			end
		
		--IF ON GROUND--
			if  player:mem(0x146,FIELD_WORD) ~= 0 or player:mem(0x48,FIELD_WORD) ~= 0 or player:mem(0x176,FIELD_WORD) ~= 0 or player:mem(0x40, FIELD_WORD) == 3 then 
				if jumpo > 0 then
					jumpo = 0
				end
			elseif  jumpo > 0 and jumpo < jumpmax and not jumped then
				jumped=true
				if juni.highjump then
					player.speedY = -Defines.jumpheight*0.6
				else 
					player.speedY = -Defines.jumpheight*0.8
				end
			end
		end
		
		--WALLCLIMB
		if juni.wallclimb and climb then
			climb = false
			player.speedX=0
			jumpo = 0
			if player.upKeyPressing then
				player:mem(0x40, FIELD_WORD, 3)
			else
				player:mem(0x40, FIELD_WORD, 1)
				playeranim.setFrame(player,25)
			end
		end

		--UMBRELLA
		if inputs.state["altrun"] == inputs.PRESS and Level.winState() == 0 then
			if juni.parasol then
				if parasolopen then 
					Audio.playSFX(pm.getSound(CHARACTER_JUNI,sfx_umbrella1))
					parasolopen = false
				elseif parasolopen == false then
					Audio.playSFX(pm.getSound(CHARACTER_JUNI,sfx_umbrella2))
					parasolopen = true
				end 
			end
		end
	end
end

return juni