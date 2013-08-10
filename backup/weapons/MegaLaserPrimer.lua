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
    commandfire        = true,
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
    name               = "Megalaser",
    noExplode	     = true,
    noSelfDamage       = true,
    projectiles        = 0,
    range              = 1800,
    reloadtime         = 30,
    rgbColor           = "1 1 1",
    soundHit           = "",
    soundStart         = "llaser",
    thickness          = 30,
    tolerance          = 1000,
    turret             = false,
    weaponType         = "BeamLaser",
    damage = {
      default            = 200,
    },
  },
--------------------------------------------------------------------------------

return lowerkeys({["MegaLaserPrimer"] = weaponDef})

--------------------------------------------------------------------------------
