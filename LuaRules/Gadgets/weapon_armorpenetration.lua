--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Armor Penetration",
		desc = "Reduces damage against hard targets (also manages critical hits)",
		author = "KingRaptor (L.J. Lim)",
		date = "2008-02-10",
		license = "Public Domain",
		layer = 1,
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
local DEFAULT_PENETRATION = 100
local DEFAULT_ARMOR = 100
local CRIT_DAMAGE_MULT = 2

local unitArmor = {}
local weapons = {}	-- [weaponID] = {ap = x, damageType = "energy"/"kinetic", critChance = y}

for i=1,#UnitDefs do
	unitArmor[i] = tonumber(UnitDefs[i].customParams.armor) or DEFAULT_ARMOR
end

for i=1,#WeaponDefs do
	local customParams = WeaponDefs[i].customParams or {}
	weapons[i] = {}
	local damage = WeaponDefs[i].damages[0]
	weapons[i].damage = damage
	weapons[i].damageType = customParams.damagetype or "energy"
	weapons[i].critChance = tonumber(customParams.critchance) or 0
	weapons[i].ap = tonumber(customParams.ap) or (weapons[i].damageType == "kinetic" and DEFAULT_PENETRATION or 0)
	weapons[i].reportCrits = (damage > 100)
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID,
                            attackerID, attackerDefID, attackerTeam)
	if not (weaponID and unitDefID and unitArmor[unitDefID] and weapons[weaponID]) then
		return damage
	end
	local wep = weapons[weaponID]
	local armor = unitArmor[unitDefID]
	-- critical hit
	local critical = false
	if wep.critChance > 0 then
		if math.random() <= wep.critChance then
			--Spring.Echo("boom headshot", unitID, attackerID)
			critical = true
			damage = damage*2
			armor = 0
		end
	end
	
	if wep.damageType == "kinetic" then
		if armor > wep.ap then
			damage = damage * wep.ap/armor
		end
	elseif wep.damageType == "energy" then
		if (wep.ap > 0) and (not critical) then
			-- energy AP doesn't reduce effective armor below 100
			if armor > 100 then
				armor = armor - wep.ap
				if armor < 100 then
					armor = 100
				end
			end
			damage = (damage*2)/(1+armor/100)
		end
	end
	
	if critical and wep.reportCrits then
		GG.EventWrapper.AddEvent("criticalHit", damage, attackerID, attackerDefID, attackerTeam, unitID, unitDefID, unitTeam)
		GG.EventWrapper.AddEvent("criticalHit_received", damage, unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	end
	
	return damage
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
