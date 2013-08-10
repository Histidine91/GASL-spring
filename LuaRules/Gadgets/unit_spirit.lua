--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Spirit",
    desc      = "Voltage to the max!",
    author    = "KingRaptor (L.J. Lim)",
    date      = "2013.05.18",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if (not gadgetHandler:IsSyncedCode()) then
  return false  --  silent removal
end

local spSetUnitRulesParam = Spring.SetUnitRulesParam

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local spiritDefs = {
  [UnitDefNames.luckystar.id] = true,
  [UnitDefNames.kungfufighter.id] = true,
  [UnitDefNames.happytrigger.id] = true,
}
local units = {}

function GG.GetUnitSpirit(unitID)
  return units[unitID]
end

local function CalculateSpiritChange(unitDefID, damage)
  local unitDef = UnitDefs[unitDefID]
  local health = unitDef.health
  local power = unitDef.customParams.cost
  return damage/health * power / 20
end

local function AddSpirit(unitID, unitDefID, unitTeam, targetDefID, damage)
  local currSpirit, newSpirit = units[unitID], units[unitID] + CalculateSpiritChange(unitDefID, damage)
  units[unitID] = newSpirit
  if currSpirit < 100 and newSpirit >= 100 then
    GG.EventWrapper.AddEvent("spiritFull", 10, unitID, unitDefID, unitTeam)
  end
  if units[unitID] > 100 then units[unitID] = 100 end
  spSetUnitRulesParam(unitID, "spirit", units[unitID])
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if units[unitID] then
    AddSpirit(unitID, unitDefID, unitTeam, unitDefID, damage)
  end
  if units[attackerID] then
    AddSpirit(attackerID, attackerDefID, attackerTeam, unitDefID, damage)
  end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  if spiritDefs[unitDefID] then
    units[unitID] = 0
    spSetUnitRulesParam(unitID, "spirit", 0)
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  units[unitID] = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
