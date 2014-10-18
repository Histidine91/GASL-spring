--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Mission Info Helper",
    desc      = "Helper gadget for mission stuff",
    author    = "KingRaptor",
    date      = "2012.12.16",
    license   = "Public Domain",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (not gadgetHandler:IsSyncedCode()) then
  return
end

if (not VFS.FileExists("mission.lua")) then
  return
end
--------------------------------------------------------------------------------
-- synced
--------------------------------------------------------------------------------
local MIN_GAMEFRAME = 30*60*2	-- damage dealt before this time will be disregarded
local gameframe = 0
local invulnerableUnits = {}
local nonNeutrals = {}
local angels = {}

local function SetUnitInvulnerable(unitID, bool)
  if bool == true then
    invulnerableUnits[unitID] = true
    if Spring.GetUnitHealth(unitID) < 0 then
      Spring.SetUnitHealth(unitID, 1)
    end
  elseif bool == false then
    invulnerableUnits[unitID] = nil
  else
    Spring.Log(gadget:GetInfo().name, LOG.ERROR, "invalid parameters for SetUnitInvulnerable")
  end
end

local function SuspendCombat()
  local units = Spring.GetAllUnits()
  for i=1,#units do
    local unitID = units[i]
    if not Spring.GetUnitNeutral(unitID) then
      nonNeutrals[unitID] = true
      Spring.SetUnitNeutral(unitID, true)
    end
    --SetUnitInvulnerable(unitID, true)
  end
  Spring.SetGameRulesParam("combatSuspended", 1)
  Spring.GiveOrderToUnitArray(units, CMD.STOP, {}, 0)
end

local function ResumeCombat()
  for unitID in pairs(nonNeutrals) do
    Spring.SetUnitNeutral(unitID, false)
  end
  Spring.SetGameRulesParam("combatSuspended", 0)
end

local function SetAngelsInvulnerable(bool)
  for unitID in pairs(angels) do
    SetUnitInvulnerable(unitID, bool)
  end
end

local function ElsiorDestroyed(unitID)
  SetUnitInvulnerable(unitID, true)
  SuspendCombat()
  local env = Spring.UnitScript.GetScriptEnv(unitID)
  Spring.UnitScript.CallAsUnit(unitID, env.DyingTrigger)
  Spring.SetGameRulesParam("gameOver", 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if invulnerableUnits[unitID] then
    return 0
  end
  if (GG.mission.unitGroups[unitID] or {})["Elsior"] and not paralyzer then
    local health = Spring.GetUnitHealth(unitID)
    if health - damage < 0 then
      ElsiorDestroyed(unitID)
      GG.mission.ExecuteTriggerByName("Elsior Destroyed")
      return health-1
    end
  end
  return damage
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  angels[unitID] = UnitDefs[unitDefID].customParams.angel
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  invulnerableUnits[unitID] = nil
  nonNeutrals[unitID] = nil
  angels[unitID] = nil
end

function gadget:Initialize()
  GG.SetUnitInvulnerable = SetUnitInvulnerable
  GG.SuspendCombat = SuspendCombat
  GG.ResumeCombat = ResumeCombat
  GG.SetAngelsInvulnerable = SetAngelsInvulnerable
end

function gadget:Shutdown()
  GG.SetUnitInvulnerable = nil
  GG.SuspendCombat = nil
  GG.ResumeCombat = nil
  GG.SetAngelsInvulnerable = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------