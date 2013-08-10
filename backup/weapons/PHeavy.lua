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
    duration           = .2,
    explosionGenerator = "custom:plasma",
    impulseBoost       = 0,
    impulseFactor      = 0,
    intensity          = 1,
    interceptedByShieldType = 16,
    name               = "Heavy Plasma Cannon",
    noSelfDamage       = true,
    range              = 750,
    reloadtime         = 2,
    rgbColor           = "1 1 1",
    soundHit           = "weapons\pmediumhit",
    soundStart         = "weapons\pmediumfire",
    sprayAngle         = 450,
    texture1           = "plasma",
    texture2           = "null",
    thickness          = 10,
    tolerance          = 3000,
    turret             = true,
    weaponType         = "LaserCannon",
    weaponVelocity     = 300,
    damage = {
      default            = 450,
      large              = "750",
      maglarge           = "200",
      magsmall           = "100",
    },
}


--------------------------------------------------------------------------------

return lowerkeys({["PHeavy"] = weaponDef})

--------------------------------------------------------------------------------
