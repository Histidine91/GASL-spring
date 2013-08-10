--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 0,
    avoidFeature       = false,
    avoidFriendly      = false,
    burnblow           = true,
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    explosionGenerator = "custom:torpedo",
    flightTime         = 2,
    guided             = "1",
    heightMod          = .3,
    impulseBoost       = 0,
    impulseFactor      = 0,
    interceptedByShieldType = 2,
    model              = "torpedo.s3o",
    name               = "Torpedo Warhead",
    noSelfDamage       = true,
    range              = 50,
    reloadtime         = 2,
    soundHit           = "weapons\mlighthit",
    startVelocity      = 100,
    targetBorder       = 1,
    tolerance          = 53000,
    tracks             = true,
    turnRate           = 220000,
    turret             = false,
    weaponAcceleration = 100,
    weaponType         = "Melee",
    weaponVelocity     = 100,
    damage = {
      default            = 500,
    },
  },


--------------------------------------------------------------------------------

return lowerkeys({["Torpedo"] = weaponDef})

--------------------------------------------------------------------------------
