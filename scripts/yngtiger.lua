--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include("constants.lua")
--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

local fuselage, wing_L, wing_R, fin_L, fin_R = piece('fuselage', 'wing_l', 'wing_r', 'fin_l', 'fin_r')
local bomb_L, bomb_R = piece('bomb_l', 'bomb_r')

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
	EmitSfx(wing_L, 1024)
	if ((health/maxHealth) < 0.3) then
	    EmitSfx(wing_R, 1024)
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
    return gun_1 and bomb_L or bomb_R
end

function script.FireWeapon()
    Sleep(1500)
    GG.FlightControl.BreakOffTarget(unitID)
end

--[[
function script.Shot()
    local flare = gun_1 and bomb_L or bomb_R
    EmitSfx(flare, 1026)
    gun_1 = not gun_1
end
]]

function script.HitByWeapon()
    StartThread(DamageLoop)
end

function script.Killed(recentDamage, maxHealth)
    local severity = recentDamage/maxHealth
    if severity < 1 then
	for i=1,6 do
	    EmitSfx(fuselage, 1027)
	    Sleep(500)
	end
    end
    EmitSfx(fuselage, 1025)
end

