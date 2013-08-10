--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 24,
    avoidFeature       = false,
    avoidFriendly      = false,
    beamburst          = true,
    beamDecay          = .7,
    beamTTL            = 4,
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    explosionGenerator = "custom:antimatter",
    impulseBoost       = 0,
    impulseFactor      = 0,
    intensity          = 1,
    interceptedByShieldType = 4,
    largeBeamLaser     = true,
    laserFlareSize     = 4,
    minIntensity       = 1,
    name               = "Antimatter Beam",
    noSelfDamage       = true,
    projectiles        = 0,
    range              = 1000,
    reloadtime         = 10,
    rgbColor           = "1 1 1",
    soundHit           = "",
    soundStart         = "llaser",
    thickness          = 18,
    tolerance          = 1000,
    turret             = true,
    weaponType         = "BeamLaser",
    damage = {
      default            = 65,
    },
  },
--------------------------------------------------------------------------------

return lowerkeys({["EclipseAMBeamPrimer"] = weaponDef})

--------------------------------------------------------------------------------
