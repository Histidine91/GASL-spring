local unitName = "yngcommando"
local unitDef = {
	name = "Neinzul Youngling Commando",
	description = "Youngling Interceptor",

	-- Required Tags
	power = 50,
	mass = 40,
	icontype = "dagger",
	category = "SMALL WEAK TARGET ANY",
	footprintX = 1,
	footprintZ = 1,
	maxDamage = 3000,
	idleTime = 0,
	idleAutoHeal = 0,
	objectName = "yngcommando.s3o",
	SoundCategory = "FIGHTER",
	collisionVolumeType = "Box",
	collisionVolumeScales = "16 6 22",
	collisionVolumeTest = true,

	-- Movement
	canFly = true,
	hoverAttack = true,
	airHoverFactor = 0,
	airStrafe = false,
	cruiseAlt = 130,
	brakeRate = 1.5,
	acceleration = .09,
	canMove = true,
	maxVelocity = 3,
	turnRate = 1200,
	collide = false,

	-- Construction
	levelGround = false,

	-- Sight/Radar
	--radarDistance = 975,
	sightDistance = 1200,
	noChaseCategory = "ANY",
	stealth = true,

	-- Weapons
	weapons = {
		{
			name = "NEEDLER_FIGHTER",
			onlyTargetCategory = "TARGET",
			badTargetCategory = "LARGE",
			weaponMainDir = "0 0 1",
			maxAngleDif = 10,
		},	
	},

	explodeAs = "RetroDeathSmall",
	selfDestructAs = "RetroDeathSmall",

	-- Misc
	script = "yngcommando.lua",
	sfxTypes = {
		explosionGenerators = {
			"custom:damage_fire",
			"custom:death_small",
			"custom:gunmuzzle",
		},
	},
	customParams  =  {
		shortname = "Yng Commando",
		helptext = "The Youngling Commando is an exceedingly fast fighter with dual needlers. Like all Neinzul Younglings, it has low endurance and must periodically return to an Enclave Starship for resupply.",
		type = "small",
		role = "attacker",
		cost = 200,
		trailtex = "bitmaps/trails/1m2sw.png",
		trailr = .5,
		trailg = 1,
		trailb = .5,
		trailalpha = 1,
		useflightcontrol = 1,
		combatspeed = 1.6,
		combatrange = 1200,
		inertiafactor = 0.96,
		rollangle = math.rad(30),
		armor = 50,
	},
}

unitDef.unitname = unitName
return lowerkeys({ [unitName] = unitDef })
