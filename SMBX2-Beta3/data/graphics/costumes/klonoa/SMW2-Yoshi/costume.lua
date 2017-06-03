local costume = {}

function costume.onInit()
	registerEvent(costume, "onDraw");
end

function costume.onDraw()
	for _,v in ipairs(Animation.get(152)) do
		v.width = 50;
		v.height = 64;
	end
end

function costume.onCleanup(playerObject)
end

return costume;