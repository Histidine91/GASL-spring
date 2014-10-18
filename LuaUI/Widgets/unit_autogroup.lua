function widget:GetInfo()
  return {
	name		= "Autogroup",
	desc 		= "bla",
	author		= "KingRaptor",
	date		= "2013.08.28",
	license		= "Public Domain",
	layer		= 0,
	enabled		= true  --loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local unitGroups = {
      [UnitDefNames.luckystar.id] = 1,
      [UnitDefNames.kungfufighter.id] = 2,
      --[UnitDefNames.trickmaster.id] = 3,
      [UnitDefNames.happytrigger.id] = 4,
      --[UnitDefNames.harvester.id] = 5,
      [UnitDefNames.sharpshooter.id] = 6,
      --[UnitDefNames.elsior.id] = 0,
      [UnitDefNames.placeholdersior.id] = 0,
}

function widget:UnitFinished(unitID, unitDefID, unitTeam)
      if unitGroups[unitDefID] then
	    Spring.SetUnitGroup(unitID, unitGroups[unitDefID])
      end
end