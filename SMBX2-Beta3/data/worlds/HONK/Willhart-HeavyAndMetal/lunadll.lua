
--Used for conveyors
local firstLoop = true

--Used for pause
local scrolling = false
local scrolled = false

--MUSIC STUFF STARTS

--Keeps track of the music currently playing, so it doesn't try to end a track to play itself.
local musicKey = nil;

--Pass a filename, and if it's different from our current tune, play it immediately
function playMusic(filename)
	if(filename ~= musicKey) then
		MusicOpen(filename);
		musicKey = filename;
		MusicPlay();
	end
end

--Pass a filename, and fade out the previous track over the specified time.
function changeMusic(fileName, milliseconds)
	if(fileName ~= nextTrackName) then
		NextMusic(fileName, milliseconds)		
	end
end

function NextMusic(track, milliseconds)
	MusicStopFadeOut(milliseconds);
	nextTrackName = track
	WaitTicks = (milliseconds / 1000)*65 -- Convert milliseconds into ticks (1 tick is 1/65 of second)
	WaitTicks = WaitTicks+30 
	PlayNext = 1
end

function nextMusicWaiter()
	if(PlayNext ==1 ) then
		WaitTicks = WaitTicks-1 
		if (WaitTicks<=0) then
			playMusic(nextTrackName)
			PlayNext=0
		end
	end
end

function doMusicStuff()
	--Passive call of music fader
	nextMusicWaiter()

	--Section 1
	if(-194400 > player.x) then
		changeMusic("mega-man-2.nsf|5",100)
	elseif(-180000 > player.x) then
		changeMusic("mega-man-2.nsf|13",1000)
	end
end
		
--MUSIC STUFF ENDS		

--Whichever comes first in onLoop function will take priority

function onStart()
	--Character Filter
	player.character = 6
	local appear = {19,20,29,89,164}
	
	--Prevent despawn.
	for a,i in pairs(appear) do
		for k,v in pairs(findnpcs(i,-1)) do
			if v.isValid then
				--Despawn prevent.
				v:mem(0x12A, FIELD_WORD, 0)
			end
		end
	end
end

function onLoadSection()
	
	--Set Conveyor belts
    if (firstLoop) then
        firstLoop = false
        
        -- Set all block-512 to an x-speed of 1
        for i,block in pairs(findblocks(162)) do
            block.speedX = -0.9
        end
        
        -- Set all block-358 to an x-speed of 10
        for i,block in pairs(findblocks(163)) do
            block.speedX = 0.9
        end
    end
end

function onEvent(eventName)
	if eventName == "Screen3" then
		scrolling=true
	end
	if eventName == "Screen4" then
		scrolling=true
	end
end

function onTick()

	-- Set Musid
	doMusicStuff()
		
	-- Set Drills
    for k,v in pairs(findnpcs(285,-1)) do	
		if (v.direction == -1) then
			v.speedY = 0.6;
			v.direction = -1;
		else
			v.speedY = -1;
			v.direction = 1;
		end
		
		if (v.y < -200600) or (v.y > -200000) then
			v:kill(0);
		end
    end
	
	-- Set Walker
    for k,v in pairs(findnpcs(20,-1)) do	
		if v.isValid then
			if (v.y > player.y+6) and (v.y < player.y+38) and (v.x < player.x+600) then
				if (v.speedX > 0) then
					v.x = v.x+2;
				else
					v.x = v.x-2;
				end
			end
		end
	end
	
	-- Set Wart
    for k,v in pairs(findnpcs(202,-1)) do
		v.speedX = -2.6;
		if (v.x > -199560) then
			v.speedY = 0;
		else
			v.y = v.y+2;
		end
		if (v.y > -200192) and (v.x > -199560-300) then
			v.speedY = -12;
		end
	end
end

--Camera scroll.
local spdX = 3
local first = false
function onCameraUpdate()
	if scrolling then
		Misc.pause()
		local boundaryRect = Section.get(1).boundary
		boundaryRect.top = -199032
		boundaryRect.bottom = -198432
		boundaryRect.left = boundaryRect.left + spdX
		boundaryRect.right = boundaryRect.right + spdX
		Section.get(1).boundary = boundaryRect
		if (boundaryRect.left > -194848)then
			if first == false then
				scrolling=false
				scrolled=true
				first=true
			end
		end
		if (boundaryRect.left > -194176)then
			scrolling=false
			scrolled=true
		end
	end
	if scrolled then
		Misc.unpause()
		scrolled = false
		scrolling=false
	end
end