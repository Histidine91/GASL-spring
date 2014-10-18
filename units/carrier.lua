local unitName = "carrier"
local unitDef = {
	Name = "Fleet Carrier",
	Description = "Field production and maintenance ship",

	-- Required Tags
	power = 1500,
	mass = 10000,
	icontype = "carrier",
	category = "LARGE CARRIER WEAK TARGET COMMANDER ANY",
	footprintX = 6,
	footprintZ = 6,
	maxDamage = 25000,
	idleTime = 0,
	idleAutoHeal = 0,
	objectName = "carrier.s3o",
	soundCategory = "CARRIER",
	collisionVolumeType = "Box",
	collisionVolumeScales = "92 40 180",
	collisionVolumeTest = true,
	collide = 0,

	-- Movement
	canFly = true,
	hoverAttack = true,
	airHoverFactor = 0,
	airStrafe = false,
	cruiseAlt = 80,
	brakeRate = .5,
	acceleration = .01,
	canMove = true,
	maxVelocity = 1,
	turnRate = 220,

	-- Construction
	levelGround = false,

	-- Sight/Radar
	sightDistance = 1500,
	noChaseCategory = "NOCHASE",
	stealth = true,

	-- Weapons
	weapons = {
		{
			name = "NEEDLER_FIGHTER",
			onlyTargetCategory = "TARGET",
			weaponMainDir = "0 0 1",
			MaxAngleDif = 270,
			badTargetCategory = "LARGE",
		},
	
		{
			name = "NEEDLER_FIGHTER",
			onlyTargetCategory = "TARGET",
			weaponMainDir = "0 0 -1",
			maxAngleDif = 270,
			badTargetCategory = "LARGE",
		},
		{
			name = "NEEDLER_FIGHTER",
			onlyTargetCategory = "TARGET",
			weaponMainDir = "0 0 1",
			maxAngleDif = 270,
			badTargetCategory = "LARGE",
		},
	},
	
	explodeAs = "RetroDeathBig",
	selfDestructAs = "RetroDeathBig",
	
	-- Misc
	smoothAnim = false,
	selfDestructCountdown = 6,
	movestate = 0,
	
	sfxTypes = {
		explosionGenerators = {
			"custom:death_med",
			"custom:death_large",
			"custom:death_multimed",
			"custom:teleport",
			"custom:muzzlekinetic",
			"custom:muzzlemassdriver",
		},
	},
	
	customParams = {
		type = "large",
		helptext = "An escort carrier for supporting small wings of fighters in the field. Lightly armored and armed for its size.",
		cost = 3000,
		combatrange = 1000,
		inertiafactor = 0.995,
		armor = 150,
		ecm = 40,
		energy = -1,
		resupply = 200,
		attackspeedstate = 0,
		suppressionmod = 0.25,
		suppressionflankingresist = 0.4,
	},
}

unitDef.unitname = unitName
return lowerkeys({ [unitName] = unitDef })
