--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include("constants.lua")
--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

local hull, engine = piece('hull', 'engine')
local missiles = {}
local bay1, bay2 = piece('bay1', 'bay2')
local bays = {bay1, bay2}

for i=1,4 do
    missiles[i] = piece("missile"..i)
end

--------------------------------------------------------------------------------
-- constants
--------------------------------------------------------------------------------
local SIG_DAMAGE = 1
local SIG_SPAWN = 2
local SIG_LOCK = 4
local spawnDefs = VFS.Include("LuaRules/Configs/enclave_spawn_defs.lua")

--------------------------------------------------------------------------------
-- variables
--------------------------------------------------------------------------------
local gunIndex = 1
local bayIndex = 1
local weaponsLocked = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function DamageLoop()	-- FIXME
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

-- prevents missiles from hitting freshly-launched younglings
-- only you can prevent friendly fire
local function LockWeapons()
    Signal(SIG_LOCK)
    SetSignalMask(SIG_LOCK)
    weaponsLocked = true
    Sleep(5000)
    weaponsLocked = false
end

local function SpawnYoungling(unitDefID)
    local x,y,z,dx,dy,dz = Spring.GetUnitPiecePosDir(unitID, bays[bayIndex])
    --Spring.Echo(bays[bayIndex], piece('bay1'), piece('bay2'))
    local team = Spring.GetUnitTeam(unitID)
    local newUnit = Spring.CreateUnit(unitDefID, x, y, z, 0, team)
    local heading = Spring.GetHeadingFromVector(dx, dz)
    Spring.MoveCtrl.SetPosition(unitID,x,y,z)
    GG.FlightControl.SetUnitHeading(newUnit, heading/32768 * math.pi)
    GG.FlightControl.SetUnitSpeed(newUnit, 4)
    --Spring.GiveOrderToUnit(newUnit, CMD.FIGHT, {x-45+math.random(90), y, z-45+math.random(90)}, 0)
    
    bayIndex = bayIndex + 1
    if bayIndex > #bays then
	bayIndex = 1
    end
end

local function EnclaveSpawnLoop()
    Signal(SIG_SPAWN)
    SetSignalMask(SIG_SPAWN)
    Sleep(3000)--(20000)
    while true do
	local selected
	local rand = math.random()
	local cumulativeChance = 0
	for i=1,#spawnDefs do
	    local def = spawnDefs[i]
	    cumulativeChance = cumulativeChance + def.chance
	    if cumulativeChance > rand then
		selected = def
		for i=1,2 do
		    SpawnYoungling(def.unitDefID)
		end
		StartThread(LockWeapons)
		break
	    end
	end
	Sleep(selected and selected.cooldown or 10000)
    end
end

function SetSpawnDefs(defs)
    spawnDefs = defs
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function script.Create()
    for i=1,4 do
	if i%2 == 0 then
	    Turn(missiles[i], y_axis, math.rad(90))
	else
	    Turn(missiles[i], y_axis, math.rad(-90))
	end
    end
    Turn(bay1, y_axis, math.rad(-90))
    Turn(bay2, y_axis, math.rad(90))
    StartThread(EnclaveSpawnLoop)
end

function script.AimWeapon(num)
    --GG.UpdateWeaponAccuracy(unitID, unitDefID, num)
    return (not weaponsLocked)
end

function script.AimFromWeapon()
    return hull
end

function script.QueryWeapon()
    return missiles[gunIndex]
end

function script.Shot()
    local flare = missiles[gunIndex]
    --EmitSfx(flare, 1026)
    gunIndex = gunIndex + 1
    if gunIndex > 4 then
	gunIndex = 1
    end
end

function script.HitByWeapon()
    --StartThread(DamageLoop)
end

function script.Killed(recentDamage, maxHealth)
    EmitSfx(hull, 1026)
    Sleep(750)
    EmitSfx(missiles[1], 1024)
    Sleep(100)
    EmitSfx(bay2, 1024)
    Sleep(150)
    EmitSfx(fuselage, 1026)
    Sleep(1000)
    EmitSfx(fuselage, 1025)
end

