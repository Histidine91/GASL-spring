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

if gadgetHandler:IsSyncedCode() then

--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local spSetUnitRulesParam = Spring.SetUnitRulesParam
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local INITIAL_SPIRIT = 0	-- don't change this except for testing
-- make sure these values matche the ones in unit_morale
-- FIXME: should probably use a global config for these...
local BASE_MORALE = 50
local MORALE_DAMAGE_SCALE_FACTOR = 0.5

local spiritDefs = {
  [UnitDefNames.luckystar.id] = true,
  [UnitDefNames.kungfufighter.id] = true,
  [UnitDefNames.happytrigger.id] = true,
  [UnitDefNames.sharpshooter.id] = true,
}
local spiritUnits = {}
_G.spiritUnits = spiritUnits

local invalidWeapons = {}
for i=1,#WeaponDefs do
  if (WeaponDefs[i].customParams or {}).special then
    invalidWeapons[i] = true
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function GG.GetUnitSpirit(unitID)
  return spiritUnits[unitID] and spiritUnits[unitID].spirit
end

local function SetSpiritRaw(unitID, unitDefID, unitTeam, newSpirit)
  local currSpirit = spiritUnits[unitID].spirit
  if newSpirit > 100 then
    newSpirit = 100
  end
  local unitDefID = Spring.GetUnitDefID(unitID)
  local unitTeam = Spring.GetUnitTeam(unitTeam)
  spiritUnits[unitID].spirit = newSpirit
  spSetUnitRulesParam(unitID, "spirit", newSpirit)
  if currSpirit < 100 and newSpirit == 100 then
    GG.EventWrapper.AddEvent("spiritFull", 10, unitID, unitDefID, unitTeam)
    SendToUnsynced("spirit_full", unitID)	-- handled by unit script with CEG
    GG.SpecialPower.RefreshCommandEnableState(unitID, unitDefID, unitTeam)
    Spring.PlaySoundFile("sounds/spirit_full.wav", 1.0, "ui")
  end
  spSetUnitRulesParam(unitID, "spirit", newSpirit)
end

local function SetSpirit(unitID, newSpirit)
  if spiritUnits[unitID] then
    local unitDefID = Spring.GetUnitDefID(unitID)
    local unitTeam = Spring.GetUnitTeam(unitTeam)
    SetSpiritRaw(unitID, unitDefId, unitTeam, newSpirit)
  end
end
GG.SetUnitSpirit = SetSpirit
GG.SetUnitSpiritRaw = SetSpiritRaw

local function CalculateSpiritChange(unitDefID, damage)
  local unitDef = UnitDefs[unitDefID]
  local health = unitDef.health
  local power = unitDef.customParams.cost	--unitDef.customParams.power
  return damage/health * power / 20
end

local function AddSpirit(unitID, unitDefID, unitTeam, targetID, targetDefID, damage)
  local currSpirit = spiritUnits[unitID].spirit
  -- high morale reduces damage taken, which in turn reduces spirit gain
  -- this reverses that effect
  if unitID == targetID then
    local morale = GG.GetMorale(unitDefID)
    if morale then
      local diffMorale = morale - BASE_MORALE
      local mult = diffMorale/BASE_MORALE * MORALE_DAMAGE_SCALE_FACTOR
      if mult == 1 then
	damage = 0
      else
	damage = damage / (1-mult)
      end
    end
  end
  
  local delta = CalculateSpiritChange(targetDefID, damage)
  local newSpirit = currSpirit + delta
  SetSpiritRaw(unitID, unitDefID, unitTeam, newSpirit)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if invalidWeapons[weaponID] then
    return
  end
  if spiritUnits[unitID] then
    AddSpirit(unitID, unitDefID, unitTeam, unitID, unitDefID, damage)
  end
  if spiritUnits[attackerID] then
    AddSpirit(attackerID, attackerDefID, attackerTeam, unitID, unitDefID, damage)
  end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  if spiritDefs[unitDefID] then
    spiritUnits[unitID] = {unitDefID = unitDefID, unitTeam = unitTeam, allyTeam = Spring.GetUnitAllyTeam(unitID), spirit = INITIAL_SPIRIT}
    spSetUnitRulesParam(unitID, "spirit", INITIAL_SPIRIT)
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  spiritUnits[unitID] = nil
end

function gadget:GameFrame(n)
  --SendToUnsynced("spirit_GameFrame", n)
end

function gadget:Initialize()
  local units = Spring.GetAllUnits()
  for i=1,#units do
    local unitID = units[i]
    local unitDefID = Spring.GetUnitDefID(unitID)
    local team = Spring.GetUnitTeam(unitID)
    gadget:UnitCreated(unitID, unitDefID)
  end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------
local spGetUnitViewPosition = Spring.GetUnitViewPosition
local spGetUnitVectors = Spring.GetUnitVectors

local FEATHER_PERIOD = 15

local Lups

local feather = {
  class = "SimpleParticles2",
  options = {
    life         = 90,
    lifeSpread   = 15,
    speed	 = 3,
    speedSpread  = 1,
    colormap     = { {1, 1, 1, 0.01}, {1, 1, 1, 0.01}, {1, 1, 1, 0.01}, {1, 1, 1, 0} },
    rotSpeed     = 0.3,
    rotFactor    = 1.0,
    rotFactorSpread = -2.0,
    rotairdrag	= 1,
    rotSpread	= 360,
    size	= 5,
    emitVector	= {0,0,1},
    emitRotSpread	= 10,
    texture	= "bitmaps/CC/feather.png",
    count	= 1,
  }
}

local burst = {
  class = "Bursts",
  options = {
    life       = 45,
    rotSpeed   = 8,
    rotSpread  = 3,
    arc        = 30,
    arcSpread  = 0,
    size       = 35,
    sizeSpread = 10,
    colormap   = { {1, 1, 1, 0.3}, {1, 1, 1, 0.3}, {1, 1, 1, 0} },
    directional= true,
    count      = 30,
    sizeGrowth = 6,
  }
}

-- need this because SYNCED.tables are merely proxies, not real tables
local function MakeRealTable(proxy)
  local ret = {}
  for i,v in spairs(proxy) do
    if type(v) == "table" then
      ret[i] = MakeRealTable(v)
    else
      ret[i] = v
    end
  end
  return ret
end

local function SpawnFeather(unitID, data)
  local fx = feather
  local x, y, z = spGetUnitViewPosition(unitID)
  local vector = spGetUnitVectors(unitID)
  
  for i=1,3 do
    vector[i] = -vector[i]
  end
  
  --fx.options.unit      = unitID
  fx.options.unitDefID = data.unitDefID
  fx.options.team      = data.unitTeam
  fx.options.allyTeam  = data.allyTeam
  fx.options.pos = {x, y, z}
  fx.options.emitVector = vector
  Lups.AddParticles(fx.class,fx.options)
end

local function SpiritFull(_, unitID)
  local fx = burst
  local data = MakeRealTable(SYNCED.spiritUnits[unitID])
  
  fx.options.unit      = unitID
  fx.options.unitDefID = data.unitDefID
  fx.options.team      = data.unitTeam
  fx.options.allyTeam  = data.allyTeam
  Lups.AddParticles(fx.class,fx.options)
  
  Script.LuaUI.SpiritFullEvent(unitID)
end

local function GameFrame(_, n)
  if (n%FEATHER_PERIOD == 0) then
    -- TODO add to specific pieces
    for unitID, data in spairs(SYNCED.spiritUnits) do
      data = MakeRealTable(data)
      if data.spirit == 100 then
	SpawnFeather(unitID, data)
      end
    end
  end
end

function gadget:Update()
  if (not Lups) then
    Lups = GG['Lups']
  end
end

function gadget:Initialize()
  gadgetHandler:AddSyncAction("spirit_GameFrame", GameFrame)
  gadgetHandler:AddSyncAction("spirit_full", SpiritFull)
end

function gadget:Shutdown()
  gadgetHandler:RemoveSyncAction("spirit_GameFrame")
  gadgetHandler:RemoveSyncAction("spirit_full")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
