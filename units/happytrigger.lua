local unitName = "happytrigger"
local unitDef = {
	name = "Happy Trigger",
	description = "Assault Emblem Frame",

	-- Required Tags
	power = 400,
	mass = 240,
	icontype = "happytrigger",
	category = "SMALL STRONG TARGET ANY",
	footprintX = 2,
	footprintZ = 2,
	maxDamage = 15000,
	idleTime = 0,
	idleAutoHeal = 0,
	objectName = "happytrigger.s3o",
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
	acceleration = .06,
	canMove = true,
	maxVelocity = 2.4,
	turnRate = 600,
	collide = false,

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
			def = "RAILGUN",
			onlyTargetCategory = "TARGET",
			weaponMainDir = "0 0 1",
			maxAngleDif = 10,
		},
		{
			def = "LASER",
			onlyTargetCategory = "TARGET",
			weaponMainDir = "0 0 1",
			maxAngleDif = 10,
		},
		--nil,	-- hyper cannon goes here?
		{
			def = "MISSILE",
			onlyTargetCategory = "TARGET",
			badTargetCategory = "ARMORED",
			weaponMainDir = "0 0 1",
			maxAngleDif = 120,
		},
		{
			def = "PHALANX",
			onlyTargetCategory = "TARGET",
			badTargetCategory = "ARMORED",
		},
		
	},
	
	weaponDefs = {
		RAILGUN = {
			name                    = [[Assault Railgun]],
			areaOfEffect            = 32,
			--burst                   = 2,
			--burstRate               = 0.2,
			coreThickness           = 0,
			craterBoost             = 0,
			craterMult              = 0,
			
			customParams	= {
				ap = 150,
				damagetype = "kinetic",
				description = "Twin high-caliber railguns fire medium-velocity shells with a creamy high-explosive filling. Effective against larger ships.",
				minimumrange = 400,
				critchance = 0.1,
				energypershot = 90,
			},
			
			damage                  = {
				default = 450,
			},
			
			explosionGenerator      = "custom:missile",
			impactOnly              = true,
			impulseBoost            = 0,
			impulseFactor           = 0.4,
			intensity               = 1,
			interceptedByShieldType = 1,
			noSelfDamage            = true,
			projectiles             = 2,
			range                   = 1500,
			reloadtime              = 6,
			soundHit                = [[weapon/cannon/kheavyfire]],
			soundStart              = [[weapon/cannon/medplasma_fire]],
			sprayangle		= 250,
			thickness		= 6,
			texture1		= "plasma",
			texture2		= "null",
			turret                  = true,
			weaponType              = [[LaserCannon]],
			weaponVelocity          = 600,	
		},
		
		LASER = {
			name		= "Beam Laser",
			accuracy	= 150,
			areaOfEffect	= 8,
			beamDecay	= 0.9,
			beamTTL		= 20,
			beamTime	= 0.1,
			
			customParams	= {
				ap = 0,
				damagetype = "energy",
				description = "A standard high-power laser weapon, effective against all targets.",
				critchance = 0.05,
				energypershot = 50,
			},
			
			craterMult		= 0,
			craterBoost		= 0,
			
			damage = {
				default = 500,
			},
			
			explosiongenerator = "custom:laser",
			impactOnly 	= true,
			impulsefactor	= 0,
			impulseBoost	= 0,
			intensity	= 1,
			interceptedByShieldType = 2,
			laserFlareSize	= 8,
			minIntensity	= 1,
			noSelfDamage	= true,
			range		= 1750,
			reloadtime	= 4,
			rgbColor 	= "0.5 1 0.5",
			soundHit	= nil,
			soundStart 	= "weapon/laser/small_laser_fire2",
			thickness	= 3,
			tolerance	= 1000,
			turret		= true,
			weaponType	= "BeamLaser",
		},
		
		MISSILE = 
		{
			name 		= "Standard Missile",
			areaofeffect	= 64,
			avoidfriendly 	= false,
			burnblow	= true,
			burst		= 3,
			burstRate	= 0.8,
			cegTag		= "missiletrailredsmall",
			
			customParams	= {
				ap = 100,
				damagetype = "kinetic",
				description = "A standard missile mounted on a fighter, good against other fighters and smaller ships.",
				minimumrange = 700,
				suppression_noFlank = 1,
				critchance = 0.075,
				energypershot = 360,
				jammable = true,
				eccm = 20,
			},
			
			craterMult		= 0,
			craterBoost		= 0,
			
			damage = {
				default = 600,
			},
			
			dance 		= 10,
			explosiongenerator = "custom:missile",
			fixedLauncher	= true,
			flightTime	= 12,
			impulseFactor	= 0,
			impulseBoost	= 0,
			interceptedByShieldType = 4,
			model		= "wep_m_hailstorm.s3o",
			myGravity	= 0,
			noSelfDamage	= true,
			projectiles     = 2,
			range		= 1800,
			reloadTime	= 30,
			smoketrail 	= true,
			soundHit	= "weapon/missile/sabot_hit",
			soundStart	= "weapon/missile/missile_fire9",
			startVelocity	= 100,
			tolerance	= 3000,
			tracks		= true,
			turret		= true,
			turnrate	= 12800,
			weaponAcceleration = 25,
			weaponType 	= "MissileLauncher",
			weaponVelocity	= 300,
			wobble		= 22000,
		},
		
		PHALANX = 
		{
			name 		= "Phalanx Seeker",
			areaofeffect	= 8,
			avoidfriendly 	= false,
			burnblow	= true,
			burst		= 4,
			burstRate	= 0.06,
			
			customParams	= {
				ap = 25,
				damagetype = "energy",
				description = "A general-purpose homing energy weapon.",
				minimumrange = 500,
				seekerttl = 60,
				seekeraccuracy = 25,
				suppression_noFlank = 1,
				critchance = 0.05,
				energypershot = 160,
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
			projectiles	= 4,
			range		= 1450,
			reloadTime	= 20,
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
	},

	explodeAs = "RetroDeathSmall",
	selfDestructAs = "RetroDeathSmall",

	-- Misc
	script = "happytrigger.lua",
	sfxTypes = {
		explosionGenerators = {
			"custom:damage_fire",
			"custom:death_small",
			"custom:cannon_muzzle",
			"custom:feather",
		},
	},
	customParams  =  {
		shortname = "Happy Trigger",
		helptext = "More battleship than fighter, the GA-003 Happy Trigger is Forte Stollen's Emblem Frame. Its mobility suffers from the mass penalties imposed by its heavy armor and weaponry.",
		type = "brawler",
		role = "attacker",
		cost = 2000,
		useflightcontrol = 1,
		combatspeed = 1,
		combatrange = 1450,
		inertiafactor = 0.99,
		rollangle = math.rad(30),
		armor = 140,
		morale = 50,
		ecm = 20,
		energy = 15000,
		thrusterenergyuse = 1.4,
		suppressionmod = 0.8,
	},
}

unitDef.unitname = unitName
return lowerkeys({ [unitName] = unitDef })
