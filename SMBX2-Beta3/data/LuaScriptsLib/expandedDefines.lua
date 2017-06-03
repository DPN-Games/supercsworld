---------------**********************-------------
---------------** EXPANDED DEFINES **-------------
---------------**********************-------------						 
----------Created by Hoeloe and Horikawa (2016)---
--------------Just some block lists---------------
--------------For Super Mario Bros X--------------
----------------------v1.3------------------------

local expandedDefines = {}


--PLEASE UPDATE THESE LISTS AS NECESSARY

--This list should contain any block NOT listed in the NONSOLID, SEMISOLID, LAVA or PLAYER lists.
expandedDefines.BLOCK_SOLID = {1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 29, 31, 32, 33, 34, 35, 36, 37, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 77, 78, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 124, 125, 126, 127, 128, 129, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 162, 163, 164, 165, 166, 167, 169, 170, 171, 173, 174, 176, 177, 179, 180, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 257, 258, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 291, 292, 293, 294, 295, 296, 297, 298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 323, 324, 325, 326, 327, 328, 329, 330, 331, 332, 333, 334, 335, 336, 337, 338, 339, 340, 341, 342, 343, 344, 345, 346, 347, 348, 349, 350, 351, 352, 353, 354, 355, 356, 357, 358, 359, 360, 361, 362, 363, 364, 365, 366, 367, 368, 369, 370, 376, 377, 378, 383, 384, 385, 386, 387, 388, 390, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402, 403, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 421, 422, 423, 424, 425, 426, 427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 569, 570, 571, 573, 574, 576, 577, 578, 580, 581, 582, 583, 584, 585, 586, 587, 588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 606, 607, 608, 609, 610, 611, 612, 613, 614, 615, 616, 617, 618, 619, 620, 621, 622, 623, 624, 625, 630, 631, 633, 634, 635, 636, 637, 638, 639, 641, 643, 645, 647, 649, 651, 653, 655, 657, 659, 661, 663, 665, 666, 667, 668, 669, 670, 671, 674, 675, 676, 677, 678, 679, 680, 681, 682, 683, 684, 685, 686, 687, 688, 689, 690, 691, 692, 693, 694, 695, 696, 697, 698, 699, 700};
--This list should contain blocks that can be stood on, but do not act as walls or ceilings.
expandedDefines.BLOCK_SEMISOLID = {8, 25, 26, 27, 28, 38, 69, 79, 108, 121, 122, 123, 130, 161, 168, 240, 241, 242, 243, 244, 245, 259, 260, 261, 287, 288, 289, 290, 372, 373, 374, 375, 379, 380, 381, 382, 389, 391, 392, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 506, 507, 508, 568, 572, 575, 579};
--This list should contain blocks that are entirely intangible
expandedDefines.BLOCK_NONSOLID = {172, 175, 178, 181, 665};
--This list should contain lava.
expandedDefines.BLOCK_LAVA = {30, 371, 404, 405, 406, 420, 459, 460, 461, 462, 463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487};
--This list should contain blocks that can hurt the player.
expandedDefines.BLOCK_HURT = {109, 110, 267, 268, 269, 407, 408, 428, 429, 430, 431, 511, 598, 672, 673, 682, 683};
--This list should contain player filter blocks.
expandedDefines.BLOCK_PLAYER = {626, 627, 628, 629, 632, 640, 642, 644, 646, 648, 650, 652, 654, 656, 658, 660, 662, 664}

--This list should contain each list of block types.
expandedDefines.BLOCK_LISTS = {expandedDefines.BLOCK_SOLID, expandedDefines.BLOCK_SEMISOLID, expandedDefines.BLOCK_NONSOLID, expandedDefines.BLOCK_LAVA, expandedDefines.BLOCK_HURT, expandedDefines.BLOCK_PLAYER};

--NPC Data Here...

--This list should contain NPCs that constitute powerups. Not fireballs, but instead fire flowers, etc.
expandedDefines.NPC_POWERUP = {273, 187, 186, 90, 249, 185, 184, 9, 183, 182, 14, 277, 264, 170, 287, 169, 34}
--This list should contain NPCs that are unhittable. Vines and the like.
expandedDefines.NPC_UNHITTABLE = {9, 10, 11, 13, 14, 16, 21, 22, 26, 30, 31, 32, 33, 34, 35, 40, 41, 45, 46, 56, 57, 58, 60, 62, 64, 66, 67, 68, 69, 70, 75, 78, 79, 80, 81, 82, 83, 84, 85, 87, 88, 90, 91, 92, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 133, 134, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 169, 170, 171, 178, 179, 181, 182, 183, 184, 185, 186, 187, 188, 190, 191, 192, 193, 196, 197, 198, 202, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 237, 238, 239, 240, 241, 246, 248, 249, 250, 251, 252, 253, 254, 255, 258, 259, 260, 264, 265, 266, 269, 273, 274, 276, 277, 278, 279, 282, 283, 287, 288, 289, 290, 291, 292, 293, 294}
--This list should contain NPCs that take multiple hits to kill. Mother Brain, etc.
expandedDefines.NPC_MULTIHIT = {15, 44, 208, 209, 256, 257, 263, 267, 268, 280, 281}
--This list should contain NPCs that you can hit. Goombas, koopas, etc.
expandedDefines.NPC_HITTABLE = {1, 2, 3, 4, 5, 6, 7, 8, 12, 15, 17, 18, 19, 20, 23, 24, 25, 27, 28, 29, 36, 37, 38, 39, 42, 43, 44, 47, 48, 49, 50, 51, 52, 53, 54, 55, 59, 61, 63, 65, 71, 72, 73, 74, 76, 77, 86, 89, 93, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 135, 136, 137, 161, 162, 163, 164, 165, 166, 167, 168, 172, 173, 174, 175, 176, 177, 180, 189, 194, 195, 199, 200, 201, 203, 204, 205, 206, 207, 208, 209, 210, 229, 230, 231, 232, 233, 234, 235, 236, 242, 243, 244, 245, 247, 256, 257, 261, 262, 263, 267, 268, 270, 271, 272, 275, 280, 281, 284, 285, 286, 295, 296, 297, 298, 299, 300}
--This list should contain Shells
expandedDefines.NPC_SHELL = {5, 7, 24, 73, 113, 114, 115, 116, 172, 174, 195, 268, 281}

--This list should contain each list of NPC types.
expandedDefines.NPC_LISTS = {expandedDefines.NPC_POWERUP, expandedDefines.NPC_UNHITTABLE, expandedDefines.NPC_MULTIHIT, expandedDefines.NPC_HITTABLE, expandedDefines.NPC_SHELL}

--Misc Lists Here

expandedDefines.LUNALUA_EVENTS = {"onStart", "onLoad", "onTick", "onTickEnd", "onDraw", "onDrawEnd", "onLoop", "onLoopSection0", "onLoopSection1", "onLoopSection2", "onLoopSection3", "onLoopSection4", "onLoopSection5", "onLoopSection6", "onLoopSection7", "onLoopSection8", "onLoopSection9", "onLoopSection10", "onLoopSection11", "onLoopSection12", "onLoopSection13", "onLoopSection14", "onLoopSection15", "onLoopSection16", "onLoopSection17", "onLoopSection18", "onLoopSection19", "onLoopSection20", "onLoadSection", "onLoadSection0", "onLoadSection1", "onLoadSection2", "onLoadSection3", "onLoadSection4", "onLoadSection5", "onLoadSection6", "onLoadSection7", "onLoadSection8", "onLoadSection9", "onLoadSection10", "onLoadSection11", "onLoadSection12", "onLoadSection13", "onLoadSection14", "onLoadSection15", "onLoadSection16", "onLoadSection17", "onLoadSection18", "onLoadSection19", "onLoadSection20", "onJump", "onJumpEnd", "onKeyDown", "onKeyUp", "onEvent", "onEventDirect", "onExitLevel", "onInputUpdate", "onMessageBox", "onHUDDraw", "onNPCKill", "onCameraUpdate", "onKeyboardPress"}


--**************************************************************--
--** DO NOT TOUCH PAST HERE UNLESS YOU KNOW WHAT YOU'RE DOING **--
--**************************************************************--

local function calculateMaxOfTables(tableName)
	local maxValue = 0
	for _, v in ipairs(tableName) do
		for _, w in ipairs(v) do
			maxValue = math.max(unpack({w, maxval}))
		end
	end
	return maxValue
end

expandedDefines.BLOCK_MAX_NUMBER = calculateMaxOfTables({expandedDefines.BLOCK_SOLID, expandedDefines.BLOCK_SEMISOLID, expandedDefines.BLOCK_NONSOLID, expandedDefines.BLOCK_LAVA, expandedDefines.BLOCK_HURT, expandedDefines.BLOCK_PLAYER})

expandedDefines.NPC_MAX_NUMBER = calculateMaxOfTables({expandedDefines.NPC_POWERUP, expandedDefines.NPC_UNHITTABLE, expandedDefines.NPC_MULTIHIT, expandedDefines.NPC_HITTABLE})

local function makeTestMap(src)
	local ret = {};
	for _,v in ipairs(src) do
		ret[v] = true;
	end
	return ret
end

local function makelistmtraw(id, basemt)
	local r = {};
	for k, v in pairs(basemt) do
		r[k] = v;
	end
	r.__index = function(tbl, key)
		if(key == "id") then
			return id;
		end
	end
	return r;
end

--IDs are set to powers of two so that concats can store IDs with the bitwise or of the concatenated lists.
--For example, lists with IDs 2,4 and 16 will produce bit patterns of 00010, 00100 and 10000, which produces
--a concatenated bit pattern of 10110, which gives the ID 22, which will be unique for this concatenation pattern.
local function makelistmt(rootid, basemt)
	return makelistmtraw(math.pow(2,rootid), basemt);
end

local indexerror = function(tbl, key, val)
	error("Attempted to assign a value in a read-only table.", 2)
end

local function makeConcat(cacheList, basemt)
	return  function(a, b)
				if(cacheList[bit.bor(a.id,b.id)] ~= nil) then
					return cacheList[bit.bor(a.id,b.id)];
				end
				local r = {};
				for k, v in ipairs(a) do
					r[k] = v;
				end
				for k, v in ipairs(b) do
					r[#a+k] = v;
				end
				setmetatable(r, makelistmtraw(bit.bor(a.id,b.id), basemt));
				cacheList[bit.bor(a.id,b.id)] = r;
				return r;
			end
end

local blockscache = {};
local blockmt = {}
blockmt.__concat = makeConcat(blockscache, blockmt)
blockmt.__newindex = indexerror;

local npcscache = {};
local npcmt = {}
npcmt.__concat = makeConcat(npcscache, npcmt)
npcmt.__newindex = indexerror;

expandedDefines.BLOCK_ALL = {}
for i=1,expandedDefines.BLOCK_MAX_NUMBER do
	table.insert(expandedDefines.BLOCK_ALL, i);
end

local maxBlockID = 0;
--Set the IDs of the block lists for caching of concatenated lists.
for k,v in ipairs(expandedDefines.BLOCK_LISTS) do
	setmetatable(v, makelistmt(k-1,blockmt));
	maxBlockID = k;
end
--Set ID of the "all" list to be the same as all lists concatenated.
setmetatable(expandedDefines.BLOCK_ALL, makelistmtraw(math.pow(2,maxBlockID)-1,blockmt));

expandedDefines.NPC_ALL = {}
for i=1,expandedDefines.NPC_MAX_NUMBER do
	table.insert(expandedDefines.NPC_ALL, i);
end

local maxNPCID = 0;
--Set the IDs of the NPC lists for caching of concatenated lists.
for k,v in ipairs(expandedDefines.NPC_LISTS) do
	setmetatable(v, makelistmt(k-1,npcmt));
	maxNPCID = k;
end
--Set ID of the "all" list to be the same as all lists concatenated.
setmetatable(expandedDefines.NPC_ALL, makelistmtraw(math.pow(2,maxNPCID)-1,npcmt));

local function contains(a, b)
	if(type(a) == 'number') then return a == b; end
	for _, v in ipairs(a) do
		if(v == b) then
			return true;
		end
	end
	return false;
end

expandedDefines.BLOCK_SOLID_MAP = makeTestMap(expandedDefines.BLOCK_SOLID)
expandedDefines.BLOCK_SEMISOLID_MAP = makeTestMap(expandedDefines.BLOCK_SEMISOLID)
expandedDefines.BLOCK_NONSOLID_MAP = makeTestMap(expandedDefines.BLOCK_NONSOLID)
expandedDefines.BLOCK_LAVA_MAP = makeTestMap(expandedDefines.BLOCK_LAVA)
expandedDefines.BLOCK_HURT_MAP = makeTestMap(expandedDefines.BLOCK_HURT)
expandedDefines.BLOCK_PLAYER_MAP = makeTestMap(expandedDefines.BLOCK_PLAYER)

expandedDefines.NPC_POWERUP_MAP = makeTestMap(expandedDefines.NPC_POWERUP)
expandedDefines.NPC_UNHITTABLE_MAP = makeTestMap(expandedDefines.NPC_UNHITTABLE)
expandedDefines.NPC_MULTIHIT_MAP = makeTestMap(expandedDefines.NPC_MULTIHIT)
expandedDefines.NPC_HITTABLE_MAP = makeTestMap(expandedDefines.NPC_HITTABLE)
expandedDefines.NPC_SHELL_MAP = makeTestMap(expandedDefines.NPC_SHELL)

expandedDefines.LUNALUA_EVENTS_MAP = makeTestMap(expandedDefines.LUNALUA_EVENTS)

return expandedDefines;