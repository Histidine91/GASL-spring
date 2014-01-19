--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include ("constants.lua")

local spGetUnitRulesParam = Spring.GetUnitRulesParam
--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

local base, fuselage, pod_L, pod_R, prong_L, prong_R = piece('base', 'fuselage', 'pod_l', 'pod_r', 'prong_l', 'prong_r')
local railgun, railgunFlare = piece('railgun', 'railgunflare')
local vulcan, vulcanFlare = piece('vulcan', 'vulcanflare')
local missile, missile1, missile2 = piece('missile', 'missile1', 'missile2')
local engine_L, engine_R = piece('engine_l', 'engine_r')
local shieldArm = {}
local phalanx, shield = piece('phalanx', 'shield')

local weapons = {
    {aimpoint = railgun, muzzles = {railgunFlare}, index = 1, emit = 1028},	-- railgun
    {aimpoint = vulcan, muzzles = {vulcanFlare}, index = 1, emit = 1029},	-- vulcan
    {aimpoint = missile, muzzles = {missile1, missile2}, index = 1},	-- missile
    {aimpoint = base, muzzles = {}, index = 1},	-- phalanx
    {aimpoint = railgun, muzzles = {railgunFlare}, index = 1, emit = 1028}	-- fatalArrow
}
do
    local muzzles = weapons[4].muzzles
    for i=1,8 do
	muzzles[#muzzles+1] = piece("phalanx"..i)
    end
    for i=1,4 do
	shieldArm[#shieldArm+1] = piece("shieldarm"..i)
    end
end

local gunRotate = 0

--------------------------------------------------------------------------------
-- constants
--------------------------------------------------------------------------------
local SIG_DAMAGE = 1
local SIG_RESTORE = 2
local SIG_SPECIAL = 4

--------------------------------------------------------------------------------
-- variables
--------------------------------------------------------------------------------
local isUsingSpecial = false
local dead = false
local specialShots = 0
local specialTarget
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function DamageLoop()
    Signal(SIG_DAMAGE)
    SetSignalMask(SIG_DAMAGE)
    local health, maxHealth = Spring.GetUnitHealth(unitID)
    while(health/maxHealth < 0.5) do
	SetUnitValue(COB.CEG_DAMAGE, math.floor(25 - (health/maxHealth)*0.5))
	EmitSfx(pod_L, 1024)
	if ((health/maxHealth) < 0.3) then
	    EmitSfx(prong_R, 1024)
	end
	if dead then
	    EmitSfx(pod_R, 1024)
	    EmitSfx(prong_L, 1024)
	    EmitSfx(fuselage, 1024)
	end
	Sleep(50)
    end
end

local function RestoreAfterDelay()
    Signal(SIG_RESTORE)
    SetSignalMask(SIG_RESTORE)
    Sleep(4000)
    StopSpin(vulcan, z_axis, math.pi/8)
end

local function FeatherLoop()
    while true do
	local spirit = spGetUnitRulesParam(unitID, "spirit")
	if spirit == 100 then
	    EmitSfx(engine_L, 1025)
	    EmitSfx(engine_R, 1025)
	end
	Sleep(500)
    end
end

local function FatalArrowThread(params)
    Signal(SIG_SPECIAL)
    SetSignalMask(SIG_SPECIAL)
    isUsingSpecial = true
    GG.FlightControl.SetUnitForcedSpeed(unitID, 0)
    while GG.FlightControl.GetUnitTrueSpeed(unitID) > 0 do
	Sleep(200)
    end
    
    while specialShots > 0 do
	if (not specialTarget) or Spring.GetUnitIsDead(specialTarget) then
	    specialTarget = GG.FatalArrow.GetTarget(unitID)
	    if not specialTarget then
		specialShots = 0	-- all targets dead, cancel
	    end
	end
	Sleep(100)
    end
    Sleep(1000)
    
    GG.FlightControl.SetUnitForcedSpeed(unitID, nil)
    isUsingSpecial = false
end

function FatalArrowTrigger(params)
    specialShots = 3
    specialTarget = nil
    GG.FatalArrow.SearchForTargets(unitID, params[1]) 
    StartThread(FatalArrowThread)
end

local function DebugPhalanx()
    while true do
	for i=1,8 do
	    EmitSfx(piece("phalanx"..i), 1029)
	end
	Sleep(300)
    end
end

local function DebugMuzzleFlare()
    while true do
	EmitSfx(railgunFlare, 1030)
	Sleep(1000)
    end
end

function script.Create()
    Turn(pod_L, z_axis, math.rad(12))
    Turn(pod_R, z_axis, math.rad(-12))
    Turn(prong_L, z_axis, math.rad(-42))
    Turn(prong_R, z_axis, math.rad(42))
    Turn(prong_L, x_axis, math.rad(30))
    Turn(prong_R, x_axis, math.rad(30))
    Turn(prong_L, y_axis, math.rad(-20))
    Turn(prong_R, y_axis, math.rad(20))
    Turn(phalanx, z_axis, math.rad(-12))
    
    Turn(shieldArm[1], y_axis, math.rad(-15))
    Turn(shieldArm[1], z_axis, math.rad(-15))
    Turn(shieldArm[2], z_axis, math.rad(-15))
    Turn(shieldArm[3], z_axis, math.rad(30))
    Turn(shieldArm[4], x_axis, math.rad(15))
    
    local pair = 0
    for i=1,7,2 do
	pair = pair + 1
	local angles = {0, math.rad(12), math.rad(24), math.rad(36)}
	Turn(piece("phalanx"..i), y_axis, math.pi/2)
	Turn(piece("phalanx"..i), x_axis, -math.rad(90) + angles[pair])
	Turn(piece("phalanx"..i+1), y_axis, math.pi/2)
	Turn(piece("phalanx"..i+1), x_axis, math.rad(90) - angles[pair])
    end
    
    StartThread(FeatherLoop)
    --StartThread(DebugPhalanx)
    --StartThread(DebugMuzzleFlare)
end

function script.MoveRate(rate)
end

function script.AimFromWeapon(num)
    local data = weapons[num]
    return data.aimpoint
end

function script.QueryWeapon(num)
    local data = weapons[num]
    return data.muzzles[data.index]
end

function script.FireWeapon(num)
    if num == 2 then
	--[[
	Turn(vulcan_L, z_axis, gunRotate*math.rad(-60), math.pi*2)
	Turn(vulcan_R, z_axis, gunRotate*math.rad(60), math.pi*2)
	gunRotate = gunRotate + 1
	if gunRotate == 3 then gunRotate = 0 end
	]]--
	Spin(vulcan, z_axis, math.pi*4)
	StartThread(RestoreAfterDelay)
    end
end

function script.AimWeapon(num)
    GG.UpdateWeaponAccuracy(unitID, unitDefID, num)
    if num == 5 then return isUsingSpecial
    else return (not isUsingSpecial) end
end

function script.Shot(num)
    local data = weapons[num]
    if data.emit then
	EmitSfx(data.muzzles[data.index], data.emit)
    end
    data.index = data.index + 1
    if data.index > #data.muzzles then
	data.index = 1
    end
    
    if num == 5 then
	if specialShots == 3 then
	    local unitDefID = Spring.GetUnitDefID(unitID)
	    local unitTeam = Spring.GetUnitTeam(unitID)
	    --local specialTargetDefID = Spring.GetUnitDefID(specialTarget)
	    --local specialTargetTeam = Spring.GetUnitTeam(specialTarget)
	    GG.EventWrapper.AddEvent("specialWeapon", 0, unitID, unitDefID, unitTeam, specialTarget, specialTargetDefID, specialTargetTeam)
	end
	specialShots = specialShots - 1
    end
end

function script.BlockShot(weaponID, targetID, userTarget)
    local minRange = minRanges[weaponID]
    local energyPerShot = (GG.Energy) and energyPerShot[weaponID]
    if minRange then
	local distance
	if targetID then
	    distance = Spring.GetUnitSeparation(unitID, targetID, true)
	elseif userTarget then
	    local cmd = Spring.GetUnitCommands(unitID, 1)[1]
	    if cmd.id == CMD.ATTACK then
		local tx,ty,tz = unpack(cmd.params)
		distance = GetUnitDistanceToPoint(unitID, tx, ty, tz, true)
	    end
	end
	if distance < minRange then return true end
    end
    if usingSpecial and (not Spring.GetUnitIsDead(specialTarget)) and specialTarget ~= targetID then
	return true
    end
    if energyPerShot then
	return (not GG.Energy.UseUnitEnergy(unitID, unitDefID, energyPerShot))
    end
    return false
end

function script.HitByWeapon(x, z, weaponDefID, damage)
    --if isUsingSpecial then
	--return 0
    --end
    StartThread(DamageLoop)
end

function script.Killed(recentDamage, maxHealth)
    dead = true
    for i=1,8 do
	EmitSfx(base, 1027)
	Sleep(500)
    end
    EmitSfx(fuselage, 1026)
end