--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Only Unit Commands",
    desc      = 'Converts commands to CMDTYPE.ICON_UNIT',
    author    = "KingRaptor",
    date      = "10 April 2011",
    license   = "Public Domain",
    layer     = 0,
    enabled   = true,
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (not gadgetHandler:IsSyncedCode()) then
  return false  --  silent removal
end

local cmdIDs = {CMD.ATTACK, CMD.MANUALFIRE, CMD.REPAIR}

local spFindUnitCmdDesc = Spring.FindUnitCmdDesc
local spEditUnitCmdDesc = Spring.EditUnitCmdDesc

function gadget:UnitCreated(unitID, unitDefID, team)
	for i=1,#cmdIDs do
		local cmd = spFindUnitCmdDesc(unitID, cmdIDs[i])
		local desc = {
			type = CMDTYPE.ICON_UNIT,
		}
		if cmd then spEditUnitCmdDesc(unitID, cmd, desc) end
	end
end