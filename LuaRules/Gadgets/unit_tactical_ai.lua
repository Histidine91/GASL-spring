
function gadget:GetInfo()
  return {
	name 	= "Tactical Unit AI",
	desc	= "Implements tactial AI for some units",
	author	= "KingRaptor",
	date	= "2013.08.30",
	license	= "GNU GPL, v2 or later",
	layer	= 0,
	enabled = true,
  }
end

--------------------------------------------------------------------------------
if (not gadgetHandler:IsSyncedCode()) then
  return false  --  no unsynced code
end


--------------------------------------------------------------------------------
-- Speedups

local spGetUnitsInSphere	= Spring.GetUnitsInSphere
local spGetUnitNearestEnemy = Spring.GetUnitNearestEnemy
local spGetUnitSeparation 	= Spring.GetUnitSeparation
local spGetUnitDefID		= Spring.GetUnitDefID
local spGetUnitTeam		= Spring.GetUnitTeam
local spGetUnitPosition		= Spring.GetUnitPosition
local spAreTeamsAllied		= Spring.AreTeamsAllied
local spGetUnitNeutral		= Spring.GetUnitNeutral

local random 				= math.random

local MAX_QUERIES = 10	-- don't waste time checking every possible target
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local defaults, unitConfigs = include("LuaRules/Configs/tactical_ai_defs.lua")
local unitStats = {}

for i=1,#UnitDefs do
      local ud = UnitDefs[i]
      unitStats[i] = {}
      unitStats[i].armor = tonumber(ud.customParams.armor) or 100
      unitStats[i].speed = ud.speed
      unitStats[i].healthPerCost = ud.health/(ud.customParams.cost or 1000)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetUnitMidPos(unitID)
	local _,_,_,x,y,z = spGetUnitPosition(unitID, true)
	return x,y,z
end

local function GetTargetingScore(unitID, unitDefID, targetID, targetDefID)
      local config = unitConfigs[unitDefID] or defaults
      local stats = unitStats[targetDefID]
      
      local distance = spGetUnitSeparation(unitID, targetID)
      local distanceScore = (distance - config.minDistance) * config.distanceMod
      if distanceScore < 0 then
	    distanceScore = 0
      end
      
      local apScore = 0
      local ap, armor = config.ap, stats.armor
      if ap > armor then
	    apScore = ap - armor * config.apModOver
      else
	    apScore = armor - ap * config.apModUnder
      end
      
      local speedScore = 0
      local mySpeed, targetSpeed = unitStats[unitDefID].speed, stats.speed
      if mySpeed > targetSpeed then
	    speedScore = mySpeed - targetSpeed * config.speedModOver
      else
	    speedScore = targetSpeed - mySpeed * config.speedModUnder
      end
      
      local hpScore = stats.healthPerCost * config.hpPerCostMod
      local rand = random(0, config.randomMod)
      
      return distanceScore + apScore + speedScore + hpScore + rand
end

local function PickTarget(unitID, unitDefID, unitTeam, searchRange)
      local ux, uy, uz = GetUnitMidPos(unitID)
      local units = spGetUnitsInSphere(ux, uy, uz, searchRange)
      
      if not units or #units == 0 then
	    return spGetUnitNearestEnemy(unitID)
      end
      
      local bestScore = 100000
      local bestTarget
      local tries = 0
      
      for i=1,#units do
	    local targetID = units[i]
	    local targetDefID = spGetUnitDefID(units[i])
	    local targetTeam = spGetUnitTeam(targetID)
	    
	    if not (spAreTeamsAllied(unitTeam, targetTeam) or spGetUnitNeutral(targetID)) then
		  local score = GetTargetingScore(unitID, unitDefID, targetID, targetDefID)
		  if score < bestScore then
			bestScore = score
			bestTarget = targetID
		  end
		  tries = tries + 1
	    end
	    if tries == MAX_QUERIES then
		  break
	    end
      end
      
      return bestTarget
end

function gadget:Initialize()
      GG.PickTarget = PickTarget
end

function gadget:Shutdown()
      GG.PickTarget = nil
end