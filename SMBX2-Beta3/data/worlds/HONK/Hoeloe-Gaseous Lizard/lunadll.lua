local snake = API.load("snake")
local vision = API.load("visioncone");
local pnpc = API.load("pnpc");
local vectr = API.load("vectr");
local colliders = API.load("colliders");
local eventu = API.load("eventu");
local pm = API.load("playerManager");

function onStart()
	player.character = CHARACTER_SNAKE;
	--Audio.MusicOpen("InnocentDeception.ogg");
	--Audio.MusicPlay();
end

local cameras = {};
local movingCameras = {}
local exclamations = {}
local G_VISION = Graphics.loadImage(Misc.resolveFile("vision_light.png"))

local drawConeQueue = {};
local doorLayer = Layer(3);
doorLayer:hide(true);
local Layer_MovingWall1 = Layer(4);
local MovingWall1Timer;
local Layer_MovingWall2 = Layer(5);
local MovingWall2Timer;
local Layer_MovingWall3 = Layer(6);
local MovingWall3Timer;

--UNUSED
local function DrawCamera(cone)
	table.insert(drawConeQueue,cone);
end


--Eventu-based layer movement setup
local function PauseLayerEvents()
		if(player:mem(0x122,FIELD_WORD) == 0 or player:mem(0x122,FIELD_WORD) == 7 or player:mem(0x122,FIELD_WORD) == 500) then
			if(MovingWall1Timer ~= nil) then eventu.resumeTimer(MovingWall1Timer) end;
			if(MovingWall2Timer ~= nil) then eventu.resumeTimer(MovingWall2Timer) end;
			if(MovingWall3Timer ~= nil) then eventu.resumeTimer(MovingWall3Timer) end;
		else
			if(MovingWall1Timer ~= nil) then eventu.pauseTimer(MovingWall1Timer) end;
			if(MovingWall2Timer ~= nil) then eventu.pauseTimer(MovingWall2Timer) end;
			if(MovingWall3Timer ~= nil) then eventu.pauseTimer(MovingWall3Timer) end;
		end
end

--More layer movement
function onLoadSection1()
	if(MovingWall1Timer == nil) then
		Layer_MovingWall1.speedY = -1;
		MovingWall1Timer = eventu.setFrameTimer(4*(32/math.abs(Layer_MovingWall1.speedY)), 
				function()
					Layer_MovingWall1.speedY = -Layer_MovingWall1.speedY;
				end, true);
	end
end

--More layer movement
function onLoadSection2()
	if(MovingWall2Timer == nil) then
		Layer_MovingWall2.speedY = -1;
		MovingWall2Timer = eventu.setFrameTimer(16*(32/math.abs(Layer_MovingWall2.speedY)), 
				function()
					Layer_MovingWall2.speedY = -Layer_MovingWall2.speedY;
				end, true);
	end
	if(MovingWall3Timer == nil) then
		Layer_MovingWall3.speedY = -1;
		MovingWall3Timer = eventu.setFrameTimer(16*(32/math.abs(Layer_MovingWall3.speedY)), 
				function()
					Layer_MovingWall3.speedY = -Layer_MovingWall3.speedY;
				end, true);
	end
end

function onTick()
	--Control alertness doors
	if(snake.alertTimer > 0 and doorLayer.isHidden) then
		doorLayer:show(false);
	elseif(snake.alertTimer <= 0 and not doorLayer.isHidden) then
		doorLayer:hide(false);
	end
	
	--Custom exclamations for the camera objects
	if(snake.alertTimer <= 0) then
		exclamations = {};
	end
	
	--Create vision cones for static cameras
	for k,v in ipairs(NPC.get(158,player.section)) do
		local n = pnpc.wrap(v);
		n.friendly = true;
		if(cameras[n.uid] == nil) then
			cameras[n.uid] = vision.VisionCone(n.x+n.width/2 + (n.direction*n.width/2),n.y+n.height,(vectr.up2):rotate(-45)*vectr.v2(n.direction,1)*512,45);	
			cameras[n.uid].static = true;
			cameras[n.uid]:AddStatic("Default");
		end
	end
	
	--Create vision cones for moving cameras
	for k,v in ipairs(NPC.get(104,player.section)) do
		local n = pnpc.wrap(v);
		n.friendly = true;
		if(movingCameras[n.uid] == nil) then
			movingCameras[n.uid] = {npc = n, cone = vision.VisionCone(n.x+n.width/2,n.y+n.height,(vectr.up2)*512,45)};
		end
	end
	
	--Test static cameras, creating custom exclamation objects
	for k,v in pairs(cameras) do
		--DrawCamera(v);
		if(v:Check(player,v.fov/4,colliders.BLOCK_SOLID,true) and snake.canAlert()) then
			if(exclamations[k] == nil) then
				exclamations[k] = {t=65,x=v.x,y=v.y-64};
				Audio.playSFX(Misc.resolveFile("alert.ogg"))
				snake.alert(vectr.v2(v.x,v.y),1);
			end
			snake.alertTimer=snake.alertCooldown;
		end
	end
	
	--Test moving cameras, creating custom exclamation objects
	for k,v in pairs(movingCameras) do
		if(v.npc.isValid) then
			v.cone.x = v.npc.x+v.npc.width/2+32;
			v.cone.y = v.npc.y+v.npc.height;
			--DrawCamera(v.cone);
			if(v.cone:Check(player,v.cone.fov/8,colliders.BLOCK_SOLID,true) and snake.canAlert()) then
				if(exclamations[k] == nil) then
					exclamations[k] = {t=65,npc = v.npc, x_off = 32, y_off = -32};
					Audio.playSFX(Misc.resolveFile("alert.ogg"))
					snake.alert(v.npc,1);
				end
				snake.alertTimer=snake.alertCooldown;
			end
		else
			movingCameras[k] = nil;
		end
	end
	
	--Update custom exclamation objects
	for k,v in pairs(exclamations) do
		if(v.t > 0) then
			v.t = v.t-1;
			if(v.npc ~= nil) then
				v.x = v.npc.x+v.x_off;
				v.y = v.npc.y+v.y_off;
			end
			Graphics.drawImageToSceneWP(pm.getGraphic(CHARACTER_SNAKE, snake.EXCLAMATION), v.x, v.y, -45);
		end			
	end
	
	--Pause moving layer timers when moving layers pause
	PauseLayerEvents();
end

local function getScreenBounds()
	local c = Camera.get()[1];
	local b = {left = c.x, right = c.x + 800, top = c.y, bottom = c.y+600};
	return b;
	
end

local function worldToScreen(x,y)
			local b = getScreenBounds();
			local x1 = x-b.left;
			local y1 = y-b.top;
			return x1,y1;
end

function onEvent(event)
	if(event == "Press Switch") then
			Defines.earthquake = 6;
	end
end

--UNUSED (drawConeQueue is always empty)
function onHUDDraw()
	for k,v in ipairs(drawConeQueue) do
		local pts = {};
		local p1 = v.collider:Get(3);
		local p2 = v.collider:Get(2);
		local p3 = v.collider:Get(1);
		
		p1[1],p1[2] = worldToScreen(p1[1],p1[2]);
		p2[1],p2[2] = worldToScreen(p2[1],p2[2]);
		p3[1],p3[2] = worldToScreen(p3[1],p3[2]);
		
		pts[0] = p1[1]; pts[1]=p1[2];
		pts[2] = p2[1]; pts[3]=p2[2];
		pts[4] = vectr.lerp(p2[1],p3[1],0.5); pts[5]=vectr.lerp(p2[2],p3[2],0.5);
		pts[6] = p1[1]; pts[7]=p1[2];
		pts[8] = pts[4]; pts[9] = pts[5]
		pts[10] = p3[1]; pts[11]=p3[2];
		
		local tx = {};
		tx[0] = 1; tx[1] = 0;
		tx[2] = 0; tx[3] = 0;
		tx[4] = 0; tx[5] = 0.5;
		tx[6] = 1; tx[7] = 1;
		tx[8] = 0; tx[9] = 0.5;
		tx[10] = 0; tx[11] = 1;
		
		Graphics.glDraw{vertexCoords = pts, textureCoords = tx, primitive=Graphics.GL_TRIANGLES, texture = G_VISION, priority = -45}
		
		drawConeQueue[k] = nil;
	end
end