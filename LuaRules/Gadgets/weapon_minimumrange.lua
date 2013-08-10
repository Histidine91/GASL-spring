--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Minimum Range",
		desc = "Prevents too-close weapons from firing",
		author = "KingRaptor (L.J. Lim)",
		date = "2013-05-21",
		license = "Public Domain",
		layer = 1,
		enabled = false	-- this gadget donut work!!
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (not gadgetHandler:IsSyncedCode()) then
	return false
end

local spValidUnitID = Spring.ValidUnitID
local spGetUnitSeparation = Spring.GetUnitSeparation
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local minRanges = {}

for i=1,#WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams and wd.customParams.minimumrange then
		minRanges[i] = tonumber(wd.customParams.minimumrange)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:AllowWeaponTarget(unitID, targetID, attackerWeaponNum, attackerWeaponDefID, defPriority)
	local minRange = minRanges[attackerWeaponDefID]
	if minRange then
		if unitID and targetID then
			local range = spGetUnitSeparation(unitID, targetID, false)
			if range < minRange then
				--Spring.Echo(range, minRange)
				return false, defPriority
			end
		end
	end
	return true, defPriority
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
