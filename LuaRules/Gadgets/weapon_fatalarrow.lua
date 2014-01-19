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
local CONE_ANGLE = math.rad(30)
local function GetTargetCircleRadius(distance)
	return distance*math.tan(CONE_ANGLE)
end

if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local targets = {}	-- [unitID] = {target1, target2, target3}
local targetsByTargetID = {}	-- [unitID] = attackerID
local allow = false

local function GetTarget(unitID)
	local targetArray = targets[unitID]
	if not targetArray then
		return nil
	end
	if #targetArray == 0 then
		targets[unitID] = nil
		return nil
	end
	local targetID = targetArray[1]
	allow = true
	Spring.GiveOrderToUnit(unitID, CMD.ATTACK, {targetID}, 0)
	Spring.SetUnitTarget(unitID, targetID)
	allow = false
	return targetID
end

local function ClearTargets(unitID)
	local targetArray = targets[unitID]
	if not targetArray then
		return nil
	end
	for i=1,#targetArray do
		local targetID = targetArray[i]
		targetsByTargetID[targetID] = nil
	end
	targets[unitID] = nil
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
	local radius = GetTargetCircleRadius(distance)
	local extraTargets = Spring.GetUnitsInCylinder(tx, tz, radius)
	for _,etID in pairs(extraTargets) do
		local etTeam = Spring.GetUnitTeam(etID)
		if not Spring.AreTeamsAllied(unitTeam, etTeam) then
			count = count + 1
			targets[unitID][count] = etID
			targetsByTargetID[etID] = unitID
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

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if allow then
		return true
	end
	return (not targets[unitID])
end

function gadget:Initialize()
	GG.FatalArrow = {
		GetTarget = GetTarget,
		SearchForTargets = SearchForTargets,
		ClearTargets = ClearTargets,
	}
end

function gadget:Shutdown()
	GG.FatalArrow = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- unsynced
--------------------------------------------------------------------------------
end