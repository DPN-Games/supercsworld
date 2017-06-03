--------------------------------------------------
--============== Barebones Framework ==============--
--                                              --
-- Load in a level with something like:         --
--   local barebones = loadAPI("barebones")     --
--------------------------------------------------

-- Declare our API object
local barebones = {}

function barebones.onInitAPI()
	registerEvent(barebones, "onLoop", "onLoop", false)

	-- Put stuff that happens upon loading here
end

function barebones.onLoop()
	-- Put onLoop stuff here
end

return barebones