--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 12,
    avoidFeature       = false,
    avoidFriendly      = false,
    beamburst          = true,
    beamDecay          = .9,
    beamTTL            = 24,
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    explosionGenerator = "custom:laser",
    fallOffRate        = .05,
    impulseBoost       = 0,
    impulseFactor      = 0,
    intensity          = 1,
    interceptedByShieldType = 1,
    minIntensity       = 1,
    name               = "Point Defense",
    noSelfDamage       = true,
    range              = 850,
    reloadtime         = .5,
    rgbColor           = "0 0.7 0.7",
    size               = 2,
    soundHit           = "weapons\klighthit",
    thickness          = 4,
    tolerance          = 30000,
    turret             = true,
    weaponType         = "BeamLaser",
    weaponVelocity     = 1200,
    damage = {
      default            = 2,
      drone              = "45",
      torpedo            = "45",
    },
  },
--------------------------------------------------------------------------------

return lowerkeys({["MPointDefense"] = weaponDef})

--------------------------------------------------------------------------------
