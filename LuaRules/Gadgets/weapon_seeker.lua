--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Seeker Handler",
		desc = "Handles some seeker weapons",
		author = "KingRaptor (L.J. Lim)",
		date = "2013-05-18",
		license = "GNU GPL, v2 or later",
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
local seekerDefs = {}
local seekerProjectiles = {}
local loseLockSchedule = {}
local gameframe = 0

for i=1,#WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams and wd.customParams.seekerttl then
		Script.SetWatchWeapon(i, true)
		seekerDefs[i] = {
			ttl = wd.customParams.seekerttl,
			accuracy = wd.customParams.seekeraccuracy,
			speed = wd.customParams.seekerspeed or wd.projectilespeed
		}
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetScatterImpactPoint(projectileID, targetID, maxSpread, speed)
	local _,_,_,x,y,z = Spring.GetUnitPosition(targetID, true)
	local x1, y1, z1 = Spring.GetProjectilePosition(projectileID)
	
	if not (x and y and z) then
		return
	end
	
	local vx, vy, vz = Spring.GetUnitVelocity(targetID)
	local range = (x-x1)^2 + (y-y1)^2 + (z-z1)^2
	range = range^0.5
	local time = range/speed
	x = x + vx*time
	y = y + vy*time
	z = z + vz*time
	
	local dist = math.random(0, maxSpread)
	local heading = math.random(-180,180)
	local pitch = math.random(-90,90)
	heading = math.rad(heading)
	pitch = math.rad(pitch)
	local tx = x - dist * math.sin(heading) * math.cos(pitch)
	local ty = y + dist * math.sin(pitch)
	local tz = z - dist * math.cos(heading) * math.cos(pitch)
	return tx, ty, tz
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:Initialize()
end

function gadget:UnitCreated(unitID)
	--Spring.Echo("bla", unitID)
end

function gadget:GameFrame(n)
	gameframe = n
	if loseLockSchedule[n] then
		for proID, proData in pairs(loseLockSchedule[n]) do
			if seekerProjectiles[proID] then	-- check if table entry still exists (make sure it hasn't died on us in the meantime)
				local weaponID = proData.weaponID
				local targetID, type = Spring.GetProjectileTarget(proID)
				if targetID then
					local unitID = proData.unitID
					local unitDefID = Spring.GetUnitDefID(unitID)
					local targetDefID = Spring.GetUnitDefID(targetID)
					local accuracy = seekerDefs[weaponID].accuracy  * GG.GetAccMult(unitID, unitDefID, targetID, targetDefID) or 1
					local tx, ty, tz = GetScatterImpactPoint(proID, targetID, accuracy, seekerDefs[weaponID].speed)
					if tx and ty and tz then
						Spring.SetProjectileTarget(proID, tx, ty, tz)
					end
				end
				seekerProjectiles[proID] = nil
			end
		end
		loseLockSchedule[n] = nil
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	if seekerDefs[weaponID] then
		seekerProjectiles[proID] = true;
		local loseLockTime = gameframe + seekerDefs[weaponID].ttl
		loseLockSchedule[loseLockTime] = loseLockSchedule[loseLockTime] or {}
		loseLockSchedule[loseLockTime][proID] = {weaponID = weaponID, unitID = proOwnerID}
	end
end	

function gadget:ProjectileDestroyed(proID)
	seekerProjectiles[proID] = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
