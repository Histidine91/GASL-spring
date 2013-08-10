--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 8,
    avoidFeature       = false,
    avoidFriendly      = false,
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    duration           = .01,
    explosionGenerator = "custom:kinetic",
    impactonly         = "1",
    impulseBoost       = 0,
    impulseFactor      = 0,
    intensity          = 1,
    interceptedByShieldType = 1,
    name               = "Medium Kinetic Weapon",
    noSelfDamage       = true,
    range              = 700,
    reloadtime         = .5,
    rgbColor           = "1 .3 .1",
    soundHit           = "weapons\klighthit",
    soundStart         = "weapons\klightfire",
    sprayAngle         = 500,
    thickness          = 1,
    tolerance          = 3000,
    turret             = true,
    weaponType         = "LaserCannon",
    weaponVelocity     = 600,
    damage = {
      default            = 120,
    },
},


--------------------------------------------------------------------------------

return lowerkeys({["KMedium"] = weaponDef})

--------------------------------------------------------------------------------
