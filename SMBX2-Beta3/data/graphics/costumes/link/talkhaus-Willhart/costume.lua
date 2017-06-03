local costume = {}

function costume.onInit()
	registerEvent(costume, "onDraw");
end

function costume.onDraw()
	for _,v in ipairs(Animation.get(134)) do
		v.width = 34;
		v.height = 58;
	end
end

return costume;