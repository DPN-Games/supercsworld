local costume = {}

function costume.onInit()
	registerEvent(costume, "onDraw");
end

function costume.onDraw()
	for _,v in ipairs(Animation.get(129)) do
		v.width = 30;
		v.height = 44;
	end
end

return costume;