-- Most of the apis used have a page here: http://wohlsoft.ru/pgewiki/Category:LunaLua_helper_libraries
-- Also some of the enemies like the Bony Beetle can simply be placed on the level like normal npc.

local npcParse = API.load("npcParse");
local paralX = API.load("paralX");
local particles = API.load("particles");
local customLotus = API.load("NPCs\\customLotus");
local moarRinkas = API.load("NPCs\\moarRinkas");

-- Set the particles.
local leafEmitter = particles.Emitter(0, 0, Misc.resolveFile("particles/p_leaf.ini"), 1)
leafEmitter:AttachToCamera(Camera.get()[1]);

-- Load the images.
local bg0Img = Graphics.loadImage("bgp-0.png")
local bg1Img = Graphics.loadImage("bgp-1.png")
local bg2Img = Graphics.loadImage("bgp-2.png")
local bg3Img = Graphics.loadImage("bgp-3.png")
local bg4Img = Graphics.loadImage("bgp-4.png")
local bg5Img = Graphics.loadImage("bgp-5.png")
local bg6Img = Graphics.loadImage("bgp-6.png")
local bg7Img = Graphics.loadImage("bgp-7.png")
local bg8Img = Graphics.loadImage("bgp-8.png")
local bg9Img = Graphics.loadImage("bgp-9.png")

function onStart ()
	--Set the paralX layers.
	bg0		= paralX.create ({image=bg0Img,		parallaxX=0,		speedX=0, 		alignY = paralX.ALIGN_BOTTOM})
	bg1		= paralX.create ({image=bg1Img,		parallaxX=0.1,		speedX=0, 		alignY = paralX.ALIGN_BOTTOM,		parallaxY=0.6,		repeatY=false})
	bg2		= paralX.create ({image=bg2Img,		parallaxX=0.15,		speedX=0, 		alignY = paralX.ALIGN_BOTTOM,		parallaxY=0.6,		repeatY=false})
	bg3		= paralX.create ({image=bg3Img,		parallaxX=0.3,		speedX=-0.1, 		alignY = paralX.ALIGN_BOTTOM,		parallaxY=0.62,		repeatY=false})
	bg4		= paralX.create ({image=bg4Img,		parallaxX=0.38,		speedX=-0.2,		 alignY = paralX.ALIGN_BOTTOM,		parallaxY=0.64,		repeatY=false})
	bg5		= paralX.create ({image=bg5Img,		parallaxX=0.5,		speedX=-0.3, 		alignY = paralX.ALIGN_BOTTOM,		parallaxY=0.66,		repeatY=false})
	bg6		= paralX.create ({image=bg6Img,		parallaxX=0.6,		speedX=-0.5,		 alignY = paralX.ALIGN_BOTTOM,		parallaxY=0.68,		repeatY=false})
	bg7		= paralX.create ({image=bg7Img,		parallaxX=0.7,		speedX=-0.7, 		alignY = paralX.ALIGN_BOTTOM,		parallaxY=0.7,		repeatY=false})
	bg8		= paralX.create ({image=bg8Img,		parallaxX=0.8,		speedX=-1.0, 		alignY = paralX.ALIGN_BOTTOM,		parallaxY=0.8,		repeatY=false})
	bg9		= paralX.create ({image=bg9Img,		parallaxX=0.9,		speedX=-1.3,		priority=-4, 		alignY = paralX.ALIGN_BOTTOM,		parallaxY=1,		repeatY=false})
	
	--Filter to Mario.
	player.character = 1
end

function onCameraUpdate()
	if  player.section == 0  then
		leafEmitter:Draw(1);
	end
end