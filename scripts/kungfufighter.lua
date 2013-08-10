--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include ("constants.lua")
--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

local base, fuselage, pod_L, pod_R, prong_L, prong_R = piece('base', 'fuselage', 'pod_l', 'pod_r', 'prong_l', 'prong_r')
local bellypod = piece('bellypod')
local vulcan_L, vulcan_R, vulcanFlare_L, vulcanFlare_R = piece('vulcan_l', 'vulcan_r', 'vulcanflare_l', 'vulcanflare_r')
local missile_L, missile_L1, missile_L2, missile_L3 = piece('missile_l', 'missile_l1', 'missile_l2', 'missile_l3')
local missile_R, missile_R1, missile_R2, missile_R3 = piece('missile_r', 'missile_r1', 'missile_r2', 'missile_r3')
local armJoint_L, armJoint_R, arm_L, arm_R, claw_L, claw_R = piece('armjoint_l', 'armjoint_r', 'arm_l', 'arm_r', 'claw_l', 'claw_r')

local weapons = {
    {aimpoint = base, muzzles = {vulcanFlare_L, vulcanFlare_R}, index = 1, emit = 1026},	-- vulcan
    {aimpoint = fuselage, muzzles = {missile_L1, missile_R1, missile_L2, missile_R2, missile_L3, missile_R3}, index = 1},	-- missile
}
local gunRotate = 0

--------------------------------------------------------------------------------
-- constants
--------------------------------------------------------------------------------
local SIG_DAMAGE = 1

--------------------------------------------------------------------------------
-- variables
--------------------------------------------------------------------------------

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
	Sleep(50)
    end
end

function script.Create()
    Turn(pod_L, z_axis, math.rad(12))
    Turn(pod_R, z_axis, math.rad(-12))
    Turn(missile_L, z_axis, math.rad(-12))
    Turn(missile_R, z_axis, math.rad(12))
    Turn(prong_L, z_axis, math.rad(-42))
    Turn(prong_R, z_axis, math.rad(42))
    Turn(prong_L, x_axis, math.rad(30))
    Turn(prong_R, x_axis, math.rad(30))
    Turn(armJoint_L, z_axis, math.rad(-30))
    Turn(armJoint_R, z_axis, math.rad(30))
    Turn(arm_L, y_axis, math.rad(-20))
    Turn(arm_R, y_axis, math.rad(20))
    
    for i=2,3 do
	local angle = math.rad(22.5*(i-1))
	Turn(piece("missile_l"..i), y_axis, -angle)
	Turn(piece("missile_r"..i), y_axis, angle)
    end
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
    if num == 1 then
	Turn(vulcan_L, z_axis, gunRotate*math.rad(-60), math.pi)
	Turn(vulcan_R, z_axis, gunRotate*math.rad(60), math.pi)
	gunRotate = gunRotate + 1
	if gunRotate == 3 then gunRotate = 0 end
    end
end

function script.AimWeapon(num)
    GG.UpdateWeaponAccuracy(unitID, unitDefID, num)
    return true
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
end

function script.HitByWeapon()
    StartThread(DamageLoop)
end

function script.Killed(recentDamage, maxHealth)
    EmitSfx(fuselage, 1025)
end
