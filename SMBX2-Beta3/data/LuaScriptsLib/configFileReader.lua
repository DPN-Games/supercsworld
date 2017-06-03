--configFileReader.lua
--v1.0.0
--Created by Horikawa Otane, 2016

local configFileReader = {}

function configFileReader.parseTxt(objectId)
	finalArray = {}
	local objectPath = Misc.resolveFile(objectId)
	if objectPath ~= nil then
		for line in io.lines(objectPath) do
			key, value = line:match("%s*(%S+)%s*=%s*(%S+)%s*")
			if(key ~= nil and value ~= nil) then
				if(value:match("^\".*\"$") or value:match("^'.*'$")) then -- string surrounded by ' ' or " " 
					value = string.sub(value, 2, -2)
				elseif(value:match("%f[%.%d]%d*%.?%d*%f[^%.%d%]]")) then -- numbers/decimals
					value = tonumber(value)
				elseif(value:match("true")) then -- boolean
					value = true
				elseif(value:match("false")) then 
					value = false
				--else 
				--  throw error ?
				end
				  
				finalArray[key] = value
			else
				Text.warn("Invalid line was passed to config file "..objectId..": "..line);
			end
		end
		return finalArray
	else
		return nil
	end
end

return configFileReader
