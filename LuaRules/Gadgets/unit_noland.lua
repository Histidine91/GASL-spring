--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
   return {
      name      = "No Land",
      desc      = "Removes Land At and Land/Fly commands",
      author    = "KingRaptor (L.J. Lim)",
      date      = "15/1/2011",
      license   = "Public Domain",
      layer     = 0,
      enabled   = true
   }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--SYNCED
if gadgetHandler:IsSyncedCode() then

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local spFindUnitCmdDesc		= Spring.FindUnitCmdDesc
local spRemoveUnitCmdDesc	= Spring.RemoveUnitCmdDesc
local spGiveOrderToUnit		= Spring.GiveOrderToUnit
local spGetUnitRadius		= Spring.GetUnitRadius
local spSetUnitRadiusAndHeight	= Spring.SetUnitRadiusAndHeight

function gadget:UnitCreated(unitID, unitDefID, teamID)
      local cmdDescID = spFindUnitCmdDesc(unitID, CMD.AUTOREPAIRLEVEL)
      if cmdDescID then
	    spGiveOrderToUnit(unitID, CMD.AUTOREPAIRLEVEL, {0}, {} )
	    spRemoveUnitCmdDesc(unitID, cmdDescID)
      end
      cmdDescID = spFindUnitCmdDesc(unitID, CMD.IDLEMODE)
      if cmdDescID then
	    spGiveOrderToUnit(unitID, CMD.IDLEMODE,{0},{})
	    spRemoveUnitCmdDesc(unitID, cmdDescID)
      end
      -- fix for "bounce on water" bug (it's super annoying)
      local radius = spGetUnitRadius(unitID)
      local wantedHeight = UnitDefs[unitDefID] and UnitDefs[unitDefID].wantedHeight or 0
      if radius > wantedHeight then
	    spSetUnitRadiusAndHeight(unitID,wantedHeight)
      end
end

------------------------------------------------------

function gadget:Initialize()
	local units = Spring.GetAllUnits()
	for i=1, #units do
		gadget:UnitCreated(units[i])
	end
end

end