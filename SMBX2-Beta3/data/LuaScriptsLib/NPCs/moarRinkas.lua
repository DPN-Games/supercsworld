local pnpc = API.load("pnpc")
local rng = API.load("rng")
local camera = Camera.get()[1]
local redsprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\redrinka.png"))
local yellowsprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\yellowrinka.png"))
local purplesprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\purplerinka.png"))
local greensprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\greenrinka.png"))
local cyansprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\cyanrinka.png"))
local pinksprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\pinkrinka.png"))
local bluesprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\bluerinka.png"))
local whitesprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\whiterinka.png"))
local turquoisesprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\turquoiserinka.png"))
local orangesprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\orangerinka.png"))
local blacksprite = Graphics.loadImage(Misc.resolveFile("graphics\\new_npcs\\moarRinkas\\blackrinka.png"))

local moarRinkas = {}

local redRinkaCounter = 0
local yellowRinkaCounter = 0
local greenRinkaCounter = 0
local cyanRinkaCounter = 0
local purpleRinkaCounter = 0
local pinkRinkaCounter = 0
local blueRinkaCounter = 0
local whiteRinkaCounter = 0
local turquoiseRinkaCounter = 0
local orangeRinkaCounter = 0
local blackRinkaCounter = 0
local normalRinkaCounter = 0

local redRinkaLimit = 8
local yellowRinkaLimit = 8
local greenRinkaLimit = 8
local cyanRinkaLimit = 8
local purpleRinkaLimit = 8
local pinkRinkaLimit = 8
local blueRinkaLimit = 8
local whiteRinkaLimit = 8
local turquoiseRinkaLimit = 8
local orangeRinkaLimit = 8
local blackRinkaLimit = 8
local normalRinkaLimit = 100

local rinkawrapper = {}

local happyRinka = {}
happyRinka[1] = "Boy are you swell"
happyRinka[2] = "You have nice shoes"
happyRinka[3] = "I think you smell nice today"
happyRinka[4] = "Don't sweat the small things"
happyRinka[5] = "Just live for today. You can do it!"
happyRinka[6] = "Dayum you sexy!"
happyRinka[7] = "How do you get your hair to look that great?? :O"
happyRinka[8] = "You're beautiful no matter what they say"
happyRinka[9] = "I'm so glad we met."
happyRinka[10] = "My life would suck without you. Thanks, You're great."
happyRinka[11] = "Playing video games with you would be fun."
happyRinka[12] = "You're more fun than bubble wrap."
happyRinka[13] = "You're so rad."
happyRinka[14] = "I don't speak much English, but with you all I really need to say is beautiful."
happyRinka[15] = "Hi, I'd like to know why you're so beautiful."
happyRinka[16] = "Are you a Beaver? Cause Dam!"
happyRinka[17] = "You are the gravy to my mashed potatoes."
happyRinka[18] = "You're so fancy, you already know."
happyRinka[19] = "You're nicer than a day on the beach."
happyRinka[20] = "I appreciate all of your opinions."
happyRinka[21] = "You could invent words and people would use them."
happyRinka[22] = "Any day spent with you is my favorite day."
happyRinka[23] = "You make me think of beautiful things, like strawberries."
happyRinka[24] = "You have a good fashion sense."
happyRinka[25] = "Do you wanna build a snowman, with me?"
happyRinka[26] = "Your personality is brighter than the stars."
happyRinka[27] = "You are unbelievably pleasant."
happyRinka[28] = "You make everyone feel great."
happyRinka[29] = "You are very neat."
happyRinka[30] = "You tell exceptionally funny jokes."

local memeRinka = {}
memeRinka[1] = "memes"
memeRinka[2] = "butts"
memeRinka[2] = "pyro is a dorkatron yo"

function moarRinkas.onInitAPI()
    registerEvent(moarRinkas, "onCameraUpdate", "Randomizer")
	registerEvent(moarRinkas, "onNPCKill", "onNPCKill")
end

function moarRinkas.Randomizer()
	spawningRinka()
	redRinka()
	yellowRinka()
	greenRinka()
	cyberRinka()
	purpleRinka()
	pinkRinka()
	blueRinka()
	whiteRinka()
	turquoiseRinka()
	orangeRinka()
	blackRinka()
	normalRinka()
end

function spawningRinka()
	rinkas = NPC.get(210,-1)
	for k,v in ipairs(rinkas) do
		spawner = NPC.getIntersecting(v.x, v.y,v.x+v.width,v.y+v.height)
		for g,w in ipairs(spawner) do
		openblocks = Block.getIntersecting(w.x-32,w.y-32,w.x+w.width+16,w.y+w.height+16)
		innerblocks = Block.getIntersecting(w.x+2,w.y+2,w.x+w.width-2,w.y+w.height-2)
		spawnertype = pnpc.wrap(w)
		if spawnertype.data.spawnertype == nil then
			spawnertype.data.spawnertype = 0
		end
			if w.msg.length > 0 then
				if w.msg.str == "purple" or w.msg.str == "bounce" then
					spawnertype.data.spawnertype = 1
				elseif w.msg.str == "yellow" or w.msg.str == "wrap" or w.msg.str == "warp" then
					spawnertype.data.spawnertype = 2	
				elseif w.msg.str == "green" or w.msg.str == "follow" then
					spawnertype.data.spawnertype = 3
				elseif w.msg.str == "cyber" or w.msg.str == "cyan" or w.msg.str == "glitch" then
					spawnertype.data.spawnertype = 4
				elseif w.msg.str == "red" or w.msg.str == "multiply" then
					spawnertype.data.spawnertype = 5
				elseif w.msg.str == "pink" or w.msg.str == "slow" then
					spawnertype.data.spawnertype = 6
				elseif w.msg.str == "blue" or w.msg.str == "teleport" then
					spawnertype.data.spawnertype = 7
				elseif w.msg.str == "horikawaisradicola" then
					spawnertype.data.spawnertype = 8
				elseif w.msg.str == "turquoise" or w.msg.str == "dizzy" or w.msg.str == "drunk" then
					spawnertype.data.spawnertype = 9
				elseif w.msg.str == "orange" or w.msg.str == "fast" then
					spawnertype.data.spawnertype = 10
				elseif w.msg.str == "black" or w.msg.str == "kamikaze" or w.msg.str == "bomb" then
					spawnertype.data.spawnertype = 11
				elseif w.msg.str == "rainbow" or w.msg.str == "random" then
					spawnertype.data.spawnertype = 12
				end
				w.msg.str = ""
			end
			if #spawner > 0 and v.ai2 == 0 then
				if spawnertype.data.spawnertype == 1 then
					v.ai5 = 1
				elseif spawnertype.data.spawnertype == 2 then
					v.ai5 = 2
				elseif spawnertype.data.spawnertype == 3 then
					v.ai5 = 3
				elseif spawnertype.data.spawnertype == 4 then
					v.ai5 = 4
					v.x = v.x + rng.randomInt(-128,128)
					v.y = v.y + rng.randomInt(-128,128)
				elseif spawnertype.data.spawnertype == 5 then
					v.ai5 = 5
				elseif spawnertype.data.spawnertype == 6 then
					v.ai5 = 6
				elseif spawnertype.data.spawnertype == 7 then
					v.ai5 = 7
				elseif spawnertype.data.spawnertype == 8 then
					v.ai5 = 8
				elseif spawnertype.data.spawnertype == 9 then
					v.ai5 = 9
				elseif spawnertype.data.spawnertype == 10 then
					v.ai5 = 10
				elseif spawnertype.data.spawnertype == 11 then
					v.ai5 = 11
				elseif spawnertype.data.spawnertype == 12 then
					v.ai5 = rng.randomInt(0,9)
					if #openblocks < 5 and #innerblocks == 0 then
						if v.ai5 == 4 then
						v.x = v.x + rng.randomInt(-128,128)
						v.y = v.y + rng.randomInt(-128,128)
						end
					else
						if v.ai5 == 1 then
							v.ai5 = 0
						end
						if v.ai5 == 4 then
						v.x = v.x + rng.randomInt(-128,128)
						v.y = v.y + rng.randomInt(-128,128)
						end
					end
				end
			end
		end
	end
end

function redRinka()
	for k,v in ipairs(rinkas) do
	multiplyingrinka = pnpc.wrap(v)
		if v.ai5 == 5 then
			if multiplyingrinka.data.sprite == nil then
			multiplyingrinka.data.sprite = 0
			redRinkaCounter = redRinkaCounter + 1
			end
			multiplyingrinka.data.sprite = multiplyingrinka.data.sprite + 1
			if multiplyingrinka.data.sprite >= 0 and multiplyingrinka.data.sprite < 8 then
				Graphics.drawImageToSceneWP(redsprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif multiplyingrinka.data.sprite >= 8 and multiplyingrinka.data.sprite < 16 then
				Graphics.drawImageToSceneWP(redsprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif multiplyingrinka.data.sprite >= 16 and multiplyingrinka.data.sprite < 24 then
				Graphics.drawImageToSceneWP(redsprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif multiplyingrinka.data.sprite >= 24 and multiplyingrinka.data.sprite < 32 then
				Graphics.drawImageToSceneWP(redsprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif multiplyingrinka.data.sprite >= 32 and multiplyingrinka.data.sprite < 40 then
				Graphics.drawImageToSceneWP(redsprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif multiplyingrinka.data.sprite >= 40 and multiplyingrinka.data.sprite < 48 then
				Graphics.drawImageToSceneWP(redsprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif multiplyingrinka.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(redsprite,v.x,v.y,0,0,v.width,v.height,-14)
				multiplyingrinka.data.sprite = 0
			end
			if multiplyingrinka.data.multiplycounter == nil then
			multiplyingrinka.data.multiplycounter = 0
			end
			if v.ai1 == 1 then
			multiplyingrinka.data.multiplycounter = multiplyingrinka.data.multiplycounter + 1
			end
			if multiplyingrinka.data.multiplycounter == 120 then
			multiplyingrinka.data.multiplycounter = 0
			local newred = NPC.spawn(210, v.x, v.y, player.section)
			newred.ai5 = 5
			end
			if v:mem(0x128, FIELD_WORD) == -1 then
				v:kill(9)
				redRinkaCounter = redRinkaCounter - 1
			elseif redRinkaCounter >= redRinkaLimit then
				v:kill(9)
				redRinkaCounter = redRinkaCounter - 1
			end
		end
	end
end

function yellowRinka()
	for k,v in ipairs(rinkas) do
		wrappingrinka = pnpc.wrap(v)
		if v.ai5 == 2 then
			if wrappingrinka.data.sprite == nil then
			wrappingrinka.data.sprite = 0
			yellowRinkaCounter = yellowRinkaCounter + 1
			end
			wrappingrinka.data.sprite = wrappingrinka.data.sprite + 1
			if wrappingrinka.data.sprite >= 0 and wrappingrinka.data.sprite < 8 then
				Graphics.drawImageToSceneWP(yellowsprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif wrappingrinka.data.sprite >= 8 and wrappingrinka.data.sprite < 16 then
				Graphics.drawImageToSceneWP(yellowsprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif wrappingrinka.data.sprite >= 16 and wrappingrinka.data.sprite < 24 then
				Graphics.drawImageToSceneWP(yellowsprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif wrappingrinka.data.sprite >= 24 and wrappingrinka.data.sprite < 32 then
				Graphics.drawImageToSceneWP(yellowsprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif wrappingrinka.data.sprite >= 32 and wrappingrinka.data.sprite < 40 then
				Graphics.drawImageToSceneWP(yellowsprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif wrappingrinka.data.sprite >= 40 and wrappingrinka.data.sprite < 48 then
				Graphics.drawImageToSceneWP(yellowsprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif wrappingrinka.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(yellowsprite,v.x,v.y,0,0,v.width,v.height,-14)
				wrappingrinka.data.sprite = 0
			end
			if v:mem(0x146, FIELD_WORD) == player.section then
				if v.x < camera.x - v.width then
					v.x = v.x + 800 + v.width
				elseif v.x > camera.x + camera.width then
					v.x = v.x - 800 - v.width
				end
				if v.y < camera.y - v.height then
					v.y = v.y + 600 + v.height
				elseif v.y > camera.y + camera.height then
					v.y = v.y - 600 - v.height
				end
			end
			if yellowRinkaCounter >= yellowRinkaLimit then
				v:kill(9)
				yellowRinkaCounter = yellowRinkaCounter - 1
			end
		end
	end
end

function greenRinka()
	for k,v in ipairs(rinkas) do
	reaimingrinka = pnpc.wrap(v)
	if v.ai5 == 3 then
		if reaimingrinka.data.sprite == nil then
			reaimingrinka.data.sprite = 0
			greenRinkaCounter = greenRinkaCounter + 1
		end
		reaimingrinka.data.sprite = reaimingrinka.data.sprite + 1
			if reaimingrinka.data.sprite >= 0 and reaimingrinka.data.sprite < 8 then
				Graphics.drawImageToSceneWP(greensprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif reaimingrinka.data.sprite >= 8 and reaimingrinka.data.sprite < 16 then
				Graphics.drawImageToSceneWP(greensprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif reaimingrinka.data.sprite >= 16 and reaimingrinka.data.sprite < 24 then
				Graphics.drawImageToSceneWP(greensprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif reaimingrinka.data.sprite >= 24 and reaimingrinka.data.sprite < 32 then
				Graphics.drawImageToSceneWP(greensprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif reaimingrinka.data.sprite >= 32 and reaimingrinka.data.sprite < 40 then
				Graphics.drawImageToSceneWP(greensprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif reaimingrinka.data.sprite >= 40 and reaimingrinka.data.sprite < 48 then
				Graphics.drawImageToSceneWP(greensprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif reaimingrinka.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(greensprite,v.x,v.y,0,0,v.width,v.height,-14)
				reaimingrinka.data.sprite = 0
			end
			if reaimingrinka.data.counter == nil then
			reaimingrinka.data.counter = 0
			end
			reaimingrinka.data.counter = reaimingrinka.data.counter + 1
			if reaimingrinka.data.counter == 100 then
				reaimingrinka.data.counter = 0
				v.ai1 = 0
			end
			if v:mem(0x128, FIELD_WORD) == -1 then
				v:kill(9)
				greenRinkaCounter = greenRinkaCounter - 1
			elseif greenRinkaCounter >= greenRinkaLimit then
				v:kill(9)
				greenRinkaCounter = greenRinkaCounter - 1
			end
		end
	end
end

function cyberRinka()
	for k,v in ipairs(rinkas) do
	shakingrinka = pnpc.wrap(v)
		if v.ai5 == 4 then
			if shakingrinka.data.sprite == nil then
				shakingrinka.data.sprite = 0
				cyanRinkaCounter = cyanRinkaCounter + 1
			end
			shakingrinka.data.sprite = shakingrinka.data.sprite + 1
			if shakingrinka.data.sprite >= 0 and shakingrinka.data.sprite < 8 then
				Graphics.drawImageToSceneWP(cyansprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif shakingrinka.data.sprite >= 8 and shakingrinka.data.sprite < 16 then
				Graphics.drawImageToSceneWP(cyansprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif shakingrinka.data.sprite >= 16 and shakingrinka.data.sprite < 24 then
				Graphics.drawImageToSceneWP(cyansprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif shakingrinka.data.sprite >= 24 and shakingrinka.data.sprite < 32 then
				Graphics.drawImageToSceneWP(cyansprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif shakingrinka.data.sprite >= 32 and shakingrinka.data.sprite < 40 then
				Graphics.drawImageToSceneWP(cyansprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif shakingrinka.data.sprite >= 40 and shakingrinka.data.sprite < 48 then
				Graphics.drawImageToSceneWP(cyansprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif shakingrinka.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(cyansprite,v.x,v.y,0,0,v.width,v.height,-14)
				shakingrinka.data.sprite = 0
			end
			if shakingrinka.data.shaking == nil then
			shakingrinka.data.shaking = 0
			end
			shakingrinka.data.shaking = shakingrinka.data.shaking + 1
			if shakingrinka.data.shaking < 9 then
				v.speedX = 0
				v.speedY = 0
				xspeed = rng.randomInt(1,2)
				yspeed = rng.randomInt(1,2)
				if xspeed == 1 then
					v.x = v.x + rng.randomInt(0,10)
				elseif xspeed == 2 then
					v.x = v.x - rng.randomInt(0,10)
				end
				if yspeed == 1 then
					v.y = v.y + rng.randomInt(0,10)
				elseif yspeed == 2 then
					v.y = v.y - rng.randomInt(0,10)
				end
			end
			if shakingrinka.data.shaking == 100 or shakingrinka.data.shaking == rng.randomInt(1,99) then
			shakingrinka.data.shaking = 0
			end
			if v:mem(0x128, FIELD_WORD) == -1 then
				v:kill(9)
				cyanRinkaCounter = cyanRinkaCounter - 1
			elseif cyanRinkaCounter >= cyanRinkaLimit then
				v:kill(9)
				cyanRinkaCounter = cyanRinkaCounter - 1
			end
		end
	end
end

function purpleRinka()
	for k,v in ipairs(rinkas) do
		if v.ai5 == 1 then
			purplerinkas = pnpc.wrap(v)
			if purplerinkas.data.sprite == nil then
				purplerinkas.data.sprite = 0
				purpleRinkaCounter = purpleRinkaCounter + 1
			end
			purplerinkas.data.sprite = purplerinkas.data.sprite + 1
			if purplerinkas.data.sprite >= 0 and purplerinkas.data.sprite < 8 then
				Graphics.drawImageToSceneWP(purplesprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif purplerinkas.data.sprite >= 8 and purplerinkas.data.sprite < 16 then
				Graphics.drawImageToSceneWP(purplesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif purplerinkas.data.sprite >= 16 and purplerinkas.data.sprite < 24 then
				Graphics.drawImageToSceneWP(purplesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif purplerinkas.data.sprite >= 24 and purplerinkas.data.sprite < 32 then
				Graphics.drawImageToSceneWP(purplesprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif purplerinkas.data.sprite >= 32 and purplerinkas.data.sprite < 40 then
				Graphics.drawImageToSceneWP(purplesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif purplerinkas.data.sprite >= 40 and purplerinkas.data.sprite < 48 then
				Graphics.drawImageToSceneWP(purplesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif purplerinkas.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(purplesprite,v.x,v.y,0,0,v.width,v.height,-14)
				purplerinkas.data.sprite = 0
			end
			top = Block.getIntersecting(v.x+10,v.y,v.x+v.width-10,v.y+v.height)
			if #top > 0 then
				v.speedY = -v.speedY
			end
			side = Block.getIntersecting(v.x,v.y+10,v.x+v.width,v.y+v.height-10)
			if #side > 0 then
				v.speedX = -v.speedX
			end
			if v:mem(0x128, FIELD_WORD) == -1 or purpleRinkaCounter >= purpleRinkaLimit then
				v:kill(9)
				purpleRinkaCounter = purpleRinkaCounter - 1
			end
		end
	end
end

function pinkRinka()
	for k,v in ipairs(rinkas) do
		if v.ai5 == 6 then
			pinkrinkas = pnpc.wrap(v)
			if pinkrinkas.data.sprite == nil then
				pinkrinkas.data.sprite = 0
				pinkRinkaCounter = pinkRinkaCounter + 1
			end
			pinkrinkas.data.sprite = pinkrinkas.data.sprite + 1
			if pinkrinkas.data.sprite >= 0 and pinkrinkas.data.sprite < 8 then
				Graphics.drawImageToSceneWP(pinksprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif pinkrinkas.data.sprite >= 8 and pinkrinkas.data.sprite < 16 then
				Graphics.drawImageToSceneWP(pinksprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif pinkrinkas.data.sprite >= 16 and pinkrinkas.data.sprite < 24 then
				Graphics.drawImageToSceneWP(pinksprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif pinkrinkas.data.sprite >= 24 and pinkrinkas.data.sprite < 32 then
				Graphics.drawImageToSceneWP(pinksprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif pinkrinkas.data.sprite >= 32 and pinkrinkas.data.sprite < 40 then
				Graphics.drawImageToSceneWP(pinksprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif pinkrinkas.data.sprite >= 40 and pinkrinkas.data.sprite < 48 then
				Graphics.drawImageToSceneWP(pinksprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif pinkrinkas.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(pinksprite,v.x,v.y,0,0,v.width,v.height,-14)
				pinkrinkas.data.sprite = 0
			end
			v.speedX = v.speedX * 0.99
			v.speedY = v.speedY * 0.99
			if v.ai1 == 1 then
				if v.speedX < 0.01 and v.speedX > -0.01 or v.speedY < 0.01 and v.speedY > -0.01 then
					v:kill(9)
					pinkRinkaCounter = pinkRinkaCounter - 1
				elseif v:mem(0x128, FIELD_WORD) == -1 or pinkRinkaCounter >= pinkRinkaLimit then
					v:kill(9)
					pinkRinkaCounter = pinkRinkaCounter - 1
				end
			end
		end
	end
end

function blueRinka()
	for k,v in ipairs(rinkas) do
		if v.ai5 == 7 then
			bluerinkas = pnpc.wrap(v)
			if bluerinkas.data.sprite == nil then
				bluerinkas.data.sprite = 0
				blueRinkaCounter = blueRinkaCounter + 1
			end
			if bluerinkas.data.counter == nil then
				bluerinkas.data.counter = 0
			end
			if v.ai1 == 1 then
				bluerinkas.data.counter = bluerinkas.data.counter + 1
			end
			bluerinkas.data.sprite = bluerinkas.data.sprite + 1
			if bluerinkas.data.sprite >= 0 and bluerinkas.data.sprite < 8 then
				Graphics.drawImageToSceneWP(bluesprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif bluerinkas.data.sprite >= 8 and bluerinkas.data.sprite < 16 then
				Graphics.drawImageToSceneWP(bluesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif bluerinkas.data.sprite >= 16 and bluerinkas.data.sprite < 24 then
				Graphics.drawImageToSceneWP(bluesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif bluerinkas.data.sprite >= 24 and bluerinkas.data.sprite < 32 then
				Graphics.drawImageToSceneWP(bluesprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif bluerinkas.data.sprite >= 32 and bluerinkas.data.sprite < 40 then
				Graphics.drawImageToSceneWP(bluesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif bluerinkas.data.sprite >= 40 and bluerinkas.data.sprite < 48 then
				Graphics.drawImageToSceneWP(bluesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif bluerinkas.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(bluesprite,v.x,v.y,0,0,v.width,v.height,-14)
				bluerinkas.data.sprite = 0
			end
			if bluerinkas.data.counter == 100 then
				posornegx = rng.randomInt(0,1)
				posornegy = rng.randomInt(0,1)
				if posornegx == 1 then
					v.x = rng.randomInt(player.x+(player.width/2)+128,camera.x+camera.width-v.width)
				else
					v.x = rng.randomInt(camera.x,player.x+(player.width/2)-128)
				end
				if posornegy == 1 then
					v.y = rng.randomInt(player.y+(player.height/2)+128,camera.y+camera.height-v.height)
				else
					v.y = rng.randomInt(camera.y,player.y+(player.height/2)-128)
				end
				bluerinkas.data.counter = 0
				v.ai1 = 0
			end
			if v:mem(0x128, FIELD_WORD) == -1 or blueRinkaCounter >= blueRinkaLimit then
				v:kill(9)
				blueRinkaCounter = blueRinkaCounter - 1
			end
		end
	end
end

function whiteRinka()
	for k,v in ipairs(rinkas) do
		if v.ai5 == 8 then
			whiterinkas = pnpc.wrap(v)
			if whiterinkas.data.sprite == nil then
				whiterinkas.data.sprite = 0
				whiteRinkaCounter = whiteRinkaCounter + 1
				message = rng.randomInt(1,10)
			end
			whiterinkas.data.sprite = whiterinkas.data.sprite + 1
			if whiterinkas.data.sprite >= 0 and whiterinkas.data.sprite < 8 then
				Graphics.drawImageToSceneWP(whitesprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif whiterinkas.data.sprite >= 8 and whiterinkas.data.sprite < 16 then
				Graphics.drawImageToSceneWP(whitesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif whiterinkas.data.sprite >= 16 and whiterinkas.data.sprite < 24 then
				Graphics.drawImageToSceneWP(whitesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif whiterinkas.data.sprite >= 24 and whiterinkas.data.sprite < 32 then
				Graphics.drawImageToSceneWP(whitesprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif whiterinkas.data.sprite >= 32 and whiterinkas.data.sprite < 40 then
				Graphics.drawImageToSceneWP(whitesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif whiterinkas.data.sprite >= 40 and whiterinkas.data.sprite < 48 then
				Graphics.drawImageToSceneWP(whitesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif whiterinkas.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(whitesprite,v.x,v.y,0,0,v.width,v.height,-14)
				whiterinkas.data.sprite = 0
			end
			v.friendly = true
			v.msg = happyRinka[rng.randomInt(1, #happyRinka)]
			if v:mem(0x128, FIELD_WORD) == -1 or whiteRinkaCounter >= whiteRinkaLimit then
				v:kill(9)
				whiteRinkaCounter = whiteRinkaCounter - 1
			end
		end
	end
end

function turquoiseRinka()
	for k,v in ipairs(rinkas) do
		if v.ai5 == 9 then
			turquoiserinkas = pnpc.wrap(v)
			if turquoiserinkas.data.sprite == nil then
				turquoiserinkas.data.sprite = 0
				turquoiseRinkaCounter = turquoiseRinkaCounter + 1
			end
			turquoiserinkas.data.sprite = turquoiserinkas.data.sprite + 1
			if turquoiserinkas.data.sprite >= 0 and turquoiserinkas.data.sprite < 8 then
				Graphics.drawImageToSceneWP(turquoisesprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif turquoiserinkas.data.sprite >= 8 and turquoiserinkas.data.sprite < 16 then
				Graphics.drawImageToSceneWP(turquoisesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif turquoiserinkas.data.sprite >= 16 and turquoiserinkas.data.sprite < 24 then
				Graphics.drawImageToSceneWP(turquoisesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif turquoiserinkas.data.sprite >= 24 and turquoiserinkas.data.sprite < 32 then
				Graphics.drawImageToSceneWP(turquoisesprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif turquoiserinkas.data.sprite >= 32 and turquoiserinkas.data.sprite < 40 then
				Graphics.drawImageToSceneWP(turquoisesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif turquoiserinkas.data.sprite >= 40 and turquoiserinkas.data.sprite < 48 then
				Graphics.drawImageToSceneWP(turquoisesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif turquoiserinkas.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(turquoisesprite,v.x,v.y,0,0,v.width,v.height,-14)
				turquoiserinkas.data.sprite = 0
			end
			if v.ai1 == 1 then
				v.x = v.x + math.sin(v.y/32)
				v.y = v.y + math.cos(v.x/32)
			end
			if v:mem(0x128, FIELD_WORD) == -1 or turquoiseRinkaCounter >= turquoiseRinkaLimit then
				v:kill(9)
				turquoiseRinkaCounter = turquoiseRinkaCounter - 1
			end
		end
	end
end

function orangeRinka()
	for k,v in ipairs(rinkas) do
		if v.ai5 == 10 then
			orangerinkas = pnpc.wrap(v)
			if orangerinkas.data.sprite == nil then
				orangerinkas.data.sprite = 0
				orangeRinkaCounter = orangeRinkaCounter + 1
			end
			orangerinkas.data.sprite = orangerinkas.data.sprite + 1
			if orangerinkas.data.sprite >= 0 and orangerinkas.data.sprite < 8 then
				Graphics.drawImageToSceneWP(orangesprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif orangerinkas.data.sprite >= 8 and orangerinkas.data.sprite < 16 then
				Graphics.drawImageToSceneWP(orangesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif orangerinkas.data.sprite >= 16 and orangerinkas.data.sprite < 24 then
				Graphics.drawImageToSceneWP(orangesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif orangerinkas.data.sprite >= 24 and orangerinkas.data.sprite < 32 then
				Graphics.drawImageToSceneWP(orangesprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif orangerinkas.data.sprite >= 32 and orangerinkas.data.sprite < 40 then
				Graphics.drawImageToSceneWP(orangesprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif orangerinkas.data.sprite >= 40 and orangerinkas.data.sprite < 48 then
				Graphics.drawImageToSceneWP(orangesprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif orangerinkas.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(orangesprite,v.x,v.y,0,0,v.width,v.height,-14)
				orangerinkas.data.sprite = 0
			end
			v.speedX = v.speedX * 1.01
			v.speedY = v.speedY * 1.01
			if v:mem(0x128, FIELD_WORD) == -1 or orangeRinkaCounter >= orangeRinkaLimit then
				v:kill(9)
				orangeRinkaCounter = orangeRinkaCounter - 1
			end
		end
	end
end

function blackRinka()
	for k,v in ipairs(rinkas) do
		if v.ai5 == 11 then
			blackrinkas = pnpc.wrap(v)
			if blackrinkas.data.sprite == nil then
				blackrinkas.data.sprite = 0
				blackRinkaCounter = blackRinkaCounter + 1
				blackrinkas.data.bomb = 0
			end
			blackrinkas.data.bomb = blackrinkas.data.bomb + 1
			blackrinkas.data.sprite = blackrinkas.data.sprite + 1
			if blackrinkas.data.sprite >= 0 and blackrinkas.data.sprite < 8 then
				Graphics.drawImageToSceneWP(blacksprite,v.x,v.y,0,0,v.width,v.height,-14)
			elseif blackrinkas.data.sprite >= 8 and blackrinkas.data.sprite < 16 then
				Graphics.drawImageToSceneWP(blacksprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif blackrinkas.data.sprite >= 16 and blackrinkas.data.sprite < 24 then
				Graphics.drawImageToSceneWP(blacksprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif blackrinkas.data.sprite >= 24 and blackrinkas.data.sprite < 32 then
				Graphics.drawImageToSceneWP(blacksprite,v.x,v.y,0,3*v.height,v.width,v.height,-14)
			elseif blackrinkas.data.sprite >= 32 and blackrinkas.data.sprite < 40 then
				Graphics.drawImageToSceneWP(blacksprite,v.x,v.y,0,2*v.height,v.width,v.height,-14)
			elseif blackrinkas.data.sprite >= 40 and blackrinkas.data.sprite < 48 then
				Graphics.drawImageToSceneWP(blacksprite,v.x,v.y,0,1*v.height,v.width,v.height,-14)
			elseif blackrinkas.data.sprite >= 48 then
				Graphics.drawImageToSceneWP(blacksprite,v.x,v.y,0,0,v.width,v.height,-14)
				blackrinkas.data.sprite = 0
			end
			if blackrinkas.data.bomb == 120 then
				local rinka1 = NPC.spawn(210,v.x,v.y,player.section)
				local rinka2 = NPC.spawn(210,v.x,v.y,player.section)
				local rinka3 = NPC.spawn(210,v.x,v.y,player.section)
				if player.x+player.width/2 > v.x+v.width/2 then
					rinka1.speedX = rng.randomInt(1,3)
					rinka2.speedX = rng.randomInt(1,3)
					rinka3.speedX = rng.randomInt(1,3)
				else
					rinka1.speedX = rng.randomInt(-3,-1)
					rinka2.speedX = rng.randomInt(-3,-1)
					rinka3.speedX = rng.randomInt(-3,-1)
				end
				if player.y+player.height/2 > v.y+v.height/2 then
					rinka1.speedY = rng.randomInt(1,3)
					rinka2.speedY = rng.randomInt(1,3)
					rinka3.speedY = rng.randomInt(1,3)
				else
					rinka1.speedY = rng.randomInt(-3,-1)
					rinka2.speedY = rng.randomInt(-3,-1)
					rinka3.speedY = rng.randomInt(-3,-1)
				end
				rinka1.ai1 = 1
				rinka2.ai1 = 1
				rinka3.ai1 = 1
				v:kill(9)
				blackRinkaCounter = blackRinkaCounter - 1
			end
			if v:mem(0x128, FIELD_WORD) == -1 or blackRinkaCounter >= blackRinkaLimit then
				v:kill(9)
				blackRinkaCounter = blackRinkaCounter - 1
			end
		end
	end
end

function normalRinka()
	for k,v in ipairs(rinkas) do
		if v.ai5 == 11 then
			normalrinkas = pnpc.wrap(v)
			if normalrinkas.data.what == nil then
				normalrinkas.data.what = rng.randomInt(1,1000)
				normalrinkas.data.memes = 0
				normalRinkaCounter = normalRinkaCounter + 1
			end
			if normalrinkas.data.what == 1000 then
				v.friendly = true
				v.msg = memeRinka[rng.randomInt(1, #memeRinka)]
			end
			if normalRinkaCounter > normalRinkaLimit then
				v:kill()
				normalRinkaCounter = normalRinkaCounter - 1
			end
		end
	end
end

function moarRinkas.onNPCKill(butt, killed, reason)
	if killed.id == 210 then
		if killed.ai5 == 0 then
			normalRinkaCounter = normalRinkaCounter - 1
		elseif killed.ai5 == 1 then
			purpleRinkaCounter = purpleRinkaCounter - 1
		elseif killed.ai5 == 2 then
			yellowRinkaCounter = yellowRinkaCounter - 1
		elseif killed.ai5 == 3 then
			greenRinkaCounter = greenRinkaCounter - 1
		elseif killed.ai5 == 4 then
			cyanRinkaCounter = cyanRinkaCounter - 1
		elseif killed.ai5 == 5 then
			redRinkaCounter = redRinkaCounter - 1
		elseif killed.ai5 == 6 then
			pinkRinkaCounter = pinkRinkaCounter - 1
		elseif killed.ai5 == 7 then
			blueRinkaCounter = blueRinkaCounter - 1
		elseif killed.ai5 == 8 then
			whiteRinkaCounter = whiteRinkaCounter - 1
		elseif killed.ai5 == 9 then
			turquoiseRinkaCounter = turquoiseRinkaCounter - 1
		elseif killed.ai5 == 10 then
			orangeRinkaCounter = orangeRinkaCounter - 1
		elseif killed.ai5 == 11 then
			blackRinkaCounter = blackRinkaCounter - 1
		end
	end
end

return moarRinkas