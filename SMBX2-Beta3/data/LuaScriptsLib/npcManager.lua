--npcManager.lua
--v1.0.5
--Created by Horikawa Otane, 2016
local npcconfig = API.load("npcconfig")
local configFileReader = API.load("configFileReader")

local npcManager = {}
local negativeValueArray = {}
negativeValueArray["jumphurt"] = true
negativeValueArray["nohurt"] = true
negativeValueArray["nogravity"] = true
negativeValueArray["noblockcollision"] = true

function npcManager.onInitAPI()
	registerEvent(npcManager, "onNPCKill");
end

local deathEffectArray = {}

function npcManager.setNpcSettings(settingsArray)
	local configFile = configFileReader.parseTxt("npc-" .. settingsArray.id .. ".txt") or {}
	for npcCode, npcValue in pairs(settingsArray) do
		if negativeValueArray[npcCode] then
			npcconfig[settingsArray.id][npcCode] = -1 * (tonumber(configFile[npcCode]) or npcValue)
			configFile[npcCode] = -1 * (tonumber(configFile[npcCode]) or npcValue)
		else
			npcconfig[settingsArray.id][npcCode] = configFile[npcCode] or npcValue
			configFile[npcCode] = configFile[npcCode] or npcValue
		end
	end
	return configFile
end

function npcManager.registerHarmTypes(id, harmList, deatheffects)
	NPC.vulnerableHarmTypes[id] = harmList;
	deathEffectArray[id] = deatheffects;
end

function npcManager.onNPCKill(eventobj, npc, reason)
	if(not npc.isValid or deathEffectArray[npc.id] == nil) then
		return;
	end
	if(reason == 1) then
		Audio.playSFX(2)
	elseif(reason == 2 or reason == 3 or reason == 5 or reason == 7) then
		Audio.playSFX(9)
	elseif(reason == 4) then
		Audio.playSFX(3)
	elseif(reason == 6) then
		Audio.playSFX(16)
	elseif(reason == 8) then
		Audio.playSFX(36)
	elseif(reason == 10) then
		Audio.playSFX(53)
	end
	if(deathEffectArray[npc.id] ~= nil and deathEffectArray[npc.id][reason] ~= nil) then
		local aid = deathEffectArray[npc.id][reason];
		local offx,offy = 0.5,0.5;
		local rex,rey = 0.5,0.5;
		if(type(aid) == "table") then
			offx = aid.xoffset or 0.5;
			offy = aid.yoffset or 0.5;
			rex = aid.xoffsetBack or offx;
			rey = aid.yoffsetBack or offy;
			aid = aid.id;
		end
		local a = Animation.spawn(aid,npc.x+(offx*npc.width),npc.y+(offy*npc.height));
		a.x = a.x-((rex)*a.width);
		a.y = a.y-((rey)*a.height);
	end
end

return npcManager