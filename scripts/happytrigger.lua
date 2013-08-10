--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include ("constants.lua")
--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

local base, fuselage, pod_L, pod_R, prong_L, prong_R = piece('base', 'fuselage', 'pod_l', 'pod_r', 'prong_l', 'prong_r')
local laser, laserflare = piece('laser', 'laserflare')
local railgun_brace, railgun_L, railgunflare_L, railgun_R, railgunflare_R = piece('railgun_brace', 'railgun_l', 'railgunflare_l', 'railgun_r', 'railgunflare_r')
local missile_L, missileflare_L, missile_R, missileflare_R = piece('missile_l', 'missileflare_l', 'missile_r', 'missileflare_r')
local phalanx_L, phalanxarm_L, phalanx_R, phalanxarm_R = piece('phalanx_l', 'phalanxarm_l', 'phalanx_r', 'phalanxarm_r')

local weapons = {
    {aimpoint = base, muzzles = {railgunflare_L, railgunflare_R}, index = 1, emit = 1026},	-- railgun
    {aimpoint = laser, muzzles = {laserflare}, index = 1},	-- laser
    {aimpoint = base, muzzles = {missileflare_L, missileflare_R}, index = 1},	-- missile
    {aimpoint = base, muzzles = {}, index = 1}	-- phalanx
}
do
    local muzzles = weapons[4].muzzles
    for i=1,8 do
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

local function Ping()
    while true do
	for i=1,8 do
	    EmitSfx(piece("phalanx_l"..i), 1026)
	    EmitSfx(piece("phalanx_r"..i), 1026)
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
    Turn(phalanxarm_L, z_axis, math.rad(-12))
    Turn(phalanxarm_R, z_axis, math.rad(12))
    
    for i=1,8 do
	local angle = (i%2 == 0) and math.rad(80) or -math.rad(80)
	local angle2 = math.rad(90)
	Turn(piece("phalanx_l"..i), x_axis, angle)
	Turn(piece("phalanx_l"..i), y_axis, angle2)
	Turn(piece("phalanx_r"..i), x_axis, angle)
	Turn(piece("phalanx_r"..i), y_axis, -angle2)
    end
    
    --StartThread(Ping)
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
end

function script.AimWeapon(num)
    GG.UpdateWeaponAccuracy(unitID, unitDefID, num)
    return num == 1 or num == 4
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

