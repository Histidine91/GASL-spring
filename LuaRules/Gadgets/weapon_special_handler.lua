--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Special Weapon Handler",
    desc      = "bla",
    author    = "KingRaptor (L.J. Lim)",
    date      = "2013.08.13",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
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
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--local unitsWithSpecial = {}	--[unitID] = specialWeapons[unitDefsWithSpecials[unitDefID]]

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

local function SetSpecialWeaponEnabled(unitID, unitDefID, unitTeam, bool)
  local data = specialWeapons[unitDefsWithSpecials[unitDefID]]
  if not data then
    return
  end
  
  local cmdDescID = Spring.FindUnitCmdDesc(unitID, data.cmdDesc.id)
  if (cmdDescID) then
    local cmdDesc = {disabled = not bool}
    Spring.EditUnitCmdDesc(unitID, cmdDescID, cmdDesc)
  end
end
GG.SetSpecialWeaponEnabled = SetSpecialWeaponEnabled

-- actualy use the special
local function ExecuteCommand(cmdData, unitID, unitDefID, unitTeam, cmdParams)
  if cmdData.scriptFunction then
    local env = Spring.UnitScript.GetScriptEnv(unitID)
    local func = env[cmdData.scriptFunction]
    Spring.UnitScript.CallAsUnit(unitID, func)
  end
  if cmdData.gadgetFunction then
    cmdData.gadgetFunction(unitID, unitDefID, unitTeam, cmdParams)
  end
  GG.SetUnitSpirit(unitID, unitDefID, unitTeam, 0)
  SetSpecialWeaponEnabled(unitID, unitDefId, unitTeam, false)
  GG.SetUnitSuppression(unitID, 0)
  
  local unitID2, unitDefID2, unitTeam2
  if #cmdParams == 1 then
    unitID2 = cmdParams[1]
    unitDefID2 = Spring.GetUnitDefID(unitID2)
    unitTeam2 = spGetUnitTeam(unitID2)
  end
  GG.EventWrapper.AddEvent("specialWeapon", 0, unitID, unitDefID, unitTeam, unitID2, unitDefID2, unitTeam2)
end

-- check if we can activate the special
local function ProcessCommand(cmdData, unitID, unitDefID, unitTeam, cmdParams)
  if cmdData.instant then
    ExecuteCommand(cmdData, unitID, unitDefID, unitTeam, cmdParams)
    return true
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
      ExecuteCommand(cmdData, unitID, unitDefID, unitTeam, cmdParams)
      return true
    end
  end
  return false 
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitCreated(unitID, unitDefID, unitTeam)
  if unitDefsWithSpecials[unitDefID] then
    local data = specialWeapons[unitDefsWithSpecials[unitDefID]]
    --unitsWithSpecial[unitID] = data
    
    data.cmdDesc.id = data.cmdDesc.id or CMD_SPECIAL_WEAPON
    data.cmdDesc.disabled = (GG.GetUnitSpirit(unitID) or 0) < 100
    Spring.InsertUnitCmdDesc(unitID, 500, data.cmdDesc)	
  end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
  --unitsWithSpecial[unitID] = nil
end

function gadget:CommandFallback(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
  local data
  if specialCMDs[cmdID] then
    data = specialWeapons[specialCMDs[cmdID]]
  elseif cmdID == CMD_SPECIAL_WEAPON then
    data = specialWeapons[unitDefsWithSpecials[unitDefID]]
  end
  
  if data then
    if (GG.GetUnitSpirit(unitID) or 0) < 100 then
      return true, true	-- command was used, but cannot execute - remove it
    end
    return true, ProcessCommand(data, unitID, unitDefID, unitTeam, cmdParams)	-- command was used, clear it if successfully executed
  end
  return false -- command not used
end

-- check for target validity
function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
  local data
  if specialCMDs[cmdID] then
    data = specialWeapons[specialCMDs[cmdID]]
  elseif cmdID == CMD_SPECIAL_WEAPON then
    data = specialWeapons[unitDefsWithSpecials[unitDefID]]
  end
  
  if data then
    if (GG.GetUnitSpirit(unitID) or 0) < 100 then
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
  for cmdID in pairs(specialCMDs) do
    gadgetHandler:RegisterCMDID(cmdID)
    Spring.SetCustomCommandDrawData(cmdID, "DGun", {0, 1, 1, 0.7})
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
