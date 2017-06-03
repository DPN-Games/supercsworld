local costume = {}

function costume.onInit()
	registerEvent(costume, "onDraw");
end

function costume.onDraw()
	for _,v in ipairs(Animation.get(3)) do
		v.width = 32;
		v.height = 42;
	end
end

return costume;