--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

do
	local required = {
	}
	local g = getfenv(1)
	for _,v in pairs(required) do
		if (not g[v]) then error("missing required definition: " .. v) end
	end
end

--include is broken apparently, adding functions directly
--include "damage.lua"
include "THIS.lua"

local engineEnabled = false


--local MY_ID = GetUnitValue(71)
--local unitDef = Spring.GetUnitDefID(unitID)
local unitTeam = Spring.GetUnitTeam(unitID)
local damageFX = 1024

local spGetUnitHealth = Spring.GetUnitHealth

--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

--core hull pieces
local hullMain, head, hullLeft, hullRight, hullAft = piece ("hullmain", "head", "hulll", "hullr", "hullaft")
local noseLeft, noseRight, plateLeft, plateRight = piece ("nosel", "noser", "platel", "plater")
--main hull weapons
local turretBaseAM, turretAM, flareAM, grav = piece ("amturretbase", "amturret", "amflare", "grav")
local droneLeft, droneRight, megaLaser = piece ("dronel", "droner", "megalaser")
--kinetic
local turretKForeLeft, sleeveKForeLeft, barrel1KForeLeft, barrel2KForeLeft, flare1KForeLeft, flare2KForeLeft = piece ("kturret_fore_l", "ksleeve_fore_l", "kbarrel1_fore_l", "kbarrel2_fore_l", "kflare1_fore_l", "kflare2_fore_l")
local turretKForeRight, sleeveKForeRight, barrel1KForeRight, barrel2KForeRight, flare1KForeRight, flare2KForeRight = piece ("kturret_fore_l", "ksleeve_fore_l", "kbarrel1_fore_l", "kbarrel2_fore_l", "kflare1_fore_l", "kflare2_fore_l")
local turretKMidLeft, sleeveKMidLeft, barrel1KMidLeft, barrel2KMidLeft, flare1KMidLeft, flare2KMidLeft = piece ("kturret_mid_l", "ksleeve_mid_l", "kbarrel1_mid_l", "kbarrel2_mid_l", "kflare1_mid_l", "kflare2_mid_l")
local turretKMidRight, sleeveKMidRight, barrel1KMidRight, barrel2KMidRight, flare1KMidRight, flare2KMidRight = piece ("kturret_mid_l", "ksleeve_mid_l", "kbarrel1_mid_l", "kbarrel2_mid_l", "kflare1_mid_l", "kflare2_mid_l")
local turretKAftLeft, sleeveKAftLeft, barrel1KAftLeft, barrel2KAftLeft, flare1KAftLeft, flare2KAftLeft = piece ("kturret_aft_l", "ksleeve_aft_l", "kbarrel1_aft_l", "kbarrel2_aft_l", "kflare1_aft_l", "kflare2_aft_l")
local turretKAftRight, sleeveKAftRight, barrel1KAftRight, barrel2KAftRight, flare1KAftRight, flare2KAftRight = piece ("kturret_aft_l", "ksleeve_aft_l", "kbarrel1_aft_l", "kbarrel2_aft_l", "kflare1_aft_l", "kflare2_aft_l")
--PDLs
local turretPDFore, sleevePDFore, barrelPDFore, flarePDFore = piece ("lturret_fore", "lsleeve_fore", "lbarrel_fore", "lflare_fore")
local turretPDLeft, sleevePDLeft, barrelPDLeft, flarePDLeft = piece ("lturret_mid_l", "lsleeve_mid_l", "lbarrel_mid_l", "lflare_mid_l")
local turretPDRight, sleevePDRight, barrelPDRight, flarePDRight = piece ("lturret_mid_r", "lsleeve_mid_r", "lbarrel_mid_r", "lflare_mid_r")
local turretPDAft, sleevePDAft, barrelPDAft, flarePDAft = piece ("lturret_aft", "lsleeve_aft", "lbarrel_aft", "lflare_aft")
--plasma
local turretPLeft, sleevePLeft, barrelPLeft, flarePLeft = piece ("pturret_l", "psleeve_l", "pbarrel_l", "pflare_l")
local turretPRight, sleevePRight, barrelPRight, flarePRight = piece ("pturret_r", "psleeve_r", "pbarrel_r", "pflare_r")
--missiles
local turretMLeft, pod1MLeft, pod2MLeft, flare1MLeft, flare2MLeft = piece ("mturret_l", "mpod1_l", "mpod2_l", "mflare1_l", "mflare2_l")
local turretMRight, pod1MRight, pod2MRight, flare1MRight, flare2MRight = piece ("mturret_r", "mpod1_r", "mpod2_r", "mflare1_r", "mflare2_r")
--torpedoes
local torp1, torp2, torp3, torp4, torp5, torp6 = piece ("torp1", "torp2", "torp3", "torp4", "torp5", "torp6")

--------------------------------------------------------------------------------
-- default values
--------------------------------------------------------------------------------

local turretMinHealth = {
	[1] = 0.5,
	[4] = 0.25,
	[5] = 0.6,
	[6] = 0.6,
	[7] = 0.25,
	[8] = 0.25,
	[9] = 0.45,
	[10] = 0.45,
	[11] = 0.55,
	[12] = 0.7,
	[13] = 0.7,
	[14] = 0.85,
	[15] = 0.25,
	[16] = 0.45,
	[17] = 0.45,
	[18] = 0.65,
	[19] = 0.65,
	[20] = 0.2,
	[21] = 0.5,
	[22] = 0.5,
}

local muzzleFX = 1028

--local damagePiece = { hullAft, head }

--------------------------------------------------------------------------------
--perks
--------------------------------------------------------------------------------
local perks = _G.perks
local haveMoreGuns = GetUnitValue(PERK_MORE_GUNS)

local function newPerk(perk)
	if (perk == perkMoreGuns) then
		haveMoreGuns = true
		showExtraGuns()
	end
	if (perk == perkMassDriver) then
		for i=5,10 do
			GetUnitValue(WEAPON_SPRAY, -i,KMEDIUM_SPRAY_BOOST)
			GetUnitValue(WEAPON_RELOADTIME, -i,KMEDIUM_ROF_BOOST)
		end
		muzzleFX = 1029
	end
	if perk == perkGravRange then
		GetUnitValue(WEAPON_RANGE, -4, GSTANDARD_RANGE_BOOST)
		GetUnitValue(WEAPON_RANGE, -15, GFLAK_RANGE_BOOST)
	end
end

GG.newPerk = newPerk
_G.newPerk = newPerk

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function hideExtraGuns()
	Hide(grav)
	Hide(turretMLeft)
	Hide(pod1MLeft)
	Hide(pod2MLeft)
	Hide(turretMRight)
	Hide(pod1MRight)
	Hide(pod2MRight)
	Hide(turretPDFore)
	Hide(sleevePDFore)
	Hide(barrelPDFore)
end

local function showExtraGuns()
	Show(grav)
	Show(turretMLeft)
	Show(pod1MLeft)
	Show(pod2MLeft)
	Show(turretMRight)
	Show(pod1MRight)
	Show(pod2MRight)
	Show(turretPDFore)
	Show(sleevePDFore)
	Show(barrelPDFore)
end

local function droneSpawnLoop()
	while true do
		local minHealth = turretMinHealth[weaponNum] or 0
		local health, maxHealth = spGetUnitHealth(unitID)
		if health/maxHealth >= minHealth then
			local target = GetUnitValue(TARGET_ID, 18)
			--LaunchDroneAsWeapon(unitID, nil, team, target, "drone", droneLeft, -90, 0)
			--LaunchDroneAsWeapon(unitID, nil, team, target, "drone", droneRight, 90, 0)
			LaunchDroneWeapon(target, DRONE_K, droneLeft, -1)
			LaunchDroneWeapon(target, DRONE_K, droneRight, 1)
			Sleep(800)
		end
		Sleep(15000)
	end
end

function script.Create()
	Sleep(30)
	EmitSfx(hullMain, 1027)
	EmitSfx(hullAft, 1027)
	EmitSfx(megaLaser, 1027)
		for i=5,10 do
			GetUnitValue(WEAPON_SPRAY, -i,KMEDIUM_SPRAY_BOOST)
			GetUnitValue(WEAPON_RELOADTIME, -i,KMEDIUM_ROF_BOOST)
		end
		muzzleFX = 1029
	if GetUnitValue(PERK_BETTER_GRAV) then
		GetUnitValue(WEAPON_RANGE, -4, GSTANDARD_RANGE_BOOST)
		GetUnitValue(WEAPON_RANGE, -15, GFLAK_RANGE_BOOST)
	end
	if (not haveMoreGuns) then
		hideExtraGuns()
	end
	StartThread(droneSpawnLoop)
end

--------------------------------------------------------------------------------
--aiming code
--------------------------------------------------------------------------------
local mRad = math.rad

local turretSpeedK = mRad(360)
local sleeveSpeedK = mRad(240)
local turretSpeedP = mRad(120)
local sleeveSpeedP = mRad(80)
local turretSpeedM = mRad(240)
local podSpeedM = mRad(160)

local gun1, gun2, gun3, gun4, gun5, gun6, miss1, miss2 = false, false, false, false, false, false, false, false

local firingMegaLaser = false

local function aimTurret(heading, pitch, turret, sleeve, turretSpeed, sleeveSpeed, weaponNum)
	local minHealth = turretMinHealth[weaponNum] or 0
	local health, maxHealth = spGetUnitHealth(unitID)
	if (health/maxHealth) < minHealth then
		EmitSfx(turret, 1031)
		Sleep(500)
		return false
	end
	Turn(turret, y_axis, heading, turretSpeed)
	Turn(sleeve, x_axis, -pitch, sleeveSpeed)
	WaitForTurn(turret, y_axis)
	WaitForTurn(sleeve, x_axis)
	return true
end

local function aimWeaponKinetic(heading, pitch, turret, sleeve, weaponNum)
	return aimTurret(heading, pitch, turret, sleeve, turretSpeedK, sleeveSpeedK, weaponNum)
end

local function aimWeaponInstant(weaponNum)
	local minHealth = turretMinHealth[weaponNum] or 0
	local health, maxHealth = spGetUnitHealth(unitID)
	if health/maxHealth < minHealth then
		EmitSfx(turret, 1031)
		Sleep(500)
		return false
	end
	return true
end

function script.AimFromWeapon(wid)
	if wid == 1 or wid == 2 then return turretAM end
	if wid == 3 or wid == 23 then return megaLaser end
	if wid == 4 or wid == 15 then return grav end
	if wid == 5 then return turretKForeLeft end
	if wid == 6 then return turretKForeRight end
	if wid == 7 then return turretKMidLeft end
	if wid == 8 then return turretKMidRight end
	if wid == 9 then return turretKAftLeft end
	if wid == 10 then return turretKAftRight end
	if wid == 11 then return turretPDFore end
	if wid == 12 then return turretPDMidLeft end
	if wid == 13 then return turretPDMidRight end
	if wid == 14 then return turretPDAft end
	if wid == 16 then return turretPLeft end
	if wid == 17 then return turretPRight end
	if wid == 18 or wid == 20 then return hullMid end
	if wid == 21 then return turretMLeft end
	if wid == 22 then return turretMRight end
end

function script.QueryWeapon(wid)
	if wid == 1 or wid == 2 then return flareAM end
	if wid == 3 or wid == 23 then return megaLaser end
	if wid == 4 or wid == 15 then return grav end
	if wid == 5 then
		gun1 = not gun1
		if gun1 then return flare1KForeLeft end
		return flare2KForeLeft
	end
	if wid == 6 then 
		gun2 = not gun2
		if gun2 then return flare1KForeRight end
		return flare2KForeRight
	end
	if wid == 7 then 
		gun3 = not gun3
		if gun3 then return flare1KMidLeft end
		return flare2KMidLeft
	end
	if wid == 8 then 
		gun4 = not gun4
		if gun4 then return flare1KMidRight end
		return flare2KMidRight
	end
	if wid == 9 then 
		gun5 = not gun5
		if gun5 then return flare1KAftLeft end
		return flare2KAftLeft
	end
	if wid == 10 then 
		gun6 = not gun6
		if gun6 then return flare1KAftRight end
		return flare2KAftRight
	end
	if wid == 11 then return flarePDFore end
	if wid == 12 then return flarePDMidLeft end
	if wid == 13 then return flarePDMidRight end
	if wid == 14 then return flarePDAft end
	if wid == 16 then return flarePLeft end
	if wid == 17 then return flarePRight end
	if wid == 18 or wid == 20 then return hullMid end
	if wid == 21 then
		miss1 = not miss1
		if miss1 then return pod1MLeft end
		return pod2MLeft
	end
	if wid == 22 then
		miss2 = not miss2
		if miss2 then return pod1MRight end
		return pod2MRight
	end
end

--WEAPON 1: Antimatter beam	
function script.AimWeapon1(heading, pitch)
	local SIG_AIM = 1
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	
	turnSpeed = mRad(90)
	pitchSpeed = mRad(60)
	return aimTurret(heading, pitch, turretAM, turretAM, turnSpeed , pitchSpeed, 1)
end

function script.QueryWeapon1()
	return flareAM
end

function script.FireWeapon1()
	for i=0,120 do
		SetUnitValue(CEG_DAMAGE,i)
		EmitSfx(flareAM,1030)
		Sleep(30)
	end
	for i=0,150 do
		Sleep(30)
		EmitSfx(flareAM,2049)
	end
end

function script.AimFromWeapon1()
	return turretAM
end

function script.AimWeapon2(heading, pitch)
	return false
end

--WEAPONS 3 AND 23: Superlaser
function script.QueryWeapon3()
	return megaLaser
end

function script.AimFromWeapon3()
	return megaLaser
end

function script.FireWeapon3()
	--open nose
	Move(noseLeft, x_axis, -20, 20)
	Move(noseRight, x_axis, 20, 20)
	WaitForMove(noseLeft, x_axis)
	WaitForMove(noseRight, x_axis)
	Sleep(500)
	--charge
	for i=0,180 do
		SetUnitValue(CEG_DAMAGE,i)
		EmitSfx(1030,megaLaser)
		Sleep(30)
	end
	--fire
	for i=0,300 do
		Sleep(30)
		EmitSfx(2049,megaLaser)
	end
	--close nose
	Sleep(500)
	Move(noseLeft, x_axis, 0, 20)
	Move(noseRight, x_axis, 0, 20)
	WaitForMove(noseLeft, x_axis)
	WaitForMove(noseRight, x_axis)
end
--------------------------------
function script.QueryWeapon23()
	return megaLaser
end

function script.AimFromWeapon23()
	return megaLaser
end

function script.AimWeapon23(heading, pitch)
	return false
end

--WEAPONS 4 AND 15: Gravitrics
function script.AimFromWeapon4()
	return grav
end

function script.AimWeapon4(heading, pitch)
	if (not haveMoreGuns) then
		return false
	end
	return aimWeaponInstant(4)
end

function script.QueryWeapon4()
	return grav
end
--------------------------------
function script.AimFromWeapon15()
	return grav
end

function script.AimWeapon15(heading, pitch)
	if (not haveMoreGuns or not GetUnitValue(PERK_GRAV_FLAK)) then
		return false
	end
	return aimWeaponInstant(15)
end

function script.QueryWeapon15()
	return grav
end

--WEAPONS 5 - 10: Kinetic cannons
function script.AimWeapon5(heading, pitch)
	return aimWeaponKinetic(heading, pitch, turretKForeLeft, sleeveKForeLeft, 5)
end

function script.AimFromWeapon5()
	return turretKForeLeft
end

function script.QueryWeapon5()
	if(gun1) then
		return flare1KForeLeft
	end
	return flare2KForeLeft
end

function script.Shot5()
	if(gun1) then
		EmitSfx(flare1KForeLeft, muzzleFX)
	else
		EmitSfx(flare2KForeLeft, muzzleFX)
	end
	gun1 = not gun1
end
--------------------------------
function script.AimWeapon6(heading, pitch)
	return aimWeaponKinetic(heading, pitch, turretKForeRight, sleeveKForeRight, 6)
end

function script.AimFromWeapon6()
	return turretKForeRight
end

function script.QueryWeapon6()
	if(gun2) then
		return flare1KForeRight
	end
	return flare2KForeRight
end

function script.Shot6()
	if(gun2) then
		EmitSfx(flare1KForeRight, muzzleFX)
	else
		EmitSfx(flare2KForeRight, muzzleFX)
	end
	gun2 = not gun2
end
--------------------------------
function script.AimWeapon7(heading, pitch)
	return aimWeaponKinetic(heading, pitch, turretKMidLeft, sleeveKMidLeft, 7)
end

function script.AimFromWeapon7()
	return turretKMidLeft
end

function script.QueryWeapon7()
	if(gun3) then
		return flare1KMidLeft
	end
	return flare2KMidLeft
end

function script.Shot7()
	if(gun3) then
		EmitSfx(flare1KMidLeft, muzzleFX)
	else
		EmitSfx(flare2KMidLeft, muzzleFX)
	end
	gun3 = not gun3
end
--------------------------------
function script.AimWeapon8(heading, pitch)
	return aimWeaponKinetic(heading, pitch, turretKMidRight, sleeveKMidRight, 8)
end

function script.AimFromWeapon8()
	return turretKMidRight
end

function script.QueryWeapon8()
	if(gun4) then
		return flare1KMidRight
	end
	return flare2KMidRight
end

function script.Shot8()
	if(gun3) then
		EmitSfx(flare1KMidRight, muzzleFX)
	else
		EmitSfx(flare2KMidRight, muzzleFX)
	end
	gun4 = not gun4
end
--------------------------------
function script.AimWeapon9(heading, pitch)
	return aimWeaponKinetic(heading, pitch, turretKAftLeft, sleeveKAftLeft, 9)
end

function script.AimFromWeapon9()
	return turretKAftLeft
end

function script.QueryWeapon9()
	if(gun5) then
		return flare1KAftLeft
	end
	return flare2KAftLeft
end

function script.Shot9()
	if(gun5) then
		EmitSfx(flare1KAftLeft, muzzleFX)
	else
		EmitSfx(flare2KAftLeft, muzzleFX)
	end
	gun5 = not gun5
end
--------------------------------
function script.AimWeapon10(heading, pitch)
	return aimWeaponKinetic(heading, pitch, turretKAftRight, sleeveKAftRight, 10)
end

function script.AimFromWeapon10()
	return turretKAftRight
end

function script.QueryWeapon10()
	if(gun6) then
		return flare1KAftRight
	end
	return flare2KAftRight
end

function script.Shot10()
	if(gun6) then
		EmitSfx(flare1KAftRight, muzzleFX)
	else
		EmitSfx(flare2KAftRight, muzzleFX)
	end
	gun6 = not gun6
end

--WEAPONS 11 - 14: Point defense lasers
function script.AimWeapon11(heading, pitch)
	if (not haveMoreGuns) then
		return false
	end
	return aimWeaponKinetic(heading, pitch, turretPDFore, sleevePDFore, 11)
end

function script.AimFromWeapon11()
	return turretPDFore
end

function script.QueryWeapon11()
	return flarePDFore
end
--------------------------------
function script.AimWeapon12(heading, pitch)
	return aimWeaponKinetic(heading, pitch, turretPDMidLeft, sleevePDMidLeft, 12)
end

function script.AimFromWeapon12()
	return turretPDMidLeft
end

function script.QueryWeapon12()
	return flarePDMidLeft
end
--------------------------------
function script.AimWeapon13(heading, pitch)
	return aimWeaponKinetic(heading, pitch, turretPDMidRight, sleevePDMidRight, 13)
end

function script.AimFromWeapon13()
	return turretPDMidRight
end

function script.QueryWeapon13()
	return flarePDMidRight
end
--------------------------------
function script.AimWeapon14(heading, pitch)
	return aimWeaponKinetic(heading, pitch, turretPDAft, sleevePDAft, 14)
end

function script.AimFromWeapon14()
	return turretPDAft
end

function script.QueryWeapon14()
	return flarePDAft
end

--WEAPONS 16 - 17: Plasma cannons
function script.AimWeapon16(heading, pitch)
	return aimTurret(heading, pitch, turretPLeft, sleevePLeft, turretSpeedP, sleeveSpeedP, 16)
end

function script.AimFromWeapon16()
	return turretPLeft
end

function script.QueryWeapon16()
	return flarePLeft
end
--------------------------------
function script.AimWeapon17(heading, pitch)
	return aimTurret(heading, pitch, turretPRight, sleevePRight, turretSpeedP, sleeveSpeedP, 16)
end

function script.AimFromWeapon17()
	return turretPRight
end

function script.QueryWeapon17()
	return flarePRight
end

--WEAPON 18 : Drone launcher
local function AimWeapon18(heading, pitch)
	return aimWeaponInstant(18)
end

--WEAPON 20: Torpedoes
function script.AimWeapon20()
	return aimWeaponInstant(20)
end

function script.AimFromWeapon20()
	return hullMain
end

function script.QueryWeapon20()
	return hullMain
end

function script.FireWeapon20()
	while true do
		local target = GetUnitValue(TARGET_ID, 18)
		LaunchDroneAsWeapon(unitID, nil, unitTeam, target, "torpedo", torp5, -90, 0)
		LaunchDroneAsWeapon(unitID, nil, unitTeam, target, "torpedo", torp6, 90, 0)
		Sleep(300)
		target = GetUnitValue(TARGET_ID, 18)
		LaunchDroneAsWeapon(unitID, nil, unitTeam, target, "torpedo", torp3, -90, 0)
		LaunchDroneAsWeapon(unitID, nil, unitTeam, target, "torpedo", torp4, 90, 0)
		target = GetUnitValue(TARGET_ID, 18)
		LaunchDroneAsWeapon(unitID, nil, unitTeam, target, "torpedo", torp1, -90, 0)
		LaunchDroneAsWeapon(unitID, nil, unitTeam, target, "torpedo", torp2, 90, 0)
		end
end

--WEAPONS 21-22: SAM launchers
function script.AimWeapon21(heading, pitch)
	return aimTurret(heading, pitch, turretMLeft, pod1MLeft, turretSpeedM, sleeveSpeedM, 21)
end

function script.AimFromWeapon21()
	return turretMLeft
end

function script.QueryWeapon21()
	if(miss1) then
		return flare1MLeft
	end
	return flare2MLeft
end

function script.Shot21()
	miss1 = not miss1
end
--------------------------------
function script.AimWeapon22(heading, pitch)
	return aimTurret(heading, pitch, turretMRight, pod1MRight, turretSpeedP, sleeveSpeedP, 21)
end

function script.AimFromWeapon22()
	return turretPRight
end

function script.QueryWeapon22()
	if(miss2) then
		return flare1MRight
	end
	return flare2MLeft
end

function script.Shot22()
	miss2 = not miss2
end

--------------------------------------------------------------------------------
--death
--------------------------------------------------------------------------------
local function explodeAftPieces()
end

local function explodeNosePieces()
end

local function explodeSidePieces()
end

function script.Killed(recentDamage, maxHealth)
	EmitSfx(head, 1025)
	Sleep(700)
	
	Move(hullAft,z_axis,-90,16)
	Move(plateLeft,x-axis,-90,15)
	Move(plateRight,x-axis,90,15)
	EmitSfx(hullAft, 1026)
	Sleep(1000)
			
	Move(hullLeft,z_axis,90,16)
	Move(hullRright,z_axis,90,16)
	Spin(hullLeft,z_axis,20)
	Spin(hullRight,z_axis,20)
	Sleep(1800)	
	Hide(hullAft)
	explodeAftPieces()
	Explode(plateLeft)
	Explode(plateRight)
	
	EmitSfx(hullMain, 1026)
	EmitSfx(hullLeft, 1025)
	EmitSfx(hullRight, 1025)
	EmitSfx(noseLeft, 1024)
	EmitSfx(noseRight, 1024)
	Sleep(1400)	

	Hide(noseLeft)
	Hide(noseRight)
	explodeNosePieces()
	EmitSfx(hullMain, 1024)
	EmitSfx(hullLeft, 1025)
	EmitSfx(hullRight, 1025)
	Sleep(1100)	
	Hide(hullLeft)
	Hide(hullRight)
	explodeSidePieces()
	EmitSfx(hullMain, 1026)
	Sleep(700)
end
