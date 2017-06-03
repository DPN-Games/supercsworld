--original by PixelPest but enjl is evil and modified it so you could call this 1.1 or something
local altpsystem = {};

local storedPower = false; --true if player has power-up other than mushroom
local canChange = false; --true if it is safe to change the player's power-up
local needChange = false; --true if the player's power-up needs to be changed
local disableInv = false
local doDisable = false
local storedFrames = 0

altpsystem.usingSystem = nil
altpsystem.SYSTEM_WII = 1; --one of three possible power-up systems based on NSMBWii
altpsystem.SYSTEM_DS = 2; --one of three possible power-up systems based on NSMBDS
altpsystem.SYSTEM_SMW = 3; --one of three possible power-up systems based on SMW

function altpsystem.onInitAPI()
	registerEvent(altpsystem, "onTick", "onTick", false)
	registerEvent(altpsystem, "onNPCKill", "onNPCKill", false)
end

function altpsystem.onNPCKill(killObj, killedNPC, killReason)
	if altpsystem.usingSystem == altpsystem.SYSTEM_SMW then
		if killReason == 9 and ((killedNPC.id == 9 or killedNPC.id == 184 or killedNPC.id == 185) and killedNPC:mem(0x12A, FIELD_WORD) == 3600) or (killedNPC.id == 250 and killedNPC:mem(0x12A, FIELD_WORD) == 180) then
			player.reservePowerup = killedNPC.id
		end
	end
end

function altpsystem.onTick()
	if altpsystem.usingSystem ~= nil then
		if player.powerup > 2 then --if the player has a power-up other than a mushroom
			storedPower = true;
		end
		
		if player.powerup == 1 then disableInv = true end
		
		if player:mem(0x122,FIELD_WORD) == 2 and storedPower then --if the player is powering down (hit by an ememy but not killed)
			needChange = true; --the player's power-up needs to be changed from default, but cannot be yet, as it will cause an error while powering down
		end
		
		if player:mem(0x122,FIELD_WORD) ~= 2 and needChange then --if the player is not powering down
			player.powerup = PLAYER_BIG; --the player is now Big Mario
			canChange = false; --reset all values to false
			needChange = false;
			storedPower = false;
		end
		
		if (player:mem(0x122,FIELD_WORD) == 1 or 
			player:mem(0x122,FIELD_WORD) == 4 or 
			player:mem(0x122,FIELD_WORD) == 5 or 
			player:mem(0x122,FIELD_WORD) == 11 or 
			player:mem(0x122,FIELD_WORD) == 12 or 
			player:mem(0x122,FIELD_WORD) == 41) and disableInv then
			doDisable = true
			storedFrames = player:mem(0x140, FIELD_WORD)
		end
		
		if player:mem(0x122,FIELD_WORD) == 0 and doDisable and disableInv then
			doDisable = false
			disableInv = false
			player:mem(0x140, FIELD_WORD, storedFrames)
		end
		
		if altpsystem.usingSystem == altpsystem.SYSTEM_WII then
			player.reservePowerup = 0;
		end
		
		if (player:mem(0x122,FIELD_WORD) == 2) and (altpsystem.usingSystem == altpsystem.SYSTEM_SMW) then
			player.dropItemKeyPressing = true;
		end
	end
end
return altpsystem