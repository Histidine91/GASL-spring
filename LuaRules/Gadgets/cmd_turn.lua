function gadget:GetInfo()
	return {
		name      = "Turn Command",
		desc      = "Implements Turn command for vehicles",
		author    = "FLOZi, yuritch", -- yuritch is magical
		date      = "5/02/10",
		license   = "PD",
		layer     = -5,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include("LuaRules/Configs/customcmds.h.lua")

if (gadgetHandler:IsSyncedCode()) then

--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local spGetUnitVectors = Spring.GetUnitVectors
local spGetUnitPosition = Spring.GetUnitPosition

local turnCmdDesc = {
	id = CMD_TURN,
	type = CMDTYPE.ICON_MAP,
	name = "Turn",
	action = "turn",
	tooltip = "Turn to face a given point",
	cursor = "Patrol",
}

local function GetVectorToPoint(unitID, tx, ty, tz)
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
function gadget:UnitCreated(unitID, unitDefID, unitTeam, builderID)
	local ud = UnitDefs[unitDefID]
	if (ud.speed > 0) then
		Spring.InsertUnitCmdDesc(unitID, 500, turnCmdDesc)
	end
end

function gadget:CommandFallback(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_TURN then
		local tx, ty, tz = unpack(cmdParams)
		local _, dotFront = GetVectorToPoint(unitID, tx, ty, tz)
		return true, dotFront > 0.99
	end
	return false
end

function gadget:Initialize()
	local unitList = Spring.GetAllUnits()
	for i=1,#(unitList) do
		local ud = Spring.GetUnitDefID(unitList[i])
		local team = Spring.GetUnitTeam(unitList[i])
		gadget:UnitCreated(unitList[i], ud, team)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- UNSYNCED
function gadget:Initialize()
	gadgetHandler:RegisterCMDID(CMD_TURN)
	Spring.SetCustomCommandDrawData(CMD_TURN, "Patrol", {0,1,0,0.7})
end

end