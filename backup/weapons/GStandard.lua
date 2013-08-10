--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 50,
    avoidFeature       = false,
    avoidFriendly      = true,
    beamburst          = true,
    beamTTL            = 2,
    burst              = 10,
    burstrate          = .06,
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    explosionGenerator = "custom:grav",
    explosionSpeed     = 600,
    impulseBoost       = 0,
    impulseFactor      = 0,
    intensity          = 1,
    interceptedByShieldType = 8,
    name               = "Gravitrics",
    noSelfDamage       = true,
    range              = 350,
    reloadtime         = 3,
    rgbColor           = "0 0 0",
    soundHit           = "",
    soundStart         = "grav",
    thickness          = 8,
    tolerance          = 9000,
    turret             = true,
    weaponType         = "BeamLaser",
    damage = {
      default            = 600,
    },
}

--------------------------------------------------------------------------------

return lowerkeys({["GStandard"] = weaponDef})

--------------------------------------------------------------------------------
