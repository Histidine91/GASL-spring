--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Automatically generated local definitions

local CMD_MOVE        	= CMD.MOVE
local CMD_FIGHT       	= CMD.FIGHT
local CMD_PATROL       	= CMD.PATROL
local CMD_INSERT        = CMD.INSERT
local CMD_REMOVE        = CMD.REMOVE
local spGetUnitPosition = Spring.GetUnitPosition
local spGiveOrderToUnit = Spring.GiveOrderToUnit

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name = "Center Move",
		desc = "makes units go to midair positions instead of the ground; blocks ground attack orders",
		author = "KDR_11k (David Becker)",
		date = "2008-03-09",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if not (gadgetHandler:IsSyncedCode()) then
	return false
end
--------------------------------------------------------------------------------
--SYNCED
--------------------------------------------------------------------------------
include("LuaRules/Configs/customcmds.h.lua")

local cmds = {
	[CMD.MOVE] = true,
	[CMD.FIGHT] = true,
	[CMD.PATROL] = true,
	[CMD_TURN] = true,
}

local replaceList = {}

function gadget:AllowCommand(u, ud, team, cmd, param, opt, tag, synced)
	--[[if cmd == CMD_ATTACK or cmd == CMD_MANUALFIRE then
		if #param > 1 then return false end	-- disable attack orders on ground
	end]]
	if cmds[cmd] then
		local overwrite = not opt.shift
		local y = param[2]
		if y then
			if synced then
				return true
			else
				--y = select(5, spGetUnitPosition(u, true))
				y = 0
			end
		else
			return true
		end
		table.insert(replaceList, {
			cmd=cmd,
			u=u,
			overwrite=overwrite,
			x=param[1],
			y=y,
			z=param[3],
		})
		return false
	end
	return true
end

function gadget:GameFrame(f)
	for i,t in pairs(replaceList) do
		if not t.overwrite then
			spGiveOrderToUnit(t.u, CMD_INSERT, {-1, t.cmd, 0, t.x, t.y, t.z }, {"alt"})
		else
			spGiveOrderToUnit(t.u, t.cmd, {t.x, t.y, t.z }, {})
		end
		--spGiveOrderToUnit(t.u, CMD_REMOVE, {t.tag}, {})
		replaceList[i]=nil
	end
end
