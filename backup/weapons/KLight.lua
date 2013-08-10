--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 8,
    avoidFeature       = false,
    avoidFriendly      = false,
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    duration           = .02,
    explosionGenerator = "custom:kinetic",
    fallOffRate        = .05,
    impactonly         = "1",
    impulseBoost       = 0,
    impulseFactor      = 0,
    intensity          = 1,
    interceptedByShieldType = 1,
    name               = "Light Kinetic Weapon",
    noSelfDamage       = true,
    range              = 500,
    reloadtime         = .25,
    rgbColor           = "1 .7 .2",
    soundHit           = "weapons\klighthit",
    soundStart         = "weapons\klightfire",
    sprayAngle         = 600,
    thickness          = .5,
    tolerance          = 3000,
    turret             = true,
    weaponType         = "LaserCannon",
    weaponVelocity     = 600,
    damage = {
      default            = 15,
    },
 }
--------------------------------------------------------------------------------

return lowerkeys({["KLight"] = weaponDef})

--------------------------------------------------------------------------------
