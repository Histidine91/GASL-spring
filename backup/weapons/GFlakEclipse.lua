--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 150,
    avoidFeature       = false,
    avoidFriendly      = false,
    beamburst          = true,
    burnblow           = true,
    burst              = 4,
    burstrate          = .06,
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    explosionGenerator = "custom:grav",
    explosionSpeed     = 65536,
    impulseBoost       = 0,
    impulseFactor      = 0,
    interceptedByShieldType = 8,
    minIntensity       = 1,
    myGravity          = .001,
    name               = "Grav Flak",
    noSelfDamage       = true,
    range              = 750,
    reloadtime         = .65,
    rgbColor           = "1 1 1",
    soundHit           = "grav",
    thickness          = 1,
    tolerance          = 3000,
    turret             = true,
    weaponType         = "BeamLaser",
    weaponVelocity     = 900,
    damage = {
      default            = 40,
    },
  },
--------------------------------------------------------------------------------

return lowerkeys({["GFlakEclipse"] = weaponDef})

--------------------------------------------------------------------------------
