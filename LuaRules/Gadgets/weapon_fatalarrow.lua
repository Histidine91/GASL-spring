--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Fatal Arrow Handler",
		desc = "Shot through the heart",
		author = "KingRaptor (L.J. Lim)",
		date = "2014-01-19",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (not gadgetHandler:IsSyncedCode()) then
	return false
end

--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local CONE_ANGLE = 30	-- degrees

local targets = {}	-- [unitID] = {target1, target2, target3}
local targetsByTargetID = {}	-- [unitID] = attackerID
local allow = false

local function GetTarget(unitID)
	local targetArray = targets[unitID]
	if not targetArray then
		return nil
	end
	local targetID = targetArray[1]
	allow = true
	Spring.GiveOrderToUnit(unitID, CMD.ATTACK, {targetID}, 0)
	allow = false
	return targetID
end

--[[
local function GetTargetStatus(unitID)
	local targetArray = targets[unitID]
	if not targetArray then
		return
	end
	for i=#targetArray,1,-1 do
		local targetID = targetArray[i]
		if Spring.GetUnitIsDead(targetID) then
			targetArray[i] = nil
		end
	end
end
]]

local function SearchForTargets(unitID, targetID)
	if not targetID then return end
	local _,_,_,tx, ty, tz = Spring.GetUnitPosition(targetID, true)
	if not tx and ty and tz then return end
	
	targets[unitID] = {targetID}
	targetsByTargetID[targetID] = unitID
	local count = 1
	local unitTeam = Spring.GetUnitTeam(unitID)
	local distance = Spring.GetUnitSeparation(unitID, targetID, false)
	local radius = distance*math.tan(CONE_ANGLE)
	local extraTargets = Spring.GetUnitsInCylinder(tx, tz, radius)
	for _,etID in pairs(extraTargets) do
		local etTeam = Spring.GetUnitTeam(etID)
		if Spring.AreTeamsAllied(unitTeam, etTeam) then
			targets[unitID][count] = etID
			count = count + 1
			if count == 5 then
				break
			end
		end
	end
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	local attackerID = targetsByTargetID[unitID]
	if attackerID then
		local targetArray = targets[attackerID]
		for i=#targetArray,1,-1 do
			if targetArray[i] == unitID then
				table.remove(targetArray, i)
			end
		end
	end
	targetsByTargetID[unitID] = nil
end

function gadget:AllowUnitCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if allow then
		return true
	end
	return (not targets[unitID])
end

function gadget:Initialize()
	GG.FatalArrow = {
		GetTarget = GetTarget,
		SearchForTargets = SearchForTargets,
		AttackTarget = AttackTarget,
	}
end

function gadget:Shutdown()
	GG.FatalArrow = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
