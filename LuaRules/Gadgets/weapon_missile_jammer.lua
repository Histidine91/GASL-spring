--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Missile Jammer",
		desc = "Anti-missile ECM",
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
local spGetProjectileTarget	= Spring.GetProjectileTarget
local spGetProjectilePosition	= Spring.GetProjectilePosition
local spGetUnitDefID		= Spring.GetUnitDefID
local spGetUnitPosition		= Spring.GetUnitPosition
local spGetUnitIsDead		= Spring.GetUnitIsDead

local DEFLECTION_PER_POINT = 10
local BASE_JAM_CHANCE = 0
local JAMMER_CHECK_PERIOD = 6

local missileDefs = {}
local jammerDefs = {}
local missiles = {}
--local missilesByTarget = {}

for i=1,#UnitDefs do
	local ud = UnitDefs[i]
	if ud.customParams.ecm or ud.customParams.missilejamstrength then
		jammerDefs[i] = {
			jammerRadius = tonumber(ud.customParams.missilejamradius) or (ud.xsize*40 + 100),
			jammerStrength = ud.customParams.missilejamstrength or ((ud.customParams.ecm or 0)^0.5)*10,
		}
	end
end

for i=1,#WeaponDefs do
	local wd = WeaponDefs[i]
	if wd.customParams and wd.customParams.jammable then
		Script.SetWatchWeapon(i, true)
		missileDefs[i] = {
			eccm = tonumber(wd.customParams.eccm) or 0,
		}
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetDistance(x1, y1, z1, x2, y2, z2)
	local dist = ((x1 - x2)^2 + (z1 - z2)^2)
	dist = (dist + (z1 - z2)^2)^0.5
	return dist
end

local function GetUnitMidPos(unitID)
	local _,_,_,x,y,z = spGetUnitPosition(unitID, true)
	return x,y,z
end

local function GetScatterImpactPoint(projectileID, targetID, maxSpread, speed)
	local x,y,z = GetUnitMidPos(targetID)
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

local function JammerCheck(proID, proData, targetID)
	local targetDefID = spGetUnitDefID(targetID)
	local jammerDef = jammerDefs[targetDefID]
	if jammerDef then
		local tx, ty, tz = GetUnitMidPos(targetID)
		local px, py, pz = spGetProjectilePosition(proID)
		local distance = GetDistance(tx, ty, tz, px, py, pz)
		if distance < jammerDef.jammerRadius then
			-- perform the actual jamming roll
			local netStrength = BASE_JAM_CHANCE + jammerDef.jammerStrength - missileDefs[proData.weapon].eccm
			local rand = math.random()*100
			local result = netStrength - rand
			if result >= 0 then	-- success!
				local x,y,z = GetScatterImpactPoint(proID, targetID, result*DEFLECTION_PER_POINT, 250)	-- FIXME use actual velocity?
				if x and y and z then
					Spring.SetProjectileTarget(proID, x, y, z)
				end
			end
			--Spring.Echo("Jam "..(result >= 0 and "successful" or "failed") .. "!", netStrength, rand, jammerDef.jammerRadius)
			missiles[proID] = nil
		end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:Initialize()
end

function gadget:UnitCreated(unitID)
	--Spring.Echo("bla", unitID)
end

function gadget:GameFrame(n)
	if (n%JAMMER_CHECK_PERIOD) == 0 then
		for proID, data in pairs(missiles) do
			-- first check if our original target is dead and get new target if necessary
			if (not data.target) or spGetUnitIsDead(data.target) then
				data.target = nil
			end
			
			if data.target == nil then
				local _, targetID = spGetProjectileTarget(targetID)
				if targetID then
					data.target = targetID
				end
			end
			
			-- now check if our target can actually jam
			local targetID = data.target
			if targetID then
				JammerCheck(proID, data, targetID)
			end
		end
	end
end

function gadget:ProjectileCreated(proID, proOwnerID, weaponID)
	if missileDefs[weaponID] then
		local _, targetID = spGetProjectileTarget(proID)
		missiles[proID] = {owner = proOwnerID, weapon = weaponID, failedJammers = {}, target = targetID}
		--missilesByTarget[targetID] = missilesByTarget[targetID] or {}
		--missilesByTarget[targetID][proID] = true
	end
end	

function gadget:ProjectileDestroyed(proID)
	missiles[proID] = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
