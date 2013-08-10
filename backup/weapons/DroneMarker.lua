--------------------------------------------------------------------------------

local weaponDef = {
    areaOfEffect       = 8,
    craterBoost        = 0,
    craterMult         = 0,
    impulseBoost       = 0,
    impulseFactor      = 0,
    interceptedByShieldType = 0,
    name               = "Drone Launch Control",
    projectiles        = 0,
    range              = 1600,
    reloadtime         = 8,
    tolerance          = 3000,
    turret             = true,
    weaponType         = "Melee",
    damage = {
      default            = .0001,
    },
  },


--------------------------------------------------------------------------------

return lowerkeys({["DroneMarker"] = weaponDef})

--------------------------------------------------------------------------------
