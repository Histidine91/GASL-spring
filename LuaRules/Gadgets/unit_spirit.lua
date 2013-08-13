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

local spiritDefs = {
  [UnitDefNames.luckystar.id] = true,
  [UnitDefNames.kungfufighter.id] = true,
  [UnitDefNames.happytrigger.id] = true,
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

local function SetSpirit(unitID, unitDefID, unitTeam, newSpirit)
  if spiritUnits[unitID] then
    local currSpirit = spiritUnits[unitID].spirit
    if newSpirit > 100 then
      newSpirit = 100
    end	
    spiritUnits[unitID].spirit = newSpirit
    spSetUnitRulesParam(unitID, "spirit", newSpirit)
    if currSpirit < 100 and newSpirit == 100 then
      GG.EventWrapper.AddEvent("spiritFull", 10, unitID, unitDefID, unitTeam)
      SendToUnsynced("spirit_max", unitID)	-- handled by unit script with CEG
      GG.SetSpecialWeaponEnabled(unitID, unitDefID, unitTeam, true)
    end
    spSetUnitRulesParam(unitID, "spirit", newSpirit)
  end
end
GG.SetUnitSpirit = SetSpirit

local function CalculateSpiritChange(unitDefID, damage)
  local unitDef = UnitDefs[unitDefID]
  local health = unitDef.health
  local power = unitDef.customParams.cost
  return damage/health * power / 20
end

local function AddSpirit(unitID, unitDefID, unitTeam, targetDefID, damage)
  local currSpirit = spiritUnits[unitID].spirit
  local newSpirit = currSpirit + CalculateSpiritChange(targetDefID, damage)
  SetSpirit(unitID, unitDefID, unitTeam, newSpirit)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  if invalidWeapons[weaponID] then
    return
  end
  if spiritUnits[unitID] then
    AddSpirit(unitID, unitDefID, unitTeam, unitDefID, damage)
  end
  if spiritUnits[attackerID] then
    AddSpirit(attackerID, attackerDefID, attackerTeam, unitDefID, damage)
  end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  if spiritDefs[unitDefID] then
    spiritUnits[unitID] = {unitDefID = unitDefID, unitTeam = unitTeam, allyTeam = Spring.GetUnitAllyTeam(unitID), spirit = 0}
    spSetUnitRulesParam(unitID, "spirit", 0)
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

local function MaxSpirit(_, unitID)
  local fx = burst
  local data = MakeRealTable(SYNCED.spiritUnits[unitID])
  
  fx.options.unit      = unitID
  fx.options.unitDefID = data.unitDefID
  fx.options.team      = data.unitTeam
  fx.options.allyTeam  = data.allyTeam
  Lups.AddParticles(fx.class,fx.options)
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
  gadgetHandler:AddSyncAction("spirit_max", MaxSpirit)
end

function gadget:Shutdown()
  gadgetHandler:RemoveSyncAction("spirit_GameFrame")
  gadgetHandler:RemoveSyncAction("spirit_max")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
