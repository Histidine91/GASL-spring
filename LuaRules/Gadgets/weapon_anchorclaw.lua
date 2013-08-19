--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Anchor Claw Handler",
		desc = "Iron Fisted Judgement!",
		author = "KingRaptor (L.J. Lim)",
		date = "2013-08-19",
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
local CLAW_WEAPONS = {
	[WeaponDefNames.kungfufighter_anchorclaw_l.id] = true,
	[WeaponDefNames.kungfufighter_anchorclaw_r.id] = true,
}
local DELAY_BEFORE_RESEEK = 30*1.5

local clawProjectiles = {}
local targetSchedule = {}	-- [gameframe] = {[projectileID] = owner}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	if CLAW_WEAPONS[weaponID] then
		clawProjectiles[proID] = true
		local frame = Spring.GetGameFrame() + DELAY_BEFORE_RESEEK
		targetSchedule[frame] = targetSchedule[frame] or {}
		targetSchedule[frame][proID] = proOwnerID
	end
end	

function gadget:ProjectileDestroyed(proID)
	clawProjectiles[proID] = nil
end

function gadget:UnitPreDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam, projectileID)
	--TODO: impact CEG, impulse
end

function gadget:GameFrame(n)
	local schedule = targetSchedule[n]
	if schedule then
		for proID, proOwnerID in pairs(schedule) do
			local targetID = GG.SpecialWeapon.GetTarget(proOwnerID)
			if targetID and type(targetID) == "number" and (not Spring.GetUnitIsDead(targetID)) then
				Spring.SetProjectileTarget(proID, targetID, 'u')
			else
				-- TODO: reseek
			end
		end
	end
end

function gadget:Initialize()
	for weaponID in pairs(CLAW_WEAPONS) do
		Script.SetWatchWeapon(weaponID, true)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
