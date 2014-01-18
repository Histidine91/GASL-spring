--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Special Weapon/Ability Handler",
    desc      = "bla",
    author    = "KingRaptor (L.J. Lim)",
    date      = "2013.08.13",
    license   = "GNU GPL, v2 or later",
    layer     = 1,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
-- TODO: refactor to allow units with multiple specials
--------------------------------------------------------------------------------
include "LuaRules/Configs/special_weapon_defs.lua"

if gadgetHandler:IsSyncedCode() then
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitTeam	= Spring.GetUnitTeam
local spAreTeamsAllied	= Spring.AreTeamsAllied
local spGetUnitVectors	= Spring.GetUnitVectors

local COOLDOWN_INTERVAL = 3

local specialAbilitiesEnabled = Spring.GetModOptions().enableabilities ~= 0
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local targets = {}	--[unitID] = targetID
local coolingDownUnits = {}

-- helper funcs
local function GetDistance(x1, y1, z1, x2, y2, z2)
  local dist = ((x1 - x2)^2 + (z1 - z2)^2)
  dist = (dist + (z1 - z2)^2)^0.5
  return dist
end

local function GetUnitMidPos(unitID)
  local _,_,_,x,y,z = spGetUnitPosition(unitID, true)
  return x,y,z
end

local function GetTargetVector(unitID, tx, ty, tz)
  local frontDir, upDir = spGetUnitVectors(unitID)
  local ux, uy, uz = spGetUnitPosition(unitID)
  local dx, dy, dz = tx - ux, ty - uy, tz - uz
  dx, dy, dz, d = GG.Vector.Normalized(dx, dy, dz)
  
  local dotUp = dx * upDir[1] + dy * upDir[2] + dz * upDir[3]
  local dotFront = dx * frontDir[1] + dy * frontDir[2] + dz * frontDir[3]
  return dotUp, dotFront
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function SetTarget(unitID, target)
  targets[unitID] = target
end

local function GetTarget(unitID)
  return targets[unitID]
end

local function RefreshCommandEnableState(unitID, unitDefID, unitTeam)
  for _, powerName in pairs(unitDefsWithSpecials[unitDefID]) do
    local power = specialPowers[powerName]
    local cmdDescID = Spring.FindUnitCmdDesc(unitID, power.cmdDesc.id)
    if (cmdDescID) then
      local enabled = true
      if power.isSpiritAttack then
	enabled = (GG.GetUnitSpirit(unitID) or 0) == 100
      else
	enabled = not coolingDownUnits[unitID]
      end
      local cmdDesc = {disabled = not enabled}
      Spring.EditUnitCmdDesc(unitID, cmdDescID, cmdDesc)
    end
  end
end


-- actualy use the special
local function ExecuteCommand(cmdData, unitID, unitDefID, unitTeam, cmdParams)
  
  if not cmdData.isSpiritAttack then
    if coolingDownUnits[unitID] then
      return false
    end
  end
  if cmdData.energy then
    local success = GG.Energy.UseUnitEnergy(unitID, cmdData.energy)
    if not success then return false end
  end
  
  local target = cmdParams
  if #cmdParams == 1 then
    target = cmdParams[1]
  end
  SetTarget(unitID, target)

  if cmdData.scriptFunction then
    local env = Spring.UnitScript.GetScriptEnv(unitID)
    local func = env[cmdData.scriptFunction]
    Spring.UnitScript.CallAsUnit(unitID, func, cmdParams)
  end
  if cmdData.gadgetFunction then
    cmdData.gadgetFunction(unitID, unitDefID, unitTeam, cmdParams)
  end
  
  if cmdData.isSpiritAttack then
    GG.SetUnitSpirit(unitID, unitDefID, unitTeam, 0)
    GG.SetUnitSuppression(unitID, 0)
    
    local unitID2, unitDefID2, unitTeam2
    if #cmdParams == 1 then
      unitID2 = cmdParams[1]
      unitDefID2 = Spring.GetUnitDefID(unitID2)
      unitTeam2 = spGetUnitTeam(unitID2)
    end
    GG.EventWrapper.AddEvent("specialWeapon", 0, unitID, unitDefID, unitTeam, unitID2, unitDefID2, unitTeam2)
  else
    local cooldown = cmdData.cooldown or 30
    Spring.SetUnitRulesParam(unitID, "specialPowerCooldown", cooldown)
    Spring.SetUnitRulesParam(unitID, "specialPowerCooldownLength", cooldown)
    coolingDownUnits[unitID] = cooldown
  end
  
  RefreshCommandEnableState(unitID, unitDefID, unitTeam)
  
  -- broken; seems to block CommandFallback clearing
  --if cmdData.afterCommand then
  --  Spring.GiveOrderToUnit(unitID, CMD.INSERT, {0, cmdData.afterCommand, 0, cmdParams[1], cmdParams[2], cmdParams[3], cmdParams[4]}, {"alt"})
  --end
  
  return true
end

-- check if we can activate the special
local function ProcessCommand(cmdData, unitID, unitDefID, unitTeam, cmdParams)
  if cmdData.instant then
    return ExecuteCommand(cmdData, unitID, unitDefID, unitTeam, cmdParams)
  end
  
  --range check
  local ux, uy, uz = GetUnitMidPos(unitID)
  local tx, ty, tz
  if (#cmdParams == 1) then
    tx,ty,tz = GetUnitMidPos(cmdParams[1])
  else
    tx,ty,tz = unpack(cmdParams)
  end
  if not (tx and ty and tz) then
    Spring.Echo("errah", tx, ty, tz)
    return false
  end
  local dist = GetDistance(ux, uy, uz, tx, ty, tz)
  if (dist < cmdData.maxRange) and (dist > cmdData.minRange) then
    -- angle check
    local _, dotFront = GetTargetVector(unitID, tx, ty, tz)
    if (not cmdData.maxAngle) or dotFront >= math.cos(cmdData.maxAngle) then
      return ExecuteCommand(cmdData, unitID, unitDefID, unitTeam, cmdParams)
    end
  end
  return false 
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  if unitDefsWithSpecials[unitDefID] then
    
    --unitsWithSpecial[unitID] = data
    for _,powerName in pairs(unitDefsWithSpecials[unitDefID]) do
      local data = specialPowers[powerName]
      data.cmdDesc.id = data.cmdDesc.id
      data.cmdDesc.disabled = data.isSpiritAttack and ((GG.GetUnitSpirit(unitID) or 0) < 100) or false
      if data.isSpiritAttack or specialAbilitiesEnabled then
	Spring.InsertUnitCmdDesc(unitID, 500, data.cmdDesc)
      end
    end
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  targets[unitID] = nil
  coolingDownUnits[unitID] = nil
end

function gadget:CommandFallback(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
  if specialCMDs[cmdID] then
    local data = specialPowers[specialCMDs[cmdID]]
    if data.isSpiritAttack and (GG.GetUnitSpirit(unitID) or 0) < 100 then
      return true, true	-- command was used, but cannot execute - remove it
    end
    local execution = ProcessCommand(data, unitID, unitDefID, unitTeam, cmdParams)	-- command was used, clear it if successfully executed
    return true, execution
  end
  return false -- command not used
end

-- check for target validity
function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
  if specialCMDs[cmdID] then
    local data = specialPowers[specialCMDs[cmdID]]
    
    if not cmdOptions.shift then
      if (data.energy and data.energy > GG.Energy.GetUnitEnergy(unitID)) then
	return false
      end
    end
    
    if data.isSpiritAttack then
      if (GG.GetUnitSpirit(unitID) or 0) < 100 then
	return false
      end
    elseif coolingDownUnits[unitID]  then
      return false
    end
    
    if #cmdParams == 1 then
      local targetTeam = spGetUnitTeam(cmdParams[1])
      local isAllied = spAreTeamsAllied(unitTeam, targetTeam)
      return (isAllied and data.canTargetAllies) or ((not isAllied) and (data.canTargetEnemies ~= false))
    end
  end
  
  return true
end

function gadget:Initialize()
  GG.SpecialPower = {
    RefreshCommandEnableState = RefreshCommandEnableState,
    SetTarget = SetTarget,
    GetTarget = GetTarget,
  }
end

function gadget:GameFrame(n)
  if n % COOLDOWN_INTERVAL == 0 then
    for unitID in pairs(coolingDownUnits) do
      local value = coolingDownUnits[unitID] - COOLDOWN_INTERVAL
      if value <= 0 then
	Spring.SetUnitRulesParam(unitID, "specialPowerCooldown", 0)
	coolingDownUnits[unitID] = nil
	local unitDefID = Spring.GetUnitDefID(unitID)
	local unitTeam = Spring.GetUnitTeam(unitID)
	RefreshCommandEnableState(unitID, unitDefID, unitTeam)
      else
	Spring.SetUnitRulesParam(unitID, "specialPowerCooldown", value)
	coolingDownUnits[unitID] = value
      end
    end
  end
end

--[[
function gadget:GameFrame(n)
  for unitID, data in pairs(rangeCheckList) do
    --bla
  end
end
]]
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------

function gadget:Initialize()
  for cmdID, cmdName in pairs(specialCMDs) do
    gadgetHandler:RegisterCMDID(cmdID)
    local cursor = specialPowers[cmdName].cmdDesc.cursor or "DGun" 
    Spring.SetCustomCommandDrawData(cmdID, cursor, {0, 1, 1, 0.7})
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
