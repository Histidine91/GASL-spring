--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 64,
    avoidFeature       = false,
    avoidFriendly      = false,
    burnblow           = true,
    cegTag             = "trail_missile",
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    explosionGenerator = "custom:missile",
    fixedLauncher      = true,
    flightTime         = 1,
    guided             = "1",
    impulseBoost       = 0,
    impulseFactor      = 0,
    interceptedByShieldType = 2,
    model              = "missile_small.s3o",
    name               = "Light Missile Pack",
    noSelfDamage       = true,
	projectiles		   = 2,
    range              = 475,
    reloadtime         = 2,
    smokeTrail         = true,
    soundHit           = "weapons\mlighthit",
    soundStart         = "weapons\mlightfire",
    startVelocity      = 400,
    targetBorder       = 1,
    tolerance          = 3000,
    tracks             = true,
    turnRate           = 22000,
    turret             = true,
    weaponAcceleration = 100,
    weaponType         = "MissileLauncher",
    weaponVelocity     = 400,
    damage = {
      default            = 120,
    },
  },
--------------------------------------------------------------------------------

return lowerkeys({["MEclipse"] = weaponDef})

--------------------------------------------------------------------------------
