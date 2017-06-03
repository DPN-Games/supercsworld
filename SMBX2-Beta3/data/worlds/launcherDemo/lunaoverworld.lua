local colliders = API.load("colliders")
local encrypt = API.load("encrypt")
local rng = API.load("rng")

local boulderImg = Graphics.loadImage("TMC_Boulder.png")

local boulders = {}

local moveCounter = 0
local newCounter = 0
local biggest = 1

local checkPoints = {}
checkPoints[1] = {touched = true, x1 = 304, x2 = 336, y1 = 0, y2 = 118}
checkPoints[2] = {touched = false, x1 = 449, x2 = 511, y1 = 284, y2 = 316}
checkPoints[3] = {touched = false, x1 = 641, x2 = 703, y1 = 284, y2 = 316}
checkPoints[4] = {touched = false, x1 = 705, x2 = 767, y1 = 476, y2 = 508}
checkPoints[5] = {touched = false, x1 = 513, x2 = 575, y1 = 476, y2 = 508}
checkPoints[6] = {touched = false, x1 = 513, x2 = 575, y1 = 156, y2 = 188}
checkPoints[7] = {touched = false, x1 = 385, x2 = 447, y1 = 540, y2 = 572}
checkPoints[8] = {touched = false, x1 = 769, x2 = 831, y1 = 156, y2 = 188}
checkPoints[9] = {touched = false, x1 = 769, x2 = 831, y1 = 348, y2 = 380}
checkPoints[10] = {touched = false, x1 = 304, x2 = 336, y1 = 76, y2 = 118}

local hasWon = false
local selectCounter = 0

local firstRun = true
local playerHitbox

local function makeNewBoulder()
	boulder = {}
	boulder.x = 320 + (64 * rng.randomInt(0, 9))
	boulder.y = 32
	boulder.hitBox = colliders.Box(boulder.x, boulder.y, 32, 32)
	table.insert(boulders, boulder)
end

local function resetGame()
	playSFX(44)
	boulders = {}
	for i = 2, 10 do
		checkPoints[i].touched = false
	end
	world.playerX = 320
	world.playerY = 96
	world.playerWalkingDirection = 0
	world.playerWalkingTimer = 0
	world.playerWalkingFrame = 0
	world.playerWalkingFrameTimer = 0
	hasWon = false
end

local function manageBoulders()
	if not hasWon then
		newCounter = newCounter + 1
		playerHitbox.x = world.playerX
		playerHitbox.y = world.playerY
		for _, v in pairs(boulders) do
			v.y = v.y + 1.5
			v.hitBox.y = v.y
		end
		if newCounter == 60 then
			makeNewBoulder()
			newCounter = 0
		end
		for _, v in pairs(boulders) do
			if v.x - world.playerX + 384 > 66 and v.x - world.playerX + 384 < 734 and v.y - world.playerY + 300 > 130 and v.y - world.playerY + 300 < 534 then
				Graphics.placeSprite(1, boulderImg, v.x - world.playerX + 384, v.y - world.playerY + 300, "", 2)
			end
			if colliders.collide(playerHitbox, v.hitBox) then
				resetGame()
			end
		end
	end
end

local function manageDialogue()
	Text.print("MINIGAME: TOUCH BASES IN ORDER", 130, 553)
	Text.print("Hold Select to Reset!", 211, 573)
	if not checkPoints[9].touched and not checkPoints[10].touched then
		Text.print("Checkpoint " .. biggest .. " Reached!", 5, 5)
	elseif checkPoints[9].touched and not checkPoints[10].touched then
		Text.print("Good Job! Head Back to Start!", 5, 5)
	else
		Text.print("Congratulations! You Did it!", 5, 5)
	end
end

local function manageProgress()
	for big, valuer in pairs(checkPoints) do
		if valuer.touched then
			biggest = big
		end
	end
	if (not hasWon) and (world.playerX >= checkPoints[biggest + 1].x1 and world.playerX <= checkPoints[biggest + 1].x2 and world.playerY >= checkPoints[biggest + 1].y1 and world.playerY <= checkPoints[biggest + 1].y2) then
		checkPoints[biggest + 1].touched = true
	end
	if not hasWon and checkPoints[10].touched then
		checkPoints[10].touched = true
		boulders = {}
		hasWon = true
		playSFX(21)
	end
end

function onInputUpdate()
	if firstRun then
		Audio.SeizeStream(-1)
		Audio.MusicOpen("trials1.ogg")
		Audio.MusicPlay()
		world.playerX = 320
		world.playerY = 96
		firstRun = false
		makeNewBoulder()
		playerHitbox = colliders.Box(world.playerX, world.playerY, 16, 16)
	end
	if player.dropItemKeyPressing then
		selectCounter = selectCounter + 1
	else
		selectCounter = 0
	end
end

function onTick()
	if selectCounter == 50 then
		resetGame()
	end
	manageBoulders()
	manageDialogue()
	manageProgress()
end