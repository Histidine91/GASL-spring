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
	[WeaponDefNames.kungfufighter_anchorclaw_l.id] = -1,
	[WeaponDefNames.kungfufighter_anchorclaw_r.id] = 1,
}
local BASE_RESEEK_TIME = 45
local ADDITIONAL_RESEEK_TIME_AT_MAX_RANGE = 45
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

--[[
local function GetVelocityChange(x, y, z, mass)
	local speedChange = IMPULSE/mass
	return x*speedChange, y*speedChange, z*speedChange
end
]]

local function GetUnitMidPos(unitID)
	local _,_,_,x,y,z = Spring.GetUnitPosition(unitID, true)
	return x,y,z
end

-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	local dir = CLAW_WEAPONS[weaponID]
	if dir then
		clawProjectiles[proID] = true
		
		local targetID = GG.SpecialPower.GetTarget(proOwnerID)
		if not (targetID and type(targetID) == "number" and (not Spring.GetUnitIsDead(targetID))) then
			return
		end
		local ux,uy,uz = GetUnitMidPos(proOwnerID)
		local tx,ty,tz = GetUnitMidPos(targetID)
		local dx, dy, dz = tx - ux, ty - uy, tz - uz
		local dist = math.sqrt(dx^2 + dy^2 + dz^2)
		
		local vectorFront, vectorTop, vectorRight = Spring.GetUnitVectors(proOwnerID)
		--local vectorLeft, vectorBottom = {}, {}
		--for i=1,3 do
		--	vectorLeft[i] = vectorRight[i] * -1
		--	vectorBottom[i] = vectorBottom[i] * -1
		--end
		
		local vx = (vectorFront[1] + vectorRight[1]*dir + vectorTop[1]*-0.5) * dist/4 + ux
		local vy = (vectorFront[2] + vectorRight[2]*dir + vectorTop[2]*-0.5) * dist/4 + uy
		local vz = (vectorFront[3] + vectorRight[3]*dir + vectorTop[3]*-0.5) * dist/4 + uz
		
		Spring.SetProjectileTarget(proID, vx, vy, vz)
		
		local bonusTime = math.ceil(ADDITIONAL_RESEEK_TIME_AT_MAX_RANGE*dist/1800)
		local frame = Spring.GetGameFrame() + BASE_RESEEK_TIME + bonusTime
		targetSchedule[frame] = targetSchedule[frame] or {}
		targetSchedule[frame][proID] = {proOwnerID = proOwnerID, weaponID = weaponID}
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
	--GG.FlightControl.SetUnitVelocity(unitID, vx + dvx, vy + dvy, vz + dvz)
	--Spring.AddUnitImpulse(unitID, vecX, vecY, vecZ, 1)
	
	-- apply spin
	--local rvx, rvy = 0, 0
	local vecX2, vecY2, vecZ2 = ux - px, uy - py, uz - pz
	--local vecXU, vecXY, vecXZ = unpack(spGetUnitVectors(unitID))
	local dotVector = 1	-- 1 - (vecX2 * vecX + vecY2 * vecY + vecZ2 * vecZ)
	local rot = speedChange*0.015*dotVector
	--Spring.Echo(rot)
	local rvx_abs, rvy_abs, rvz_abs = vecX*rot, vecY*rot, vecZ*rot
	local rvx = rvy_abs
	local rvy = rvx_abs + rvz_abs
	
	--rvx = vecY*math.acos(vecX)*dotVector
	--rvy = math.asin(vecX) * math.acos(vecZ)
	--Spring.MoveCtrl.SetRotationVelocity(unitID, rvx, rvy, 0)
	GG.FlightControl.SetUnitRotationVelocity(unitID, rvx, rvy, 0)
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	toRestoreControl[unitID] = nil
end

function gadget:GameFrame(n)
	local schedule = targetSchedule[n]
	if schedule then
		for proID, data in pairs(schedule) do
			local proOwnerID = data.proOwnerID
			local targetID = GG.SpecialPower.GetTarget(proOwnerID)
			if targetID and type(targetID) == "number" and (not Spring.GetUnitIsDead(targetID)) then
				GG.Seeker.RegisterSeekerTarget(proID, data.weaponID, proOwnerID, targetID, true)
			else
				GG.Seeker.RetargetProjectile(proID)
			end
		end
	end
	for unitID, frame in pairs(toRestoreControl) do
		if n >= frame then
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
