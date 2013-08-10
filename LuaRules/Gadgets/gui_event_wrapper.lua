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
	shot missed		-need gadget
	enemy shot evaded	-need gadget
	-enemy damaged
	+took damage (low, moderate, severe)
	+critical hit
	+energy low/critical
	+suppression (low, moderate, severe)
	received repair		-need gadget
	received resupply	-need gadget
	+command received	- delegate to widget
	+spirit maxed
	using special ability	- need gadget
	+engaging new target
]]--

local DAMAGE_LEVELS = {
	{0.25, "severe"},
	{0.5, "moderate"},
	{0.8, "minor"}
}

local function AddEvent(eventType, magnitude, unitID, unitDefID, unitTeam, unitID2, unitDefID2, unitTeam2)
	SendToUnsynced("WrapEvent", eventType, magnitude, unitID, unitDefID, unitTeam, unitID2, unitDefID2, unitTeam2)
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID,
                            attackerID, attackerDefID, attackerTeam)
	-- TODO striate into low/moderate/severe, or let widget handle?
	local health, maxHealth = Spring.GetUnitHealth(unitID)
	local healthFraction, healthFractionOld = health/maxHealth, (health + damage)/maxHealth
	for i=1,#DAMAGE_LEVELS do
		local params = DAMAGE_LEVELS[i]
		if healthFraction <= params[1] and healthFractionOld > params[1] then
			AddEvent("unitDamaged_" .. params[2], damage, unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
			break
		end
	end
	--AddEvent("unitDamaged", damage, unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	local attackerID = Spring.GetUnitLastAttacker(unitID)
	local attackerDefID, attackerTeam
	if attacker and attacker > 0 then
		attackerDefID = Spring.GetUnitDefID(attackerID)
		attackerTeam = Spring.GetUnitTeam(attackerID)
	end
	AddEvent("unitDestroyed", UnitDefs[unitDefID].power^0.5, unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
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
