local npcParse = API.load("npcParse")
local npcConfig = API.load("npcconfig")
local vectr = API.load("vectr")
local colliders = API.load("colliders")
local eventu = API.load("eventu")
local pnpc = API.load("pnpc")

local customLotus = {}

--***************************************************************************************************
--                                                                                                  *
--              DEFAULTS AND NPC CONFIGURATION                                                      *
--                                                                                                  *
--***************************************************************************************************

local Lotus = {}

local Pollen = {}

local defaults = {
	normal=false, invisible=false, friendly=false,
	state=0, timer=0, lo1=170, lo2=70, lo3=50,
	range="1-7", sprite=1, spriteD=0, spriteLD=0, frameN=4, frameS=5,
	waves=1, dieIn=-2, bullets=4, rate=3, speed=2, focus=45, spin=0, lineN=1, lineW=10, spawnx=0, spawny=-6, velX=0, velY=0, velMX=1, velMY=1,
	spinD=0, bulletsD=0, rateD=0, speedD=0, focusD=0, spawnxD=0, spawnyD=0, lineND=0, lineWD=0, delayD=0, velXD=0, velYD=0, velMXD=0, velMYD=0,
	spinDD=0, bulletsDD=0, rateDD=0, speedDD=0, focusDD=0, spawnxDD=0, spawnyDD=0, lineNDD=0, lineWDD=0, delayDD=0,
	bulletsA=0, bulletsB=0.5, bulletsC=0,
	spinA=0, spinB=0.5, spinC=0,
	focusA=0, focusB=0.5, focusC=0,
	rateA=0, rateB=0.5, rateC=0,
	speedA=0, speedB=0.5, speedC=0,
	spawnxA=0, spawnxB=0.5, spawnxC=0,
	spawnyA=0, spawnyB=0.5, spawnyC=0,
	bulletsAD=0, bulletsBD=0, bulletsCD=0,
	spinAD=0, spinBD=0, spinCD=0,
	focusAD=0, focusBD=0, focusCD=0,
	rateAD=0, rateBD=0, rateCD=0,
	speedAD=0, speedBD=0, speedCD=0,
	spawnxAD=0, spawnxBD=0, spawnxCD=0,
	spawnyAD=0, spawnyBD=0, spawnyCD=0,
	bulletsADD=0, bulletsBDD=0, bulletsCDD=0,
	spinADD=0, spinBDD=0, spinCDD=0,
	focusADD=0, focusBDD=0, focusCDD=0,
	rateADD=0, rateBDD=0.5, rateCDD=0,
	speedADD=0, speedBDD=0, speedCDD=0,
	spawnxADD=0, spawnxBDD=0, spawnxCDD=0,
	spawnyADD=0, spawnyBDD=0, spawnyCDD=0,
	delay=40, delayD=0, delayDD=0, aim=0, 
	turn=nil, tilldeath=nil, clear=0.1, dEffect=0, flip=false
}

--***************************************************************************************************
--                                                                                                  *
--              PRIVATE MEMBERS                                                                     *
--                                                                                                  *
--***************************************************************************************************

local lotussprite = Graphics.loadImage(Misc.resolveFile("customLotus.png"))

--Make box around camera.
local cam = Camera.get()[1]
local buffer=128
local cameraCollider = colliders.Box(cam.x-buffer,cam.y-buffer,cam.width+buffer*2,cam.height+buffer*2);

--***************************************************************************************************
--                                                                                                  *
--              LOCAL FUNCTIONS                                                                     *
--                                                                                                  *
--***************************************************************************************************

--Localized Functinons.
local sine = math.sin

--SPAWN FIRE FUNCTION

--(x,y,bullets,spread,delay,speed,direction,playerx,playery,Aiming,Sprite,rangelow,rangehigh,frameNum,frameSpd,VelosityX,VelosityY,Multiplier,Multiplier,minSpeed,TurnINTO,tilldeath,deffect,friendly,flip)
local function spawnFire(lx,ly,lbullets,lfocus,delay,lspeed,ldirection,lplayerx,lplayery,lAiming,sprite,lHigh,lLow,frameN,frameS,lVelX,lVelY,lVelMX,lVelMY,clear,turn,tilldeath,dEffect,lFriendly,lFlip)
	
	for j=(-lbullets+1)/2, (lbullets-1)/2 do
	
	local fire = NPC.spawn(260, lx, ly, player.section, false, true)
	local firePNPC = pnpc.wrap(fire)
	
		--Set friendly
		if lFriendly~=0 then
			fire.friendly = lFriendly
		end
		
		--Aim style
		if (lAiming==0 or lAiming==nil) then
			--No Aiming
			firePNPC.data.vector = vectr.v2(lspeed,0);
			firePNPC.data.vector=firePNPC.data.vector:rotate(ldirection+j*lfocus);
		elseif (lAiming==1) then
			--Aim previous
			firePNPC.data.vector = vectr.v2(lplayerx+player.width/2 - lx, lplayery+player.height/2 - ly):normalise() * lspeed
			firePNPC.data.vector=firePNPC.data.vector:rotate(ldirection+j*lfocus+90);
		elseif (lAiming==2) then
			--Aim current
			firePNPC.data.vector = vectr.v2(player.x+player.width/2 - lx, player.y+player.height/2 - ly):normalise() * lspeed
			firePNPC.data.vector=firePNPC.data.vector:rotate(ldirection+j*lfocus+90);
		end
	
		--Set starting speed.
			fire.speedX = firePNPC.data.vector.x;
			fire.speedY = firePNPC.data.vector.y;
		
		--SETTING VALUES FOR LATER.

		--Firebar Momentum
		fire.ai2 = 4
		--Firebar State
		firePNPC.data.firestate = 1
		
		--Sprite limits. Prevent sprite rotation from going over range.
		while (sprite > lHigh) do
			sprite = sprite-lHigh+lLow-1
		end	
		while (sprite < lLow) do
			sprite = sprite+lHigh-lLow+1
		end
		
		--Prevent errors from bad numbers.
		if (sprite < 1) or (lLow > lHigh) then
			sprite = 1
		end
		
		if lFlip == true then
			firePNPC.data.flip=-1
		else
			firePNPC.data.flip=1
		end
		
		--Delay Before Moving
		firePNPC.data.delay = delay
		--Set sprite for the fire.
		firePNPC.data.sprite = sprite
		--Set FrameNumber for the fire.
		firePNPC.data.frameN = frameN
		--Set FrameSPeed for the fire.
		firePNPC.data.frameS = frameS
		--Is bullet cleared when speed less than 0.1?
		firePNPC.data.clear = clear
		--Turn into NPC upon death.
		firePNPC.data.turn = turn
		--Time before death.
		firePNPC.data.tilldeath = tilldeath
		--Death effect
		firePNPC.data.dEffect = dEffect
		
		--Set XVEL for the fire.
		if firePNPC.data.velX~=0 then
			if (fire.speedX>0.0001) then
				firePNPC.data.velX = lVelX
			end
			if (fire.speedX<-0.0001) then
				firePNPC.data.velX = -lVelX
			end
		end
		
		--Set YVEL for the fire.
		if firePNPC.data.velY~=0 then
			if (fire.speedY>0.0001) then
				firePNPC.data.velY = lVelY
			end
			if (fire.speedY<-0.0001) then
				firePNPC.data.velY = -lVelY
			end
		end
		
		--Set VEL MULTIPLIERS
		if (lVelMX~=1) then
			firePNPC.data.velMX = lVelMX
		end
		if (lVelMY~=1) then
			firePNPC.data.velMY = lVelMY
		end
	end
end

--Get Effect Size

local function getEffectSize(id)
    local effectdef_width_ptr = mem(0xB2BA68, FIELD_DWORD)
    local effectdef_height_ptr = mem(0xB2BA84, FIELD_DWORD)
    local width = mem(effectdef_width_ptr + (id-1)*2, FIELD_WORD)
    local height = mem(effectdef_height_ptr + (id-1)*2, FIELD_WORD)
    return width, height
end

----------------------------------------------------------------------------

--onTick

function Lotus.onTick()
	
	--Tables
	local tableOfBars = NPC.get(260, -1)
	local tableOfLotus = NPC.get(275, -1)
	cameraCollider = colliders.Box(cam.x-buffer,cam.y-buffer,cam.width+buffer*2,cam.height+buffer*2);
	
-- LAVALOTUS

	for _,i in ipairs(tableOfLotus) do
	
		--Save message contents
		local lotusPNPC = pnpc.wrap(i)
		
		if lotusPNPC.data.customLotus == nil then
			lotusPNPC.data.customLotus = {normal = true}
		end
		
		for k,v in pairs(defaults) do
			if (lotusPNPC.data.customLotus[k] == nil) then lotusPNPC.data.customLotus[k] = v end 
		end
		
		--Prevent normal timer
		i.ai2=2
		
		--Anything that is set only once. (Timer/Sprite/range)
		if lotusPNPC.data.firstloop == nil then
			i.ai1 = lotusPNPC.data.customLotus.state
			lotusPNPC.data.lTimer2 = lotusPNPC.data.customLotus.timer
			lotusPNPC.data.lotusdie = lotusPNPC.data.customLotus.dieIn
			lotusPNPC.data.customLotus.spriteRH = tonumber(string.match(lotusPNPC.data.customLotus.range, '%d+%-(%d+)'))
			lotusPNPC.data.customLotus.spriteRL = tonumber(string.match(lotusPNPC.data.customLotus.range, '(%d+)%-%d+'))
			lotusPNPC.data.firstloop = false
			lotusPNPC.data.revert = 0
			lotusPNPC.data.direction = 270
		end
		
		--Reversed
		if (i.direction == 1) then
			i.speedY = -3
			lotusPNPC.data.direction=90
			lotusPNPC.data.revert = npcConfig[275].height
		end
		
		if (colliders.collide(i, cameraCollider)) then
			
			--Set new one.
			lotusPNPC.data.lTimer2=lotusPNPC.data.lTimer2+1
			
			--Shorten firerate. i.ai1 is lotus state
			if (lotusPNPC.data.lTimer2>lotusPNPC.data.customLotus.lo1) and (i.ai1==0) then
				i.ai1=1
				lotusPNPC.data.lTimer2=1
			end
			if (lotusPNPC.data.lTimer2>lotusPNPC.data.customLotus.lo2) and (i.ai1==1) then
				if lotusPNPC.data.customLotus.normal then
					i.ai2=0
				end
				i.ai1=2
				lotusPNPC.data.lTimer2=1
			end
			if (lotusPNPC.data.lTimer2>lotusPNPC.data.customLotus.lo3) and (i.ai1==2) then
				i.ai1=0
				lotusPNPC.data.lTimer2=1
			end
			
			--Kill when amount of repeats is over.
			if (lotusPNPC.data.lotusdie==0) and (i.ai1==0) then
				i:kill(9)
			end
			if (lotusPNPC.data.lTimer2==lotusPNPC.data.customLotus.lo2) and (i.ai1==1) then
				if (lotusPNPC.data.lotusdie>0) or (lotusPNPC.data.lotusdie<=-2) then
					if (colliders.collide(i, cameraCollider)) then
						lotusPNPC.data.lotusdie=lotusPNPC.data.lotusdie-1
					end
				end
			end
			
			--Check timer and prevent normal shot.
			
			--Normal to not do anything
			if not lotusPNPC.data.customLotus.normal then
				
				if (lotusPNPC.data.lTimer2==lotusPNPC.data.customLotus.lo2) and (i.ai1==1) then
					
					
					
					--SPAWN FIRE
					
					--Waves
						
					--TRIGGER THE FUNCTION NUMBER OF TIMES.
					
					for m=0,(lotusPNPC.data.customLotus.waves-1) do
						
						--More constants.
		
						local DDD = {"lineN", "lineW", "delay"}
						for _,v in ipairs(DDD) do
							lotusPNPC.data[v] = lotusPNPC.data.customLotus[v]
							lotusPNPC.data[v.."D"] = lotusPNPC.data.customLotus[v.."D"]+lotusPNPC.data.customLotus[v.."DD"]*m
						end
		
						local ABCD = {"rate", "focus", "speed", "spin", "spawnx", "spawny", "bullets"}
						for _,v in ipairs(ABCD) do
							lotusPNPC.data[v.."A"] = lotusPNPC.data.customLotus[v.."A"]+(lotusPNPC.data.customLotus[v.."AD"]+lotusPNPC.data.customLotus[v.."ADD"]*m)*m
							lotusPNPC.data[v.."B"] = lotusPNPC.data.customLotus[v.."B"]+(lotusPNPC.data.customLotus[v.."BD"]+lotusPNPC.data.customLotus[v.."BDD"]*m)*m
							lotusPNPC.data[v.."C"] = lotusPNPC.data.customLotus[v.."C"]+(lotusPNPC.data.customLotus[v.."CD"]+lotusPNPC.data.customLotus[v.."CDD"]*m)*m
							lotusPNPC.data[v] = sine(m*lotusPNPC.data[v.."B"]+lotusPNPC.data[v.."C"])*lotusPNPC.data[v.."A"]+lotusPNPC.data.customLotus[v]
							lotusPNPC.data[v.."D"] = lotusPNPC.data.customLotus[v.."D"]+lotusPNPC.data.customLotus[v.."DD"]*m
						end
						
						--Reverse offsety
						if (i.direction == 1) then
							lotusPNPC.data["spawny"]=-lotusPNPC.data["spawny"]
						end
						
						--CALL THE FUNCTION
						
						for w=1,m*lotusPNPC.data["lineND"]+lotusPNPC.data["lineN"] do
							eventu.setTimer(m/(m*lotusPNPC.data["rateD"]+lotusPNPC.data["rate"]),
						
						--(x,y,bullets,spread,delay,speed,direction,playerx,playery,Aiming,Sprite,rangelow,rangehigh,frameNum,frameSpd,VelosityX,VelosityY,Multiplier,Multiplier,MinSpeed,TurnINTO,Timetilldeath,dEffect,flip)
						
							function() spawnFire(
								i.x+0.5*npcConfig[275].gfxwidth+m*lotusPNPC.data["spawnxD"]+lotusPNPC.data["spawnx"],
								i.y + lotusPNPC.data.revert + m*lotusPNPC.data["spawnyD"]+lotusPNPC.data["spawny"], 
								m*lotusPNPC.data["bulletsD"]+lotusPNPC.data["bullets"]+0.5-(m*lotusPNPC.data["bulletsD"]+lotusPNPC.data["bullets"]+0.5) % 1,
								m*lotusPNPC.data["focusD"]+lotusPNPC.data["focus"],
								m*lotusPNPC.data["delayD"]+lotusPNPC.data["delay"],
								m*lotusPNPC.data["speedD"]+lotusPNPC.data["speed"],
								lotusPNPC.data.direction+(m*lotusPNPC.data["spinD"]+lotusPNPC.data["spin"])*0.5+(w-1)*(m*lotusPNPC.data["lineWD"]+lotusPNPC.data["lineW"])-((m*lotusPNPC.data["lineWD"]+lotusPNPC.data["lineW"])*(m*lotusPNPC.data["lineND"]+lotusPNPC.data["lineN"])-(m*lotusPNPC.data["lineWD"]+lotusPNPC.data["lineW"]))/2,
								player.x,
								player.y,
								lotusPNPC.data.customLotus.aim,
								lotusPNPC.data.customLotus.sprite+lotusPNPC.data.customLotus.spriteD*m+lotusPNPC.data.customLotus.spriteLD*w,
								lotusPNPC.data.customLotus.spriteRH,
								lotusPNPC.data.customLotus.spriteRL,
								lotusPNPC.data.customLotus.frameN,
								lotusPNPC.data.customLotus.frameS,
								lotusPNPC.data.customLotus.velX+lotusPNPC.data.customLotus.velXD*m,
								lotusPNPC.data.customLotus.velY+lotusPNPC.data.customLotus.velYD*m,
								lotusPNPC.data.customLotus.velMX+lotusPNPC.data.customLotus.velMXD*m,
								lotusPNPC.data.customLotus.velMY+lotusPNPC.data.customLotus.velMYD*m,
								lotusPNPC.data.customLotus.clear,
								lotusPNPC.data.customLotus.turn,
								lotusPNPC.data.customLotus.tilldeath,
								lotusPNPC.data.customLotus.dEffect,
								lotusPNPC.data.customLotus.friendly,
								lotusPNPC.data.customLotus.flip);
							end);
						end
					end
				end
			end
		end
	--empty message to prevent the explanation mark from being drawn.
		if string.find(i.msg.str, "{id") then
			i.msg.str = ""
		end
	end
end

function Pollen.onTick()
	
	--
	
	--Set table
	local tableOfBars = NPC.get(260, -1)
	for k,v in ipairs(tableOfBars) do
		
		--Wrappers
		local firePNPC = pnpc.wrap(v)
		
		--Make invisible
		if (firePNPC.data.firestate ~= 0) then
			if(firePNPC.data.firestate ~= 3) then
				-- Memorise speed / set timer / change state
				if (firePNPC.data.firestate == 1) then
					firePNPC.data.firestate = 2
					firePNPC.data.lotusSpeedX = v.speedX*firePNPC.data.flip
					firePNPC.data.lotusSpeedY = v.speedY
				end
				
				-- Stay stationary for duration of timer (firePNPC.data.delay)
				if (firePNPC.data.delay > 0) then
					firePNPC.data.delay = firePNPC.data.delay-1
					v.speedX = 0
					v.speedY = 0
					else
					v.speedX = firePNPC.data.lotusSpeedX
					v.speedY = firePNPC.data.lotusSpeedY
					firePNPC.data.firestate = 3
				end
			else
			
				--Set Velocity
				if firePNPC.data.lVelMX ~= nil then
					v.speedX = v.speedX*firePNPC.data.velMX
				end
				if firePNPC.data.velMY ~= nil then
					v.speedY = v.speedY*firePNPC.data.velMY
				end
				if firePNPC.data.velX ~= nil then
					v.speedX = v.speedX+firePNPC.data.velX/10
				end
				if firePNPC.data.velY ~= nil then
					v.speedY = v.speedY+firePNPC.data.velY/10
				end
				
				-- OTHER
				
				--Kill when offscreen
				if not(colliders.collide(v, cameraCollider)) then
					firePNPC[v] = nil
					v:kill(9)
				end
				
				--tilldeath timer
				if not(firePNPC.data.tilldeath==nil) then
					firePNPC.data.tilldeath = firePNPC.data.tilldeath-1
				end
				
				--Kill when speed>0.1, or turn into other.
				
				if ((v.speedX>-firePNPC.data.clear)and(v.speedX<firePNPC.data.clear) and (v.speedY>-firePNPC.data.clear)and(v.speedY<firePNPC.data.clear)and(0<firePNPC.data.clear)) or (firePNPC.data.tilldeath~=nil) then
					if (firePNPC.data.tilldeath==nil) or (firePNPC.data.tilldeath<1) then
						if (firePNPC.data.turn==nil) then
							if firePNPC.data.dEffect>0 then
								local m1, m2 = getEffectSize(firePNPC.data.dEffect)
								Animation.spawn(firePNPC.data.dEffect, v.x-m1/2+v.width/2, v.y-m2/2+v.height/2)
							end
							firePNPC[v] = nil
							v:kill(9)
						else
							local ID=firePNPC.data.turn
							v.ai1=0
							v.ai2=0
							v.speedY=0
							v.x=v.x-npcConfig[ID].width/2+v.width/2
							v.height=npcConfig[ID].height
							v.width=npcConfig[ID].width
							if firePNPC.data.dEffect>0 then
								local m1, m2 = getEffectSize(firePNPC.data.dEffect)
								Animation.spawn(firePNPC.data.dEffect, v.x-m1/2+v.width/2, v.y-m2/2+v.height/2)
							end
							firePNPC[v] = nil
							v.id=ID
						end
					end
				end
			end
		end
	end
end


--ON CAMERA UPDATE

function Lotus.onCameraUpdate()

	--DRAW LOTUS
	local tableOfLotus = NPC.get(275, -1)
	for _,i in ipairs(tableOfLotus) do
	
		--pnpc frap
		local lotusPNPC = pnpc.wrap(i)
		
		--locals
		local reverseOffset = 0
		local lotusoffsety = npcConfig[275].gfxheight-npcConfig[275].height
		
		--Select graphic
		if (i.direction == 1) and not lotusPNPC.data.customLotus.normal then
			reverseOffset = lotussprite.height/2
			lotusoffsety = 0
		end
		
		--Draw lotus or have them invisible (0x12A is for despawn)
		lotusPNPC.data.customLotus.lotusframe = i.animationFrame or 1
		if not lotusPNPC.data.customLotus.invisible and i:mem(0x12A, FIELD_WORD) > 0 then
			Graphics.draw {
				type = RTYPE_IMAGE, 
				image = lotussprite,
				x = i.x, 
				y = i.y-lotusoffsety, 
				sourceY = lotusPNPC.data.customLotus.lotusframe*npcConfig[275].gfxheight+reverseOffset, 
				sourceWidth = npcConfig[275].gfxwidth, 
				sourceHeight = npcConfig[275].gfxheight, 
				priority = -46,
				isSceneCoordinates = true}
		end
		i.animationFrame=-1
	end
end

function Pollen.onCameraUpdate()
	--Set table
	local tableOfBars = NPC.get(260, -1)
	for a,k in ipairs(tableOfBars) do
		
		--Wrappers
		local firePNPC = pnpc.wrap(k)
		
		--Make invisible
		if (firePNPC.data.firestate ~= 0) then
			k.animationFrame = -1
			
		-- FIREBARS ANIMATION
			
			--Set Starting values.
			if (firePNPC.data.fireTimer == nil) then
				--Animation Timers for fire.
				firePNPC.data.fireTimer = 0
				firePNPC.data.fireTimerPre = 0
				--Load graphic.
				firePNPC.data.spriteID = "customLotusFire1.png"
				firePNPC.data.spriteID2 = Graphics.loadImage(Misc.resolveFile(tostring(string.gsub(firePNPC.data.spriteID, "%d+", firePNPC.data.sprite))))
			end
			
		--Draw bullets
			if not(firePNPC.data.spriteID2 == nil) then
				Graphics.draw {
					type = RTYPE_IMAGE, 
					image = (firePNPC.data.spriteID2),
					x = k.x+k.width/2-(firePNPC.data.spriteID2).width/2, 
					y = k.y+k.height/2-(firePNPC.data.spriteID2).height/(2*firePNPC.data.frameN),
					sourceY = firePNPC.data.fireTimer*(firePNPC.data.spriteID2).height/firePNPC.data.frameN, 
					sourceWidth = (firePNPC.data.spriteID2).width, 
					sourceHeight = (firePNPC.data.spriteID2).height/firePNPC.data.frameN, 
					priority = -15,
					isSceneCoordinates = true}
			end
			
			--Increase timer
			firePNPC.data.fireTimerPre = (firePNPC.data.fireTimerPre+1)
			if (firePNPC.data.fireTimerPre == firePNPC.data.frameS) then
				firePNPC.data.fireTimer = (firePNPC.data.fireTimer+1)
				firePNPC.data.fireTimerPre = 0
			end
			
			--Reset timer
			if (firePNPC.data.fireTimer >= firePNPC.data.frameN) then
				firePNPC.data.fireTimer = 0
			end
		end
	end
end

--ONDRAW

function Lotus.onDrawEnd()

	--DRAW LOTUS
	local tableOfLotus = NPC.get(275, -1)
	for _,i in ipairs(tableOfLotus) do
	
		--Save message contents
		local lotusPNPC = pnpc.wrap(i)
		--Draw lotus or have them invisible
		i.animationFrame = lotusPNPC.data.customLotus.lotusframe

	end
	
end

--***************************************************************************************************
--                                                                                                  *
--              API FUNCTIONS                                                                       *
--                                                                                                  *
--***************************************************************************************************

function customLotus.onTick()


	if not Defines.levelFreeze then
		Lotus.onTick()
		Pollen.onTick()
	end
end

function customLotus.onCameraUpdate()
	Lotus.onCameraUpdate()
	Pollen.onCameraUpdate()
end 

function customLotus.onDrawEnd()
	Lotus.onDrawEnd()
end

function customLotus.onInitAPI()
	registerEvent(customLotus, "onTick", "onTick", false)
	registerEvent(customLotus, "onCameraUpdate", "onCameraUpdate", true)
	registerEvent(customLotus, "onDrawEnd", "onDrawEnd", true)
end

return customLotus