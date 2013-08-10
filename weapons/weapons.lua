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
    noSelfDamage	= 1,
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
}