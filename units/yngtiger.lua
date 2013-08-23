local unitName = "yngtiger"
local unitDef = {
	name = "Neinzul Youngling Tiger",
	description = "Youngling Attack Bomber",

	-- Required Tags
	power = 65,
	mass = 50,
	icontype = "sword",
	category = "SMALL WEAK TARGET ANY",
	footprintX = 1,
	footprintZ = 1,
	maxDamage = 3600,
	idleTime = 0,
	idleAutoHeal = 0,
	objectName = "yngtiger.s3o",
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
	maxVelocity = 2.95,
	turnRate = 900,
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
			name = "ENERGYBOMB",
			onlyTargetCategory = "TARGET",
			badTargetCategory = "SMALL",
			weaponMainDir = "0 0 1",
			maxAngleDif = 10,
		},	
	},

	explodeAs = "RetroDeathSmall",
	selfDestructAs = "RetroDeathSmall",

	-- Misc
	script = "yngtiger.lua",
	sfxTypes = {
		explosionGenerators = {
			"custom:damage_fire",
			"custom:death_small",
			"custom:gunmuzzle",
		},
	},
	customParams  =  {
		shortname = "Yng Tiger",
		helptext = "The Youngling Tiger is a fast strike bomber that delivers a powerful package of energy bombs. Like all Neinzul Younglings, it has low endurance and must periodically return to an Enclave Starship for resupply.",
		type = "small",
		role = "attacker",
		cost = 300,
		useflightcontrol = 1,
		combatspeed = 1.5,
		combatrange = 1200,
		inertiafactor = 0.99,
		rollangle = math.rad(30),
		minavoidanceangle = 75,
		maxavoidanceangle = 150,
		armor = 60,
		--ecm = 0,
	},
}

unitDef.unitname = unitName
return lowerkeys({ [unitName] = unitDef })
