--classExpander.lua
--v1.0.1
--Created by Horikawa Otane, 2016
--Contact me at https://www.youtube.com/subscription_center?add_user=msotane

local npcconfig = API.load("npcconfig");

function Player:isGroundTouching()
	return self:mem(0x146, FIELD_WORD) ~= 0 or self:mem(0x48, FIELD_WORD) ~= 0 or self:mem(0x176, FIELD_WORD) ~= 0
end

if(not isOverworld) then
	function NPC:transform(newID, centered)
		local x = self.x;
		local y = self.y;
		if(centered == nil) then
			centered = true;
		end
		if(centered) then
			x = x+self.width*0.5;
			y = y+self.height*0.5;
		end
		self.id = newID;
		local w = npcconfig[self.id].width;
		local h = npcconfig[self.id].height;
		self:mem(0x90, FIELD_DFLOAT, w);
		self:mem(0x88, FIELD_DFLOAT, h);
		if(npcconfig[self.id].gfxwidth ~= 0) then
			w = npcconfig[self.id].gfxwidth;
		end
		if(npcconfig[self.id].gfxheight ~= 0) then
			h = npcconfig[self.id].gfxheight;
		end
		self:mem(0xB8, FIELD_DFLOAT, w);
		self:mem(0xC0, FIELD_DFLOAT, h);
		self:mem(0xE4, FIELD_WORD, 0);
		
		if(centered) then
			x = x-w*0.5;
			y = y-h*0.5;
		end
		
		self.x = x;
		self.y = y;
		
		self.ai1 = 0;
		self.ai2 = 0;
		self.ai3 = 0;
		self.ai4 = 0;
		self.ai5 = 0;
	end
end

do --Table helper functions
	function table.ifindlast(t, val)
		for i = #t,1,-1 do
			if(t[i] == val) then
				return i;
			end
		end
		return nil;
	end

	function table.findlast(t, val)
		local lst = nil;
		for k,v in pairs(t) do
			if(v == val) then
				lst = k;
			end
		end
		return lst;
	end

	function table.ifind(t, val)
		for k,v in ipairs(t) do
			if(v == val) then
				return k;
			end
		end
		return nil;
	end

	function table.find(t, val)
		for k,v in pairs(t) do
			if(v == val) then
				return k;
			end
		end
		return nil;
	end

	function table.ifindall(t, val)
		local rt = {};
		for k,v in ipairs(t) do
			if(v == val) then
				table.insert(rt,k);
			end
		end
		return rt;
	end

	function table.findall(t, val)
		local rt = {};
		for k,v in pairs(t) do
			if(v == val) then
				table.insert(rt,k);
			end
		end
		return rt;
	end

	function table.icontains(t, val)
		return table.ifind(t, val) ~= nil;
	end

	function table.contains(t, val)
		return table.find(t, val) ~= nil;
	end

	function table.iclone(t)
		local rt = {};
		for k,v in ipairs(t) do
			rt[k] = v;
		end
		setmetatable(rt, getmetatable(t));
		return rt;
	end

	function table.clone(t)
		local rt = {};
		for k,v in pairs(t) do
			rt[k] = v;
		end
		setmetatable(rt, getmetatable(t));
		return rt;
	end

	function table.ideepclone(t)
		local rt = {};
		for k,v in ipairs(t) do
			if(type(v) == "table") then
				rt[k] = table.deepclone(v);
			else
				rt[k] = v;
			end
		end
		setmetatable(rt, getmetatable(t));
		return rt;
	end

	function table.deepclone(t)
		local rt = {};
		for k,v in pairs(t) do
			if(type(v) == "table") then
				rt[k] = table.deepclone(v);
			else
				rt[k] = v;
			end
		end
		setmetatable(rt, getmetatable(t));
		return rt;
	end
end
return {}