--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Seeker Handler",
		desc = "Special functions for some seeker weapons",
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
local spGetUnitTeam		= Spring.GetUnitTeam
local spGetUnitPosition 	= Spring.GetUnitPosition
local spGetProjectilePosition 	= Spring.GetProjectilePosition
local spGetUnitsInSphere 	= Spring.GetUnitsInSphere
local spAreTeamsAllied		= Spring.AreTeamsAllied

local seekerDefs = {}
local seekerProjectiles = {}	-- [projectileID] = {weapon = weaponID, target = unitID, unit = unitID}
local loseLockSchedule = {}	-- [gameframe] = {projectile1, projectile2, ...}
local retargetSchedule = {}	-- [gameframe] = {projectile1, projectile2, ...}
local seekersByTarget = {}	-- [targetID] = {projectile1, projectile2, ...}

local gameframe = 0

for i=1,#WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams and wd.customParams.seekerttl or wd.customParams.retarget then
		Script.SetWatchWeapon(i, true)
		seekerDefs[i] = {
			ttl = wd.customParams.seekerttl,
			accuracy = wd.customParams.seekeraccuracy,
			speed = wd.customParams.seekerspeed or wd.projectilespeed,
			retarget = tonumber(wd.customParams.retarget),
			retargetTime = tonumber(wd.customParams.retargettime),
		}
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetScatterImpactPoint(projectileID, targetID, maxSpread, speed)
	local _,_,_,x,y,z = spGetUnitPosition(targetID, true)
	local x1, y1, z1 = spGetProjectilePosition(projectileID)
	
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

local function RegisterSeekerTarget(proID, weaponID, unitID, targetID, seekToTarget)
	seekerProjectiles[proID].target = targetID
	seekersByTarget[targetID] = seekersByTarget[targetID] or {}
	seekersByTarget[targetID][proID] = true
	if seekToTarget then
		Spring.SetProjectileTarget(proID, targetID, string.byte('u'))
	end
	local loseLockTime = seekerDefs[weaponID].ttl
	if loseLockTime then
		loseLockTime = loseLockTime + gameframe
		loseLockSchedule[loseLockTime] = loseLockSchedule[loseLockTime] or {}
		loseLockSchedule[loseLockTime][proID] = {weaponID = weaponID, unitID = unitID}
	end
end

local function DeregisterSeekerTarget(proID, targetID)
	if not targetID then
		return
	end
	local seekers = seekersByTarget[targetID]
	if seekers then
		seekers[proID] = nil
	end
	if seekerProjectiles[proID] then
		seekerProjectiles[proID].target = nil
	end
end

local function RetargetProjectile(proID)
	local px, py, pz = spGetProjectilePosition(proID)
	local weaponID = seekerProjectiles[proID].weapon
	local def = seekerDefs[weaponID]
	local units = spGetUnitsInSphere(px, py, pz, def.retarget)
	for i=1,#units do
		local team = spGetUnitTeam(units[i])
		if not spAreTeamsAllied(team, seekerProjectiles[proID].team) then
			RegisterSeekerTarget(proID, weaponID, seekerProjectiles[proID].unit, units[i], true)
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	local seekers = seekersByTarget[unitID]
	if not seekers then
		return
	end
	for proID in pairs(seekers) do
		if seekerProjectiles[proID] then
			DeregisterSeekerTarget(proID, unitID)
			local def = seekerDefs[seekerProjectiles[proID].weapon]
			if def.retarget then
				local retargetTime = gameframe + (def.retargetTime or 1)
				retargetSchedule[retargetTime] = retargetSchedule[retargetTime] or {}
				retargetSchedule[retargetTime][proID] = true
			end
		end
	end
	seekersByTarget[unitID] = nil
end

function gadget:GameFrame(n)
	gameframe = n
	if loseLockSchedule[n] then
		for proID, proData in pairs(loseLockSchedule[n]) do
			if seekerProjectiles[proID] then	-- check if table entry still exists (make sure it hasn't died on us in the meantime)
				local weaponID = proData.weaponID
				local targetID = seekerProjectiles[proID].target
				if targetID and (not Spring.GetUnitIsDead(targetID)) then
					local unitID = proData.unitID
					local unitDefID = Spring.GetUnitDefID(unitID)
					local targetDefID = Spring.GetUnitDefID(targetID)
					local accuracy = seekerDefs[weaponID].accuracy  * GG.GetAccMult(unitID, unitDefID, targetID, targetDefID) or 1
					local tx, ty, tz = GetScatterImpactPoint(proID, targetID, accuracy, seekerDefs[weaponID].speed)
					if tx and ty and tz then
						Spring.SetProjectileTarget(proID, tx, ty, tz)
					end
				end
				--seekerProjectiles[proID] = nil
			end
		end
		loseLockSchedule[n] = nil
	end
	if retargetSchedule[n] then
		for proID, proData in pairs(retargetSchedule[n]) do
			if seekerProjectiles[proID] then
				RetargetProjectile(proID)
			end
		end
		retargetSchedule[n] = nil
	end
	
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	if seekerDefs[weaponID] then
		seekerProjectiles[proID] = {weapon = weaponID, team = Spring.GetUnitTeam(proOwnerID), unit = proOwnerID}
		local targetType, targetID = Spring.GetProjectileTarget(proID)
		seekerProjectiles[proID].target = targetID
		RegisterSeekerTarget(proID, weaponID, proOwnerID, targetID, false)
	end
end	

function gadget:ProjectileDestroyed(proID)
	local targetID = seekerProjectiles[proID] and seekerProjectiles[proID].target
	DeregisterSeekerTarget(proID, targetID)
	seekerProjectiles[proID] = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
