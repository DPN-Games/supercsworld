--***************************************************************************************
--                                                                                      *
-- 	console.lua                                                                         *
--  v1.0                                                                                *
--  Documentation: http://wohlsoft.ru/pgewiki/console.lua                               *
--                                                                                      *
--***************************************************************************************

local graphx2 = API.load("graphx2")
local textblox = API.load("textblox")

local console = {}

function console.onInitAPI()
	registerEvent(console, "onKeyboardPress", "onKeyboardPress", true)
	registerEvent(console, "onCameraUpdate", "onCameraUpdate", true)
end

console.active = false
console.log = {"Hey there! Type a command and press enter to activate it. Type /h for a list of commands."}
console.inputString = "hashtag yoloswag"


function console.print(str)
	table.insert(console.log, 1, str)
end

function console.onKeyboardPress(vk)
	--windowDebug ("sup dawg")
	local clearBuffer = true
	
	-- If the console is active...
	if  console.active  then
	
		-- Disable the console if tab is pressed
		if  vk == VK_TAB  then		
			--Misc.unpause ()
			console.active = false
		
		-- Otherwise, if enter, send the command to the cheat buffer
		elseif  vk == VK_RETURN  then
			clearBuffer = false
			Misc.cheatBuffer(console.inputString)
			console.print (console.inputString)
			console.inputString = ""
		
		-- Otherwise, if backspace, remove the latest character
		elseif  vk == VK_BACK  then
			if  string.len (console.inputString) > 0  then
				console.inputString = string.sub(console.inputString, 1, -2)
			end
		
		-- Otherwise, add the character pressed to the input string
		else
			console.inputString = console.inputString..string.sub(Misc.cheatBuffer(), -1)
		end

		-- Clear the cheat buffer
		if  clearBuffer  then  Misc.cheatBuffer("");  end;
		
		
	-- If the console is inactive...
	else
		-- Enable the console if tab is pressed
		if  vk == VK_TAB  then
			--Misc.pause ()
			console.active = true
		end
	end
end

function console.onCameraUpdate (eventObj, cameraIndex)
	if  console.active  then		
		-- Dim the screen
		graphx2.box{x=0,y=0,w=800,h=600, z=3, color=0x00000099, isSceneCoords=false}
		-- Draw the bottom bar
		graphx2.box{x=0,y=580,w=800,h=25, z=3, color=0x00000099, isSceneCoords=false}
		
		-- Print the current text
		textblox.printExt (console.inputString, {x=10,y=600,z=4, valign=textblox.ALIGN_BOTTOM, bind=textblox.BIND_SCREEN, font=textblox.FONT_SPRITEDEFAULT4X2})
		
		-- Print the previous log entries
		for  k,v  in ipairs(console.log)  do
			textblox.printExt (v, {x=10,y=600-25*k,z=4, valign=textblox.ALIGN_BOTTOM, bind=textblox.BIND_SCREEN, font=textblox.FONT_SPRITEDEFAULT4X2, color=0xAAAAAAFF})
		end
	end
end

return console