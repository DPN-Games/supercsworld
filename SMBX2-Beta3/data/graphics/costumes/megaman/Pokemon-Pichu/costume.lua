local costume = {}

function costume.onInit()
	registerEvent(costume, "onDraw");
end

function costume.onDraw()
	for _,v in ipairs(Animation.get(149)) do
		v.width = 58;
		v.height = 88;
	end
end

return costume;