--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--include "damage.lua"
include "constants.lua"

--local unitDefID = Spring.GetUnitDefID(unitID)
local unitTeam = Spring.GetUnitTeam(unitID)

local spGetUnitTeam = Spring.GetUnitTeam
local spGetUnitHealth = Spring.GetUnitHealth
local spEcho = Spring.Echo
local spSetWepState = Spring.SetUnitWeaponState
local spGetUnitCommands = Spring.GetUnitCommands

local LaunchDroneAsWeapon = GG.LaunchDroneAsWeapon

--------------------------------------------------------------------------------
-- pieces
--------------------------------------------------------------------------------

local hull, fin_l, fin_r, brace_l, brace_r, jawfin, maim = piece("hull", "fin_l", "fin_r", "brace_l", "brace_r", "jawfin", "maim")
local graser, graserFlare, emit_f, emit_b = piece("graser", "graserflare", "emit_f", "emit_b")
local kturret_l1, kpivot_l1, kbarrel1_l1, kbarrel2_l1, kflare1_l1, kflare2_l1 = piece("kturret_l1", "kpivot_l1", "kbarrel1_l1", "kbarrel2_l1", "kflare1_l1", "kflare2_l1")
local kturret_r1, kpivot_r1, kbarrel1_r1, kbarrel2_r1, kflare1_r1, kflare2_r1 = piece("kturret_r1", "kpivot_r1", "kbarrel1_r1", "kbarrel2_r1", "kflare1_r1", "kflare2_r1")
local kturret_l2, kpivot_l2, kbarrel1_l2, kbarrel2_l2, kflare1_l2, kflare2_l2 = piece("kturret_l2", "kpivot_l2", "kbarrel1_l2", "kbarrel2_l2", "kflare1_l2", "kflare2_l2")
local kturret_r2, kpivot_r2, kbarrel1_r2, kbarrel2_r2, kflare1_r2, kflare2_r2 = piece("kturret_r2", "kpivot_r2", "kbarrel1_r2", "kbarrel2_r2", "kflare1_r2", "kflare2_r2")
local lturret_f, lpivot_f, lbarrel1_f, lbarrel2_f, lflare1_f, lflare2_f = piece("lturret_f", "lpivot_f", "lbarrel1_f", "lbarrel2_f", "lflare1_f", "lflare2_f")
local lturret_b, lpivot_b, lbarrel1_b, lbarrel2_b, lflare1_b, lflare2_b = piece("lturret_b", "lpivot_b", "lbarrel1_b", "lbarrel2_b", "lflare1_b", "lflare2_b")
local khbarrel_l, khbarrel_r, khflare_l, khflare_r = piece("khbarrel_l", "khbarrel_r", "khflare_l", "khflare_r")
local mbox_l, mflare1_l, mflare2_l, mflare3_l = piece("mbox_l", "mflare1_l", "mflare2_l", "mflare3_l")
local mbox_r, mflare1_r, mflare2_r, mflare3_r = piece("mbox_r", "mflare1_r", "mflare2_r", "mflare3_r")

local weapons = {
	{aimFrom = hull, muzzles = {khflare_l, khflare_r} },
	{aimFrom = maim, muzzles = {mflare1_l, mflare1_r, mflare2_l, mflare2_r, mflare3_l, mflare3_r}},
	{aimFrom = graser, muzzles = {graserFlare}},
	{aimFrom = kturret_l1, yaw = kturret_l1, pitch = kpivot_l1, muzzles = {kflare1_l1, kflare2_l1}, emit = 1028 },
	{aimFrom = kturret_r1, yaw = kturret_r1, pitch = kpivot_r1, muzzles = {kflare1_r1, kflare2_r1}, emit = 1028  },
	{aimFrom = kturret_l2, yaw = kturret_l2, pitch = kpivot_l2, muzzles = {kflare1_l2, kflare2_l2}, emit = 1028  },
	{aimFrom = kturret_r2, yaw = kturret_r2, pitch = kpivot_r2, muzzles = {kflare1_r2, kflare2_r2}, emit = 1028  },
	{aimFrom = lturret_f, yaw = lturret_f, pitch = lpivot_f, muzzles = {lflare1_f, lflare2_f} },
	{aimFrom = lturret_b, yaw = lturret_b, pitch = lpivot_b, muzzles = {lflare1_b, lflare2_b} },
	{aimFrom = hull, muzzles = {}},
	{aimFrom = graser, muzzles = {graserFlare}},
}
for i=1,#weapons do
	weapons[i].index = 1
end
for i=1,8 do
	weapons[10].muzzles[i] = piece("torp"..i)
end

--------------------------------------------------------------------------------
-- default values
--------------------------------------------------------------------------------
local deathMed = 1024
local deathLarge = 1025
local deathMultiMed = 1026
local chargeFX = 1032
local muzzleFX = 1028
local muzzleFXLarge = 1030

--milliseconds * 150
local graserChargeTime = 120
local graserFireTime = 240

local SIG_GRASER = 2^13

local dead = false

--------------------------------------------------------------------------------
--perks
--------------------------------------------------------------------------------
local perks = GG.perks

local function PerkLoop()
	while true do
		perks = GG.perks
		if perks then return end
		Sleep(33)
	end
end

local haveMoreGuns = perks and perks[unitTeam].have[perkMoreGuns] or false

local function HideExtraGuns()
	Hide(kturret_l1)
	Hide(kbarrel1_l1)
	Hide(kbarrel2_l1)
	Hide(kturret_r1)
	Hide(kbarrel1_r1)
	Hide(kbarrel2_r1)
	Hide(lturret_b)
	Hide(lbarrel1_b)
	Hide(lbarrel2_b)
end

local function ShowExtraGuns()
	Show(kturret_l1)
	Show(kbarrel1_l1)
	Show(kbarrel2_l1)
	Show(kturret_r1)
	Show(kbarrel1_r1)
	Show(kbarrel2_r1)
	Show(lturret_b)
	Show(lbarrel1_b)
	Show(lbarrel2_b)
end

local function TurnPieceInit()
	Turn(lturret_b, y_axis, math.rad(180))
	for i=1,8 do
		local angle = math.rad(90)
		if i%2 == 0 then angle = -angle end
		Turn(weapons[10].muzzles[i], y_axis, angle)
	end
	for i=1,6 do
		Turn(weapons[2].muzzles[i], x_axis, -math.rad(45))
	end
end

local function SetDGunCMD()
	local cmd = Spring.FindUnitCmdDesc(unitID, CMD.MANUALFIRE)
	local desc = {
		name = "Graser",
		tooltip = "Graser: Fires an very high-energy beam\nThe weapon is hull-mounted and can only be aimed at large ships",
		type = CMDTYPE.ICON_UNIT_OR_MAP,
		texture = "&.1x.1&bitmaps/icons/megalaser.png&bitmaps/icons/frame_slate_128x96.png",
		onlyTexture = false,
	}
	if cmd then Spring.EditUnitCmdDesc(unitID, cmd, desc) end
end

function script.Create()
	TurnPieceInit()	
	SetDGunCMD()
end

--------------------------------------------------------------------------------
--aiming code
--------------------------------------------------------------------------------
local turretSpeed = math.rad(240)
local pivotSpeed = math.rad(120)

local function AimTurret(num, heading, pitch)
	local SIG_AIM = 2^(num - 1)
	Signal(SIG_AIM)
	SetSignalMask(SIG_AIM)
	local turret = weapons[num].yaw
	local pivot = weapons[num].pitch
	Turn(turret, y_axis, heading, turretSpeed)
	Turn(pivot, x_axis, -pitch, pivotSpeed)
	WaitForTurn(turret, y_axis)
	WaitForTurn(pivot, x_axis)
	GG.UpdateWeaponAccuracy(unitID, unitDefID, num)
	return true
end

function script.AimFromWeapon(num)
	return weapons[num].aimFrom
end

function script.QueryWeapon(num)
	local index = weapons[num].index
	return weapons[num].muzzles[index]
end

function script.AimWeapon(num, heading, pitch)
	if num >= 4 and num <= 9 then
		return AimTurret(num, heading, pitch)
	else
		GG.UpdateWeaponAccuracy(unitID, unitDefID, num)
		return true
	end
end

local function FireGraser()
	Signal(SIG_GRASER)
	SetSignalMask(SIG_GRASER)
	for i=0,graserChargeTime do
		SetUnitValue(COB.CEG_DAMAGE,i*0.6)
		EmitSfx(graserFlare, chargeFX)
		Sleep(30)
	end
	for i=0,graserFireTime do
		Sleep(30)
		EmitSfx(graserFlare, 2048 + 10)
	end
end

function script.FireWeapon(num)
	if num == 3 then
		StartThread(FireGraser)
	elseif num == 10 then
		FireTorpedoes()
	end
end

function script.Shot(num)
	local x = weapons[num].index
	if weapons[num].emit then
		EmitSfx(weapons[num].muzzles[x], weapons[num].emit)
	end
	x = x + 1
	if x > #weapons[num].muzzles then
		x = 1
	end
	weapons[num].index = x
end

--[[
function script.BlockShot(weaponNum, targetID, userTarget)
	if weaponNum ~= 10 then return false end
	if targetID == nil or targetID < 1 or targetID == unitID then return true end
	return false
end
]]

--------------------------------------------------------------------------------
--death
--------------------------------------------------------------------------------
local shatter = SFX.SHATTER

function script.Killed(recentDamage, maxHealth)
	dead = true
	local mrad = math.rad

	EmitSfx(hull, deathLarge)
	--Turn(hullMain,x_axis,10,mr(1))
	Turn(hull,z_axis, math.random(-5,5),mrad(1))
	Sleep(700)
	Move(fin_l, x_axis, 10, math.random(1,5))
	Sleep(450)
	EmitSfx(jawfin, deathMed)
	Sleep(600)
	EmitSfx(hull, deathMultiMed)
	Hide(jawfin)
	Sleep(300)
	EmitSfx(emit_b, deathLarge)
	Hide(fin_r)
	Sleep(1500)
	-- TBD
end
