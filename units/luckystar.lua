local unitName = "luckystar"
local unitDef = {
	name = "Lucky Star",
	description = "All-Rounder Emblem Frame",

	-- Required Tags
	power = 400,
	mass = 160,
	icontype = "luckystar",
	category = "SMALL STRONG TARGET ANY",
	footprintX = 2,
	footprintZ = 2,
	maxDamage = 10000,
	idleTime = 0,
	idleAutoHeal = 0,
	objectName = "luckystar.s3o",
	SoundCategory = "FIGHTER",
	collisionVolumeType = "Box",
	collisionVolumeScales = "22 15 30",
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
	turnRate = 900,
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
			def = "LASER",
			onlyTargetCategory = "TARGET",
			weaponMainDir = "0 0 1",
			maxAngleDif = 10,
		},
		{
			def = "VULCAN_DUAL",
			onlyTargetCategory = "TARGET",
			badTargetCategory = "ARMORED",
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
		{
			def = "HYPERCANNON",
			onlyTargetCategory = "NONE"
		},
	},
	
	weaponDefs = {
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
			turret		= false,
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
				energypershot = 180,
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
			model		= "missile_small.s3o",
			myGravity	= 0,
			noSelfDamage	= true,
			range		= 1800,
			reloadTime	= 24,
			smoketrail 	= true,
			soundHit	= "weapon/missile/sabot_hit",
			soundStart	= "weapon/missile/missile_fire9",
			startVelocity	= 100,
			tolerance	= 3000,
			tracks		= true,
			turret		= false,
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
			--cegTag		= "light_pink",
			
			customParams	= {
				ap = 25,
				damagetype = "energy",
				description = "A general-purpose homing energy weapon.",
				minimumrange = 500,
				seekerttl = 60,
				seekeraccuracy = 25,
				suppression_noFlank = 1,
				critchance = 0.05,
				energypershot = 80,
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
			reloadTime	= 16,
			smoketrail 	= false,
			--soundHit	= "weapons/mlighthit",
			soundStart	= "weapon/laser/medlaser_fire",
			--sprayangle 	= 25,
			startVelocity	= 300,
			--texture1	= "light_pink",
			--texture2	= "phalanxtrail_pink",
			tolerance	= 3000,
			tracks		= true,
			turret		= true,
			turnrate	= 9600,
			weaponAcceleration = 25,
			weaponType 	= "MissileLauncher",
			weaponVelocity	= 300,
		},
		
		VULCAN_DUAL = {
			name			= "Dual Vulcan Cannon",
			areaOfEffect		= 8,
			burst                   = 3,
			burstRate               = 0.1,
			
			customParams	= {
				ap = 50,
				damagetype = "kinetic",
				description = "Twin rapid-fire autocannons that chew up soft targets. Accuracy and armor penetration are subpar.",
				critchance = 0.075,
				energypershot = 6,
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
			projectiles		= 2,
			range			= 1200,
			reloadtime		= 0.3,
			rgbColor		= "1 0.5 0",
			soundStart		= "weapon/cannon/klightfire",
			soundHit		= "weapon/cannon/klighthit",
			sprayangle		= 300,
			thickness		= .5,
			tolerance		= 3000,
			turret			= false,
			weaponVelocity		= 800,
			weaponType		= "LaserCannon",
		},
		HYPERCANNON = {
			name		= "Hyper Cannon",
			accuracy	= 0,
			areaOfEffect	= 48,
			beamDecay	= 0.85,
			beamTTL		= 6,
			beamTime	= 0.03,
			
			customParams	= {
				ap = 0,
				damagetype = "energy",
				description = "An immensely powerful beam that wipes anything in its path.",
				critchance = 0.05,
				special = true,
				statsdamage = 100*30*5
			},
			
			craterMult		= 0,
			craterBoost		= 0,
			
			damage = {
				default = 100,
			},
			
			explosiongenerator = "custom:graser_pink",
			impactOnly 	= true,
			impulsefactor	= 0,
			impulseBoost	= 0,
			intensity	= 1,
			interceptedByShieldType = 2,
			--largeBeamLaser	= true,
			laserFlareSize	= 8,
			minIntensity	= 1,
			noExplode	= true,
			noSelfDamage	= true,
			range		= 2000,
			reloadtime	= 10,
			rgbColor 	= "1 0.2 0.8",
			soundHit	= nil,
			soundStart 	= nil,
			thickness	= 40,
			tolerance	= 1000,
			turret		= false,
			weaponType	= "BeamLaser",
		},		
	},

	explodeAs = "RetroDeathSmall",
	selfDestructAs = "RetroDeathSmall",

	-- Misc
	script = "luckystar.lua",
	sfxTypes = {
		explosionGenerators = {
			"custom:damage_fire",
			"custom:death_small",
			"custom:gunmuzzle",
			"custom:feather",
		},
	},
	customParams  =  {
		shortname = "Lucky Star",
		helptext = "The GA-001 Lucky Star is Milfeulle Sakuraba's Emblem Frame. Well-balanced and armed with a wide variety of weapons, it performs well in all situations.",
		type = "small",
		role = "attacker",
		cost = 2000,
		useflightcontrol = 1,
		combatspeed = 1.4,
		combatrange = 1600,
		inertiafactor = 0.985,
		rollangle = math.rad(30),
		armor = 100,
		morale = 50,
		ecm = 25,
		energy = 10000,
		thrusterenergyuse = 1,
	},
}

unitDef.unitname = unitName
return lowerkeys({ [unitName] = unitDef })
