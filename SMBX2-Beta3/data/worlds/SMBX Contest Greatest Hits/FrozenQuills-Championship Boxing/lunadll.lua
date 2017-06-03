bossBattle = false
moves = {}
debounce = false
counter = 0
r = 2
bossweak = false
d = 0

function onLoad()
	bossBattle = false
	moves = {"SOUL BURN", "FINAL PUNISHMENT", "MANA SHORT", "SERPENT ASSASSIN", "AZORIUS KEYRUNE", "FURNACE WHELP"}
	arrsize = 0
	for _ in pairs(moves) do arrsize = arrsize + 1 end
	debounce = false
	counter = 0
	r = 2
	bossweak = false
	d = 0
end

function setNpcSpeed(npcid, speed)
   local p = mem(0x00b25c18, FIELD_DWORD) -- Get the pointer to the NPC speed array
   mem(p + (0x4 * npcid), FIELD_FLOAT, speed)
end

local A1, A2 = 727595, 798405  -- 5^17=D20*A1+A2
local D20, D40 = 1048576, 1099511627776  -- 2^20, 2^40
local X1, X2 = 0, 1
function rand()
    local U = X2*A2
    local V = (X1*A2 + X2*A1) % D20
    V = (V*D20 + U) % D40
    X1 = math.floor(V/D20)
    X2 = V - X1*D20
    return V/D40
end

function printCenteredText(s, y)
	s = tostring(s)
	stringx = 400-(s:len()*18/2)
	printText(s, stringx, y)
end

function onLoop()
	local check = findnpcs(273, -1)
	for i, v in pairs(check) do
		xpos = -199744
		if v.x < xpos-10 then
			--printText("hi again", 30, 200)
			bossBattle = true
		end
	end
	
	if bossBattle==true then
		if debounce == false then
			r = r + 1
			if r > arrsize then
				r = 1
			end
			action = moves[r]
			text = "--- " .. tostring(action) .. " ---" --.. tostring(r) .. " --- " .. tostring(counter)
			counter = 0
			--earthquake(3)
			debounce = true
			if action == "SOUL BURN" then
				triggerEvent("SoulBurn")
			elseif action == "MANA SHORT" then
				triggerEvent("ManaShort")
			elseif action == "FINAL PUNISHMENT" then
				triggerEvent("FinalPunishment")
				bossweak = true
			elseif action == "SERPENT ASSASSIN" then
				triggerEvent("SerpentAssassin")
				bossweak = true
			elseif action == "AZORIUS KEYRUNE" then
				triggerEvent("AzoriusKeyrune")
			elseif action == "FURNACE WHELP" then
				triggerEvent("FurnaceWhelp")
				bossweak = true
			elseif action == "WEAK POINT" then
				triggerEvent("WeakPoint")
			end
			
		else

			blocks_hit = findblocks(2)
			c = 0
			for i, v in pairs(blocks_hit) do
				c = c+1
			end
			if c > 8 then
				triggerEvent("ManaFree")
			end
	
			counter = counter + 1
			if counter > 1000 then
				if bossweak == true then
					bosshurt = findblocks(225)
					c = 0
					for i, v in pairs(bosshurt) do
						v.x = 0
						c = c+1
					end
					if c > d then
						d = c
						counter = 0
						debounce = false
						triggerEvent("SwitchActions")
						bossweak = false
					end
				else
					counter = 0
					debounce = false
					triggerEvent("SwitchActions")
				end
			end
		end
		printCenteredText(text, 575)
		
	end
	
end

function onKeyUp(key, plIndex)

end
	
function onKeyDown(key, plIndex)

end
	

