--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 64,
    avoidFeature       = false,
    avoidFriendly      = false,
    burnblow           = true,
    burst              = 4,
    burstrate          = .25,
    cegTag             = "trail_missile_small",
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    dance              = 30,
    explosionGenerator = "custom:missile",
    flightTime         = 1,
    impulseBoost       = 0,
    impulseFactor      = 0,
    interceptedByShieldType = 2,
    model              = "missile_small.s3o",
    name               = "Tiny Missile",
    noSelfDamage       = true,
    range              = 250,
    reloadtime         = 5,
    smokeTrail         = true,
    soundHit           = "weapons\mlighthit",
    soundStart         = "mtinyfire",
    startVelocity      = 600,
    targetBorder       = 1,
    tolerance          = 3000,
    turret             = true,
    weaponAcceleration = 100,
    weaponType         = "MissileLauncher",
    weaponVelocity     = 600,
    damage = {
      default            = 50,
      large              = "100",
    },
  },


--------------------------------------------------------------------------------

return lowerkeys({["MTiny"] = weaponDef})

--------------------------------------------------------------------------------
