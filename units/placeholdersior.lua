local unitName = "placeholdersior"
local unitDef = {
	Name = "Placeholdersior",
	Description = "Advanced command-and-control capital ship",

	-- Required Tags
	power = 4000,
	mass = 8000,
	icontype = "placeholdersior",
	category = "LARGE CARRIER STRONG TARGET ANY",
	footprintX = 8,
	footprintZ = 8,
	maxDamage = 80000,
	--autoheal = 10,
	idleTime = 0,
	idleAutoHeal = 0,
	objectName = "placeholdersior.s3o",
	soundCategory = "CARRIER",
	collisionVolumeType = "Box",
	collisionVolumeScales = "110 50 220",
	collisionVolumeTest = true,
	collide = 0,

	-- Movement
	canFly = true,
	hoverAttack = true,
	airHoverFactor = 0,
	airStrafe = false,
	cruiseAlt = 50,
	brakeRate = .6,
	acceleration = .045,
	canMove = true,
	maxVelocity = 1.72,
	turnRate = 360,

	-- Construction
	levelGround = false,

	-- Sight/Radar
	--radarDistance = 1350,
	sightDistance = 2000,
	noChaseCategory = "NOCHASE",
	stealth = true,

	-- Weapons
	weapons = {
		{
			def = "PLASMALANCE",
			onlyTargetCategory = "LARGE",
			mainDir = "0 0 1",
			MaxAngleDif = 10,
		},
		{
			def = "MISSILE_TREBUCHET",
			onlyTargetCategory = "LARGE",
			--badTargetCategory = "WEAK",
			mainDir = "0 0.5 1",
			maxAngleDif = 150,
		},
		{
			name = "NOWEAPON",
		},
		{
			def = "AUTOCANNON",
			onlyTargetCategory = "TARGET",
			mainDir = "-1 0.5 0.5",
			maxAngleDif = 210,
			badTargetCategory = "LARGE",
		},
		{
			def = "AUTOCANNON",
			onlyTargetCategory = "TARGET",
			mainDir = "1 0.5 0.5",
			maxAngleDif = 210,
			badTargetCategory = "LARGE",
		},
		{
			def = "AUTOCANNON",
			onlyTargetCategory = "TARGET",
			mainDir = "-1 0.5 0",
			maxAngleDif = 210,
			badTargetCategory = "LARGE",
		},
		{
			def = "AUTOCANNON",
			onlyTargetCategory = "TARGET",
			mainDir = "1 0.5 0",
			maxAngleDif = 210,
			badTargetCategory = "LARGE",
		},
		{
			def = "AUTOCANNON",
			onlyTargetCategory = "TARGET",
			badTargetCategory = "LARGE",
			mainDir = "0 1 0.2",
			maxAngleDif = 210,
		},
		{
			def = "AUTOCANNON",
			onlyTargetCategory = "TARGET",
			badTargetCategory = "LARGE",
			mainDir = "0 1 -0.2",
			maxAngleDif = 210,
		},
		--[[
		{
			name = "NOWEAPON"
		},
		{
			name = "SGraserEden",
			onlyTargetCategory = "VOID",
		},
		]]
	},
	
	weaponDefs = {
		PLASMALANCE = {
			name		= "Heavy Plasma Lance",
			areaOfEffect	= 128,
			avoidFriendly	= false,
			collideFriendly	= false,
			coreThickness	= 0,
			
			customParams	= {
				ap = 60,
				damagetype = "energy",
				description = "A powerful directed-energy weapon effective against even heavy targets.",
				critchance = 0.075,
			},
			
			craterMult		= 0,
			craterBoost		= 0,
			
			damage = {
				default = 600,
			},
			
			duration		= .1,
			explosiongenerator	= "custom:plasma",
			fallOffRate		= .05,
			impactOnly		= 1,
			impulsefactor		= 0,
			impulseBoost		= 0,
			intensity		= 1,
			interceptedByShieldType = 1,
			noSelfDamage		= true,
			projectiles		= 2,
			range			= 1600,
			reloadtime		= 6,
			rgbColor		= "1 1 1",
			soundStart		= "weapon/laser/heavy_laser5",
			soundHit		= "weapon/cannon/partyhit",
			sprayangle		= 200,
			texture1		= "plasma",
			texture2		= "null",
			thickness		= 5,
			tolerance		= 3000,
			turret			= true,
			weaponVelocity		= 400,
			weaponType		= "LaserCannon",
		},
	
		MISSILE_TREBUCHET = {
			name 		= "Trebuchet Missile",
			areaofeffect	= 128,
			avoidfriendly 	= false,
			burnblow	= true,
			burst		= 6,
			burstRate	= 0.25,
			cegTag		= "missiletrailred",
			
			customParams	= {
				ap = 180,
				damagetype = "kinetic",
				description = "Very heavy missile mounted on capital ships, with unmatched punch and range.",
				minimumrange = 1200,
				suppression_noFlank = 1,
				critchance = 0.1,
				energypershot = 1200,
				jammable = true,
				eccm = 15,
			},
			
			craterMult		= 0,
			craterBoost		= 0,
			
			damage = {
				default = 1800,
			},
			
			dance 		= 15,
			explosiongenerator = "custom:death_med",
			fixedLauncher	= true,
			flightTime	= 16,
			impulseFactor	= 0,
			impulseBoost	= 0,
			interceptedByShieldType = 4,
			model		= "wep_m_avalanche.s3o",
			myGravity	= 0,
			noSelfDamage	= true,
			range		= 2500,
			reloadTime	= 24,
			smoketrail 	= true,
			soundHit	= "explosion/ex_large2",
			soundStart	= "weapon/missile/large_missile_fire",
			startVelocity	= 150,
			tolerance	= 3000,
			tracks		= true,
			turret		= true,
			turnrate	= 8000,
			weaponAcceleration = 25,
			weaponType 	= "MissileLauncher",
			weaponVelocity	= 300,
			wobble		= 18000,
		},
		
		AUTOCANNON = {
			name			= "Defense Autocannon",
			areaOfEffect		= 12,
			avoidFriendly		= false,
			collideFriendly		= false,
			
			customParams	= {
				ap = 70,
				damagetype = "kinetic",
				description = "A heavy rapid-fire kinetic weapon for defending big ships from small ones.",
				critchance = 0.05,
			},
			
			craterMult		= 0,
			craterBoost		= 0,
			
			damage = {
				default = 25,
			},
			
			duration		= .02,
			explosiongenerator	= "custom:kinetic",
			fallOffRate		= .05,
			impactOnly		= true,
			impulsefactor		= 0,
			impulseBoost		= 0,
			intensity		= 1,
			interceptedByShieldType = 1,
			noSelfDamage		= true,
			range			= 1500,
			reloadtime		= .1,
			rgbColor		= ".3 .3 1",
			soundStart		= "weapon/cannon/vulcan_heavy_s",
			soundHit		= "weapon/cannon/klighthit",
			sprayangle		= 350,
			thickness		= 1,
			tolerance		= 3000,
			turret			= true,
			weaponVelocity		= 800,
			weaponType		= "LaserCannon",
		},
	},
	
	explodeAs = "RetroDeathBig",
	selfDestructAs = "RetroDeathBig",
	--canManualFire = true,
	
	-- Misc
	selfDestructCountdown = 10,
	script = "placeholdersior.lua",
	movestate = 0,

	sfxTypes = {
		explosionGenerators = {
			"custom:death_med",
			"custom:death_large",
			"custom:death_multimed",
			"custom:teleport",
			"custom:gunmuzzle",
			"custom:muzzlemassdriver",
			"custom:muzzlekineticlarge",
			"custom:muzzlemassdriverlarge",
			"custom:charge_graser_blue",
		}
	},
	
	customParams = {
		shortname = "Placeholdersior",
		helptext = "A knockoff Elsior built by the Transbaal Empire. What it lacks in appearance, it makes up for in firepower.",
		type = "large",
		role = "support",
		cost = 10000,
		useflightcontrol = 1,
		combatspeed = 0.95,
		combatrange = 1600,
		minimumrange = 600,
		inertiafactor = 0.99,
		armor = 180,
		ecm = 100,
		energy = 120000,
		resupplyrange = 300,
		attackspeedstate = 0,
		suppressionmod = 0.2,
		suppressionflankingmod = 0.5,
		angel = true,
	},
}

unitDef.unitname = unitName
return lowerkeys({ [unitName] = unitDef })
