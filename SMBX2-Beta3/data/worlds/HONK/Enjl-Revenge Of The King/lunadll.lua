local eventu = API.load("eventu")
local rng = API.load("rng")
local particles = API.load("particles")
local colliders = API.load("colliders")
local vectr = API.load("vectr")

local bg = Graphics.loadImage("arenabg.png")
local dee = Graphics.loadImage("waddledee.png")
local arena = Graphics.loadImage("arena.png")
local grabThis = Graphics.loadImage("GRAB THIS.png")

local dedede = Graphics.loadImage("boss.png")

local dedeshadow = Graphics.loadImage("dedeshadow.png")
local marioshadow = Graphics.loadImage("marioshadow.png")

local deeOffsetX = 0
local deeOffsetY = 0
local deeOffsetYDirection = 1

local tableOfAttacks = {}

local HPBAR = Graphics.loadImage("hpBar.png")
local hP = Graphics.loadImage("hitPoint.png")

local actualHP = 0

local isJumping = false

local stars = {}

local starSprite = Graphics.loadImage("star.png")

local playerCenter = 0

local hasChecked = false

local tableOfFire = {}
local fireSprite = Graphics.loadImage("fire.png")

local tableOfOtherFire = {}
local tableOfFireEmitters = {}
local actualFire = Graphics.loadImage("actualfire.png")

local isKilling = false

local STATE_NULL = -2
local STATE_JUMPIN = -1
local STATE_IDLE = 0
local STATE_WALK = 1
local STATE_LEAP = 2
local STATE_FARJUMP = 3
local STATE_SWALLOW = 4
local STATE_SPIT = 5
local STATE_BALLOON = 6
local STATE_HAMMERRUN = 7
local STATE_HAMMERJUMP = 8
local STATE_HAMMERFIRE = 9
local STATE_HAMMERROCKET = 10
local STATE_PREPAREWHIRL = 11
local STATE_SLOWWHIRL = 12
local STATE_FASTWHIRL = 13
local STATE_DIZZY = 14
local STATE_DEAD = 15
local STATE_WAIT = 16
local STATE_WAITWITHCOLLISION = 17

local shockwave = Graphics.loadImage("shockwave.png")

local availableDirections = {}

local availableMoves = {1,3,4,6,7,9,10,11}

local fighting = false

local tableOfRockets = {}
local rocketsprite = Graphics.loadImage("rocket.png")

local flamebody = Graphics.loadImage("flamebody.png")

local d3 = {}
d3.x = -199000
d3.y = -200700
d3.speedX = 0
d3.speedY = 0
d3.gravity = false
d3.state = STATE_NULL
d3.direction = -1
d3.width=74
d3.height=104
d3.collider = colliders.Box(d3.x - 0.5 * d3.width, d3.y - d3.height, d3.width, d3.height)
d3.sheetX=0
d3.sheetY=0
d3.stateTimer=0 --if not using eventu
d3.hp=25
d3.hurtFrames=0
d3.hammerEmitter = particles.Emitter(0,0,Misc.resolveFile("d3electricity.ini"))
d3.sparkEmitter = particles.Emitter(0,0,Misc.resolveFile("d3electricity2.ini"))
d3.spinDustEmitter = particles.Emitter(0,0,Misc.resolveFile("d3dust2.ini"))
d3.jumpEmitter1 = particles.Emitter(0,0,Misc.resolveFile("d3jumpyjumps.ini"))
d3.jumpEmitter2 = particles.Emitter(0,0,Misc.resolveFile("d3jumpyjumps2.ini"))
d3.ribbon = particles.Emitter(0,0,Misc.resolveFile("d3ribbon.ini"))
d3.inhaleCollider = colliders.Box(0,0,1,80)
d3.inhaleSource = particles.PointField(0,0,2000,10000)
d3.inhaleEmitter = particles.Emitter(0,0,Misc.resolveFile("d3dust.ini"))
d3.inhaleWave = particles.Emitter(0,0,Misc.resolveFile("d3wave.ini"))
d3.inhaleSource:addEmitter(d3.inhaleEmitter)
d3.inhaleSource:addEmitter(d3.inhaleWave)
d3.distanceVector = vectr.v2(0,0)
d3.bouncing = 0
d3.hammerCollider = colliders.Box(0,0,80,160)
d3.spinCollider = colliders.Box(0,0,232,80)
d3.prev = 0

local function backgroundAnimation()
	deeOffsetY = deeOffsetY + (0.125 * deeOffsetYDirection)
	if deeOffsetY >= 4 then
		deeOffsetY = 2.75
		deeOffsetYDirection = -deeOffsetYDirection
	end
	if deeOffsetY <= 0 then
		deeOffsetY = 1
		deeOffsetYDirection = -deeOffsetYDirection
	end
	if player:mem(0x140, FIELD_WORD) == 10 and deeOffsetX == 1 then
		deeOffsetX = 0
	end
end

local function spawnFire(x,y,direction)
	local entry = {}
	entry.width = 36
	entry.height = 96
	entry.x = x
	entry.sprite = fireSprite
	entry.y = y
	entry.frame = 0
	entry.timer = 0
	entry.stateDirection = 0
	entry.direction = direction
	entry.framespeed = 4
	entry.hitbox = colliders.Box(entry.x + 0.5 * entry.width - 12, entry.y + entry.height, 24,70)
	entry.frameCounter = 0
	table.insert(tableOfFire, entry)
end

function calculateBlock(x,y,direction)
	--welp this didn't work for some reason whatever
	--[[local found = false
	local x = x + 18
	local y = y + 48
	local blocks = Block.getIntersecting(x + 37 * direction, y + 50, x + 45 * direction, y + 56)
	local blocksb = Block.getIntersecting(x + 37 * direction, y + 20, x + 39 * direction, y + 21)
	if #blocks > 0 and #blocksb == 0 then
		return true
	end]]
	local x = x + 18
	x = x + 20 * direction
	if x > -199936 and x < -199264 then return true end
end

local function drawBoss()
	local d3visibility = 1
	
	if iskilling then
		d3.stateTimer = d3.stateTimer + 1
		if d3.stateTimer <= 16 then
			Graphics.glDraw{vertexCoords={0,0,800,0,0,600,800,600}, color={1,1,1,1},primitive=Graphics.GL_TRIANGLE_STRIP}
		end
		if d3.stateTimer == 50 then
			iskilling = false
			eventu.signal("unpause")
		end
	end
	
	if d3.hp > 0 then
		d3.hammerEmitter:Draw(-29)
		d3.hammerEmitter.x = d3.x + 20 * d3.direction
		d3.hammerEmitter.y = d3.y - 60
		
		d3.jumpEmitter1.x = d3.x
		d3.jumpEmitter1.y = d3.y
		d3.jumpEmitter2.x = d3.x
		d3.jumpEmitter2.y = d3.y
		
		
		d3.jumpEmitter1:Draw(-29)
		d3.jumpEmitter2:Draw(-29)
		d3.sparkEmitter:Draw(-29)
		d3.spinDustEmitter:Draw(-29)
		d3.ribbon:Draw(-50)
		if d3.hurtFrames %2 == 1 then
			d3visibility = 0.5
		end
	end
	
	local l = d3.sheetX/8
	local r = (d3.sheetX + 1)/8
	local t = d3.sheetY/14
	local b = (d3.sheetY + 1)/14
	
	local tx = {l,t,r,t,l,b,r,b}
	
	if d3.direction == -1 then
		tx = {r,t,l,t,r,b,l,b}
	end
	
	Graphics.glDraw{vertexCoords={d3.x - 148, d3.y - 228, d3.x + 148, d3.y - 228, d3.x - 148, d3.y + 52, d3.x + 148, d3.y + 52},
					primitive = Graphics.GL_TRIANGLE_STRIP,
					priority=-30,
					color={1,1,1,d3visibility},
					textureCoords=tx,
					texture=dedede,
					sceneCoords=true}
					
	
	if actualHP > 0 then
		Graphics.drawImageWP(HPBAR, 620, 554, 1)
		local length = 6.56 * actualHP
		Graphics.glDraw{vertexCoords={626, 572, 626 + length, 572, 626, 590, 626 + length, 590},
						primitive = Graphics.GL_TRIANGLE_STRIP,
						priority=1.1,
						textureCoords={0,0,1,0,0,1,1,1},
						texture=hP}
	end
	if d3.state == STATE_SWALLOW and d3.stateTimer >= 16 then
		d3.inhaleEmitter:Draw(-35)
		d3.inhaleWave:Draw(-35)
	end
	for k,v in pairs(stars) do
		Graphics.drawImageToSceneWP(starSprite, v.x - 20, v.y - 20,0,48 * (math.floor(d3.stateTimer/8)%4), 48, 48, -30)
	end
	if d3.state == STATE_HAMMERJUMP and d3.stateTimer >= 1000 and d3.stateTimer <= 1012 then
		Graphics.drawImageToSceneWP(shockwave, d3.hammerCollider.x + 0.5 * d3.hammerCollider.width - 0.5 * shockwave.width, d3.y - shockwave.height, -25)
	end
	if d3.state == STATE_FASTWHIRL and d3.sheetY == 11 then
		Graphics.drawImageToSceneWP(flamebody, d3.x - 74, d3.y - 120, 0, 140 * (math.floor(d3.stateTimer/2)%2), 148, 140, -25)
	end
end

function onInputUpdate()
	if playerSwallowed and not (mem(0x00B250E2, FIELD_BOOL) or Misc.isPausedByLua()) then
		player.jumpKeyPressing = false
		player.runKeyPressing = false
		player.dropItemKeyPressing = false
		player.altJumpKeyPressing = false
		player.leftKeyPressing = false
		player.rightKeyPressing = false
		player.upKeyPressing = false
		player.downKeyPressing = false
	end
end

function onDraw()
	Graphics.drawImageWP(bg, 0,0,-99)
	Graphics.drawImageWP(dee, 432,144,deeOffsetX * 64, math.floor(deeOffsetY) * 64, 64, 64, -98)
	Graphics.drawImageWP(arena, 0,24,0,math.floor(deeOffsetY) * 554, 800,554,-97)
	if deeOffsetY > 2 then
		for k,v in pairs(NPC.get(9)) do
			Graphics.drawImageToSceneWP(grabThis, v.x + 0.5 * v.width - 0.5 * grabThis.width, v.y - 125,-45)
		end
	end
	drawBoss()
	if playerSwallowed then
		player:mem(0x114, FIELD_WORD, 49)
	else
		if player:mem(0x13E, FIELD_WORD) == 0 then
			Graphics.drawImageToSceneWP(marioshadow, player.x + 0.5 * player.width - 16, -200194, -50)
		end
	end
	if d3.sheetX ~= 10 then
		Graphics.drawImageToSceneWP(dedeshadow, d3.x - 0.5 * d3.width, -200198, -50)
	end
	for k,v in ipairs(tableOfFire) do
		Graphics.drawImageToSceneWP(v.sprite, v.x, v.y, 0, 96 * v.frame, 36, 96, -30)
	end
	for k,v in ipairs(tableOfOtherFire) do
		Graphics.drawImageToSceneWP(actualFire, v.x, v.y, 0, v.height * math.floor(v.frame), 58, 58, -30)
	end
	for k,v in ipairs(tableOfFireEmitters) do
		v:Draw(-30.5)
	end
	for k,v in pairs(tableOfRockets) do
		Graphics.drawImageToSceneWP(rocketsprite, v.x, v.y, 0, 16 + 16 * v.direction, 58, 32, -30)
		Graphics.drawImageToSceneWP(marioshadow, v.x + 0.5 * rocketsprite.width - 16, -200194, -50)
	end
end

function onTick()
	backgroundAnimation()
	playerCenter = player.x + 0.5 * player.width
	if d3.state >= STATE_JUMPIN then
		handled3()
	end
	for k,v in ipairs(tableOfFire) do
		if v.frame > 1 then
			v.hitbox.x = v.x + 0.5 * v.width - 0.5 * v.hitbox.width
			v.hitbox.y = v.y + v.height - v.hitbox.height
			if colliders.collide(player, v.hitbox) then
				player:harm()
				deeOffsetX = 1
			end
		end
		v.timer = v.timer + 1
		if v.timer == 4 then
			local that = calculateBlock(v.x, v.y, v.direction)
			if that then
				spawnFire(v.x + 16 * v.direction, v.y, v.direction)
			end
		end
		v.frameCounter = v.frameCounter + 1
		if v.frameCounter%v.framespeed == 0 then
			if v.stateDirection == 0 then
				v.frame = v.frame + 1
				if v.frame == 3 then
					v.stateDirection = v.stateDirection - 1
				end
			else
				v.frame = v.frame -1
				if v.frame == -1 then
					table.remove(tableOfFire, k)
					k = k - 1
				end
			end
		end
	end
	for k,v in ipairs(tableOfRockets) do
		v.x = v.x + v.speedX
		v.y = v.y + v.speedY
		v.collider.x = v.x
		v.collider.y = v.y
		if colliders.collide(player,v.collider) then
			player:harm()
			deeOffsetX = 1
		end
		v.timer = v.timer + 1
		if v.timer%8 == 0 then
			Animation.spawn(10, v.x + 29 - 29 * v.direction, v.y)
		end
		if colliders.collideBlock(v.collider, colliders.BLOCK_SOLID..colliders.BLOCK_SEMISOLID) then
			Misc.doBombExplosion(v.x + 29, v.y + 16, 3)
			Audio.playSFX("sfx_explode.wav")
			table.remove(tableOfRockets, k)
			k = k - 1
		end
	end
	for k,v in pairs(tableOfOtherFire) do
		v.x = v.x + v.speedX
		v.y = v.y + v.speedY
		v.emitter.x = v.x + 0.5 * v.width
		v.emitter.y = v.y + 0.5 * v.height
		v.emitter:Emit(1)
		v.collider.x = v.x + 0.5 * v.width - 0.5 * v.collider.width
		v.collider.y = v.y + 0.5 * v.height - 0.5 * v.collider.height
		if colliders.collide(player, v.collider) then
			player:harm()
			deeOffsetX = 1
		end
		v.frame = v.frame + 0.125
		if v.frame >= 4 then
			table.remove(tableOfOtherFire, k)
			k = k - 1
		end
	end
end

function onStart()
	Graphics.activateHud(false)
end

function onNPCKill(obj,npcs,rsn)
	if npcs.id == 9 or npcs.id == 250 then
		d3.state=STATE_JUMPIN
	end
end

local function checkDirection()
	local prevDir = d3.direction
	if player.x > d3.x then
		d3.direction = 1
	else
		d3.direction = -1
	end
	if d3.direction ~= prevDir then
		d3.inhaleEmitter:FlipX()
	end
end

local function hpInit()
	while actualHP < 25 do
		actualHP = actualHP + 0.25
		eventu.waitFrames(1)
	end
	fighting = true
end

local function animateD3(speed,modulo)
	if d3.stateTimer%speed == 0 then
		d3.sheetX = (d3.sheetX + 1)%modulo
	end
end

local function jumpin()
	local _, entry = eventu.run(hpInit)
	table.insert(tableOfAttacks, entry)
	eventu.waitFrames(64)
	Audio.playSFX("sfx_jump.wav")
	d3.sheetX = 2
	d3.sheetY = 3
	d3.speedX = -6
	d3.speedY = -4
	d3.gravity = true
	eventu.waitFrames(63)
	Audio.playSFX("sfx_land.wav")
	Defines.earthquake=5
	d3.gravity=false
	d3.speedX = 0
	d3.speedY = 0
	d3.state = STATE_IDLE
end

local function idle()
	d3.sheetY = 0
	d3.gravity = false
	checkDirection()
	animateD3(8,4)
	d3.stateTimer = d3.stateTimer + 1
	if d3.stateTimer >= 64 then
		hasChecked = false
		local canBecome = {}
		for k,v in pairs(availableMoves) do
			if v ~= d3.prev then
				table.insert(canBecome,v)
			end
		end
		d3.state = rng.irandomEntry(canBecome)
		d3.prev = d3.state
		d3.stateTimer = 0
	end
end

local function move()
	d3.sheetY = 1
	animateD3(8,4)
	d3.speedX = 2.5 * d3.direction
	d3.stateTimer = d3.stateTimer + 1
	if playerCenter > d3.x - 150 and playerCenter < d3.x + 150 then
		d3.state = STATE_LEAP
		d3.stateTimer = 0
	end
end

local function leap()
	d3.sheetY = 2
	d3.sheetX = 0
	d3.speedY = -3.5
	d3.speedX = 4 * d3.direction
	eventu.waitFrames(2)
	d3.gravity = true
	eventu.waitFrames(10)
	d3.sheetX = 1
	eventu.waitFrames(16)
	d3.sheetX = 2
	Audio.playSFX("sfx_slide.wav")
	while math.abs(d3.speedX) > 0.1 do
		eventu.waitFrames(1)
	end
	d3.speedX = 0
	d3.gravity= false
	d3.state = STATE_IDLE
end

local function farJump()
	d3.sheetY = 3
	d3.sheetX = 0
	d3.gravity = true
	eventu.waitFrames(20)
	isJumping = true
	Audio.playSFX("sfx_jump.wav")
	d3.sheetX = 1
	d3.speedY = -15
	d3.speedX = 3 * d3.direction
	if playerCenter > d3.x - 150 and playerCenter < d3.x + 150 then
		d3.speedX = 1.5 * d3.direction
	end
	if playerCenter < d3.x - 450 or playerCenter > d3.x + 450 then
		d3.speedX = 4.5 * d3.direction
	end
	eventu.waitFrames(16)
	d3.sheetX = 2
	while d3.y < -200192 do
		eventu.waitFrames(1)
	end
	Audio.playSFX("sfx_land.wav")
	isJumping = false
	Defines.earthquake=5
	d3.speedX = 0
	local repeatJump = rng.randomInt(1)
	if repeatJump == 1 then
		checkDirection()
		local _, entry = eventu.run(farJump)
		table.insert(tableOfAttacks, entry)
	else
		d3.sheetX = 0
		eventu.waitFrames(20)
		d3.state = STATE_IDLE
	end
end

local function absorb()
	d3.sheetY = 4
	d3.sheetX = 0
	d3.stateTimer = d3.stateTimer + 1
	
	d3.inhaleCollider.x = d3.x + d3.direction * (d3.width - 10)
	d3.inhaleCollider.y = d3.y - 80
	
	d3.inhaleSource.x = d3.inhaleCollider.x + 20
	d3.inhaleSource.y = d3.inhaleCollider.y + 45
	d3.inhaleEmitter.x = d3.inhaleCollider.x + 800 * d3.direction
	d3.inhaleEmitter.y = d3.inhaleCollider.y - 400
	d3.inhaleWave.x = d3.inhaleEmitter.x
	d3.inhaleWave.y = d3.inhaleCollider.y + 45
	
	if d3.stateTimer >= 32 then
		if d3.stateTimer == 32 then
			Audio.SfxPlayCh(22, Audio.SfxOpen(Misc.resolveFile("sfx_inhale.wav")), 0)
		end
		d3.sheetX = 1
		if d3.stateTimer >=40 then
			d3.sheetX = 2
		end
		local dir = d3.distanceVector:normalise();
		local a = math.acos((d3.direction * vectr.right2)..dir)
		if a < 0.5 then
			if player.speedX == 0 then player.speedX = -0.1 * d3.direction end
			local div = 1 + (d3.stateTimer - 32)
			player.speedX = player.speedX - d3.direction * (1/(d3.distanceVector.length/div))
		end
		if colliders.collide(player, d3.inhaleCollider) then
			d3.state = STATE_SPIT
			Audio.SfxStop(22)
			d3.inhaleEmitter:KillParticles()
			d3.inhaleWave:KillParticles()
			Audio.playSFX("sfx_bounce.wav")
			playerSwallowed = true
			d3.stateTimer = 0
		end
	end
	if d3.stateTimer >= 366 then
		d3.inhaleEmitter:KillParticles()
		d3.inhaleWave:KillParticles()
		d3.state = STATE_IDLE
		d3.stateTimer = 0
	end
end

local function spit()
	d3.sheetY = 4
	d3.sheetX = 3
	d3.stateTimer = d3.stateTimer + 1
	if d3.stateTimer >= 100 then
		if d3.stateTimer == 100 then
			Audio.playSFX("sfx_exhale.wav")
			local star = {}
			star.x = d3.x
			star.y = d3.y - 40
			star.speedX = 15 * -d3.direction
			star.collider = colliders.Box(star.x-20, star.y-20,40,40)
			table.insert(stars, star)
		end
		d3.sheetX = 4
	end
end

local function balloon()
	d3.sheetY = 5
	d3.sheetX = 0
	if d3.stateTimer == 0 then
		Audio.playSFX("sfx_jump.wav")
	end
	if d3.stateTimer <= 400 then
		checkDirection()
	end
	d3.stateTimer = d3.stateTimer + 1
	if d3.stateTimer < 28 then
		d3.speedY = -3
	else
		d3.sheetX = 1
		if d3.bouncing > 0 then
			d3.sheetX = 2
			d3.bouncing = d3.bouncing -1
		end
		if d3.distanceVector.x == 0 then d3.distanceVector.x = 0.001 end
		if d3.distanceVector.y == 0 then d3.distanceVector.y = 0.001 end
		d3.speedX = d3.speedX + d3.distanceVector.x/math.abs(d3.distanceVector.x)/20
		d3.speedY = d3.speedY + d3.distanceVector.y/math.abs(d3.distanceVector.y)/20
		if d3.speedX > 5 then d3.speedX = 5 end
		if d3.speedX < -5 then d3.speedX = -5 end
		if d3.speedY > 5 then d3.speedY = 5 end
		if d3.speedY < -5 then d3.speedY = -5 end
		if colliders.collideBlock(d3.collider, {446, 598}) then
			d3.speedY = -d3.speedY
			d3.y = d3.y + 2* d3.speedY
			Audio.playSFX("sfx_bounce.wav")
			d3.bouncing = 8
		end
		if colliders.collideBlock(d3.collider, {109, 587}) then
			d3.speedX = -d3.speedX
			d3.x = d3.x + 2* d3.speedX
			Audio.playSFX("sfx_bounce.wav")
			d3.bouncing = 8
		end
		if d3.stateTimer > 400 then
			if d3.stateTimer == 401 then
				Audio.playSFX("sfx_star.wav")
				d3.speedY = -6
			end
			d3.sheetY = 4
			d3.sheetX = 2
			d3.speedX = 0
			d3.gravity = true
			if d3.y >= -200192 then
				d3.state = STATE_IDLE
				d3.stateTimer = 0
				d3.speedX = 0
				d3.speedY = 0
				d3.bouncing = 0
			end
		end
	end
end

local function hammerrun()
	if not hasChecked then
		d3.sheetY = 6
		animateD3(8,4)
		d3.speedX = 2.3 * d3.direction
		d3.stateTimer = d3.stateTimer + 1
		if playerCenter > d3.x - 80 and playerCenter < d3.x + 80 then
			d3.speedX = 0
			if player.y < d3.y - 84 then
				d3.state = STATE_HAMMERJUMP
			end
			d3.stateTimer = 0
			hasChecked = true
		end
	else
		d3.stateTimer = d3.stateTimer + 1
		if d3.stateTimer >= 48 then
			if d3.stateTimer == 48 then
				d3.sheetX = 5
				Audio.playSFX("sfx_hammer.wav")
			end
			if d3.stateTimer == 56 then
				d3.sheetX = 6
			end
			d3.sheetY=7
			if d3.stateTimer <= 80 then
				d3.hammerCollider.x = d3.x - 0.5 * d3.hammerCollider.width + d3.direction * 90
				d3.hammerCollider.y = d3.y - 100
				if colliders.collide(d3.hammerCollider, player) then
					player:harm()
					deeOffsetX = 1
				end
			end
			if d3.stateTimer > 120 then
				d3.state = STATE_IDLE
				d3.stateTimer = 0
			end
		elseif d3.stateTimer >= 8 then
			d3.sheetY=7
			d3.sheetX=1
			if d3.stateTimer >= 40 then
				d3.sheetX = 4
			end
		end
	end
end

local function hammerjump()
	d3.sheetY = 7
	if d3.stateTimer == 0 then
		d3.sheetX = 0
	end
	d3.gravity = true
	d3.stateTimer = d3.stateTimer + 1
	
	if d3.stateTimer >= 1000 then
		if d3.stateTimer <= 1008 and d3.stateTimer%4 == 0 then
			spawnFire(d3.hammerCollider.x - 10, d3.y - 96, d3.direction)
		end
		if d3.stateTimer >= 1090 then
			d3.sheetX = 0
			d3.state = STATE_IDLE
			d3.stateTimer = 0
		end
	elseif d3.stateTimer >= 100 then
		if d3.stateTimer == 108 then
			d3.sheetX = 5
		end
		if d3.stateTimer == 116 then
			d3.sheetX = 6
		end
		d3.hammerCollider.x = d3.x - 0.5 * d3.hammerCollider.width + d3.direction * 90
		d3.hammerCollider.y = d3.y - 100
		if colliders.collide(d3.hammerCollider, player) then
			player:harm()
			deeOffsetX = 1
		end
		if d3.y >= -200192 and isJumping then
			Audio.playSFX("sfx_land.wav")
			Defines.earthquake=5
			isJumping = false
			d3.stateTimer = 1000
		end
	elseif d3.stateTimer >= 20 then
		if d3.stateTimer == 20 then
			isJumping = true
			Audio.playSFX("sfx_jump.wav")
			d3.speedY = -15
		end
		animateD3(8,2)
		if d3.sheetX < 2 then
			d3.sheetX = d3.sheetX + 2
		end
		if d3.speedY > 0 then
			d3.stateTimer = 100
			d3.sheetX = 4
			Audio.playSFX("sfx_swing.wav")
		end
	end
end

local function spawnHammerFire()
	local fire = {}
	fire.x = d3.x - 16 + 112 * d3.direction
	fire.y = d3.y - 100
	fire.speedX = 5 * d3.direction
	fire.speedY = rng.randomInt(-5,5)
	fire.width=58
	fire.height=58
	fire.emitter = particles.Emitter(0,0,Misc.resolveFile("d3fire.ini"))
	fire.collider = colliders.Box(0,0,22,22)
	fire.timer = 0
	fire.frame = 0
	table.insert(tableOfOtherFire, fire)
	table.insert(tableOfFireEmitters, fire.emitter)
end

local function animForHammerFire()
	if d3.stateTimer == 0 then
		d3.sheetX = 0
		d3.sheetY = 8
	end
	if d3.stateTimer >= 52 and d3.stateTimer <= 72 and d3.stateTimer%8==0 then
		d3.sheetX = d3.sheetX + 1
	end
	d3.stateTimer = d3.stateTimer + 1
end

local function hammerfire()
	animForHammerFire()
	if d3.stateTimer >= 80 and d3.stateTimer <= 260 then
		if d3.stateTimer%8 == 0 then
			spawnHammerFire()
			Audio.playSFX("sfx_fire.wav")
		end
	end
	if d3.stateTimer == 320 then
		d3.stateTimer = 0
		d3.state = STATE_IDLE
	end
end

local function spawnRocket()
	local rocket = {}
	rocket.x = d3.x - 29 + 122 * d3.direction
	rocket.y = d3.y - 90
	rocket.direction = d3.direction
	rocket.speedX = 6 * d3.direction
	local entry = rng.irandomEntry(availableDirections)
	for k,v in pairs(availableDirections) do
		if entry == v then table.remove(availableDirections, k); break; end
	end
	rocket.speedY = entry
	rocket.collider = colliders.Box(0,0,58,32)
	rocket.timer = 0
	table.insert(tableOfRockets, rocket)
end

local function hammerrocket()
	animForHammerFire()
	if d3.stateTimer == 30 then
		availableDirections = {-1,0,1}
	end
	if d3.stateTimer >= 85 and d3.stateTimer <= 215 then
		if d3.stateTimer%65 == 20 then
			spawnRocket()
			for i=-1,1 do
				local puff = Animation.spawn(10, d3.x - 29 + 100 * d3.direction, d3.y-90)
				if i == 0 then
					puff.speedX = d3.direction * 2
				end
				puff.speedY = 2 * i
			end
			Audio.playSFX("sfx_rocket.wav")
		end
	end
	if d3.stateTimer == 260 then
		d3.stateTimer = 0
		d3.state = STATE_IDLE
	end
end

local function prepareWhirl()
	d3.sheetY = 9
	d3.sheetX = 0
	eventu.waitFrames(8)
	d3.sheetX = 1
	eventu.waitFrames(80)
	d3.state = STATE_SLOWWHIRL
end

local function whirlRoutine(n)
	checkDirection()
	if d3.distanceVector.x == 0 then d3.distanceVector.x = 0.001 end
	d3.speedX = d3.speedX + (d3.distanceVector.x/math.abs(d3.distanceVector.x))/(100/n)
	if (d3.speedX > n and d3.direction == 1) or (d3.speedX < -n and d3.direction == -1) then
		d3.speedX = n * d3.direction
	end
	if colliders.collideBlock(d3.collider, {109, 587}) then
		d3.speedX = -d3.speedX
		d3.x = d3.x + d3.speedX
	end
	d3.spinCollider.x = d3.x - 0.5 * d3.spinCollider.width + d3.speedX
	d3.spinCollider.y = d3.y - d3.spinCollider.height
	if colliders.collide(d3.spinCollider, player) and not (d3.state == STATE_FASTWHIRL and d3.stateTimer > 250) then
		player:harm()
		deeOffsetX = 1
	end
	d3.stateTimer = d3.stateTimer + 1
end

local function slowWhirl()
	d3.sheetY = 10
	whirlRoutine(2)
	animateD3(4,8)
	if d3.stateTimer == 1 then
		Audio.playSFX("sfx_spin2.wav")
	end
	if d3.stateTimer > 120 then
		d3.state = STATE_FASTWHIRL
		d3.stateTimer = 0
	end
end

local function fastWhirl()
	whirlRoutine(4)
	if d3.stateTimer < 250 then
		d3.sheetY = 11
		animateD3(1,8)
		d3.sparkEmitter.x = d3.x
		d3.sparkEmitter.y = d3.y
		d3.spinDustEmitter.x = d3.x
		d3.spinDustEmitter.y = d3.y
		d3.ribbon.x = d3.x
		d3.ribbon.y = d3.y
		if rng.randomInt(0,2) == 2 then
			d3.sparkEmitter:Emit(1)
		end
		d3.spinDustEmitter:Emit(1)
		d3.ribbon:Emit(1)
	else
		d3.sheetY = 10
		animateD3(6,8)
		if d3.stateTimer >= 282 then
			d3.state = STATE_DIZZY
			d3.speedX = 0
			d3.stateTimer = 0
			d3.direction = rng.randomInt(1)
			if d3.direction == 0 then d3.direction = -1 end
		end
	end
end

local function dizzy()
	d3.sheetY = 12
	d3.stateTimer = d3.stateTimer + 1
	if d3.stateTimer <= 128 then
		animateD3(8,4)
	else
		if d3.stateTimer%8==0 then
			if d3.sheetX == 5 then d3.sheetX = 6 else d3.sheetX = 5 end
		end
		if d3.stateTimer >=176 then
			d3.stateTimer = 0
			d3.state = STATE_IDLE
		end
	end
end

local function death()
	d3.sheetY = 13
	d3.sheetX = 0
	Audio.clearSFXBuffer()
	Audio.playSFX("sfx_death2.wav")
	iskilling = true
	Misc.pause()
	eventu.waitSignal("unpause")
	Misc.unpause()
	d3.sheetX = 1
	d3.speedX = -2 * d3.direction
	d3.speedY = -2
	d3.stateTimer = 0
	eventu.waitFrames(65)
	iskilling = true
	Audio.playSFX("sfx_dead.wav")
	eventu.waitFrames(10)
	d3.sheetX = 10
	triggerEvent("star")
	Audio.MusicOpen("endingtune.ogg")
	Audio.MusicPlay()
end

function handled3()
	if d3.state == STATE_JUMPIN then
		d3.state = STATE_WAIT
		local _, entry = eventu.run(jumpin)
		table.insert(tableOfAttacks, entry)
	elseif d3.state == STATE_IDLE then
		idle()
	elseif d3.state == STATE_WALK then
		move()
	elseif d3.state == STATE_LEAP then
		d3.state = STATE_WAITWITHCOLLISION
		local _, entry = eventu.run(leap)
		table.insert(tableOfAttacks, entry)
	elseif d3.state == STATE_FARJUMP then
		d3.state = STATE_WAITWITHCOLLISION
		local _, entry = eventu.run(farJump)
		table.insert(tableOfAttacks, entry)
	elseif d3.state == STATE_SWALLOW then
		absorb()
	elseif d3.state == STATE_SPIT then
		spit()
	elseif d3.state == STATE_BALLOON then
		balloon()
	elseif d3.state == STATE_HAMMERRUN then
		hammerrun()
	elseif d3.state == STATE_HAMMERJUMP then
		hammerjump()
	elseif d3.state == STATE_HAMMERFIRE then
		hammerfire()
	elseif d3.state == STATE_HAMMERROCKET then
		hammerrocket()
	elseif d3.state == STATE_PREPAREWHIRL then
		local _, entry = eventu.run(prepareWhirl)
		table.insert(tableOfAttacks, entry)
		d3.state = STATE_WAITWITHCOLLISION
	elseif d3.state == STATE_SLOWWHIRL then
		slowWhirl()
	elseif d3.state == STATE_FASTWHIRL then
		fastWhirl()
	elseif d3.state == STATE_DIZZY then
		dizzy()
	elseif d3.state == STATE_DEAD then
		eventu.run(death)
		d3.state = STATE_WAIT
	end
	
	if d3.gravity then
		d3.speedY = d3.speedY + 0.4
		if d3.y == -200192 then
			d3.speedX = d3.speedX * 0.94
		end
	end
	
	local storedX
	if colliders.collideBlock(d3.collider, {537, 109}) and d3.state ~= STATE_WAIT then
		if d3.x < -199600 then
			storedX = d3.x + 1
		else
			storedX = d3.x - 1
		end
	end
	
	if isJumping then
		if rng.randomInt(1) == 1 then
			d3.jumpEmitter1:Emit(1)
		else
			d3.jumpEmitter2:Emit(1)
		end
	end
	
	d3.x = d3.x + d3.speedX
	d3.y = d3.y + d3.speedY
	
	if not (d3.state == STATE_BALLOON and d3.stateTimer <= 400) then
		if storedX ~= nil then d3.x = storedX end
		
		if d3.y > -200192 then d3.y = -200192 end
	end
	
	d3.collider.x = d3.x - 0.5 * d3.width
	d3.collider.y = d3.y - d3.height
	
	if d3.hurtFrames > 0 then
		d3.hurtFrames = d3.hurtFrames - 1
	end
	
	if playerSwallowed then
		player:mem(0x140, FIELD_WORD, 3)
	end
	if d3.hp > 0 then
		if colliders.bounce(player, d3.collider) and player:mem(0x122, FIELD_WORD) == 0 and player:mem(0x13E, FIELD_WORD) == 0 and not playerSwallowed then
			if d3.hurtFrames == 0 then
				d3.hp = d3.hp - rng.random(1,1.4)
				d3.hurtFrames = 50
				Audio.playSFX("sfx_hurt.wav")
			end
			colliders.bounceResponse(player)
			if d3.hp <= 0 then
				actualHP = 0
				triggerEvent("nomusic")
				fighting=false
				for i=#tableOfFire, 1, -1 do
					table.remove(tableOfFire, i)
				end
				for i=#tableOfOtherFire, 1, -1 do
					table.remove(tableOfOtherFire, i)
				end
				for i=#tableOfRockets, 1, -1 do
					table.remove(tableOfRockets, i)
				end
				for i=#tableOfAttacks, 1, -1 do
					eventu.abort(tableOfAttacks[i])
				end
				d3.state = STATE_DEAD
				d3.gravity = false
				d3.stateTimer = 0
				d3.speedX = 0
				d3.speedY = 0
				d3.hammerEmitter:Destroy()
				d3.sparkEmitter:Destroy()
				d3.spinDustEmitter:Destroy()
				d3.jumpEmitter1:Destroy()
				d3.jumpEmitter2:Destroy()
				d3.ribbon:Destroy()
				d3.inhaleEmitter:Destroy()
				d3.inhaleWave:Destroy()
			end
		elseif colliders.collide(player, d3.collider) then
			player:harm()
			deeOffsetX = 1
		end
	end
	
	if fighting then
		actualHP = d3.hp
	end
	
	
	for k,v in pairs(stars) do
		v.x = v.x - v.speedX
		v.collider.x = v.x - 20
		v.collider.y = v.y - 20
		player.x = v.x - 0.5 * player.width
		player.y = v.y - 0.5 * player.height
		if colliders.collideBlock(v.collider, colliders.BLOCK_SOLID) then
			player:mem(0x140, FIELD_WORD, 0)
			playerSwallowed = false
			if player.x < d3.x then player.x = player.x + 16 else player.x = player.x - 16 end
			player:harm()
			deeOffsetX = 1
			for i=1, 4 do
				local n = Animation.spawn(1, v.x - 8, v.y - 8)
				n.speedX = rng.random(-5, 5)
				n.speedY = rng.random(-3, -7)
			end
			table.remove(stars, k)
			Audio.playSFX("sfx_star.wav")
			d3.state = STATE_IDLE
			d3.stateTimer = 0
		end
	end
	d3.distanceVector.x = player.x + 0.5 * player.width - d3.x 
	d3.distanceVector.y = player.y + 0.5 * player.height - d3.y
end