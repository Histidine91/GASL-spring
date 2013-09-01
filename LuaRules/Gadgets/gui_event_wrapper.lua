--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name = "Event Wrapper",
		desc = "Wraps event messages to LuaUI",
		author = "KingRaptor (L.J. Lim)",
		date = "20130725",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
--SYNCED
--------------------------------------------------------------------------------
--[[
events to record:
	+enemy killed
	+shot missed
	+enemy shot evaded
	enemy damaged
	+took damage (low, moderate, severe)
	+critical hit
	+energy low/critical
	+suppression (low, moderate, severe)
	received repair		-need gadget
	+received resupply
	+command received	- delegate to widget
	+spirit maxed
	+using special ability
	+engaging new target
]]--

local function AddEvent(eventType, magnitude, unitID, unitDefID, unitTeam, unitID2, unitDefID2, unitTeam2)
	SendToUnsynced("WrapEvent", eventType, magnitude, unitID, unitDefID, unitTeam, unitID2, unitDefID2, unitTeam2)
end

function gadget:Initialize()
	GG.EventWrapper = {
		AddEvent = AddEvent
	}
end

function gadget:Shutdown()
	GG.EventWrapper = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
--UNSYNCED
--------------------------------------------------------------------------------
local function AddEvent(_, eventType, magnitude, unitID, unitDefID, unitTeam, unitID2, unitDefID2, unitTeam2)
	Script.LuaUI.ChatterEvent(eventType, magnitude, unitID, unitDefID, unitTeam, unitID2, unitDefID2, unitTeam2)
end

function gadget:Initialize()
    gadgetHandler:AddSyncAction("WrapEvent", AddEvent)
end
  
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
