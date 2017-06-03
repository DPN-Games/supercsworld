local vision = {};

local colliders = loadSharedAPI("colliders");
local vectr = loadSharedAPI("vectr")

local function createmt(x,y,dir,fov)
	local mt = {}	
	
	local top = dir:rotate(fov/2);
	local bottom = dir:rotate(-fov/2);
	
	local c = colliders.Tri(x, y, {0,0},{top.x,top.y},{bottom.x,bottom.y});
	
	mt.__index = function(tbl,key)
		if(key == "x") then
			return x;
		elseif(key == "y") then
			return y;
		elseif(key == "top") then
			return top;
		elseif(key == "bottom") then
			return bottom;
		elseif(key == "direction") then
			return dir;
		elseif(key == "fov") then
			return fov;
		elseif(key == "collider") then
			return c;
		end
	end
	
	mt.__newindex = function(tbl,key,val)
		if(key == "x") then
			setmetatable(tbl, createmt(val,tbl.y,tbl.direction,tbl.fov));
		elseif(key == "y") then
			setmetatable(tbl, createmt(tbl.x,val,tbl.direction,tbl.fov));
		elseif(key == "top") then
			error("Attempted to set a read-only value: 'top'",2)
		elseif(key == "bottom") then
			error("Attempted to set a read-only value: 'bottom'",2)
		elseif(key == "direction") then
			setmetatable(tbl, createmt(tbl.x,tbl.y,val,tbl.fov));
		elseif(key == "fov") then
			setmetatable(tbl, createmt(tbl.x,tbl.y,tbl.direction,val));
		elseif(key == "collider") then
			error("Attempted to set a read-only value: 'collider'",2)
		end
	end
	
	return mt;
end

function vision.VisionCone(x, y, direction, fov)
	local c = {};
	
	c.Rotate = function(obj, angle)
		obj.direction = obj.direction:rotate(angle);
	end
	
	c.Check = vision.CheckCone;
	
	setmetatable(c,createmt(x,y,direction,fov));
	
	return c;
end

function vision.CheckCone(cone, obj, res, ids, dbg)
	if(dbg == nil) then
		dbg = false;
	end
	
	ids = ids or colliders.BLOCK_SOLID;
	res = res or 16;

	--player is not in the vision cone at all, so don't bother searching.
	if(not colliders.collide(cone.collider,obj)) then
		return false;
	end
	
	--get a list of blocks in the vision cone and add the player
	local _,_,blocks = colliders.collideBlock(cone.collider, ids, obj.section);
	table.insert(blocks,obj);
	local pid = #blocks;
	
	--create depth buffer
	local buffer = {};
	local c = vectr.v2(cone.x,cone.y);
	
	--iterate through all blocks (and player), find angle at top and bottom of block and write to depth buffer if necessary.
	for index,v in ipairs(blocks) do
		local isobj = index == pid;
		local top = vectr.v2(v.x,v.y) - c;
		local bottom = vectr.v2(v.x,v.y+32) - c;
		local t_ang = math.deg(math.acos((cone.top..top)/(cone.top.length*top.length)));
		local b_ang = math.deg(math.acos((cone.top..bottom)/(cone.top.length*bottom.length)));
		local t_i = math.floor((t_ang/cone.fov)*res);
		local b_i = math.floor((b_ang/cone.fov)*res);
		
		if(t_i > b_i) then
			local t = t_i;
			t_i = b_i;
			b_i = t;
		end
		
		for i=t_i,b_i,1 do
				local p;
				if(t_i == b_i) then
					p = top;
				else
					p = vectr.lerp(top,bottom,(i-t_i)/(b_i-t_i));
				end
				local depth = p.length;
			if(buffer[i] == nil or depth < buffer[i].d) then
				buffer[i] = {d = depth, b = isobj};
			end
		end
	end
	
	--debug draw the vision cone (not pretty)
	if(dbg) then
		local delta = cone.fov/res;
		local prev;
		
		for i=1,res,1 do
			local v = buffer[i];
			local dir;
			if(v == nil) then
				dir = cone.top:rotate(-i*delta);
			else
				dir = cone.top:normalise():rotate(-i*delta)*v.d;
			end
			if(prev ~= nil) then
				local tri = colliders.Tri(c.x,c.y,{0,0},{prev.x,prev.y},{dir.x,dir.y});
				tri:Draw();
			end
			prev = dir;
		end
	end
	
	--search the buffer for marked "player" objects, and if we find one, the player is visible.
	for _,v in pairs(buffer) do
		if(v.b) then
			return true;
		end
	end
	
	return false;
end

return vision;