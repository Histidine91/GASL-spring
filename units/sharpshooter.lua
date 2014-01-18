local unitName = "sharpshooter"
local unitDef = {
	name = "Sharpshooter",
	description = "Sniper Emblem Frame",

	-- Required Tags
	power = 400,
	mass = 160,
	icontype = "sharpshooter",
	category = "SMALL STRONG TARGET ANY",
	footprintX = 2,
	footprintZ = 2,
	maxDamage = 10000,
	idleTime = 0,
	idleAutoHeal = 0,
	objectName = "sharpshooter.s3o",
	SoundCategory = "FIGHTER",
	collisionVolumeType = "Box",
	collisionVolumeScales = "22 15 36",
	collisionVolumeTest = true,

	-- Movement
	canFly = true,
	hoverAttack = true,
	airHoverFactor = 0,
	airStrafe = false,
	cruiseAlt = 130,
	brakeRate = 1,
	acceleration = .08,
	canMove = true,
	maxVelocity = 2.5,
	turnRate = 800,
	collide = false,

	-- Construction
	levelGround = false,

	-- Sight/Radar
	--radarDistance = 975,
	sightDistance = 2500,
	noChaseCategory = "ANY",
	stealth = true,

	-- Weapons
	weapons = {
		{
			def = "RAILGUN",
			onlyTargetCategory = "TARGET",
			weaponMainDir = "0 0 1",
			maxAngleDif = 10,
		},
		{
			def = "VULCAN",
			onlyTargetCategory = "TARGET",
			badTargetCategory = "ARMORED",
			weaponMainDir = "0 0 1",
			maxAngleDif = 10,
		},		
		{
			def = "MISSILE_FANG",
			onlyTargetCategory = "TARGET",
			weaponMainDir = "0 0 1",
			maxAngleDif = 120,
		},
		{
			def = "PHALANX",
			onlyTargetCategory = "TARGET",
		},
		{
			def = "FATALARROW",
			onlyTargetCategory = "TARGET",
			weaponMainDir = "0 0 1",
			maxAngleDif = 10,
		},
	},
	
	weaponDefs = {
		RAILGUN = {
			name                    = [[Sniper Railgun]],
			areaOfEffect            = 24,
			--burst                   = 2,
			--burstRate               = 0.2,
			coreThickness           = 0,
			craterBoost             = 0,
			craterMult              = 0,
			
			customParams	= {
				ap = 200,
				damagetype = "kinetic",
				description = "Very long range kinetic weapon that cuts through armor like a knife through butter.",
				minimumrange = 750,
				critchance = 0.15,
				energypershot = 60,
				category = {ballistic = true, railgun = true},
			},
			
			damage                  = {
				default = 600,
			},
			
			duration		= .02,
			explosionGenerator      = "custom:missile",
			impactOnly              = true,
			impulseBoost            = 0,
			impulseFactor           = 0.4,
			intensity               = 1,
			interceptedByShieldType = 1,
			noSelfDamage            = true,
			noExplode		= false,
			range                   = 2500,
			reloadTime              = 4,
			rgbColor		= "0.8 0.8 0.8",
			soundHit                = [[weapon/cannon/kheavyfire]],
			soundStart              = [[weapon/cannon/cannon_fire2]],
			sprayangle		= 50,
			thickness		= 3,
			--texture1		= "plasma",
			texture2		= "null",
			turret                  = true,
			weaponType              = [[LaserCannon]],
			weaponVelocity          = 2000,	
		},
		
		VULCAN = {
			name			= "Vulcan Cannon",
			areaOfEffect		= 8,
			burst                   = 3,
			burstRate               = 0.1,
			
			customParams	= {
				ap = 50,
				damagetype = "kinetic",
				description = "Rapid-fire autocannon that chews up soft targets. Accuracy and armor penetration are subpar.",
				critchance = 0.075,
				energypershot = 3,
				category = {ballistic = true, vulcan = true},
			},
			
			craterMult		= 0,
			craterBoost		= 0,
			
			damage = {
				default = 10,
			},
			
			duration		= .02,
			explosiongenerator	= "custom:kinetic",
			fallOffRate		= .05,
			impactOnly		= 1,
			impulsefactor		= 0,
			impulseBoost		= 0,
			intensity		= 1,
			interceptedByShieldType = 1,
			noSelfDamage		= true,
			range			= 1200,
			reloadtime		= 0.3,
			rgbColor		= "1 0.5 0",
			soundStart		= "weapon/cannon/vulcan",
			soundHit		= "weapon/cannon/klighthit",
			soundTrigger		= true,
			sprayangle		= 300,
			thickness		= .5,
			tolerance		= 3000,
			turret			= true,
			weaponVelocity		= 800,
			weaponType		= "LaserCannon",
		},
		
		MISSILE_FANG = {
			name 		= "Fang Missile",
			areaofeffect	= 72,
			avoidfriendly 	= false,
			burnblow	= true,
			burst		= 2,
			burstRate	= 1,
			cegTag		= "missiletrailredsmall",
			
			customParams	= {
				ap = 125,
				damagetype = "kinetic",
				description = "A slow and bulky but powerful missile.",
				minimumrange = 800,
				suppression_noFlank = 1,
				critchance = 0.075,
				energypershot = 200,
				jammable = true,
				--eccm = 20,
				category = {seeker = true, missile = true},
			},
			
			craterMult		= 0,
			craterBoost		= 0,
			
			damage = {
				default = 1000,
			},
			
			dance 		= 10,
			explosiongenerator = "custom:missile",
			fixedLauncher	= true,
			flightTime	= 15,
			impulseFactor	= 0,
			impulseBoost	= 0,
			interceptedByShieldType = 4,
			model		= "wep_m_dragonsfang.s3o",
			myGravity	= 0,
			noSelfDamage	= true,
			range		= 1650,
			reloadTime	= 30,
			smoketrail 	= true,
			soundHit	= "explosion/ex_med4",
			soundStart	= "weapon/missile/missile_fire5",
			startVelocity	= 80,
			tolerance	= 3000,
			tracks		= true,
			turret		= true,
			turnrate	= 11000,
			weaponAcceleration = 20,
			weaponType 	= "MissileLauncher",
			weaponVelocity	= 250,
			wobble		= 20000,
		},
		
		PHALANX = {
			name 		= "Phalanx Seeker",
			areaofeffect	= 8,
			avoidfriendly 	= false,
			burnblow	= true,
			
			customParams	= {
				ap = 25,
				damagetype = "energy",
				description = "A general-purpose homing energy weapon.",
				minimumrange = 500,
				--seekerttl = 60,
				jammable = true,
				seekeraccuracy = 25,
				suppression_noFlank = 1,
				critchance = 0.05,
				energypershot = 160,
				category = {phalanx = true, seeker = true, energy = true},
			},
			
			craterMult		= 0,
			craterBoost		= 0,
			
			damage = {
				default = 100,
			},
			
			--dance 		= 10,
			explosiongenerator = "custom:laser",
			fixedLauncher	= true,
			flightTime	= 6,
			impactOnly	= true,
			impulseFactor	= 0,
			impulseBoost	= 0,
			interceptedByShieldType = 2,
			model		= "",
			myGravity	= 0,
			noSelfDamage	= true,
			projectiles	= 8,
			range		= 1450,
			reloadTime	= 18,
			smoketrail 	= false,
			--soundHit	= "weapons/mlighthit",
			soundStart	= "weapon/energy2",
			--sprayangle 	= 25,
			startVelocity	= 300,
			tolerance	= 3000,
			tracks		= true,
			turret		= true,
			turnrate	= 9600,
			weaponAcceleration = 25,
			weaponType 	= "MissileLauncher",
			weaponVelocity	= 300,
		},
	
		FATALARROW = {
			name                    = [[Fatal Arrow]],
			areaOfEffect            = 40,
			--burst                   = 2,
			--burstRate               = 0.2,
			coreThickness           = 0,
			craterBoost             = 0,
			craterMult              = 0,
			
			customParams	= {
				ap = 999,
				damagetype = "kinetic",
				description = "Three-round railgun burst with extreme range and lethality.",
				minimumrange = 1200,
				statsprojectiles = 3,
				special = true,
			},
			
			damage                  = {
				default = 8000,
			},
			
			duration		= 0.1,
			explosionGenerator      = "custom:missile",
			impactOnly              = true,
			impulseBoost            = 0,
			impulseFactor           = 0.4,
			intensity               = 1,
			interceptedByShieldType = 0,
			noSelfDamage            = true,
			noExplode		= false,
			range                   = 6000,
			reloadTime              = 4,
			rgbColor		= "0.8 0.8 0.8",
			soundHit                = [[weapon/cannon/kheavyfire]],
			soundStart              = [[weapon/cannon/cannon_fire2]],
			sprayangle		= 50,
			thickness		= 4,
			--texture1		= "plasma",
			texture2		= "null",
			turret                  = true,
			weaponType              = [[LaserCannon]],
			weaponVelocity          = 4500,	
		},
	},

	explodeAs = "RetroDeathSmall",
	selfDestructAs = "RetroDeathSmall",

	-- Misc
	script = "sharpshooter.lua",
	sfxTypes = {
		explosionGenerators = {
			"custom:damage_fire",
			"custom:missile",
			"custom:cannon_muzzle",
			"custom:feather",
			"custom:teleport",
			"custom:gunmuzzle",
			"custom:supergun",
		},
	},
	customParams  =  {
		shortname = "Sharpshooter",
		helptext = "The GA-006 Sharpshooter is Karasuma Chitose's Emblem Frame. Though its armor and close-combat capabilities are modest, it features unparalleled range and anti-armor capability.",
		type = "brawler",
		role = "sniper",
		cost = 2000,
		useflightcontrol = 1,
		combatspeed = 1.2,
		combatrange = 2400,
		inertiafactor = 0.987,
		rollangle = math.rad(30),
		armor = 90,
		morale = 50,
		ecm = 40,
		energy = 10000,
		thrusterenergyuse = 1,
		suppressionmod = 1.2,
		canresupply = true,
		angel = 6,
	},
}

unitDef.unitname = unitName
return lowerkeys({ [unitName] = unitDef })
