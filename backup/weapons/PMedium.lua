--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 120,
    avoidFeature       = false,
    avoidFriendly      = false,
    collideFeature     = false,
    collideFriendly    = false,
    coreThickness      = 0,
    craterBoost        = 0,
    craterMult         = 0,
    duration           = .1,
    explosionGenerator = "custom:plasma",
    impulseBoost       = 0,
    impulseFactor      = 0,
    intensity          = 1,
    interceptedByShieldType = 16,
    name               = "Medium Plasma Cannon",
    noSelfDamage       = true,
    range              = 700,
    reloadtime         = 2,
    rgbColor           = "1 1 1",
    soundHit           = "weapons\pmediumhit",
    soundStart         = "weapons\pmediumfire",
    sprayAngle         = 100,
    texture1           = "plasma",
    texture2           = "null",
    thickness          = 6,
    tolerance          = 3000,
    turret             = true,
    weaponType         = "LaserCannon",
    weaponVelocity     = 400,
    damage = {
      default            = 150,
      large              = "500",
      maglarge           = "150",
      magsmall           = "30",
    },
  },


--------------------------------------------------------------------------------

return lowerkeys({["PMedium"] = weaponDef})

--------------------------------------------------------------------------------
