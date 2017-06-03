--*****************************************--
--*****************************************--
--**    _                                **--
--**   | |                      o        **--
--**   | | _  _  _    __,   __,     __   **--
--** _ |/ / |/ |/ |  /  |  /  | |  /     **--
--** \_/\/  |  |  |_/\_/|_/\_/|/|_/\___/ **--
--**                         /|          **--
--**                         \|          **--
--*****************************************--
--*****************************************--			
-------------------Imagic--------------------
-----------Created by Hoeloe - 2016----------
----Open-Source Primitive Drawing Library----
------------For Super Mario Bros X-----------
--------------------v1.1.3-------------------
--------------REQUIRES VECTR.lua-------------

local vectr = API.load("vectr");

local imagic = {}

--*************--
--** DEFINES **--
--*************--

-- PRIMITIVES --
imagic.TYPE_BOX = 1;
imagic.TYPE_CIRCLE = 2;
imagic.TYPE_TRI = 3;
imagic.TYPE_POLY = 4;

imagic.TYPE_BOXBORDER = 5;
imagic.TYPE_CIRCLEBORDER = 6;

-- TEXTURE FILL TYPES --
imagic.TEX_FILL = 1;
imagic.TEX_PLACE = 2;

-- ALIGNMENTS --
imagic.ALIGN_LEFT = 1;
imagic.ALIGN_CENTRE = 2;
imagic.ALIGN_CENTER = imagic.ALIGN_CENTRE;
imagic.ALIGN_MIDDLE = imagic.ALIGN_CENTRE;
imagic.ALIGN_RIGHT = 3;
imagic.ALIGN_TOP = 4;
imagic.ALIGN_BOTTOM = 5;

imagic.ALIGN_TOPLEFT = 6;
imagic.ALIGN_TOPCENTRE = imagic.ALIGN_TOP;
imagic.ALIGN_TOPCENTER = imagic.ALIGN_TOPCENTRE;
imagic.ALIGN_TOPMIDDLE = imagic.ALIGN_TOPCENTRE;
imagic.ALIGN_TOPRIGHT = 7;

imagic.ALIGN_CENTRELEFT = imagic.ALIGN_LEFT;
imagic.ALIGN_CENTRERIGHT = imagic.ALIGN_RIGHT;
imagic.ALIGN_CENTERLEFT = imagic.ALIGN_CENTRELEFT;
imagic.ALIGN_MIDDLELEFT = imagic.ALIGN_CENTRELEFT;
imagic.ALIGN_CENTERRIGHT = imagic.ALIGN_CENTRERIGHT;
imagic.ALIGN_MIDDLERIGHT = imagic.ALIGN_CENTRERIGHT;

imagic.ALIGN_BOTTOMLEFT = 8;
imagic.ALIGN_BOTTOMCENTRE = imagic.ALIGN_BOTTOM;
imagic.ALIGN_BOTTOMCENTER = imagic.ALIGN_BOTTOMCENTRE;
imagic.ALIGN_BOTTOMMIDDLE = imagic.ALIGN_BOTTOMCENTRE;
imagic.ALIGN_BOTTOMRIGHT = 9;

-- CONSTANTS --
imagic.DEG2RAD = 0.01745329251;

--**************************--
--** CONVERSION FUNCTIONS **--
--**************************--

local function hexToRGBA(hex)
	return {r=math.floor(hex/(256*256*256)),g=math.floor(hex/(256*256))%256,b=math.floor(hex/256)%256,a=hex%256}
end

local function hexToRGB(hex)
	return {r=math.floor(hex/(256*256)),g=math.floor(hex/(256))%256,b=hex%256,a=1}
end

local function hexToRGBATable(hex)
	return {math.floor(hex/(256*256*256))/255,(math.floor(hex/(256*256))%256)/255,(math.floor(hex/256)%256)/255,(hex%256)/255}
end

--***************************--
--** DRAW OBJECT FUNCTIONS **--
--***************************--

local Object = {}
Object.__index = Object;

-- Draws the object to the screen, can also take named arguments --
--
-- Optional named arguments are:
-- colour, color, bordercolour, bordercolor, bordercol, priority, z, outlinecolour, outlinecolor, outlinecol

function Object:Draw(priority, colour)
	local v = {}
	for i = 1,#self.verts,2 do
		v[i] = self.verts[i] + self.x;
		v[i+1] = self.verts[i+1] + self.y;
	end
	local t = nil;
	if(self.uvs ~= nil) then
		t = {};
		for i = 1,#self.uvs,2 do
			t[i] = self.uvs[i] + self.texoffsetX;
			t[i+1] = self.uvs[i+1] + self.texoffsetY;
		end
	end
	local bordercol = 0xFFFFFFFF;
	local outline = true;
	local outlinecol = 0xFFFFFFFF;
	if(type(priority) == "table") then	
		bordercol = priority.bordercolour or priority.bordercolor or priority.bordercol or bordercol;
		colour = priority.colour or priority.color or colour;
		outline = priority.outline or outline;
		outlinecol = priority.outlinecolour or priority.outlinecolor or priority.outlinecol or outlinecol;
		
		priority = priority.priority or priority.z;
	end		
	
	if(colour ~= nil and type(colour) == "number") then
		colour = hexToRGBATable(colour);
	end
	Graphics.glDraw{vertexCoords = v, textureCoords = t, vertexColors = self.vertColors, texture = self.texture, primitive = self._renderType or Graphics.GL_TRIANGLES, priority = priority, color=colour, sceneCoords = self.scene};
	
	if(self.border ~= nil) then
		self.border:Draw(priority, bordercol);
	end
	
	if(self.outlineverts ~= nil and outline) then
		v = {};
		for i = 1,#self.outlineverts,2 do
			v[i] = self.outlineverts[i] + self.x;
			v[i+1] = self.outlineverts[i+1] + self.y;
		end
		
		if(outlinecol ~= nil and type(outlinecol) == "number") then
			outlinecol = hexToRGBATable(outlinecol);
		end
		Graphics.glDraw{vertexCoords = v, primitive = Graphics.GL_LINE_LOOP, priority = priority, color=outlinecol, sceneCoords = self.scene};
	end
end

-- Transforms the object via a vectR matrix --
function Object:Transform(matrix)
	local mat3 = matrix._type == "mat3";
	for i = 1,#self.verts,2 do
		local v;
		if(mat3) then	
			v = matrix * vectr.v3(self.verts[i],self.verts[i+1],1);
		else
			v = matrix * vectr.v2(self.verts[i],self.verts[i+1]);
		end
		self.verts[i] = v.x;
		self.verts[i+1] = v.y;
	end
	
	if(self.border ~= nil) then
		self.border:Transform(matrix);
	end
end

-- Rotates the object clockwise --
function Object:Rotate(degrees)
	local cs = math.cos(degrees*imagic.DEG2RAD);
	local sn = math.sin(degrees*imagic.DEG2RAD);
	self:Transform(vectr.mat2({cs, -sn}, {sn, cs}));
end

-- Moves the object relative to its pivot (will change where rotation and scale are centered) --
function Object:Translate(x, y)
	self:Transform(vectr.mat3({1,0,x}, {0,1,y}, {0,0,1}));
end

-- Resizes the object relative to its current scale --
function Object:Scale(x, y)
	y = y or x;
	self:Transform(vectr.mat2({x,0}, {0,y}));
end

-- Transforms the object UVs via a vectR matrix --
function Object:TransformTexture(matrix)
	if(self.uvs == nil) then return; end
	local mat3 = matrix._type == "mat3";
	for i = 1,#self.uvs,2 do
		local v;
		if(mat3) then
			v = matrix * vectr.v3(self.uvs[i]-0.5,self.uvs[i+1]-0.5,1);
		else
			v = matrix * vectr.v2(self.uvs[i]-0.5,self.uvs[i+1]-0.5);
		end
		self.uvs[i] = v.x+0.5;
		self.uvs[i+1] = v.y+0.5;
	end
	if(self.border ~= nil) then
		self.border:TransformTexture(matrix);
	end
end

-- Rotates the texture clockwise (UVs anticlockwise) --
function Object:RotateTexture(degrees)
	local cs = math.cos(-degrees*imagic.DEG2RAD);
	local sn = math.sin(-degrees*imagic.DEG2RAD);
	self:TransformTexture(vectr.mat2({cs, -sn}, {sn, cs}));
end

-- Moves the texture relative to its pivot (will change where rotation and scale are centered) --
function Object:TranslateTexture(x, y)
	self:TransformTexture(vectr.mat3({1,0,-y}, {0,1,x}, {0,0,1}));
end

-- Resizes the texture relative to its current scale (shrinks UVs) --
function Object:ScaleTexture(x, y)
	y = y or x;
	self:TransformTexture(vectr.mat2({1/x,0}, {0,1/y}));
end

--**************--
--** WRAPPERS **--
--**************--

local Wrapper = {};
local Wrapper_MT = {};

-- Reconstructs the internal imagic object --
local function Reconstruct(obj)
	rawset(obj,"__internal",imagic.Create(rawget(obj,"__rawdata")));
	rawset(obj,"__dirty",false);
end

-- Creates a wrapper functions that first checks if the object needs reconstructing (and does so if necessary) before drawing the object --
local function FuncWrapper(funcName)
	return function(obj, ...)
		if(rawget(obj,"__dirty")) then
			obj:Reconstruct();
		end
		rawget(obj,"__internal")[funcName](rawget(obj,"__internal"), ...);
	end
end

local wrappers = {};

-- Accessor table for wrapper objects --
Wrapper_MT.__index = function(tbl,key)
	if(key == "Reconstruct") then
		return Reconstruct;
	elseif(type(rawget(tbl,"__internal")[key]) == "function") then
		if(wrappers[key] == nil) then
			wrappers[key] = FuncWrapper(key);
		end
		return wrappers[key];
	elseif(rawget(tbl,"__internal")[key] ~= nil) then
		return rawget(tbl,"__internal")[key];
	else
		return rawget(tbl,"__rawdata")[key];
	end
end

-- Mutator table for wrapper objects --
Wrapper_MT.__newindex = function(tbl,key,val)
	local int = rawget(tbl,"__internal");
	if(int[key] ~= nil) then
		int[key] = val;
	elseif(key ~= "primitive" and val ~= rawget(tbl,"__rawdata")[key]) then
		rawget(tbl,"__rawdata")[key] = val;
		rawset(tbl,"__dirty",true);
	end
end

function imagic.Wrapper(primitive, args)
	local t = {};
	t.__rawdata = {};
	for k,v in pairs(args) do
		t.__rawdata[k] = v;
	end
	t.__rawdata.primitive = primitive;
	setmetatable(t,Wrapper_MT);
	t:Reconstruct();
	return t;
end

-- Creates a Box wrapper object
-- This behaves like a box-type drawable object, but arguments are accessible as mutable fields
-- Required arguments are:
-- x, y, width, height
--
-- Optional named arguments are: 				
-- texture, scene, align, texalign, texrotation, filltype, texoffsetX, texoffsetY, outline, borderwidth, bordertexture, bordertex
--
function imagic.Box(args)
	return imagic.Wrapper(imagic.TYPE_BOX, args);
end

-- Creates a Circle wrapper object
-- This behaves like a circle-type drawable object, but arguments are accessible as mutable fields
-- Required arguments are:
-- x, y, radius
--
-- Optional named arguments are: 				
-- texture, scene, align, texalign, texrotation, filltype, texoffsetX, texoffsetY, outline, borderwidth, bordertexture, bordertex, density
--
function imagic.Circle(args)
	return imagic.Wrapper(imagic.TYPE_CIRCLE, args);
end

-- Creates a Tri wrapper object
-- This behaves like a tri-type drawable object, but arguments are accessible as mutable fields
-- Required arguments are:
-- x, y, verts
--
-- Optional named arguments are: 				
-- texture, scene, align, texalign, texrotation, filltype, texoffsetX, texoffsetY, outline
--
function imagic.Tri(args)
	return imagic.Wrapper(imagic.TYPE_TRI, args);
end

-- Creates a Poly wrapper object
-- This behaves like a poly-type drawable object, but arguments are accessible as mutable fields
-- Required arguments are:
-- x, y, verts
--
-- Optional named arguments are: 				
-- texture, scene, align, texalign, texrotation, filltype, texoffsetX, texoffsetY, outline
--
function imagic.Poly(args)
	return imagic.Wrapper(imagic.TYPE_POLY, args);
end


--**********************--
--** HELPER FUNCTIONS **--
--**********************--

-- Gets an offset based on an alignment method --
local function getAlignOffset(align, width, height)
	local xoffset = 0;
	local yoffset = 0;
	
	if(align == imagic.ALIGN_TOPLEFT) then return 0,0 end;
	
	
	if(align == imagic.ALIGN_TOPRIGHT or align == imagic.ALIGN_RIGHT or align == imagic.ALIGN_BOTTOMRIGHT) then
		xoffset = width;
	elseif(align == imagic.ALIGN_TOPCENTRE or align == imagic.ALIGN_CENTRE or align == imagic.ALIGN_BOTTOMCENTRE) then
		xoffset = width*0.5;
	end
	
	if(align == imagic.ALIGN_BOTTOMLEFT or align == imagic.ALIGN_BOTTOM or align == imagic.ALIGN_BOTTOMRIGHT) then
		yoffset = height;
	elseif(align == imagic.ALIGN_CENTRELEFT or align == imagic.ALIGN_CENTRE or align == imagic.ALIGN_CENTRERIGHT) then
		yoffset = height*0.5;
	end
	
	return xoffset,yoffset;
end

-- Re-aligns vertices based on an alignment method --
local function alignVerts(vs, width, height, align, default)
	if(vs == nil) then return; end
	local xoffset, yoffset = getAlignOffset(default or imagic.ALIGN_TOPLEFT, width, height);
	
	if(align == imagic.ALIGN_TOPRIGHT or align == imagic.ALIGN_RIGHT or align == imagic.ALIGN_BOTTOMRIGHT) then
		xoffset = xoffset-width;
	elseif(align == imagic.ALIGN_TOPCENTRE or align == imagic.ALIGN_CENTRE or align == imagic.ALIGN_BOTTOMCENTRE) then
		xoffset = xoffset-width*0.5;
	end
	
	if(align == imagic.ALIGN_BOTTOMLEFT or align == imagic.ALIGN_BOTTOM or align == imagic.ALIGN_BOTTOMRIGHT) then
		yoffset = yoffset-height;
	elseif(align == imagic.ALIGN_CENTRELEFT or align == imagic.ALIGN_CENTRE or align == imagic.ALIGN_CENTRERIGHT) then
		yoffset = yoffset-height*0.5;
	end
	
	for i = 1,#vs,2 do
		vs[i] = vs[i] + xoffset;
		vs[i+1] = vs[i+1] + yoffset;
	end
end

-- Gets an offset for UVs based on an alignment method --
local function getUVAlignOffset(align, width, height)
	local xoffset = 0;
	local yoffset = 0;
	
	if(align == imagic.ALIGN_TOPLEFT) then return 0,0 end;
	
	
	if(align == imagic.ALIGN_TOPRIGHT or align == imagic.ALIGN_RIGHT or align == imagic.ALIGN_BOTTOMRIGHT) then
		xoffset = width-1;
	elseif(align == imagic.ALIGN_TOPCENTRE or align == imagic.ALIGN_CENTRE or align == imagic.ALIGN_BOTTOMCENTRE) then
		xoffset = (width-1)*0.5;
	end
	
	if(align == imagic.ALIGN_BOTTOMLEFT or align == imagic.ALIGN_BOTTOM or align == imagic.ALIGN_BOTTOMRIGHT) then
		yoffset = height-1;
	elseif(align == imagic.ALIGN_CENTRELEFT or align == imagic.ALIGN_CENTRE or align == imagic.ALIGN_CENTRERIGHT) then
		yoffset = (height-1)*0.5;
	end
	
	return xoffset,yoffset;
end

-- Re-aligns UVs based on an alignment method --
local function alignUVs(vs, width, height, align, default)
	if(vs == nil) then return; end
	local xoffset, yoffset = getUVAlignOffset(default or imagic.ALIGN_TOPLEFT, width, height);
	
	if(align == imagic.ALIGN_TOPRIGHT or align == imagic.ALIGN_RIGHT or align == imagic.ALIGN_BOTTOMRIGHT) then
		xoffset = xoffset+(1-width);
	elseif(align == imagic.ALIGN_TOPCENTRE or align == imagic.ALIGN_CENTRE or align == imagic.ALIGN_BOTTOMCENTRE) then
		xoffset = xoffset+(1-width)*0.5;
	end
	
	if(align == imagic.ALIGN_BOTTOMLEFT or align == imagic.ALIGN_BOTTOM or align == imagic.ALIGN_BOTTOMRIGHT) then
		yoffset = yoffset+(1-height);
	elseif(align == imagic.ALIGN_CENTRELEFT or align == imagic.ALIGN_CENTRE or align == imagic.ALIGN_CENTRERIGHT) then
		yoffset = yoffset+(1-height)*0.5;
	end
	
	for i = 1,#vs,2 do
		vs[i] = vs[i] + xoffset;
		vs[i+1] = vs[i+1] + yoffset;
	end
end

-- Adjusts vertices to account for borders --
local function adjustVariableVerts(obj, adjLeft, adjTop, adjRight, adjBot, alignment)
	if(adjustment ~= 0) then
		local ax,ay = getAlignOffset(alignment, 1, 1);
		local xs,ys = 2*(0.5-ax), 2*(0.5-ay);
		if(xs < 0) then
			xs = xs * adjRight;
		else
			xs = xs * adjLeft;
		end
		if(ys < 0) then
			ys = ys * adjBottom;
		else
			ys = ys * adjTop;
		end
		obj:Translate(xs,ys);
	end
end

-- Adjusts vertices to account for borders --
local function adjustVerts(obj, adjustment, alignment)
	adjustVariableVerts(obj, adjustment, adjustment, adjustment, adjustment, alignment);
end

-- Checks if a field is nil and errors if it is --
local function nilcheck(tbl, name)
	if(tbl[name] == nil) then
		error("Field \""..name.."\" cannot be nil.",2);
	end
end

-- Used during polygon triangulation, tests which side of a line a point is on --
local function isLeft(a, p0, p1)
	return ((p0.x or p0[1]) - (a.x or a[1])) * ((p1.y or p1[2]) - (a.y or a[2])) - ((p1.x or p1[1]) - (a.x or a[1])) * ((p0.y or p0[2]) - (a.y or a[2]));
end

-- Make a vertex list for box-type borders --
local function makeVariableBoxBorderVerts(depthleft, depthtop, depthright, depthbottom, width, height)
		return 	  {0,					0,
				   depthleft,			0,
				   0,					depthtop,
				   0,					depthtop,
				   depthleft,			0,
				   depthleft,			depthtop,
				   
				   depthleft,			0,
				   width-depthright,	depthtop,
				   depthleft,			depthtop,
				   width-depthright,	depthtop,
				   depthleft,			0,
				   width-depthright,	0,
				   
				   width,				0,
				   width,				depthtop,
				   width-depthright,	0,
				   width-depthright,	0,
				   width,				depthtop,
				   width-depthright,	depthtop,
					
				   width,				depthtop,
				   width-depthright,	height-depthbottom,
				   width-depthright,	depthtop,
				   width,				depthtop,
				   width-depthright,	height-depthbottom, 
				   width,				height-depthbottom,
				   
				   width,				height,
				   width-depthright,	height,
				   width,				height-depthbottom,
				   width,				height-depthbottom,
				   width-depthright,	height,
				   width-depthright,	height-depthbottom,
				   
				   width-depthright,	height,
				   depthleft,			height-depthbottom,
				   width-depthright,	height-depthbottom,
				   depthleft,			height-depthbottom,
				   width-depthright,	height,
				   depthleft,			height,
				   
				   0,					height,
				   0,					height-depthbottom,
				   depthleft,			height,
				   depthleft,			height,
				   0,					height-depthbottom,
				   depthleft,			height-depthbottom,
				   
				   0,					height-depthbottom,
				   depthleft,			depthtop,
				   depthleft,			height-depthbottom,
				   depthleft,			depthtop,
				   0,					height-depthbottom,
				   0,					depthtop
				   }
end

-- Make a vertex list for box-type borders --
local function makeBoxBorderVerts(depth, width, height)
		return makeVariableBoxBorderVerts(depth,depth,depth,depth,width,height);
end

--*****************************--
--** BORDER LAYOUT FUNCTIONS **--
--*****************************--

-- Create a border image layout, allows custom segmentation of an image
-- Pass in place of the "bordertexture" field
-- Box-type borders will use 8 segments, circle-type borders will use the middle top segment
--
-- Required named arguments are:
-- texture
--
-- Optional named arguments are:
-- left, right, top, bottom, width

function imagic.BorderImage(args)
	nilcheck(args, "texture");
	local p = {};
	p.texture = args.texture;
	p.left = args.left or args.width or args.right or args.top or args.bottom or args.texture.width/3;
	p.right = args.right or args.width or args.left or args.top or args.bottom or args.texture.width/3;
	p.top = args.top or args.width or args.bottom or args.left or args.right or args.texture.height/3;
	p.bottom = args.bottom or args.width or args.top or args.left or args.right or args.texture.height/3;
	
	p.left = p.left/args.texture.width;
	p.right = p.right/args.texture.width;
	p.top = p.top/args.texture.height;
	p.bottom = p.bottom/args.texture.height;
	
	p.__type = "BorderImage";
	return p;
end

-- Create a physical border layout, allows variable width for box-type borders
-- Pass in place of the "borderwidth" field
--
-- Optional named arguments are:
-- left, right, top, bottom, width
--
-- At least one argument must be given

function imagic.BorderLayout(args)
	if(args.left == nil and args.right == nil and args.top == nil and args.bottom == nil and args.width == nil) then
		error("Must define some widths for a Border Layout.", 2);
	end
	local p = {};
	p.left = args.left or args.width or args.right or args.top or args.bottom;
	p.right = args.right or args.width or args.left or args.top or args.bottom;
	p.top = args.top or args.width or args.bottom or args.left or args.right;
	p.bottom = args.bottom or args.width or args.top or args.left or args.right;
	
	p.__type = "BorderLayout";
	return p;
end

--***********************--
--** CREATION FUNCTION **--
--***********************--

-- Creates a new drawable object
-- Required arguments for all types are:
-- x, y, primitive
--
-- Optional named arguments for all types are: 				
-- texture, scene, align, texalign, texrotation, filltype, texoffsetX, texoffsetY, outline
--
-- Required arguments for BOX types are:
-- width, height
--
-- Optional named arguments for BOX types are:
-- borderwidth, bordertexture, bordertex
--
-- Required arguments for CIRCLE types are:
-- radius
--
-- Optional named arguments for CIRCLE types are:
-- density, borderwidth, bordertexture, bordertex
--
-- Required arguments for TRI types are:
-- verts
--
-- Required arguments for POLY types are:
-- verts
--

function imagic.Create(args)
	local p = {};
	setmetatable(p, Object);
	nilcheck(args,"x");
	nilcheck(args,"y");
	nilcheck(args,"primitive");
	p.x = args.x;
	p.y = args.y;
	p.texture = args.texture;
	p.scene = args.scene;
	
	local filltype = args.filltype or imagic.TEX_FILL;
	p.texoffsetX = args.texoffsetX or 0;
	p.texoffsetY = args.texoffsetY or 0;
	local texrotation = args.texrotation or 0;
	local texalign = args.texalign or imagic.ALIGN_CENTRE;
	local align;
	
	-- Create a box --
	if(args.primitive == imagic.TYPE_BOX) then
		nilcheck(args,"width");
		nilcheck(args,"height");
		p._renderType = Graphics.GL_TRIANGLE_STRIP;
		align = args.align or imagic.ALIGN_TOPLEFT;
		
		local bwidth = 0;
		local bdr;
		if(args.borderwidth ~= nil) then
			bdr = imagic.Create{x=args.x, y=args.y, width=args.width, height = args.height, primitive = imagic.TYPE_BOXBORDER, texture = (args.bordertexture or args.bordertex), depth = args.borderwidth, scene = args.scene, align = align};
			bwidth = args.borderwidth;
		end
		
		local w;
		local h;
		if(type(bwidth) == "number") then
			w = args.width-bwidth*2;
			h = args.height-bwidth*2;
		else
			w = args.width - bwidth.left - bwidth.right;
			h = args.height - bwidth.top - bwidth.bottom;
		end
		
		p.verts = {0,0,w,0,0,h,w,h};
		
		alignVerts(p.verts,w, h, align, imagic.ALIGN_TOPLEFT);
		if(p.texture ~= nil) then
			if(filltype == imagic.TEX_FILL) then
				p.uvs = {0,0,1,0,0,1,1,1};
			elseif(filltype == imagic.TEX_PLACE) then
				p.uvs = {0,0,w/p.texture.width,0,0,h/p.texture.height,w/p.texture.width,h/p.texture.height};
				alignUVs(p.uvs, (w/p.texture.width), (h/p.texture.height), texalign, imagic.ALIGN_TOPLEFT);
			end
		end
		if(type(bwidth) == "number") then
			adjustVerts(p,bwidth,align)
		else
			adjustVariableVerts(p,bwidth.left,bwidth.top,bwidth.right,bwidth.bottom,align);
		end
		
		if(args.outline) then
			p.outlineverts = {p.verts[1], p.verts[2], p.verts[3]+1, p.verts[4], p.verts[7]+1, p.verts[8]+1, p.verts[5], p.verts[6]+1};
		end
		
		p.border = bdr;
	
	-- Create a circle --
	elseif(args.primitive == imagic.TYPE_CIRCLE) then
		nilcheck(args,"radius");
		p._renderType = Graphics.GL_TRIANGLE_FAN;
		align = args.align or imagic.ALIGN_CENTRE;
		local density = args.density or math.ceil(math.sqrt(args.radius)*6);
		
		local bwidth = 0;
		local bdr;
		if(args.borderwidth ~= nil) then
			bdr = imagic.Create{x=args.x, y=args.y, radius=args.radius, primitive = imagic.TYPE_CIRCLEBORDER, density = density, texture = (args.bordertexture or args.bordertex), depth = args.borderwidth, scene = args.scene, align = align};
			bwidth = args.borderwidth;
		end
		
		p.verts = {0,0}
		for i=0,density do
			local theta = (i/density)*math.pi*2;
			table.insert(p.verts, math.sin(theta)*(args.radius-bwidth));
			table.insert(p.verts, -math.cos(theta)*(args.radius-bwidth));
		end
		alignVerts(p.verts,2*(args.radius-bwidth),2*(args.radius-bwidth), align, imagic.ALIGN_CENTRE);
		
		if(p.texture ~= nil) then
			if(filltype == imagic.TEX_FILL) then
				p.uvs = {0.5,0.5}
				for i=0,density do
					local theta = (i/density)*math.pi*2;
					table.insert(p.uvs, (math.sin(theta)+1)*0.5);
					table.insert(p.uvs, (-math.cos(theta)+1)*0.5);
				end
			elseif(filltype == imagic.TEX_PLACE) then
				p.uvs = {0.5,0.5}
				for i=0,density do
					local theta = (i/density)*math.pi*2;
					table.insert(p.uvs, (math.sin(theta)*2*(args.radius-bwidth)/p.texture.width+1)*0.5);
					table.insert(p.uvs, (-math.cos(theta)*2*(args.radius-bwidth)/p.texture.height+1)*0.5);
				end
				alignUVs(p.uvs, (2*(args.radius-bwidth)/p.texture.width), (2*(args.radius-bwidth)/p.texture.height), texalign, imagic.ALIGN_CENTRE);
			end
		end
		adjustVerts(p,bwidth,align);
		
		if(args.outline) then
			p.outlineverts = {};
			for i = 3,#p.verts do
				p.outlineverts[i-2] = p.verts[i];
			end
		end
		
		p.border = bdr;
		
	-- Create a triangle --
	elseif(args.primitive == imagic.TYPE_TRI) then
		nilcheck(args,"verts");
		p._renderType = Graphics.GL_TRIANGLES;
		align = args.align or imagic.ALIGN_TOPLEFT;
		if(type(args.verts) ~= "table" or #args.verts ~= 3) then
			error("Incorrect triangle definition.", 1);
		end
		p.verts = {};
		local minx, maxx;
		local miny, maxy;
		for _,v in ipairs(args.verts) do
				local x = v.x or v[1];
				local y = v.y or v[2];
				if(minx == nil) then 
					minx = x;
					maxx = x; 
					miny = y; 
					maxy = y; 
				end;
				table.insert(p.verts,x);
				table.insert(p.verts,y);
				minx = math.min(minx,x);
				maxx = math.max(maxx,x);
				miny = math.min(miny,y);
				maxy = math.max(maxy,y);
		end
		alignVerts(p.verts,maxx-minx,maxy-miny, align, imagic.ALIGN_TOPLEFT);
		
		if(args.outline) then
			p.outlineverts = p.verts;
		end
		
		if(p.texture ~= nil) then
			if(filltype == imagic.TEX_FILL) then
				p.uvs = {};
				for _,v in ipairs(args.verts) do
					local x = v.x or v[1];
					local y = v.y or v[2];
					table.insert(p.uvs, (x-minx)/(maxx-minx))
					table.insert(p.uvs, (y-miny)/(maxy-miny))
				end
			elseif(filltype == imagic.TEX_PLACE) then
				p.uvs = {};
				for _,v in ipairs(args.verts) do
					local x = v.x or v[1];
					local y = v.y or v[2];
					table.insert(p.uvs, (x-minx)/(p.texture.width-minx))
					table.insert(p.uvs, (y-miny)/(p.texture.height-miny))
				end
			alignUVs(p.uvs, ((maxx-minx)/p.texture.width), ((maxy-miny)/p.texture.height), texalign, imagic.ALIGN_TOPLEFT);
			end
		end
		
	-- Create a polygon --
	elseif(args.primitive == imagic.TYPE_POLY) then
		nilcheck(args,"verts");
		p._renderType = Graphics.GL_TRIANGLES;
		align = args.align or imagic.ALIGN_TOPLEFT;
		if(type(args.verts) ~= "table" or #args.verts < 3) then
			error("Incorrect polygon definition.", 1);
		end
		
		local vlist = {};
		local winding = 0;
		local minx, maxx;
		local miny, maxy;
		for k,v in ipairs(args.verts) do
				local x = v.x or v[1];
				local y = v.y or v[2];
				if(minx == nil) then 
					minx = x;
					maxx = x; 
					miny = y; 
					maxy = y; 
				end;
				minx = math.min(minx,x);
				maxx = math.max(maxx,x);
				miny = math.min(miny,y);
				maxy = math.max(maxy,y);
				
				local n = k+1;
				local pr = k-1;
				if(n > #args.verts) then n = 1; end
				if(pr <= 0) then pr = #args.verts end
				winding = winding + (x+(args.verts[n].x or args.verts[n][1]))*(y-(args.verts[n].y or args.verts[n][2]));
		end
		
		if(winding > 0) then
			for i=#args.verts,1,-1 do
				table.insert(vlist,args.verts[i]);
			end
		else
			for _,v in ipairs(args.verts)do
				table.insert(vlist,v);
			end
		end
		
		
		if(args.outline) then
			p.outlineverts = {};
			for i = 1,#vlist do
				table.insert(p.outlineverts, vlist[i].x or vlist[i][1]);
				table.insert(p.outlineverts, vlist[i].y or vlist[i][2]);
			end
		end
		
		p.verts = {};
		--Repeatedly search for and remove convex triangles (ears) from the polygon (as long as they have no other vertices inside them). When the polygon has only 3 vertices left, stop.
		while(#vlist > 3) do
			local count = #vlist;
			for k,v in ipairs(vlist) do
				local n = k+1;
				local pr = k-1;
				if(n > #vlist) then n = 1; end
				if(pr <= 0) then pr = #vlist; end
				
				local x,y = (v.x or v[1]),(v.y or v[2]);
				local nx,ny = (vlist[n].x or vlist[n][1]), (vlist[n].y or vlist[n][2])
				local prx,pry = (vlist[pr].x or vlist[pr][1]), (vlist[pr].y or vlist[pr][2])
				
				
				local lr = x > prx or y > pry;
				if lr then
					lr = 1;
				else
					lr = -1;
				end
				local left = isLeft(vlist[n], vlist[pr], v);
				if(left > 0) then
					local pointin = false;
					for k2,v2 in ipairs(vlist) do
						if(k2 ~= k and k2 ~= n and k2 ~= pr) then
							if(isLeft(vlist[pr], v, v2) > 0 and isLeft(v, vlist[n], v2) > 0 and isLeft(vlist[n], vlist[pr], v2) > 0) then
								pointin = true;
								break;
							end
						end
					end
					if(not pointin) then
						table.insert(p.verts, prx);
						table.insert(p.verts, pry);
						table.insert(p.verts, x);
						table.insert(p.verts, y);
						table.insert(p.verts, nx);
						table.insert(p.verts, ny);
						table.remove(vlist,k);
						break;
					end
				elseif(left == 0) then
					table.remove(vlist,k);
					break;
				end
			end
			if(#vlist == count) then
				error("Polygon is not simple. Please remove any edges that cross over.",2);
			end
		end
	
		--Insert the final triangle to the triangle list.
		table.insert(p.verts, vlist[1].x or vlist[1][1]);
		table.insert(p.verts, vlist[1].y or vlist[1][2]);
		table.insert(p.verts, vlist[2].x or vlist[2][1]);
		table.insert(p.verts, vlist[2].y or vlist[2][2]);
		table.insert(p.verts, vlist[3].x or vlist[3][1]);
		table.insert(p.verts, vlist[3].y or vlist[3][2]);
		
		if(p.texture ~= nil) then
			if(filltype == imagic.TEX_FILL) then
				p.uvs = {};
				for i = 1, #p.verts, 2 do
					local x = p.verts[i];
					local y = p.verts[i+1];
					table.insert(p.uvs, (x-minx)/(maxx-minx))
					table.insert(p.uvs, (y-miny)/(maxy-miny))
				end
			elseif(filltype == imagic.TEX_PLACE) then
				p.uvs = {};
				for i = 1, #p.verts, 2 do
					local x = p.verts[i];
					local y = p.verts[i+1];
					table.insert(p.uvs, (x-minx)/(p.texture.width-minx))
					table.insert(p.uvs, (y-miny)/(p.texture.height-miny))
				end
			alignUVs(p.uvs, ((maxx-minx)/p.texture.width), ((maxy-miny)/p.texture.height), texalign, imagic.ALIGN_TOPLEFT);
			end
		end
		
		alignVerts(p.verts,maxx-minx,maxy-miny, align, imagic.ALIGN_TOPLEFT);
		alignVerts(p.outlineverts,maxx-minx,maxy-miny, align, imagic.ALIGN_TOPLEFT);
		
	-- Create a box-type border (hollow box) --
	elseif(args.primitive == imagic.TYPE_BOXBORDER) then
		nilcheck(args,"width");
		nilcheck(args,"height");
		nilcheck(args,"depth");
		p._renderType = Graphics.GL_TRIANGLES;
		align = args.align or imagic.ALIGN_TOPLEFT;
		if(type(args.depth) == "number") then
			p.verts = makeBoxBorderVerts(args.depth, args.width, args.height);
		else
			p.verts = makeVariableBoxBorderVerts(args.depth.left, args.depth.top, args.depth.right, args.depth.bottom, args.width, args.height);
		end
		alignVerts(p.verts,args.width,args.height, align, imagic.ALIGN_TOPLEFT);
		if(p.texture ~= nil) then
			if(p.texture.__type ~= nil and p.texture.__type == "BorderImage") then
				p.uvs = makeVariableBoxBorderVerts(p.texture.left,p.texture.top,p.texture.right,p.texture.bottom, 1, 1);
				p.texture = p.texture.texture;
			else
				p.uvs = makeBoxBorderVerts(1/3, 1, 1);
			end
		end
		
	-- Create a circle-type border (hollow circle) --
	elseif(args.primitive == imagic.TYPE_CIRCLEBORDER) then
		nilcheck(args,"radius");
		nilcheck(args,"depth");
		p._renderType = Graphics.GL_TRIANGLE_STRIP;
		align = args.align or imagic.ALIGN_CENTRE;
		local density = args.density or math.ceil(math.sqrt(args.radius)*6);
		p.verts = {}
		local theta = 0;
		local st = 0;
		local ct = 1;
		for i=0,density-1 do
			local nt = ((i+1)/density)*math.pi*2;
			local nst = math.sin(nt);
			local nct = math.cos(nt);
			table.insert(p.verts, st*(args.radius-args.depth));
			table.insert(p.verts, -ct*(args.radius-args.depth));
			table.insert(p.verts, st*args.radius);
			table.insert(p.verts, -ct*args.radius);
			table.insert(p.verts, nst*(args.radius-args.depth));
			table.insert(p.verts, -nct*(args.radius-args.depth));
			table.insert(p.verts, nst*args.radius);
			table.insert(p.verts, -nct*args.radius);
			
			theta = nt;
			st = nst;
			ct = nct;
		end
		alignVerts(p.verts,2*args.radius,2*args.radius, align, imagic.ALIGN_CENTRE);
		if(p.texture ~= nil) then
			p.uvs = {}
			local t;
			if(p.texture.__type ~= nil and p.texture.__type == "BorderImage") then
				t = p.texture.top;
				p.texture = p.texture.texture;
			else
				t = 1/3;
			end
			for i=0,density-1 do
				table.insert(p.uvs, t);
				table.insert(p.uvs, t);
				table.insert(p.uvs, t);
				table.insert(p.uvs, 0);
				table.insert(p.uvs, 1-t);
				table.insert(p.uvs, t);
				table.insert(p.uvs, 1-t);
				table.insert(p.uvs, 0);
			end
		end
	end
	
	if(texrotation ~= 0) then
		p:RotateTexture(texrotation);
	end
	
	if(args.vertColors ~= nil) then
		p.vertColors = {};
		local i = 1;
		for _,v in ipairs(args.vertColors) do
			local c = hexToRGBA(v);
			p.vertColors[i] = c.r;
			p.vertColors[i+1] = c.g;
			p.vertColors[i+2] = c.b;
			p.vertColors[i+3] = c.a;
			i=i+4;
		end
	
	end
	return p;
end


-- Function for instant drawing of an image
-- Takes many of the same arguments as Graphics.draw, with the following additions:
-- rotation, colour, color, width, height, scene, vertexColours, vertColours, vertexColors, vertColors

function imagic.Draw(args)
	nilcheck(args, "x");
	nilcheck(args, "y");
	if((args.width == nil or args.height == nil) and args.texture == nil) then
		error("Must define either width, height or a texture to draw.",1);
	end
	local rot = args.rotation or 0;
	rot = rot*imagic.DEG2RAD;
	local col = args.colour or args.color or 0xFFFFFFFF;
	local align = args.align or imagic.ALIGN_TOPLEFT;
	
	local sourceWidth = 0;
	local sourceHeight = 0;
	local sourceX = 0;
	local sourceY = 0;
	local w = 0;
	local h = 0;
	if(args.texture ~= nil) then
		sourceWidth = args.sourceWidth or args.texture.width;
		sourceWidth = math.max(0,math.min(1,sourceWidth/args.texture.width));
		
		sourceHeight = args.sourceHeight or args.texture.height;
		sourceHeight = math.max(0,math.min(1,sourceHeight/args.texture.height));
		
		sourceX = args.sourceX or 0;
		sourceX = math.max(0,math.min(1-sourceWidth,sourceX/args.texture.width));
		
		sourceY = args.sourceY or 0;
		sourceY = math.max(0,math.min(1-sourceHeight,sourceY/args.texture.height));
	
		w = args.width or args.texture.width*sourceWidth;
		h = args.height or args.texture.height*sourceHeight;
	else
		w = args.width or 0;
		h = args.height or 0;
	end
	local scene = args.scene;
	if(scene == nil) then
		scene = args.sceneCoords;
	end
	
	local xoff,yoff = getAlignOffset(align, w, h);
	xoff = -xoff;
	yoff = -yoff;
	
	local vs = {xoff, yoff, xoff+w, yoff, xoff+w, yoff+h, xoff, yoff+h}
	
	local cs = 1;
	local sn = 0;
	if(rot ~= 0) then
		cs = math.cos(rot);
		sn = math.sin(rot);
	end
	for i=1,#vs,2 do
		local v = vs[i];
		vs[i] = (cs*vs[i]) - (sn*vs[i+1]) + args.x;
		vs[i+1] = (cs*vs[i+1]) + (sn*v) + args.y;
	end
	
	local ts = {sourceX, sourceY, math.min(1,sourceX+sourceWidth), sourceY, math.min(1,sourceX+sourceWidth), math.min(1,sourceY+sourceHeight), sourceX, math.min(1,sourceY+sourceHeight)};
	local vcs = args.vertexColours or args.vertColours or args.vertexColors or args.vertColors;
	local vcols;
	if(vcs ~= nil) then	
		vcols = {}
		for i=1,4 do
			local v = hexToRGBATable(vcs[i]);
			table.insert(vcols, v[1])
			table.insert(vcols, v[2])
			table.insert(vcols, v[3])
			table.insert(vcols, v[4])
		end
	end
	
	if(col ~= nil and type(col) == "number") then
		col = hexToRGBATable(col);
	end
	
	Graphics.glDraw{vertexCoords=vs, textureCoords=ts, vertexColors = vcols, color = col, texture = args.texture, primitive = Graphics.GL_TRIANGLE_FAN, sceneCoords = scene, priority = args.priority or args.z}
end


-- Function for instant drawing of a progress bar
--
-- Required named arguments are:
-- x, y, width, height
--
-- Optional named arguments are:
-- percent, align, baralign, bgwidth, bgheight, scene, sceneCoords, texture, colour, color, bgtexture, bgcolour, bgcolor, bgcol, priority, z, outline, outlinecolour, outlinecolor, outlinecol

function imagic.Bar(args)
	nilcheck(args, "x")
	nilcheck(args, "y")
	nilcheck(args, "width")
	nilcheck(args, "height")
	args.bgwidth = args.bgwidth or args.width+2;
	args.bgheight = args.bgheight or args.height+2;
	args.scene = args.scene;
	if(args.scene == nil) then
		args.scene = args.sceneCoords;
	end
	if(args.texture ~= nil) then
		args.colour = args.colour or args.color or 0xFFFFFFFF;
	else
		args.colour = args.colour or args.color or 0x00FF00FF;
	end
	args.bgtexture = args.bgtexture or args.bgtex;
	
	if(args.bgtexture ~= nil) then
		args.bgcolour = args.bgcolour or args.bgcolor or args.bgcol or 0xFFFFFFFF;
	else
		args.bgcolour = args.bgcolour or args.bgcolor or args.bgcol or 0x000000FF;
	end
	args.align = args.align or imagic.ALIGN_TOPLEFT;
	args.percent = args.percent or 1;
	args.percent = math.min(1,math.max(0,args.percent));
	local xs,ys = getAlignOffset(args.align, 1, 1);
	xs,ys = args.bgwidth*(0.5-xs), args.bgheight*(0.5-ys);
	imagic.Draw{x = args.x + xs, y = args.y + ys, align = imagic.ALIGN_CENTRE, texture = args.bgtexture, colour = args.bgcolour, width = args.bgwidth, height = args.bgheight, scene=args.scene, priority = args.priority or args.z}
	
	args.baralign = args.baralign or imagic.ALIGN_BOTTOMLEFT;
	if(args.baralign == imagic.ALIGN_TOP or args.baralign == imagic.ALIGN_BOTTOM or args.vertical) then
		-- Vertical bar
		local _,sb = getAlignOffset(args.baralign, 1, 1);
		sb = args.height*(0.5-sb)*(1-args.percent);
		imagic.Draw{x = args.x + xs, y = args.y + ys - sb, align = imagic.ALIGN_CENTRE, texture = args.texture, colour = args.colour, width = args.width, height = args.height*args.percent, scene=args.scene, priority = args.priority or args.z}
	else 
		-- Horizontal bar
		local sb = getAlignOffset(args.baralign, 1, 1);
		sb = args.width*(0.5-sb)*(1-args.percent);
		imagic.Draw{x = args.x + xs - sb, y = args.y + ys, align = imagic.ALIGN_CENTRE, texture = args.texture, colour = args.colour, width = args.width*args.percent, height = args.height, scene=args.scene, priority = args.priority or args.z}
	end
	
	if(args.outline) then
		local outlinecol = args.outlinecolour or args.outlinecolor or args.outlinecol or 0xFFFFFFFF;
		
		if(outlinecol ~= nil and type(outlinecol) == "number") then
			outlinecol = hexToRGBATable(outlinecol);
		end
		Graphics.glDraw{vertexCoords = 
		{args.x + xs - args.bgwidth*0.5, args.y + ys - args.bgheight*0.5, args.x + xs + args.bgwidth*0.5 + 1, args.y + ys - args.bgheight*0.5, args.x + xs + args.bgwidth*0.5 + 1, args.y + ys + args.bgheight*0.5 + 1, args.x + xs - args.bgwidth*0.5, args.y + ys + args.bgheight*0.5 + 1}, 
						primitive = Graphics.GL_LINE_LOOP, priority = args.priority or args.z, color=outlinecol, sceneCoords = args.scene};
	end
end

return imagic;