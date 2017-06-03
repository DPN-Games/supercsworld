local npcconfig = API.load("npcconfig")

local costume = {}

function costume.onInit()
	npcconfig[291].frames = 1;
	npcconfig[291].width = 32;
	npcconfig[291].height = 26;
end

function costume.onCleanup()
	npcconfig[291].frames = 9;
	npcconfig[291].width = 42;
	npcconfig[291].height = 34;
end

return costume;