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
local IMPULSE = 2500
local KNOCK_TIME = 3*30

local clawProjectiles = {}
local targetSchedule = {}	-- [gameframe] = {[projectileID] = owner}
--local restoreControlSchedule = {}
local toRestoreControl = {}

local function GetUnitVelocity(unitID)
	if GG.FlightControl then
		return GG.FlightControl.GetUnitVelocity(unitID)
	end
	return Spring.GetUnitVelocity(unitID)
end

local function GetVelocityChange(x, y, z, mass)
	local speedChange = IMPULSE/mass
	return x*speedChange, y*speedChange, z*speedChange
end

-------------------------------------------------------------------------------
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

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID, attackerID, attackerDefID, attackerTeam, projectileID)
	if not CLAW_WEAPONS[weaponID] then
		return
	end
	local px, py, pz = Spring.GetProjectilePosition(projectileID)
	if not px and py and pz then
		return
	end
	local _,_,_, ux, uy, uz = Spring.GetUnitPosition(unitID, true)
	
	local ud = UnitDefs[unitDefID]
	local mass = ud.mass
	
	GG.FlightControl.DisableUnit(unitID)
	local restoreFrame = KNOCK_TIME + Spring.GetGameFrame()
	toRestoreControl[unitID] = restoreFrame
	
	-- apply knockback
	local vx, vy, vz = GetUnitVelocity(unitID)
	local vecX, vecY, vecZ = Spring.GetProjectileVelocity(projectileID) --ux - px, uy - py, uz - pz
	vecX, vecY, vecZ = GG.Vector.Normalized(vecX, vecY, vecZ)
	local speedChange = IMPULSE/mass
	local dvx, dvy, dvz = vecX*speedChange, vecY*speedChange, vecZ*speedChange
	GG.FlightControl.SetUnitVelocity(unitID, vx + dvx, vy + dvy, vz + dvz)
	--Spring.AddUnitImpulse(unitID, vecX, vecY, vecZ, 1)
	
	-- apply spin
	--local rvx, rvy = 0, 0
	local vecX2, vecY2, vecZ2 = ux - px, uy - py, uz - pz
	--local vecXU, vecXY, vecXZ = unpack(spGetUnitVectors(unitID))
	local dotVector = 1	-- 1 - (vecX2 * vecX + vecY2 * vecY + vecZ2 * vecZ)
	local rot = speedChange*0.01*dotVector
	--Spring.Echo(rot)
	local rvx_abs, rvy_abs, rvz_abs = vecX*rot, vecY*rot, vecZ*rot
	local rvx = rvy_abs
	local rvy = rvx_abs + rvz_abs
	
	--rvx = vecY*math.acos(vecX)*dotVector
	--rvy = math.asin(vecX) * math.acos(vecZ)
	Spring.MoveCtrl.SetRotationVelocity(unitID, rvx, rvy, 0)
end

function gadget:GameFrame(n)
	local schedule = targetSchedule[n]
	if schedule then
		for proID, proOwnerID in pairs(schedule) do
			local targetID = GG.SpecialPower.GetTarget(proOwnerID)
			if targetID and type(targetID) == "number" and (not Spring.GetUnitIsDead(targetID)) then
				Spring.SetProjectileTarget(proID, targetID, string.byte('u'))
			else
				-- TODO: reseek
			end
		end
	end
	for unitID, frame in pairs(toRestoreControl) do
		if frame >= n then
			GG.FlightControl.EnableUnit(unitID)
			toRestoreControl[unitID] = nil
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
