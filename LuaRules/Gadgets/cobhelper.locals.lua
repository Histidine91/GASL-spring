--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Automatically generated local definitions

local spGetGameFrame = Spring.GetGameFrame

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name = "COB helper",
		desc = "some helper functions for COB",
		author = "KDR_11k (David Becker)",
		date = "2008-08-24",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

if (gadgetHandler:IsSyncedCode()) then

--SYNCED

local function GameFrame()
	return spGetGameFrame()
end

function gadget:Initialize()
	gadgetHandler:RegisterGlobal("GetGameFrame", GameFrame)
end

else

--UNSYNCED

return false

end
