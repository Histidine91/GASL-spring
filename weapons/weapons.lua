return {
  NEEDLER_FIGHTER = {
    name		= "Fighter Needler",
    areaOfEffect	= 8,
    avoidFriendly	= false,
    collideFriendly	= false,
    
    customParams	= {
      ap = 50,
      damagetype = "kinetic",
      description = "Rapid-fire projectile weapon used by dogfighters. Accuracy and armor penetration are subpar.",
    },
    
    craterMult		= 0,
    craterBoost		= 0,

    damage = {
      default=10,
    },
    
    duration		= .02,
    explosiongenerator	= "custom:kinetic",
    fallOffRate		= .05,
    impactOnly		= 1,
    impulsefactor	= 0,
    impulseBoost	= 0,
    intensity		= 1,
    interceptedByShieldType = 1,
    noSelfDamage	= true,
    range		= 1200,
    reloadtime		= .1,
    rgbColor		= ".3 .3 1",
    soundStart		= "weapon/cannon/klightfire",
    soundHit		= "weapon/cannon/klighthit",
    sprayangle		= 300,
    thickness		= .5,
    tolerance		= 3000,
    turret		= true,
    weaponVelocity	= 800,
    weaponType		= "LaserCannon",
  },
  
  ENERGYBOMB = {
    name		= "Energy Bomb",
    areaOfEffect	= 128,
    avoidFriendly	= false,
    burst		= 3,
    burstRate		= 0.6,
    collideFriendly	= false,
    coreThickness	= 0,
    
    customParams	= {
      ap = 25,
      damagetype = "energy",
      description = "Low-velocity bolts that release a powerful plasma pulse upon impact.",
    },
    
    craterMult		= 0,
    craterBoost		= 0,

    damage = {
      default = 250,
    },
    
    duration		= .05,
    explosiongenerator	= "custom:plasma",
    fallOffRate		= .05,
    impactOnly		= 1,
    impulsefactor	= 0,
    impulseBoost	= 0,
    intensity		= 1,
    interceptedByShieldType = 1,
    noSelfDamage	= true,
    projectiles		= 2,
    range		= 1200,
    reloadtime		= 12,
    rgbColor		= "1 1 1",
    soundStart		= "weapon/gnat_weapon",
    soundHit		= "weapon/cannon/pmediumhit",
    sprayangle		= 350,
    texture1		= "plasma",
    texture2		= "null",
    thickness		= 6,
    tolerance		= 3000,
    turret		= true,
    weaponVelocity	= 300,
    weaponType		= "LaserCannon",
  },  
}