--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 260,
    avoidFeature       = false,
    avoidFriendly      = false,
    burnblow           = true,
    collideFeature     = false,
    collideFriendly    = false,
    craterBoost        = 0,
    craterMult         = 0,
    explosionGenerator = "custom:antimatter",
    explosionSpeed     = 4,
    flightTime         = 2,
    guided             = "1",
    impulseBoost       = 0,
    impulseFactor      = 0,
    interceptedByShieldType = 2,
    model              = "torpedo.s3o",
    name               = "Antimatter Warhead",
    noSelfDamage       = true,
    range              = 50,
    reloadtime         = 2,
    soundHit           = "weapons\mlighthit",
    startVelocity      = 100,
    targetBorder       = 1,
    tolerance          = 53000,
    tracks             = true,
    turnRate           = 220000,
    turret             = true,
    weaponAcceleration = 100,
    weaponType         = "Melee",
    weaponVelocity     = 100,
    damage = {
      default            = 100,
      large              = "400",
      maglarge           = "400",
      torpedo            = "2",
    },
  },


--------------------------------------------------------------------------------

return lowerkeys({["TorpedoAM"] = weaponDef})

--------------------------------------------------------------------------------
