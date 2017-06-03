local internalProfiler = require("jit.profile")
local profilerAPI = {}

local isProfilerActive = false
local collectedSample = {}
local collectedSampleLines = {}
local collectedSampleMode = {N={}, I={}, C={}, G={}, J={}}
local totalSamples = 0
local vmModeNames = {N="JIT Compiled", I="Interpreted", C="C/C++ Code", G="Garbage Collection", J="JIT Overhead"}

local profilerGraph = {};
local profilerindex = 1;
local profilerLegend = {};
profilerLegend.lua = {r=0.125,g=0.615,b=1};
profilerLegend.draw = {r=0.2,g=0.9,b=0.4};
profilerLegend.other = {r=1,g=1,b=0.6};
local lagging = false;

local function profilerDump(th, samples, vmmode)
	local stackStr = internalProfiler.dumpstack(th, "F`l;", -100)
	
	--Don't log data about the profiler.
	if(string.find(stackStr, "[`;^]profiler.lua") == nil) then
		local samplesCounted = false
		for s in string.gmatch(stackStr, "[^;]+") do
			local parts = {}
			for p in string.gmatch(s, "[^`]+") do
				table.insert(parts, p)
			end
			local func = parts[1]
			local line = parts[2]
			if (string.find(func, "mainV2") == nil) then
				collectedSample[func] = (collectedSample[func] or 0) + samples
				collectedSampleMode[vmmode][func] = (collectedSampleMode[vmmode][func] or 0) + samples
				if (collectedSampleLines[func] == nil) then
					collectedSampleLines[func] = {}
				end
				collectedSampleLines[func][line] = (collectedSampleLines[func][line] or 0) + samples
				samplesCounted = true
			end
		end
		if (samplesCounted) then
			totalSamples = totalSamples + samples
		end
	end
end

function profilerAPI.onInitAPI()
	registerEvent(profilerAPI, "onKeyboardPress")
	registerEvent(profilerAPI, "onDraw")
end

local outputDisplayed = false;

function profilerAPI.onKeyboardPress(keyCode)
	if(not outputDisplayed) then
		if(keyCode == VK_F3)then
			if(not isProfilerActive)then
				profilerAPI.start()
			else
				profilerAPI.stop()
			end
		end
	end
end

local avgs = {};
local avgn = 0;
local profilertime = 0;

function profilerAPI.onDraw()
	outputDisplayed = false;
	if (not isProfilerActive) then return end
	local starttime = Misc.clock();
	
	local waslagging = lagging;
	local height = 200;
	local range = 128;
	local scale = 3;
	
	-- This can be replaced by some graphing stuff some time
	local data = Misc.__getPerfTrackerData()
	if (data ~= nil) then
		
		local yoffset = height+25
		local frametime = 0;
		for k, v in pairs(data) do
			if(profilerGraph[k] == nil) then
				profilerGraph[k] = {}
				avgs[k] = 0;
			end
			
			if(k=="lua") then
				v = v-(profilertime*1000);
			end
			
			frametime = frametime + v;
			v = v / 15.6
			if(avgn == range and profilerGraph[k][profilerindex] ~= nil) then
				avgs[k] = math.max(avgs[k]+(v-profilerGraph[k][profilerindex])/avgn,0);
			elseif(avgn < range) then
				avgs[k] = avgs[k]*avgn + v;
				avgs[k] = math.max(avgs[k]/(avgn+1), 0);
			end
			
			profilerGraph[k][profilerindex] = v;
			v = v*100;
			Text.printWP(string.format("% 5s:",k), 30, yoffset,10);
			Text.printWP(string.format("% 4.1f%%", v), 140, yoffset,10)
			Text.printWP("Avg:", 300, yoffset,10)
			Text.printWP(string.format("% 4.1f%%", avgs[k]*100), 370, yoffset,10)
			Graphics.glDraw{vertexCoords={10,yoffset,25,yoffset,25,yoffset+15,10,yoffset+15}, color={profilerLegend[k].r,profilerLegend[k].g,profilerLegend[k].b,1}, primitive=Graphics.GL_TRIANGLE_FAN, priority=10};
			yoffset = yoffset + 15
		end
		
		if(avgs.total == nil) then
			avgs.total = 0;
			avgs.totlist = {};
		end
		
		if(avgn == range and avgs.totlist[profilerindex] ~= nil) then
			avgs.total = math.max(avgs.total+(frametime-avgs.totlist[profilerindex])/avgn,0);
		elseif(avgn < range) then
			avgs.total = avgs.total*avgn + frametime;
			avgs.total = math.max(avgs.total/(avgn+1),0);
		end
			
		avgs.totlist[profilerindex] = frametime;
				
		if(avgn < range) then
			avgn = avgn + 1;
		end
		
		Text.printWP("Frame:", 30, yoffset,10);
		Text.printWP(string.format("% 4.1fms", frametime), 140, yoffset,10)
		Text.printWP("Avg:", 300, yoffset,10);
		Text.printWP(string.format("% 4.1fms", avgs.total), 370, yoffset,10)
		lagging = frametime > 15.6
			
	else
		lagging = false;
	end
	
	if(profilerGraph.dat == nil) then
		profilerGraph.dat = {}
		profilerGraph.dat.verts = {};
		profilerGraph.dat.vcols = {};
		profilerGraph.dat.lagverts = {};
	end
	
	for i = 1,#profilerGraph.dat.verts,2 do
		if(profilerGraph.dat.verts[i] ~= nil) then
			profilerGraph.dat.verts[i] = profilerGraph.dat.verts[i]-scale;
		end
	end
	
	local li = 1;
	
	while(li <= #profilerGraph.dat.lagverts) do
		if(profilerGraph.dat.lagverts[li] ~= nil) then
			profilerGraph.dat.lagverts[li] = math.max(profilerGraph.dat.lagverts[li]-scale,10);
			profilerGraph.dat.lagverts[li+2] = math.max(profilerGraph.dat.lagverts[li+2]-scale,10);
			profilerGraph.dat.lagverts[li+4] = math.max(profilerGraph.dat.lagverts[li+4]-scale,10);
			profilerGraph.dat.lagverts[li+6] = math.max(profilerGraph.dat.lagverts[li+6]-scale,10);
			profilerGraph.dat.lagverts[li+8] = math.max(profilerGraph.dat.lagverts[li+8]-scale,10);
			profilerGraph.dat.lagverts[li+10] = math.max(profilerGraph.dat.lagverts[li+10]-scale,10);
			if(profilerGraph.dat.lagverts[li] == 10 and profilerGraph.dat.lagverts[li+2] == 10) then
				local i;
				for i = li,li+11,1 do
					table.remove(profilerGraph.dat.lagverts,li);
				end
			else
				li = li + 12;
			end
		else
			li = li + 12;
		end
	end
	
	local y0 = height + 10;
	local y1 = height + 10;
	local y2;
	local y3;
	
	local preindex = profilerindex-1;
	if(preindex < 1) then
		preindex = preindex + range;
	end

	local i = 0;
	for k,v in pairs(profilerGraph) do
		if(k ~= "dat") then
			if(v ~= nil and v[profilerindex] ~= nil and v[preindex] ~= nil) then
				y2 = math.max(10,y0-v[profilerindex]*height*0.75);
				y3 = math.max(10,y1-(v[preindex])*height*0.75);
				
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 1] = range*scale + 10;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 2] = y2;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 3] = (range-1)*scale + 10;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 4] = y3;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 5] = range*scale + 10;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 6] = y0;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 7] = range*scale + 10;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 8] = y0;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 9] = (range-1)*scale + 10;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 10] = y3;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 11] = (range-1)*scale + 10;
				profilerGraph.dat.verts[(profilerindex-1)*36 + (i*12) + 12] = y1;
				
				
				for j = 1,6,1 do
					profilerGraph.dat.vcols[(profilerindex-1)*72 + (i*24) + (j*4) - 3] = profilerLegend[k].r;
					profilerGraph.dat.vcols[(profilerindex-1)*72 + (i*24) + (j*4) - 2] = profilerLegend[k].g;
					profilerGraph.dat.vcols[(profilerindex-1)*72 + (i*24) + (j*4) - 1] = profilerLegend[k].b;
					profilerGraph.dat.vcols[(profilerindex-1)*72 + (i*24) + (j*4)] = 1;
				end
			
				
				i = i + 1;
				y0 = y2;
				y1 = y3;
			end
		end
	end
	
		if(lagging and not waslagging) then
			table.insert(profilerGraph.dat.lagverts, range*scale + 10);
			table.insert(profilerGraph.dat.lagverts, 10);
			table.insert(profilerGraph.dat.lagverts, (range-1)*scale + 10);
			table.insert(profilerGraph.dat.lagverts, 10);
			table.insert(profilerGraph.dat.lagverts, range*scale + 10);
			table.insert(profilerGraph.dat.lagverts, 10+height);
			table.insert(profilerGraph.dat.lagverts, range*scale + 10);
			table.insert(profilerGraph.dat.lagverts, 10+height);
			table.insert(profilerGraph.dat.lagverts, (range-1)*scale + 10);
			table.insert(profilerGraph.dat.lagverts, 10);
			table.insert(profilerGraph.dat.lagverts, (range-1)*scale + 10);
			table.insert(profilerGraph.dat.lagverts, 10+height);
		elseif(waslagging) then
			profilerGraph.dat.lagverts[#profilerGraph.dat.lagverts-5] = range*scale + 10;
			profilerGraph.dat.lagverts[#profilerGraph.dat.lagverts-7] = range*scale + 10;
			profilerGraph.dat.lagverts[#profilerGraph.dat.lagverts-11] = range*scale + 10;
		end
	
	Graphics.glDraw{vertexCoords={10,10,range*scale+10,10,range*scale+10,10+height,10,10+height}, primitive = Graphics.GL_TRIANGLE_FAN, color={0.5,0.5,0.5,0.5}, priority=10}
	
	Graphics.glDraw{vertexCoords=profilerGraph.dat.verts, vertexColors=profilerGraph.dat.vcols,priority=10}
	Graphics.glDraw{vertexCoords=profilerGraph.dat.lagverts, color={1,0,0,0.25},priority=10}
	Graphics.glDraw{vertexCoords={10,10+height*0.25,range*scale+10,10+height*0.25}, primitive = Graphics.GL_LINES, priority=10}
	profilerindex = ((profilerindex) % range) + 1;
	profilertime = Misc.clock()-starttime;
end

function profilerAPI.start()
	if(isProfilerActive)then return false end	-- Do not start profiling when profiler is already 
	profilerAPI.resetVars()
	isProfilerActive = true
	internalProfiler.start("li1", profilerDump)
	playSFX(4) -- For now (maybe remove later?)
	Misc.__enablePerfTracker()
end

local function perc(count, total)
	return string.format("%.1f%%", 100.0 * count / total)
end

function profilerAPI.stop()
	if(not isProfilerActive)then return false end	-- Cannot stop, if the profiler isn't even running
	Misc.__disablePerfTracker()
	isProfilerActive = false
	profilerGraph = {};
	profilerindex = 1;
	avgn = 0;
	avgs = {};
	internalProfiler.stop()
	playSFX(6) -- For now (maybe remove later?)
	
	local ord = {}
	for d,v in pairs(collectedSample) do -- Change collectedSample to collectedSampleMode.I to sort by interpreted sample count instead
		table.insert(ord, {v, d})
	end
	table.sort(ord, function(arg1, arg2)
		return arg1[1] > arg2[1]
	end)
	output = ""
	linecnt = 0
	for _,x in ipairs(ord) do
		local funcCnt = collectedSample[x[2]]
		local func = x[2]
		
		output = output .. "\n " .. (perc(funcCnt, totalSamples) .. "\t" ..  func)
		local firstMode = true
		
		for _, vmMode in ipairs({"N", "I", "C", "G", "J"}) do
			local modeCnt = collectedSampleMode[vmMode][func]
			if (modeCnt ~= nil) then
				if (firstMode) then
					output = output .. "\t"
				else
					output = output .. ", "
				end
				output = output .. perc(modeCnt, funcCnt) .. " " .. vmModeNames[vmMode]
				firstMode = false
			end
		end
		
		output = output .. "\n "
		local lines = {}
		for line,count in pairs(collectedSampleLines[func]) do
			if (count * 20 >= funcCnt) then
				table.insert(lines, {count, line})
			end
		end
		if (#lines > 1) then
			table.sort(lines, function(arg1, arg2)
				return arg1[1] > arg2[1]
			end)
			for _,line in ipairs(lines) do
				output = output .. "\t" ..  perc(line[1], funcCnt) .. "\t" .. line[2] .. "\n "
			end
		end
		
		linecnt = linecnt + 1
		if (linecnt > 200) then break end
	end
	local f = io.open("profiler.log", "w")
	f:write(output)
	f:close()
	outputDisplayed = true;
	Misc.showRichDialog("Profiler Output", "{\\rtf1\\b Collected Data:\\b0 \n"..output:gsub("\n","\\line").."}", true);
end

function profilerAPI.resetVars()
	if(isProfilerActive)then return false end	 -- Cannot reset, if the profiler is running.

	collectedSample = {}
	collectedSampleLines = {}
	collectedSampleMode = {N={}, I={}, C={}, G={}, J={}}
	totalSamples = 0
end


return profilerAPI

