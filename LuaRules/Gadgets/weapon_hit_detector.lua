--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Hit Detector",
		desc = "Reports weapon hits/misses to GUI",
		author = "KingRaptor (L.J. Lim)",
		date = "2013-08-11",
		license = "GNU GPL, v2 or later",
		layer = math.huge,
		enabled = false
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
local spGetProjectileTarget 	= Spring.GetProjectileTarget
local spGetUnitDefID 		= Spring.GetUnitDefID
local spGetUnitTeam 		= Spring.GetUnitTeam

local weaponDamages = {}
local activeProjectiles = {}
local gameframe = 0

for i=1,#WeaponDefs do
	local damage = WeaponDefs[i].damages[0]
	if damage >= 100 then
		Script.SetWatchWeapon(i, true)
		weaponDamages[i] = damage
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:Initialize()
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam, projectileID)
	if activeProjectiles[projectileID] then
		local data = activeProjectiles[projectileID]
		--GG.EventWrapper.AddEvent("weaponHit", data.damage/20, data.targetID, data.targetDefID, data.targetTeam, data.unitID, data.unitDefID, data.unitTeam)
		activeProjectiles[projectileID] = nil
	end
	return damage
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	if not weaponDamages[weaponID] then
		return
	end
	local targetID, targetType = spGetProjectileTarget(proID)
	local targetDefID, targetTeam
	if targetID and (targetType == "u") then
		targetDefID = spGetUnitDefID(targetID)
		targetTeam = spGetUnitTeam(targetID)
	end
	local unitDefID = spGetUnitDefID(proOwnerID)
	local unitTeam = spGetUnitTeam(proOwnerID)
	activeProjectiles[proID] = {weaponID = weaponID, unitID = proOwnerID, unitDefID = unitDefID, unitTeam = unitTeam,
		targetID = targetID, targetDefID = targetDefID, targetTeam = targetTeam, damage = weaponDamages[weaponID]
	}
end	

function gadget:ProjectileDestroyed(proID)
	if activeProjectiles[proID] then
		local data = activeProjectiles[proID]
		if not Spring.GetUnitIsDead(data.targetID) then
			GG.EventWrapper.AddEvent("weaponEvaded", data.damage/20, data.targetID, data.targetDefID, data.targetTeam, data.unitID, data.unitDefID, data.unitTeam)
			GG.EventWrapper.AddEvent("weaponMiss", data.damage/20, data.unitID, data.unitDefID, data.unitTeam, data.targetID, data.targetDefID, data.targetTeam)
		end
	end
	activeProjectiles[proID] = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
