--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include("constants.lua")
--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

local fuselage, wingL, wingR, finL, finR = piece('fuselage', 'wingl', 'wingr', 'finl', 'finr')
local tankL, tankR, gunL, gunR = piece('tankl', 'tankr', 'gunl', 'gunr')

--------------------------------------------------------------------------------
-- constants
--------------------------------------------------------------------------------
local SIG_DAMAGE = 1

--------------------------------------------------------------------------------
-- variables
--------------------------------------------------------------------------------
local gun_1 = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function DamageLoop()
    Signal(SIG_DAMAGE)
    SetSignalMask(SIG_DAMAGE)
    local health, maxHealth = Spring.GetUnitHealth(unitID)
    while(health/maxHealth < 0.5) do
	SetUnitValue(COB.CEG_DAMAGE, math.floor(25 - (health/maxHealth)*0.5))
	EmitSfx(wingL, 1024)
	if ((health/maxHealth) < 0.3) then
	    EmitSfx(tankR, 1024)
	end
	Sleep(50)
    end
end


function script.Create()
end

function script.MoveRate(rate)
end

function script.AimWeapon(num)
    GG.UpdateWeaponAccuracy(unitID, unitDefID, num)
    return true
end

function script.AimFromWeapon()
    return fuselage
end

function script.QueryWeapon()
    return gun_1 and gunL or gunR
end

function script.Shot()
    local flare = gun_1 and gunL or gunR
    EmitSfx(flare, 1026)
    gun_1 = not gun_1
end

function script.HitByWeapon()
    StartThread(DamageLoop)
end

function script.Killed(recentDamage, maxHealth)
    EmitSfx(fuselage, 1025)
end

