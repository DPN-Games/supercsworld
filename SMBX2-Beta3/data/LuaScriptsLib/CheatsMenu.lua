local __title = "SMBX Test Menu Navigator";
local __version = "0.8.1";
local __description = "Cheats Menu Test";
local __author = "Lotus006";
local __url = "https://github.com/";


local CheatsMenu_API = {} --instance


local resPath = getSMBXPath() .. "\\LuaScriptsLib\\CheatsMenu"; --res path

local CheatMenuAct = 1
local SlotChangeY = 1

-- visual menu , 1 or true for activate !! -- 

local Gact = 0
local debugMenuText = 0
local debugMenuText2 = 0
local SliderMenuElements = false
local TextCheatsBuffer = false

---------------------------------------------

local MusicSoundTestTab = 0
local TabMenuElements = false


local TurnEnemy = "Coins"
local GodMode = "OFF"
local InfJump = "OFF"
local SetLives = 10

local ButtonR = 0
local ButtonL = 0

local Selbutton = Graphics.loadImage(resPath .. "\\Selbutton.png"); -- Stuff
local UnSelbutton = Graphics.loadImage(resPath .. "\\UnSelbutton.png"); -- Stuff

local SelArrow = Graphics.loadImage(resPath .. "\\SelArrow.png"); -- Stuff
local SelArrow2 = Graphics.loadImage(resPath .. "\\SelArrow2.png"); -- Stuff  

local UnSelectable = Graphics.loadImage(resPath .. "\\UnSelectable.png"); -- Stuff


local UnSelRectangle = Graphics.loadImage(resPath .. "\\UnSelRectangle.png"); -- Stuff

local SelRectangle = Graphics.loadImage(resPath .. "\\SelRectangle.png"); -- Stuff



local UnSelTopRect = Graphics.loadImage(resPath .. "\\UnSelTopRect.png"); -- Stuff
local SelTopRect = Graphics.loadImage(resPath .. "\\SelTopRect.png"); -- Stuff



-- local CheatsMenu = Graphics.loadImage(resPath .. "\\CheatsMenu.png");  
local CheatsMenuMain = Graphics.loadImage(resPath .. "\\CheatsMenuMain.png");  
local CheatsMenuValueRight = Graphics.loadImage(resPath .. "\\CheatsMenuValueRight.png");  
local CheatsMenuClose = Graphics.loadImage(resPath .. "\\CheatsMenuClose.png");  
local DebugMe1 = Graphics.loadImage(resPath .. "\\DebugMe1.png");  





local CheatsMenuTextBuffer = Graphics.loadImage(resPath .. "\\CheatsMenuTextBuffer.png");  
local CheatsMenuTextBuffer1 = Graphics.loadImage(resPath .. "\\CheatsMenuTextBuffer.png");  

local AddY2 = 10

local PosYArrow = 0 + AddY2
local chkReserveBox = 0
local MoveValueX = 0
local firstrun = 1

local SecAmountA = 0
local SecondsLeft = SecAmountA
local SecTickA = 0


local SecAmountB = 0
local SecondsRight = SecAmountB
local SecTickB = 0

local playstar1music = 0
local StarmanSound = Audio.SfxOpen(resPath .. "\\star1.wav");

function PlaneFlyOut()
        --Stop playing loop in 1'st channel with fade-out in 2 sec.
	Audio.SfxFadeOut(1, 2000);
end


function SecondCDown(SecondA)

SecondsLeft = SecondsLeft - SecondA

	if (SecondsLeft <= 0) then
		SecondsLeft = 0

	end

end


local GAmountA = 0
local MenuX = GAmountA
local GTickA = 0


function GoLeft(MoveValueX)

	if MoveValueX > 0 then
	
	 	
		MenuX = MenuX + 10

		if (MenuX >= MoveValueX) then
		MenuX = MoveValueX
		end
		elseif MoveValueX < 0 then
			MenuX = MenuX - 10

		if (MenuX <= MoveValueX) then
			MenuX = MoveValueX
		end	
			
		
		end
	end


function SecondCDownB(SecondB)

SecondsRight = SecondsRight - SecondB

	if (SecondsRight <= 0) then
		SecondsRight = 0

	end

end


function onKeyDown(keyCode)
    if keyCode == KEY_UP and SlotChangeY <= 4 then
        SlotChangeY = SlotChangeY + 0.23

    end
    if keyCode == KEY_DOWN and SlotChangeY >= 1 then
       SlotChangeY = SlotChangeY - 0.23

    end
	
	
	
   
end



 function CheatsMenu_API.onInitAPI()
   

    registerEvent(CheatsMenu_API, "onLoop", "onLoopOverride");
    registerEvent(CheatsMenu_API, "onLoad", "onLoadOverride");
    registerEvent(CheatsMenu_API, "onInputUpdate", "onInputUpdateOverride");

	

	
if (firstrun == 1) and Gact == 0 then
 MenuX = -440	
 
 
 firstrun = 0
 else
 
 end
	


end



function CheatsMenu_API.onLoopOverride()

AddY = 28
AddX = 10
SecondCDown(SecTickA)
SecondCDownB(SecTickB)



if (CheatMenuAct == 1) then



 if(getInput().str:find("n"))then
  
 
if (MenuX <= -440) then	
 Gact = 1
 else
 
 end
   
 Misc.cheatBuffer("")  --Clear the cheat buffer
  end
  
  
  
  
  if(getInput().str:find("debugme1"))  then

 if   debugMenuText == 1 then
 
  debugMenuText = 0
 Misc.cheatBuffer("")  --Clear the cheat buffer
 else
  
 debugMenuText = 1
 Misc.cheatBuffer("")  --Clear the cheat buffer
 
 end

end 
 
  if(getInput().str:find("debugme2"))  then

 if   debugMenuText2 == 1 then
 
  debugMenuText2 = 0
 Misc.cheatBuffer("")  --Clear the cheat buffer
 else
  
 debugMenuText2 = 1
 Misc.cheatBuffer("")  --Clear the cheat buffer
 
 end

end



    if(getInput().str:find("textme"))  then

 if   TextCheatsBuffer == true then
 
  TextCheatsBuffer = false
 Misc.cheatBuffer("")  --Clear the cheat buffer
 else
  
 TextCheatsBuffer = true
 Misc.cheatBuffer("")  --Clear the cheat buffer
 
 end

end 
   
 -- Graphics.drawImage(CheatsMenu, MenuX + 40 , 35 + AddY2);
  Graphics.drawImage(CheatsMenuMain, MenuX + 43 , 68 + AddY2);
  Graphics.drawImage(CheatsMenuValueRight, MenuX + 276 , 68 + AddY2);
  Graphics.drawImage(CheatsMenuClose, MenuX + 43 , 227.4 + AddY2);
  
  
if (TextCheatsBuffer) then
  Graphics.drawImage(CheatsMenuTextBuffer,   40 , 500  );
  else
  end
 
 Graphics.drawImage(SelArrow , MenuX + 57 , 86 + PosYArrow);
 -- Graphics.drawImage(SelArrow2, MenuX + 56  , 86 + AddY2 + PosYArrow);


 
 if (TabMenuElements) then 
  Text.print("CHEATS"  , MenuX + 41.6 + 14   , 12.7 + AddY2 + AddY   )
 else
 
 end
 
 if (MusicSoundTestTab == 1) then 
 Text.print("MUSICS"  ,MenuX + 188 , 12.7 + AddY2 + AddY  )
 else
 end
 
 -- Text.print("3"  ,240+ 14, 42  )
 -- Text.print("4"  ,333+ 14, 42  )

 PosXI = 9
 
 Text.print("Turn Enemy"  , MenuX + 70  + AddX , 59 + AddY2 + AddY )
 
 if (TurnEnemy == "Ice") then
 Text.print(TurnEnemy  , MenuX + 295 + 18 + PosXI  , 59 + AddY2 + AddY )

 
 else
 Text.print(TurnEnemy  ,MenuX + 295  + PosXI , 59 + AddY2 + AddY )
 end
 
 Text.print("GOD MODE"  , MenuX + 70  + AddX, 93 + AddY2 + AddY )

if (GodMode == "OFF") then
 Text.print( GodMode  ,MenuX + 312  + PosXI , 93 + AddY2 + AddY )
 else
 Text.print( "On"  ,MenuX + 320  + PosXI , 93 + AddY2 + AddY )
 end

 Text.print("Multi Jmp"  ,MenuX + 70   + AddX, 93 + 32 + AddY2 + AddY ) 
 
 if (InfJump == "OFF") then
 Text.print(InfJump  ,MenuX + 312 + PosXI  , 93 + 32 + AddY2 + AddY )
 else
 Text.print("ON"  ,MenuX + 320  + PosXI , 93 + 32 + AddY2 + AddY )
 end

 Text.print("Set Lives"  ,MenuX + 70   + AddX, 93 + 64 + AddY2 + AddY )

if (SetLives <= 9) then

 Text.print("0" .. SetLives  , MenuX + 320 + PosXI , 93 + 64 + AddY2 + AddY)
 else
  Text.print( SetLives  ,MenuX + 320  + PosXI , 93 + 64 + AddY2 + AddY)
end

  
 
 if (debugMenuText == 1) then
 

 
 DMoveX = 333
 DMoveY = -80
 
   Graphics.drawImage(DebugMe1,  507 , 238 + AddY2);
  
 Text.print("Debug Button"    ,  200.5 + DMoveX  , 330 + AddY2 + DMoveY)
 
 Text.print("SltChangeY:" .. math.ceil(SlotChangeY)  , 198 + DMoveX  , 361 + AddY2 + DMoveY)
 Text.print(  "Sec L:" ..  math.floor(SecondsLeft) ,  290  + DMoveX, 382 + AddY2 + DMoveY) 
 Text.print(  "Sec R:" ..  math.floor(SecondsRight) , 290 + DMoveX  , 405 + AddY2 + DMoveY) 
 
 
 Text.print(  "ButtonL:" ..  ButtonL , 251.7 + DMoveX  , 428 + AddY2 + DMoveY) 
 Text.print(  "ButtonR:" ..  ButtonR ,  251.7 + DMoveX , 452 + AddY2 + DMoveY) 
 Text.print(  "Starmusic:" ..  playstar1music , 213.7 + DMoveX , 475 + AddY2 + DMoveY) 

 else
 end
 
 if (debugMenuText2 == 1) then



 
  DMoveX2 = 361.8
 DMoveY2 = -440
 
 
 Text.print(  "MenuX:"  .. MenuX  , 270 + DMoveX2, 498 + DMoveY2) 
 Text.print(  "Gact:"  .. Gact  , 290 + DMoveX2, 518 + DMoveY2) 

--  Text.print(  "Collision:"  .. player:mem(0x11C, FIELD_WORD)  , 200 + DMoveX2, 538 + DMoveY2) 
 Text.print(  "Collision:"  .. player:mem(0x4A, FIELD_WORD)  , 200 + DMoveX2, 538 + DMoveY2) 
 else
 
end
 
if (TabMenuElements) then
 Graphics.drawImage(UnSelTopRect, MenuX + 39.7 , 30 + AddY2); -- Top Menu UnSelTopRect
else
end
 
 if (MusicSoundTestTab == 1) then 
 Graphics.drawImage(UnSelTopRect, MenuX +  173 , 30 + AddY2); -- Top Menu UnSelTopRect
 else
 end
 -- Graphics.drawImage(UnSelTopRect,  MenuX + 220  , 35); -- Top Menu UnSelTopRect
 
-- Graphics.drawImage(UnSelTopRect,  MenuX + 309  , 35); -- Top Menu UnSelTopRect
 
if (chkReserveBox == 1) then
 --  Graphics.drawImage(Selbutton, MenuX +  322  , 260 + AddY2 );
else

-- raphics.drawImage(UnSelbutton,  MenuX + 322 , 260 + AddY2 );
 end
 
 
-- Text.print("Reserve box"  , MenuX + 80 , 241 + AddY + AddY2 )
 Text.print("CLOSE MENU"  , MenuX + 92 , 217 + AddY  + AddY2)
 


------------------------------------------------
  if (math.ceil(SlotChangeY) == 6) then
------------------------------------------------  
 
 
 
 
 
------------------------------------------------  
elseif (math.ceil(SlotChangeY) == 5) then
------------------------------------------------
PosYArrow = 10.6 

  if (ButtonR == 1)   then
  TurnEnemy = "Coins"
  

  
  end
  
  
if (ButtonL == 1)   then 
TurnEnemy = "Ice"
  end
 
 
 
 ------------------------------------------------
 elseif  (math.ceil(SlotChangeY) == 4) then
 ------------------------------------------------
PosYArrow = 44.5
 

 
 
 if (ButtonR == 1) then
 GodMode = "OFF"
 


 elseif (ButtonL == 1) then
 GodMode = "ON"

 end
 

  	if (playstar1music == 1) and (math.ceil(SlotChangeY) == 4) then
	ButtonL = 0
	end 		

 

 
 if (GodMode == "ON")   then 



 
playstar1music = 1  

		player:mem (0x02, FIELD_WORD, -1)
		-- player:mem (0x140, FIELD_WORD, -1)
		  --player:mem (0x142, FIELD_WORD, 1)
	 	mem(0x00B2C8C0,  FIELD_WORD, 0xFFFF)  
			

end

if (GodMode == "OFF") then

		SecAmountA = 7
		SecTickA = 0.4

			playstar1music = 0 
			-- player:mem (0x140, FIELD_WORD, 0)
			mem(0x00B2C8C0,  FIELD_WORD, 0)
			player:mem (0x02, FIELD_WORD, 0)
	Audio.SfxStop(1)


   
end
   
 

 ------------------------------------------------
  elseif  (math.ceil(SlotChangeY) == 3) then
 ------------------------------------------------
PosYArrow = 76

  if (ButtonR == 1)   then
 InfJump = "OFF"
 elseif (ButtonL == 1)   then
 InfJump = "ON"
 end
 


 
------------------------------------------------
 elseif  (math.ceil(SlotChangeY) == 2) then
------------------------------------------------
PosYArrow = 109.3
 
  if (player.jumpKeyPressing) then
 mem(0x00B2C5AC, FIELD_FLOAT, SetLives)

-- Animation.spawn(SetLives,player.x, player.y)
 -- player.jumpKeyPressing = false;
 end
 
  if (ButtonR == 1)   then
  
 if (SetLives >= 99) then
 
 else
 SetLives = SetLives + 1
 

 
 
end

 elseif (ButtonL == 1)   then 

 if (SetLives <= 1) then
 else
 
 SetLives = SetLives - 1
end




 end
------------------------------------------------
 elseif  (math.ceil(SlotChangeY) == 1) then
------------------------------------------------ 
 PosYArrow = 168.5

	if (Gact == 1) and (player.jumpKeyPressing)  then
		Gact = 0
	end
	
 
 
 
 
------------------------------------------------ 
  elseif  (math.ceil(SlotChangeY) == 0) then
------------------------------------------------
 -- PosYArrow = 233


  
 --[[
 if (chkReserveBox == 1) then
 chked = "Chked"
 player.reservePowerup = 1
 else 
 player.reservePowerup = 0
 chked = ""
 end
 

  if ( player.jumpKeyPressing ) and (SecondsRight <= 0) and (chkReserveBox == 0) then 
 SecAmountB = 2
	SecTickB = 0.4
 chkReserveBox = 1
    Text.print(  "ButtonR Slot5:" .. tostring(chked) , 153.6, 475) 
  SecondsRight = SecAmountB
 elseif ( player.jumpKeyPressing ) and (SecondsRight <= 0) and (chkReserveBox == 1) then 
   SecAmountB = 2
	SecTickB = 0.4
  
  chkReserveBox = 0
   Text.print(  "ButtonR Slot5:"  , 153.6, 475) 
 

 SecondsRight = SecAmountB 

  
 end
 
   ]]-- 
------------------------------------------------ 
------------------------------------------------ 
------------------------------------------------ 
------------------------------------------------ 
 
end


  
 
if (Gact == 0) then

 GoLeft(-440)

  -- SlotChangeY = 5

  elseif (Gact == 1) then
  
  GoLeft( 1 )
  
end
 


	


	
--	 Graphics.drawImage(UnSelectable, MenuX + 22 , 255 + AddY2);
	
else	
	
end


if (SliderMenuElements) then
 Text.print(  "50"   , MenuX + 242, 305) 
 else
 end
 

   if (TextCheatsBuffer) then
 Text.print(  Misc.cheatBuffer()  , 143 , 518)
Text.printWP( "Text: "  , 52 , 518 , 1)
  else
  end

 
 if (math.ceil(SlotChangeY) == 4) and (ButtonL == 1)  then
		

SecAmountA = 15
		SecTickA = 0.4

			SecondsLeft = SecAmountA 
 
  
		-- Audio.SfxPlayCh(1, StarmanSound, -1);
	
if  (SecondsLeft >= 5)  then
	Audio.SfxPlayCh(1, StarmanSound, -1);

	
end	
 
 end


end


function CheatsMenu_API.onInputUpdateOverride()




  if (InfJump == "ON") then 

 --  player:mem(0x11C, FIELD_WORD , 1)
Defines.cheat_ahippinandahoppin = true
 elseif (InfJump == "OFF") then 
  -- player:mem(0x11C, FIELD_WORD , -1)
  Defines.cheat_ahippinandahoppin = false
 end


if (Gact == 1) then





if (CheatMenuAct == 1) then





if (player.upKeyPressing)  then


player.upKeyPressing = false;

onKeyDown(KEY_UP)

end


if (player.downKeyPressing)  then
player.downKeyPressing = false;

onKeyDown(KEY_DOWN)
end
 
 
 ------------------------------------------
 
 
if (player.rightKeyPressing)  and  (SecondsRight <= 0) then


	SecAmountB = 4

		SecTickB = 0.7


	


SecondsRight = SecAmountB
	
		ButtonR = 1
player.rightKeyPressing = false;		
		else
		
		 ButtonR = 0
		 

player.rightKeyPressing = false;
end
 
 

 
if (player.leftKeyPressing) and  (SecondsLeft <= 0) then

	SecAmountA = 4

		SecTickA = 0.7
	SecondsLeft = SecAmountA
 
		ButtonL = 1
player.leftKeyPressing = false;		
		else
	
		
		 ButtonL = 0


player.leftKeyPressing = false;	
end



if (player.jumpKeyPressing)  then

Animation.spawn(12,player.x, player.y)

  if (TurnEnemy == "Ice") and  (math.ceil(SlotChangeY) == 5)   then
	
	for k, v in pairs(NPC.get()) do


 v:toIce()
 Gact = 0 
		end
	end

	
	if (TurnEnemy ~= "Ice") and  (math.ceil(SlotChangeY) == 5)   then
	
		for k, v in pairs(NPC.get()) do


		v:toCoin()
  Gact = 0
		end
		
		
	
	end
end


else

end


else

end




end
return CheatsMenu_API