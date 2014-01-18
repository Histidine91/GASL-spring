local unitName = "enclavestar"
local unitDef = {
	name = "Neinzul Enclave Starship",
	description = "Carrier/Tender Ship",

	-- Required Tags
	power = 1200,
	mass = 1000,
	icontype = "enclavestar",
	category = "LARGE ARMORED WEAK TARGET ANY",
	footprintX = 6,
	footprintZ = 6,
	maxDamage = 25000,
	idleTime = 0,
	idleAutoHeal = 0,
	objectName = "enclavestar.s3o",
	SoundCategory = "CARRIER",
	collisionVolumeType = "Box",
	collisionVolumeScales = "60 60 90",
	collisionVolumeTest = true,

	-- Movement
	canFly = true,
	hoverAttack = true,
	airHoverFactor = 0,
	airStrafe = false,
	cruiseAlt = 80,
	brakeRate = .5,
	acceleration = .01,
	canMove = true,
	maxVelocity = 1.8,
	turnRate = 360,

	-- Construction
	levelGround = false,

	-- Sight/Radar
	--radarDistance = 975,
	sightDistance = 1500,
	noChaseCategory = "ANY",
	stealth = true,

	-- Weapons
	weapons = {
		{
			name = "MISSILE_ENCLAVE",
			onlyTargetCategory = "TARGET",
			badTargetCategory = "ARMORED",
		},
	},

	explodeAs = "RetroDeathBig",
	selfDestructAs = "RetroDeathBig",

	-- Misc
	script = "enclavestar.lua",
	sfxTypes = {
		explosionGenerators = {
			"custom:death_med",
			"custom:death_large",
			"custom:death_multimed",
		},
	},
	customParams  =  {
		shortname = "Enclave Star",
		helptext = "These large vessels form the home of the Neinzul enclave mind-hives, and provide manufacturing and support facilities for the Younglings. Lightly armed and armored for its size.",
		type = "large",
		role = "support",
		cost = 4000,
		useflightcontrol = 1,
		combatspeed = 1,
		combatrange = 2500,
		minimumrange = 700,
		inertiafactor = 0.988,
		armor = 150,
		ecm = 40,
		energy = -1,
		resupplyrange = 200,
		attackspeedstate = 0,
		suppressionmod = 0.4,
		suppressionflankingmod = 0.5,
	},
}

unitDef.unitname = unitName
return lowerkeys({ [unitName] = unitDef })
