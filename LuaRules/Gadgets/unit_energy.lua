--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Energy",
    desc      = "Makes the universe go round",
    author    = "KingRaptor (L.J. Lim)",
    date      = "2013.08.07",
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
local spGetUnitDefID = Spring.GetUnitDefID

local ENERGY_LEVELS = {
  {0.3, "critical"},
  {0.55, "low"},
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- N.B. -1 energy means infinite

local defs = {}
local units = {}

for i=1,#UnitDefs do
  local unitDef = UnitDefs[i]
  if unitDef.customParams.energy then
    defs[i] = tonumber(unitDef.customParams.energy)
  end
end

local function GetUnitEnergy(unitID)
  local unitDefID = spGetUnitDefID(unitID)
  return units[unitID], defs[unitDefID]
end

local function UseUnitEnergy(unitID, usage)
  local unitDefID = spGetUnitDefID(unitID)
  if defs[unitDefID] == -1 then
    return true, nil, -1
  end
  if (not units[unitID]) or (units[unitID] < usage) then	-- not enough energy
    return false, nil, defs[unitDefID]
  end
  
  local oldAmount = units[unitID]
  local newAmount = units[unitID] - usage
  units[unitID] = newAmount
  spSetUnitRulesParam(unitID, "energy", newAmount/defs[unitDefID])
  
  -- GUI event
  for i=1,#ENERGY_LEVELS do
    local params = ENERGY_LEVELS[i]
    if newAmount >= params[1] and oldAmount < params[1] then
      GG.EventWrapper.AddEvent("unitEnergy_" .. params[2], damage, unitID, unitDefID, Spring.GetUnitTeam(unitID))
      break
    end
  end
  
  return true, newAmount, defs[unitDefID]
end

local function SetUnitEnergy(unitID, newAmount)
  local unitDefID = spGetUnitDefID(unitID)
  units[unitID] = newAmount
  spSetUnitRulesParam(unitID, "energy", newAmount/defs[unitDefID])
  return true, newAmount, defs[unitDefID]
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  if defs[unitDefID] and defs[unitDefID] ~= -1 then
    units[unitID] = defs[unitDefID]
    spSetUnitRulesParam(unitID, "energy", 1, {inlos = true})
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  units[unitID] = nil
end

function gadget:Initialize()
  GG.Energy = GG.Energy or {}
  GG.Energy.GetUnitEnergy = GetUnitEnergy
  GG.Energy.UseUnitEnergy = UseUnitEnergy
  GG.Energy.SetUnitEnergy = SetUnitEnergy
  
  local units = Spring.GetAllUnits()
  for i=1,#units do
    local unitID = units[i]
    local unitDefID = Spring.GetUnitDefID(unitID)
    local unitTeam = Spring.GetUnitTeam(unitID)
    gadget:UnitCreated(unitID, unitDefID, unitTeam)
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
