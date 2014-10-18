-- drive
-- drive_ring

return {
  ["reactionless_drive"] = {
    trail = {
      air                = true,
      class              = [[CExpGenSpawner]],
      count              = 1,
      ground             = true,
      water              = true,
      underwater         = true,
      properties = {
        delay              = 3,
        dir                = [[dir]],
        explosiongenerator = [[custom:reactionless_drive_ring]],
        pos                = [[0, 0, 0]],
      },
    },
  },

  ["reactionless_drive_ring"] = {
    tealring = {
      air                = true,
      class              = [[CBitmapMuzzleFlame]],
      count              = 1,
      ground             = true,
      water              = true,
      underwater         = true,
      properties = {
        colormap           = [[0 1 0.5 0.03    0 0 0 0.01]],
        dir                = [[dir]],
        frontoffset        = 0,
        fronttexture       = [[bluering]],
        length             = 0.15,
        sidetexture        = [[smoketrailthinner]],
        size               = 1,
        sizegrowth         = 23,
        ttl                = 150,
        --speed = [[0 200 0]],
      },
    },
  },
  
}

