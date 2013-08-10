--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include ("constants.lua")
--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

local base, fuselage, pod_L, pod_R, prong_L, prong_R = piece('base', 'fuselage', 'pod_l', 'pod_r', 'prong_l', 'prong_r')
local laser, laserflare = piece('laser', 'laserflare')
local vulcan_L, vulcan_R, vulcanFlare_L, vulcanFlare_R = piece('vulcan_l', 'vulcan_r', 'vulcanflare_l', 'vulcanflare_r')
local missile, missile1, missile2, missile3 = piece('missile', 'missile1', 'missile2', 'missile3')

local weapons = {
    {aimpoint = laser, muzzles = {laserflare}, index = 1},	-- laser
    {aimpoint = base, muzzles = {vulcanFlare_L, vulcanFlare_R}, index = 1, emit = 1026},	-- vulcan
    {aimpoint = missile, muzzles = {missile1, missile2, missile3}, index = 1},	-- missile
    {aimpoint = base, muzzles = {}, index = 1}	-- phalanx
}
do
    local muzzles = weapons[4].muzzles
    for i=1,4 do
	muzzles[#muzzles+1] = piece("phalanx_l"..i)
	muzzles[#muzzles+1] = piece("phalanx_r"..i)
    end
end

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

local function bla()
    while true do
	for i=1,4 do
	    EmitSfx(piece("phalanx_l"..i), 1027)
	    EmitSfx(piece("phalanx_r"..i), 1027)
	end
	Sleep(300)
    end
end

function script.Create()
    Turn(pod_L, z_axis, math.rad(12))
    Turn(pod_R, z_axis, math.rad(-12))
    Turn(prong_L, z_axis, math.rad(-42))
    Turn(prong_R, z_axis, math.rad(42))
    Turn(prong_L, x_axis, math.rad(30))
    Turn(prong_R, x_axis, math.rad(30))
    
    for i=1,4 do
	local angles = {-math.rad(18), math.rad(42), -math.rad(48), math.rad(72)}
	Turn(piece("phalanx_l"..i), y_axis, math.pi/2)
	Turn(piece("phalanx_l"..i), x_axis, angles[i])
	Turn(piece("phalanx_r"..i), y_axis, -math.pi/2)
	Turn(piece("phalanx_r"..i), x_axis, angles[i])
    end
    
    --StartThread(bla)
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

