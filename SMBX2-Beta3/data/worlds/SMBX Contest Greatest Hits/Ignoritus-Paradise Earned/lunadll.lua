
NPCID = loadSharedAPI("npcid")
triggers = loadAPI("triggers");

--hi
function onStart()
	player.character = 4;
end

--***************************************************************************************
--                                                                                      *
-- CONSTANTS AND ENUMS																	*
--                                                                                      *
--***************************************************************************************
do
	if(UserData.getValue("ignoritus_rubies") == nil) then UserData.setValue("ignoritus_rubies", 0) end
	if(UserData.getValue("ignoritus_sapphires") == nil) then UserData.setValue("ignoritus_sapphires", 0) end
	
	if(UserData.getValue("ignoritus_entry") == nil) then UserData.setValue("ignoritus_entry", 0) end
	
	if(UserData.getValue("ignoritus_ruby1") == nil) then UserData.setValue("ignoritus_ruby1", 0) end
	if(UserData.getValue("ignoritus_ruby2") == nil) then UserData.setValue("ignoritus_ruby2", 0) end
	if(UserData.getValue("ignoritus_ruby3") == nil) then UserData.setValue("ignoritus_ruby3", 0) end
	if(UserData.getValue("ignoritus_ruby4") == nil) then UserData.setValue("ignoritus_ruby4", 0) end
	if(UserData.getValue("ignoritus_ruby5") == nil) then UserData.setValue("ignoritus_ruby5", 0) end
	if(UserData.getValue("ignoritus_ruby6") == nil) then UserData.setValue("ignoritus_ruby6", 0) end
	if(UserData.getValue("ignoritus_sapp1") == nil) then UserData.setValue("ignoritus_sapp1", 0) end
	if(UserData.getValue("ignoritus_sapp2") == nil) then UserData.setValue("ignoritus_sapp2", 0) end
	if(UserData.getValue("ignoritus_sapp3") == nil) then UserData.setValue("ignoritus_sapp3", 0) end
	if(UserData.getValue("ignoritus_sapp4") == nil) then UserData.setValue("ignoritus_sapp4", 0) end
	if(UserData.getValue("ignoritus_sapp5") == nil) then UserData.setValue("ignoritus_sapp5", 0) end
	if(UserData.getValue("ignoritus_sapp6") == nil) then UserData.setValue("ignoritus_sapp6", 0) end
	
	trigs = {}
	trigs[0] = triggers.Trigger(-203232,-200608,
                            function()
								UserData.setValue("ignoritus_rubies", UserData.getValue("ignoritus_rubies")+1)
                                UserData.setValue("ignoritus_ruby1", 1)
								UserData.save()
                            end,
                            "Ruby1TriggerHide");
	trigs[1] = triggers.Trigger(-203232,-200576,
                            function()
                                UserData.setValue("ignoritus_rubies", UserData.getValue("ignoritus_rubies")+1)
                                UserData.setValue("ignoritus_ruby2", 1)
								UserData.save()
                            end,
                            "Ruby2TriggerHide");
	trigs[2] = triggers.Trigger(-203232,-200544,
                            function()
                                UserData.setValue("ignoritus_rubies", UserData.getValue("ignoritus_rubies")+1)
                                UserData.setValue("ignoritus_ruby3", 1)
								UserData.save()
                            end,
                            "Ruby3TriggerHide");
	trigs[3] = triggers.Trigger(-203232,-200512,
                            function()
                                UserData.setValue("ignoritus_rubies", UserData.getValue("ignoritus_rubies")+1)
                                UserData.setValue("ignoritus_ruby4", 1)
								UserData.save()
                            end,
                            "Ruby4TriggerHide");
	trigs[4] = triggers.Trigger(-203232,-200480,
                            function()
                                UserData.setValue("ignoritus_rubies", UserData.getValue("ignoritus_rubies")+1)
                                UserData.setValue("ignoritus_ruby5", 1)
								UserData.save()
                            end,
                            "Ruby5TriggerHide");
	trigs[5] = triggers.Trigger(-203232,-200448,
                            function()
                                UserData.setValue("ignoritus_rubies", UserData.getValue("ignoritus_rubies")+1)
                                UserData.setValue("ignoritus_ruby6", 1)
								UserData.save()
                            end,
                            "Ruby6TriggerHide");
				

				
	trigs[6] = triggers.Trigger(-203232,-200384,
                            function()
								UserData.setValue("ignoritus_sapphires", UserData.getValue("ignoritus_sapphires")+1)
                                UserData.setValue("ignoritus_sapp1", 1)
								UserData.save()
                            end,
                            "Sapp1TriggerHide");
	trigs[7] = triggers.Trigger(-203232,-200352,
                            function()
                                UserData.setValue("ignoritus_sapphires", UserData.getValue("ignoritus_sapphires")+1)
                                UserData.setValue("ignoritus_sapp2", 1)
								UserData.save()
                            end,
                            "Sapp2TriggerHide");
	trigs[8] = triggers.Trigger(-203232,-200320,
                            function()
                                UserData.setValue("ignoritus_sapphires", UserData.getValue("ignoritus_sapphires")+1)
                                UserData.setValue("ignoritus_sapp3", 1)
								UserData.save()
                            end,
                            "Sapp3TriggerHide");
	trigs[9] = triggers.Trigger(-203232,-200288,
                            function()
                                UserData.setValue("ignoritus_sapphires", UserData.getValue("ignoritus_sapphires")+1)
                                UserData.setValue("ignoritus_sapp4", 1)
								UserData.save()
                            end,
                            "Sapp4TriggerHide");
	trigs[10] = triggers.Trigger(-203232,-200256,
                            function()
                                UserData.setValue("ignoritus_sapphires", UserData.getValue("ignoritus_sapphires")+1)
                                UserData.setValue("ignoritus_sapp5", 1)
								UserData.save()
                            end,
                            "Sapp5TriggerHide");
	trigs[11] = triggers.Trigger(-203232,-200224,
                            function()
                                UserData.setValue("ignoritus_sapphires", UserData.getValue("ignoritus_sapphires")+1)
                                UserData.setValue("ignoritus_sapp6", 1)
								UserData.save()
                            end,
                            "Sapp6TriggerHide");

							
	Room = {}
	function Room:new(left,right,top,bottom)
		local room = {}
		room.left = left*800-200000
		room.right = right*800-200000
		room.top = top*608-200608
		room.bottom = bottom*608-200608
		
		room.leftEx = nil
		room.rightEx = nil
		room.topEx = nil
		room.botEx = nil
		
		room.entranceEvent = nil
		
		function room:linkLeft(leftEx)
			room.leftEx = leftEx
		end	
		
		function room:linkRight(rightEx)
			room.rightEx = rightEx
		end	
		
		function room:linkTop(topEx)
			room.topEx = topEx
		end	
		
		function room:linkBot(botEx)
			room.botEx = botEx
		end	
		
		function room:setEntranceEvent(event)
			room.entranceEvent = event
		end
		
	return room
	end

	roomStart = Room:new(0, 1, 0, 1)

	
	roomEndOne = Room:new(0,1,-1,0)
	roomEndOne:setEntranceEvent("Heat")
	roomEndTwo = Room:new(0,2,-2,-1)
	roomEndTwo:setEntranceEvent("Heaven")	
	roomEndThree = Room:new(0,1,-3,-2)	
	------------------------
	--ICE ROOMS INITIATION--
	------------------------
	--Row 1--
	roomIceOne = Room:new(1, 2, 0, 1)
	roomIceOne:setEntranceEvent("Cryo")
	roomIceTwo = Room:new(2, 4, 0, 1)
	roomIceThree = Room:new(4, 5, 0, 1)
	
	--Row 2--
	roomIceFour = Room:new(4, 5, 1, 2)
	roomIceFive = Room:new(3, 4, 1, 2)
	roomIceSix = Room:new(2, 3, 1, 2)
	roomIceSeven = Room:new(1, 2, 1, 2)
	roomIceSeven:setEntranceEvent("Cryo")

	--Row 3--
	roomIceEight = Room:new(3, 5, 2, 3)
	roomIceNine = Room:new(2, 3, 2, 3)
	roomIceTen = Room:new(1, 2, 2, 3)
	
	--Row 4--
	roomIceEleven = Room:new(2, 5, 3, 4)
	roomIceTwelve = Room:new(1, 2, 3, 4)
	roomIceThirteen = Room:new(0, 1, 3, 4)
	roomIceThirteen:setEntranceEvent("Cryo")

	--Row 5--
	roomIceFourteen = Room:new(4, 5, 4, 7)
	roomIceFifteen = Room:new(3, 4, 4, 5)
	roomIceSixteen = Room:new(2, 3, 4, 5)
	roomIceSeventeen = Room:new(1, 2, 4, 5)
	roomIceEighteen = Room:new(0, 1, 4, 5)
	roomIceEighteen:setEntranceEvent("Cryo")
	
	--Row 6--
	roomIceNineteen = Room:new(2, 4, 5, 6)
	roomIceTwenty = Room:new(1, 2, 5, 6)
	roomIceTwentyOne = Room:new(0, 1, 5, 6)
	roomIceTwentyOne:setEntranceEvent("Cryo")
	
	--Row 7--
	roomIceTwentyTwo = Room:new(1, 4, 6, 7)
	
	-------------------------
	--FIRE ROOMS INITIATION--
	-------------------------
	--Row 1--
	roomFireOne = Room:new(-1, 0, 0, 1)
	roomFireOne:setEntranceEvent("Heat")
	roomFireTwo = Room:new(-2, -1, 0, 2)
	roomFireThree = Room:new(-3, -2, 0, 1)
	roomFireFour = Room:new(-4, -3, 0, 1)
	
	--Row 2--
	roomFireFive = Room:new(-4, -3, 1, 2)
	roomFireSix = Room:new(-3, -2, 1, 2)
	roomFireSeven = Room:new(-1, 0, 1, 2)
	roomFireEight = Room:new(0, 1, 1, 2)
	roomFireEight:setEntranceEvent("Heat")
	--Row 3--
	roomFireNine = Room:new(-4, -3, 2, 3)
	roomFireTen = Room:new(-3, -2, 2, 3)
	roomFireEleven = Room:new(-2, -1, 2, 3)
	roomFireTwelve = Room:new(-1, 1, 2, 3)
	--Row 4--
	roomFireThirteen = Room:new(-4, -3, 3, 4)
	roomFireFourteen = Room:new(-3, 0, 3, 4)
	roomFireFourteen:setEntranceEvent("Heat")
	--Row 5--
	roomFireSixteen = Room:new(-4, -3, 4, 7)
	roomFireSeventeen = Room:new(-3, -2, 4, 5)
	roomFireEighteen = Room:new(-2, -1, 4, 5)
	roomFireNineteen = Room:new(-1, 0, 4, 5)
	roomFireNineteen:setEntranceEvent("Heat")
	--Row 6--
	roomFireTwenty = Room:new(-3, -2, 5, 6)
	roomFireTwentyOne = Room:new(-2, -1, 5, 6)
	roomFireTwentyTwo = Room:new(-1, 0, 5, 6)
	roomFireTwentyTwo:setEntranceEvent("Heat")
	--Row 7--
	roomFireTwentyThree = Room:new(-3, -2, 6, 7)
	roomFireTwentyFour = Room:new(-2, 1, 6, 7)
	roomFireTwentyThree:setEntranceEvent("SpringSwitch")
	
	roomStart:linkRight(roomIceOne)
	roomStart:linkLeft(roomFireOne)
	roomStart:linkTop(roomEndOne)
	roomEndOne:linkBot(roomStart)
	roomEndOne:linkTop(roomEndTwo)
	roomEndTwo:linkBot(roomEndOne)
	roomEndTwo:linkTop(roomEndThree)
	roomEndThree:linkBot(roomEndTwo)
	
	------------------------
	--  ICE ROOMS LINKING --
	------------------------
	--Row 1--
	roomIceOne:linkLeft(roomStart)
	roomIceOne:linkRight(roomIceTwo)
	roomIceTwo:linkLeft(roomIceOne)
	roomIceTwo:linkBot(roomIceFive)
	roomIceTwo:linkRight(roomIceThree)
	roomIceThree:linkLeft(roomIceTwo)
	--Row 2--
	roomIceFour:linkLeft(roomIceFive)
	roomIceFour:linkBot(roomIceEight)
	roomIceFive:linkRight(roomIceFour)
	roomIceFive:linkTop(roomIceTwo)
	roomIceFive:linkLeft(roomIceSix)
	roomIceSix:linkRight(roomIceFive)
	roomIceSix:linkBot(roomIceNine)
	roomIceSix:linkLeft(roomIceSeven)
	roomIceSeven:linkRight(roomIceSix)
	roomIceSeven:linkBot(roomIceTen)
	roomIceSeven:linkLeft(roomFireEight)
	--Row 3--
	roomIceEight:linkTop(roomIceFour)
	roomIceEight:linkLeft(roomIceNine)
	roomIceNine:linkTop(roomIceSix)
	roomIceNine:linkLeft(roomIceTen)
	roomIceNine:linkBot(roomIceEleven)
	roomIceNine:linkRight(roomIceEight)
	roomIceTen:linkRight(roomIceNine)
	roomIceTen:linkTop(roomIceSeven)
	roomIceTen:linkBot(roomIceTwelve)
	--Row 4--
	roomIceEleven:linkBot(roomIceFifteen)
	roomIceEleven:linkLeft(roomIceTwelve)
	roomIceEleven:linkTop(roomIceNine)
	roomIceTwelve:linkRight(roomIceEleven)
	roomIceTwelve:linkTop(roomIceTen)
	roomIceThirteen:linkLeft(roomFireFourteen)
	--Row 5--
	roomIceFourteen:linkLeft(roomIceFifteen)
	roomIceFifteen:linkRight(roomIceFourteen)
	roomIceFifteen:linkTop(roomIceEleven)
	roomIceFifteen:linkLeft(roomIceSixteen)
	roomIceSixteen:linkRight(roomIceFifteen)
	roomIceSixteen:linkBot(roomIceNineteen)
	roomIceSixteen:linkLeft(roomIceSeventeen)
	roomIceSeventeen:linkRight(roomIceSixteen)
	roomIceSeventeen:linkBot(roomIceTwenty)
	roomIceSeventeen:linkLeft(roomIceEighteen)
	roomIceEighteen:linkRight(roomIceSeventeen)
	roomIceEighteen:linkLeft(roomFireNineteen)
	--Row 6--
	roomIceNineteen:linkTop(roomIceSixteen)
	roomIceNineteen:linkBot(roomIceTwentyTwo)
	roomIceTwenty:linkTop(roomIceSeventeen)
	roomIceTwenty:linkLeft(roomIceTwentyOne)
	roomIceTwentyOne:linkRight(roomIceTwenty)
	roomIceTwentyOne:linkLeft(roomFireTwentyTwo)
	--Row 7--
	roomIceTwentyTwo:linkTop(roomIceNineteen)
	
	------------------------
	-- FIRE ROOMS LINKING --
	------------------------
	--Row 1--
	roomFireOne:linkRight(roomStart)
	roomFireOne:linkLeft(roomFireTwo)
	roomFireTwo:linkRight(roomFireOne)
	roomFireTwo:linkBot(roomFireEleven)
	roomFireTwo:linkLeft(roomFireThree)
	roomFireThree:linkRight(roomFireTwo)
	roomFireThree:linkLeft(roomFireFour)
	roomFireFour:linkBot(roomFireFive)
	roomFireFour:linkRight(roomFireThree)
	--Row 2--
	roomFireFive:linkRight(roomFireSix)
	roomFireFive:linkBot(roomFireNine)
	roomFireFive:linkTop(roomFireFour)
	roomFireSix:linkLeft(roomFireFive)
	roomFireSeven:linkRight(roomFireEight)
	roomFireEight:linkLeft(roomFireSeven)
	roomFireEight:linkBot(roomFireTwelve)
	roomFireEight:linkRight(roomIceSeven)
	--Row 3--
	roomFireNine:linkTop(roomFireFive)
	roomFireNine:linkRight(roomFireTen) 
	roomFireNine:linkBot(roomFireThirteen)
	roomFireTen:linkRight(roomFireEleven)
	roomFireTen:linkLeft(roomFireNine)
	roomFireTen:linkBot(roomFireFourteen)
	roomFireEleven:linkLeft(roomFireTen)
	roomFireEleven:linkRight(roomFireTwelve)
	roomFireEleven:linkTop(roomFireTwo)
	roomFireTwelve:linkLeft(roomFireEleven)
	roomFireTwelve:linkTop(roomFireEight)
	--Row 4--
	roomFireThirteen:linkTop(roomFireNine)
	roomFireThirteen:linkRight(roomFireFourteen)
	roomFireThirteen:linkBot(roomFireSixteen)
	roomFireFourteen:linkTop(roomFireTen)
	roomFireFourteen:linkLeft(roomFireThirteen)
	roomFireFourteen:linkRight(roomIceThirteen)
	roomFireFourteen:linkBot(roomFireEighteen)
	--Row 5--
	roomFireSixteen:linkTop(roomFireThirteen)
	roomFireSixteen:linkRight(roomFireTwentyThree)
	roomFireSeventeen:linkBot(roomFireTwenty)
	roomFireSeventeen:linkRight(roomFireEighteen)
	roomFireEighteen:linkLeft(roomFireSeventeen)
	roomFireEighteen:linkTop(roomFireFourteen)
	roomFireEighteen:linkRight(roomFireNineteen)
	roomFireEighteen:linkBot(roomFireTwentyOne)
	roomFireNineteen:linkLeft(roomFireEighteen)
	roomFireNineteen:linkRight(roomIceEighteen)
	--Row 6--
	roomFireTwenty:linkTop(roomFireSeventeen)
	roomFireTwenty:linkRight(roomFireTwentyOne)
	roomFireTwentyOne:linkTop(roomFireEighteen)
	roomFireTwentyOne:linkLeft(roomFireTwenty)
	roomFireTwentyOne:linkBot(roomFireTwentyFour)
	roomFireTwentyOne:linkRight(roomFireTwentyTwo)
	roomFireTwentyTwo:linkLeft(roomFireTwentyOne)
	roomFireTwentyTwo:linkRight(roomIceTwentyOne)
	--Row 7--
	roomFireTwentyThree:linkLeft(roomFireSixteen)
	roomFireTwentyFour:linkTop(roomFireTwentyOne)

	
	prespeedX = 0
	prespeedY = 0
	originalBoundary = Section (0)
	newBoundary = originalBoundary.boundary	
	exitType = 0
	firstLoop = true
	exit1triggered = false
	exit2triggered = false
	currentRoom = roomStart

end


--***************************************************************************************
-- 																						*
-- LOOP FUNCTIONS																		*
-- 																						*
--***************************************************************************************

do	

	newBoundary.left = currentRoom.left
	newBoundary.right = currentRoom.right
	newBoundary.top = currentRoom.top
	newBoundary.bottom = currentRoom.bottom

	function onLoop ()	
		if (player:mem(0x15A, FIELD_WORD) == 0) then
			if(firstLoop == true) then
				if(UserData.getValue("ignoritus_ruby1") == 1) then triggerEvent("Ruby1Hide") end
				if(UserData.getValue("ignoritus_ruby2") == 1) then triggerEvent("Ruby2Hide") end
				if(UserData.getValue("ignoritus_ruby3") == 1) then triggerEvent("Ruby3Hide") end
				if(UserData.getValue("ignoritus_ruby4") == 1) then triggerEvent("Ruby4Hide") end
				if(UserData.getValue("ignoritus_ruby5") == 1) then triggerEvent("Ruby5Hide") end
				if(UserData.getValue("ignoritus_ruby6") == 1) then triggerEvent("Ruby6Hide") end

				if(UserData.getValue("ignoritus_sapp1") == 1) then triggerEvent("Sapp1Hide") end
				if(UserData.getValue("ignoritus_sapp2") == 1) then triggerEvent("Sapp2Hide") end
				if(UserData.getValue("ignoritus_sapp3") == 1) then triggerEvent("Sapp3Hide") end
				if(UserData.getValue("ignoritus_sapp4") == 1) then triggerEvent("Sapp4Hide") end
				if(UserData.getValue("ignoritus_sapp5") == 1) then triggerEvent("Sapp5Hide") end
				if(UserData.getValue("ignoritus_sapp6") == 1) then triggerEvent("Sapp6Hide") end
				
				if(UserData.getValue("ignoritus_entry") == 0) then triggerEvent("Lower") UserData.setValue("ignoritus_entry",1) UserData.save() end
				firstLoop = false
			end
			
			if(exit1triggered == false) then
				if(UserData.getValue("ignoritus_rubies") >= 3) then
					if(UserData.getValue("ignoritus_sapphires") >= 3) then
					triggerEvent("ExitA")
					exit1triggered = true
					end
				end 
			end
			if(exit2triggered == false) then
				if(UserData.getValue("ignoritus_rubies") >= 6) then
					if(UserData.getValue("ignoritus_sapphires") >= 6) then
					triggerEvent("ExitB")
					exit2triggered = true
					end
				end 
			end
		
		
			if(exitType ==  1) then 	
			player.x = player.x + 33
			player.speedX = prespeedX
			end
			
			if(exitType ==  2) then 	
			player.x = player.x - 33
			player.speedX = prespeedX
			end
			
			if(exitType ==  3) then 	
			player.y = player.y + 33
			player.speedY = prespeedY
			end
			
			if(exitType ==  4) then 	
			player.y = player.y - 33
			player.speedY = prespeedY
			end
			
			exitType = 0

			originalBoundary.boundary = newBoundary
			movedX = false
			movedY = false
		
			triggers.testTriggers(NPCID.AXE,trigs);
			

			if (player.x+player.speedX >= currentRoom.right-24) then
			if(currentRoom.rightEx ~= nil) then
				newBoundary.right = currentRoom.rightEx.right
				newBoundary.left = currentRoom.rightEx.left
				newBoundary.bottom = currentRoom.rightEx.bottom
				newBoundary.top = currentRoom.rightEx.top
				currentRoom = currentRoom.rightEx
				if(currentRoom.entranceEvent ~= nil) then triggerEvent(currentRoom.entranceEvent) end
				prespeedX = player.speedX
				movedX = true
				exitType = 1
				end
			end
			
			if (player.x+player.speedX <= currentRoom.left) then
			if (movedX ~= true) then
				if(currentRoom.leftEx ~= nil) then
					newBoundary.right = currentRoom.leftEx.right
					newBoundary.left = currentRoom.leftEx.left
					newBoundary.bottom = currentRoom.leftEx.bottom
					newBoundary.top = currentRoom.leftEx.top
					currentRoom = currentRoom.leftEx
					if(currentRoom.entranceEvent ~= nil) then triggerEvent(currentRoom.entranceEvent) end
					prespeedX = player.speedX
					exitType = 2
					end
				end
			end
			
			
			if (player.y+player.speedY >= currentRoom.bottom-24) then
			if(currentRoom.botEx ~= nil) then
				newBoundary.right = currentRoom.botEx.right
				newBoundary.left = currentRoom.botEx.left
				newBoundary.bottom = currentRoom.botEx.bottom
				newBoundary.top = currentRoom.botEx.top
				currentRoom = currentRoom.botEx
				if(currentRoom.entranceEvent ~= nil) then triggerEvent(currentRoom.entranceEvent) end
				prespeedY = player.speedY
				movedY = true
				exitType = 3
				end
			end
			
			if (player.y+player.speedY <= currentRoom.top) then
			if (movedY ~= true) then
				if(currentRoom.topEx ~= nil) then
					newBoundary.right = currentRoom.topEx.right
					newBoundary.left = currentRoom.topEx.left
					newBoundary.bottom = currentRoom.topEx.bottom
					newBoundary.top = currentRoom.topEx.top
					currentRoom = currentRoom.topEx
					if(currentRoom.entranceEvent ~= nil) then triggerEvent(currentRoom.entranceEvent) end
					prespeedY = player.speedY
					exitType = 4
					end
				end
			end
			
			
			for i,npc in pairs(findnpcs(-1,-1)) do
				if (npc.y > currentRoom.bottom or npc.y < currentRoom.top or npc.x > currentRoom.right or npc.x < currentRoom.left-16) then
				npc:mem(0x12A, FIELD_WORD, 0)
				end
			end
			

			printText("Sapphires: "..tostring(UserData.values()["ignoritus_sapphires"]), 16, 64)
			printText("Rubies: "..tostring(UserData.values()["ignoritus_rubies"]), 608, 64)
		end
	end

end





