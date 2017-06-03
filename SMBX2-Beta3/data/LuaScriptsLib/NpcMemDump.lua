local NpcMemDump = {}

local function sleep(n)  -- seconds
  local t0 = os.clock()
  while os.clock() - t0 <= n do end
end

function NpcMemDump.block(blockid)
	local y = 25
	local x = 25
	
	for i,block in pairs(findblocks(blockid)) do
	
		--player:mem(0x156, FIELD_WORD, player:mem(0x154, FIELD_WORD))
		for i = 0x00,0xE0,2 do
		--for i = 0xE0,0x120,2 do
		--for i = 0x190,0x270,2 do
			local v = block:mem(i, FIELD_WORD)
			printText(string.format("%3X: %d", i, v), x, y)
			y = y + 15
			if (y > 450) then
				y = 40
				x = x + 175
			end
		end
		
		--block:mem(0x2, FIELD_WORD, -1)
		--block:mem(0x4, FIELD_WORD, -1)
		--block:mem(0x8, FIELD_WORD, -1)
		--block:mem(0x06, FIELD_WORD, 1)
		--block:mem(0x5E, FIELD_WORD, -1)
		
		--block:mem(0x20, FIELD_DFLOAT, block:mem(0x20, FIELD_DFLOAT)+1)
	end
end

function NpcMemDump.player(startaddress, endaddress)
	local startaddress = startaddress or 0xE0
	local endaddress = endaddress or 0x184
	local y = 25
	local x = 25
	
	--player:mem(0x140, FIELD_WORD, 5)
	--player:mem(0x142, FIELD_WORD, -1)
	--player:mem(0x10E, FIELD_WORD, 30)
	--player:mem(0x156, FIELD_WORD, player:mem(0x154, FIELD_WORD))
	if (true) then
	--for i = 0x00,0xE0,2 do
	for i = startaddress,endaddress,2 do
	--for i = 0x124,0x200,2 do
	--for i = 0x190,0x270,2 do
		local v = player:mem(i, FIELD_WORD)
		printText(string.format("%03X: %d", i, v), x, y)
		y = y + 15
		if (y > 450) then
			y = 40
			x = x + 175
		end
	end
	end
	
	if (false) then
	for i = 0,8,2 do
		local v = mem(0x00B2C5A8 + i, FIELD_WORD)
		printText(string.format("0x%X: %d", 0x00B2C5A8 + i, v), x, y)
		y = y + 15
		if (y > 450) then
			y = 40
			x = x + 175
		end
	end
	end
end

function NpcMemDump.run(npcid, startaddress, endaddress)
	for i,npc in pairs(findnpcs(npcid, player.section)) do
		local y = 25
		local x = 25
		local startaddress = startaddress or 0xE0
		local endaddress = endaddress or 0x156
		--for i = 0x00,0xE0,2 do
		for i = startaddress,endaddress,2 do
			local v = npc:mem(i, FIELD_WORD)
			printText(string.format("%3X: %d", i, v), x, y)
			y = y + 15
			if (y > 500) then
				y = 70
				x = x + 175
			end
		end
		
		--npc:mem(0xF0, FIELD_DFLOAT, 1)


		printText("0x00:"..npc:mem(0x00, FIELD_STRING).str, 0, 525)
		printText("0x2C:"..npc:mem(0x2C, FIELD_STRING).str, 0, 540)
		printText("0x30:"..npc:mem(0x30, FIELD_STRING).str, 0, 555)
		printText("0x34:"..npc:mem(0x34, FIELD_STRING).str, 200, 525)
		printText("0x38:"..npc:mem(0x38, FIELD_STRING).str, 200, 540)
		printText("0x3C:"..npc:mem(0x3C, FIELD_STRING).str, 200, 555)
		printText("0x4C:"..npc:mem(0x4C, FIELD_STRING).str, 200, 570)
		
		
		--Uncomment to slow down frame rate
		--sleep(0.1)
		--npc:mem(0xF0, FIELD_DFLOAT, 1)
		if (true) then
		printText("0xE8: "..npc:mem(0xE8, FIELD_FLOAT), 400, 150)
		
		printText("0xF0: "..npc:mem(0xF0, FIELD_DFLOAT), 400, 175)
		printText("0xF8: "..npc:mem(0xF8, FIELD_DFLOAT), 400, 200)
		printText("0x100: "..npc:mem(0x100, FIELD_DFLOAT), 400, 215)
		printText("0x108: "..npc:mem(0x108, FIELD_DFLOAT), 400, 230)
		printText("0x110: "..npc:mem(0x110, FIELD_DFLOAT), 400, 245)
		printText("0x116: "..npc:mem(0x116, FIELD_BYTE), 400, 260)
		printText("0x11E: "..npc:mem(0x11E, FIELD_BYTE), 400, 275)

		printText("x: "..npc.x, 400, 290)
		printText("y: "..npc.y, 400, 310)
		
		--printText("inv1: "..npc:mem(0x26, FIELD_WORD), 25, 465)
		--printText("inv2: "..npc:mem(0x156, FIELD_WORD), 200, 465)
		printText("Hits: "..npc:mem(0x148, FIELD_FLOAT), 25, 05)
		end
		break
	end
end

return NpcMemDump