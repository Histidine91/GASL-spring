--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name = "Water Level Control",
		desc = "Changes the water level by changing the heightmap",
		author = "KingRaptor (L.J. Lim)",
		date = "2010-02-18",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

if not (gadgetHandler:IsSyncedCode()) then
	return
end

--SYNCED
local modopts = Spring.GetModOptions() or {}
local heightChange = -(modopts.changewaterlevel or 50)
Spring.Echo("Height change is "..heightChange)

local x = Game.mapSizeX
local z = Game.mapSizeZ

function gadget:Initialize()
	if heightChange ~= 0 then Spring.AdjustHeightMap(0,0,x,z,heightChange) end
end
