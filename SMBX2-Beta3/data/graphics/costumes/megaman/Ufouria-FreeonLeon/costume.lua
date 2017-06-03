local costume = {}

function costume.onInit()
	registerEvent(costume, "onDraw");
end

function costume.onDraw()
	for _,v in ipairs(Animation.get(149)) do
		v.width = 44;
		v.height = 64
	end
end

return costume;