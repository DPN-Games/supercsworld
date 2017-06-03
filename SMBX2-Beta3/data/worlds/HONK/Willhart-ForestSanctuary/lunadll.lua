--Priorities and background objects.
local priority_bg_1 = -88;
local priority_bg_2 = -87;

--[[
"Die, monster!  You don't belong in this world!"
"What the heck!?  Who are you and what are you doing in my castle!?"
"Tribute?! You steal men's souls and make them your slaves!"
"What are you babbling about?  I asked you two simple questions!"
"Your words are as empty as your soul!  Demonkind ill needs a savior such as you!"
"Enough talk!  If you won't leave, I'll make you!"
*presses a button, a trap door opens up beneath Broadsword and he falls out*

(He falls on the end star)

--Rip Dracula 1021-1041 1240-1562 1733-pr (rng?)
Died once by jumping off this cliff for bat-form did not trigger. There was nothing down there to break the fall.
]]

local bgos = {}
bgos[10] = priority_bg_1;
bgos[30] = priority_bg_1;
bgos[31] = priority_bg_1;
bgos[99] = priority_bg_1;
bgos[101] = priority_bg_1;
bgos[102] = priority_bg_1;
bgos[108] = priority_bg_1;
bgos[116] = priority_bg_1;
bgos[117] = priority_bg_1;
bgos[118] = priority_bg_1;
bgos[120] = priority_bg_1;
bgos[124] = priority_bg_1;
bgos[150] = priority_bg_1;
bgos[178] = priority_bg_1;

bgos[4] = priority_bg_2;

--Prallax
local bgoImages = {}
local bg0Img = Graphics.loadImage("background2-a.png")
local bg1Img = Graphics.loadImage("background2-b.png")

--Apis
local paralX = API.load("paralX")
local eventu = API.load("eventu")

--Npc Table.
local tableOfStones = NPC.get(69, -1)

local MUSIC_1 = "Drax - Fogging Around.xm"
local MUSIC_2 = "Castlevania SOTN - Requiem For The Gods.mp3"

--Functions
local bgolist = {}
for k,_ in pairs(bgos) do
	table.insert(bgolist,k);
end

function playMusic(filename)
	if(filename ~= musicKey) then
		MusicOpen(filename);
		musicKey = filename;
		MusicPlay();
	end
end

function changeMusic(fileName, milliseconds)
	if(fileName ~= musicKey) then
		eventu.run(function()
		MusicStopFadeOut(milliseconds);
		eventu.waitSeconds(milliseconds/1000);
		playMusic(fileName);
		end);
	end
end

--onStart
function onStart()

	player.character = 16
	player.powerup = 1
	player.reservePowerup = 0

	bg0	= paralX.create ({image=bg0Img,		parallaxX=0,	speedX=-0.4,	priority=-99, 	alignY=paralX.ALIGN_BOTTOM,		repeatY=true,	repeatX=true})
	bg0	= paralX.create ({image=bg1Img,		parallaxX=0.7,	speedX=0,	priority=-98, 	alignY=paralX.ALIGN_BOTTOM,		repeatY=false,	repeatX=true})
	
	--Set music.
	if player.y < -201500 then
		changeMusic(MUSIC_2,1000);
	elseif player.y > -201500 then
		changeMusic(MUSIC_1,1000);
	end
end

function onTick()
	--stoneNpc despawn prevent.
	for _,i in pairs(tableOfStones) do
		if i.isValid then
			i:mem(0x12A, FIELD_WORD, 1)
		end
	end
	
	--Change music.
	if player.x > -193980 and player.x < -193582 then
		if player.y < -201500 then
			changeMusic(MUSIC_2,2000);
		elseif player.y > -201500 then
			changeMusic(MUSIC_1,2000);
		end
	end
	
	if not Audio.MusicIsFading() then
		if Audio.MusicTitle() == "by DRAX" then
			Audio.MusicVolume(42)
		else
			Audio.MusicVolume(52)
		end
	end
	
	if player.isValid then
		if player:mem(0x13E, FIELD_WORD) == 1 then
			Audio.MusicStop()
		end
	end
	
	if player.x > -194060 and player.x < -193453 then
		if player.y < -203372 and  player.y > -203792 then
			Audio.MusicStopFadeOut(4000)
		end
	end
end

function onDraw()
	--Draw bgos.
	local c = Camera.get()[1];
	for _,v in ipairs(BGO.getIntersecting(c.x-300, c.y-300, c.x+800+300, c.y + 600+300)) do
		if(bgos[v.id] ~= nil) then
			Graphics.draw{type = RTYPE_IMAGE, x = v.x, y = v.y, image = Graphics.sprites.background[v.id].img, priority = bgos[v.id], isSceneCoordinates = true}
		end
	end
end

function onNPCKill(eventObj,npcID,killReason)
	if npcID == 97 then
		Audio.MusicStop()
	end
end