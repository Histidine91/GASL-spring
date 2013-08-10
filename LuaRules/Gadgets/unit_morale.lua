--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Morale",
    desc      = "Handles morale stuff",
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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local BASE_MORALE = 50
local DAMAGE_SCALE_FACTOR = 0.5

local moraleByUnitDef = {}

for i=1,#UnitDefs do
  moraleByUnitDef[i] = (UnitDefs[i].customParams or {}).morale
end

function GG.GetMorale(unitDefID)
  return moraleByUnitDef[unitDefID]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam)
  local baseDamage = damage
  if moraleByUnitDef[attackerDefID] then
    local morale = moraleByUnitDef[attackerDefID]
    local diffMorale = morale - BASE_MORALE
    local mult = diffMorale/BASE_MORALE
    local deltaDamage = baseDamage * mult
    damage = damage + deltaDamage * DAMAGE_SCALE_FACTOR
  end
  if moraleByUnitDef[unitDefID] then
    local morale = moraleByUnitDef[unitDefID]
    local diffMorale = morale - BASE_MORALE
    local mult = diffMorale/BASE_MORALE
    local deltaDamage = baseDamage * mult
    damage = damage - deltaDamage * DAMAGE_SCALE_FACTOR
  end
  return damage
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
