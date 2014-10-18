-- emg_shells_m
-- emg_hit
-- flashplosion
-- gunmuzzle
-- emg_hit_he
-- brawlimpacts
-- brawlermuzzle
-- emg_shells_l
-- emg_hit_water

return {
  ["emg_shells_m"] = {
    usedefaultexplosions = false,
    shells = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.97,
        colormap           = [[1 1 1 1   1 1 1 1]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 10,
        emitvector         = [[dir]],
        gravity            = [[0, -0.5, 0]],
        numparticles       = 1,
        particlelife       = 45,
        particlelifespread = 0,
        particlesize       = 2.5,
        particlesizespread = 0,
        particlespeed      = 3,
        particlespeedspread = 0,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0,
        sizemod            = 1.0,
        texture            = [[shell]],
      },
    },
  },

  ["emg_hit"] = {
    usedefaultexplosions = false,
    groundflash = {
      circlealpha        = 1,
      circlegrowth       = 0,
      flashalpha         = 0.9,
      flashsize          = 8,
      ttl                = 4,
      color = {
        [1]  = 1,
        [2]  = 0.75,
        [3]  = 0,
      },
    },
    sparks = {
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      unit               = 1,
      properties = {
        airdrag            = 0.97,
        colormap           = [[1 1 0 0.01   1 1 0 0.01   1 0.5 0 0.01   0 0 0 0.01]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 40,
        emitvector         = [[dir]],
        gravity            = [[0, -0.2, 0]],
        numparticles       = 4,
        particlelife       = 7,
        particlelifespread = 0,
        particlesize       = 6,
        particlesizespread = 0,
        particlespeed      = 3,
        particlespeedspread = 4,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0,
        sizemod            = 1.0,
        texture            = [[plasma]],
      },
    },
    splash = {
      class              = [[CExpGenSpawner]],
      count              = 1,
      nounit             = 1,
      properties = {
        delay              = 0,
        explosiongenerator = [[custom:EMG_HIT_WATER]],
        pos                = [[0, 0, 0]],
      },
    },
  },

  ["flashplosion"] = {
    usedefaultexplosions = false,
    groundflash = {
      circlealpha        = 1,
      circlegrowth       = 0,
      flashalpha         = 0.9,
      flashsize          = 12,
      ttl                = 3,
      color = {
        [1]  = 1,
        [2]  = 0.69999998807907,
        [3]  = 0,
      },
    },
    sparks = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.97,
        colormap           = [[1 1 0 0.01   1 1 0 0.01   1 0.5 0 0.01   0 0 0 0.01]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 40,
        emitvector         = [[dir]],
        gravity            = [[0, -0.2, 0]],
        numparticles       = 4,
        particlelife       = 7,
        particlelifespread = 0,
        particlesize       = 6,
        particlesizespread = 0,
        particlespeed      = 3,
        particlespeedspread = 4,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0,
        sizemod            = 1.0,
        texture            = [[plasma]],
      },
    },
  },

  ["gunmuzzle"] = {
    bitmapmuzzleflame = {
      air                = true,
      class              = [[CBitmapMuzzleFlame]],
      count              = 1,
      ground             = true,
      underwater         = 1,
      water              = true,
      properties = {
        colormap           = [[1 1 1 0.07  1 0.7 0 0.01	0.9 0.3 0 0.01	0 0 0 0.01]],
        dir                = [[dir]],
        frontoffset        = 0,
        fronttexture       = [[flowerflash]],
        length             = 18,
        sidetexture        = [[plasma2]],
        size               = 12,
        sizegrowth         = 1,
        ttl                = 3,
      },
    },
    groundflash = {
      circlealpha        = 1,
      circlegrowth       = 0,
      flashalpha         = 0.4,
      flashsize          = 35,
      ttl                = 3,
      color = {
        [1]  = 1,
        [2]  = 0.69999998807907,
        [3]  = 0,
      },
    },
  },

  ["emg_hit_he"] = {
    usedefaultexplosions = false,
    groundflash = {
      circlealpha        = 1,
      circlegrowth       = 0,
      flashalpha         = 0.25,
      flashsize          = 48,
      ttl                = 3,
      color = {
        [1]  = 1,
        [2]  = 0.94999998807907,
        [3]  = 0.5,
      },
    },
    groundsmoke = {
      class              = [[CSimpleParticleSystem]],
      count              = 3,
      ground             = true,
      unit               = 1,
      properties = {
        airdrag            = 0.8,
        colormap           = [[1 1 0 1  1 0.25 0 0.8  0 0 0 0.6  0 0 0 0.4  0 0 0 0.2  0 0 0 0]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 90,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0.2, 0]],
        numparticles       = 1,
        particlelife       = 10,
        particlelifespread = 5,
        particlesize       = 4,
        particlesizespread = 4,
        particlespeed      = 2,
        particlespeedspread = 2,
        pos                = [[0, 0, 0]],
        sizegrowth         = 1,
        sizemod            = 1.0,
        texture            = [[smokesmall]],
      },
    },
    main = {
      air                = true,
      class              = [[heatcloud]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        heat               = 6,
        heatfalloff        = 1,
        maxheat            = 6,
        pos                = [[0, 1, 0]],
        size               = 1,
        sizegrowth         = 8,
        speed              = [[0, 1, 0]],
        texture            = [[explo]],
      },
    },
    sparks = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.97,
        colormap           = [[1 0.95 0.5 0.01   1 0.95 0.5 0.01   1 0.95 0.5 0.01   0 0 0 0.01]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 90,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.2, 0]],
        numparticles       = 16,
        particlelife       = 10,
        particlelifespread = 0,
        particlesize       = 2,
        particlesizespread = 1,
        particlespeed      = 1,
        particlespeedspread = 6,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0,
        sizemod            = 1.0,
        texture            = [[plasma]],
      },
    },
    watermist = {
      class              = [[CSimpleParticleSystem]],
      count              = 3,
      water              = true,
      properties = {
        airdrag            = 0.8,
        colormap           = [[0.75 0.75 1 1  0 0 0 0]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 90,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0.2, 0]],
        numparticles       = 1,
        particlelife       = 10,
        particlelifespread = 5,
        particlesize       = 4,
        particlesizespread = 4,
        particlespeed      = 2,
        particlespeedspread = 2,
        pos                = [[0, 0, 0]],
        sizegrowth         = 1,
        sizemod            = 1.0,
        texture            = [[smokesmall]],
      },
    },
  },

  ["brawlimpacts"] = {
    usedefaultexplosions = false,
    groundflash = {
      circlealpha        = 1,
      circlegrowth       = 0,
      flashalpha         = 0.9,
      flashsize          = 12,
      ttl                = 3,
      color = {
        [1]  = 1,
        [2]  = 0.69999998807907,
        [3]  = 0,
      },
    },
    sparks = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.97,
        colormap           = [[1 1 0 0.01   1 1 0 0.01   1 0.5 0 0.01   0 0 0 0.01]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 90,
        emitvector         = [[dir]],
        gravity            = [[0, -0.4, 0]],
        numparticles       = 4,
        particlelife       = 14,
        particlelifespread = 0,
        particlesize       = 6,
        particlesizespread = 0,
        particlespeed      = 5,
        particlespeedspread = 10,
        pos                = [[0, 1, 0]],
        sizegrowth         = 0,
        sizemod            = 1.0,
        texture            = [[plasma]],
      },
    },
  },

  ["brawlermuzzle"] = {
    bitmapmuzzleflame = {
      air                = true,
      class              = [[CBitmapMuzzleFlame]],
      count              = 1,
      ground             = true,
      underwater         = 1,
      water              = true,
      properties = {
        colormap           = [[1 1 0 0.01	1 0.5 0 0.01	0 0 0 0.01]],
        dir                = [[dir]],
        frontoffset        = 0.1,
        fronttexture       = [[flowerflash]],
        length             = 18,
        sidetexture        = [[plasma2]],
        size               = 12,
        sizegrowth         = 1,
        ttl                = 3,
      },
    },
    groundflash = {
      circlealpha        = 1,
      circlegrowth       = 0,
      flashalpha         = 0.9,
      flashsize          = 35,
      ttl                = 3,
      color = {
        [1]  = 1,
        [2]  = 0.69999998807907,
        [3]  = 0,
      },
    },
  },

  ["emg_shells_l"] = {
    usedefaultexplosions = false,
    shells = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 0.97,
        colormap           = [[1 1 1 1   1 1 1 1]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 10,
        emitvector         = [[dir]],
        gravity            = [[0, -0.5, 0]],
        numparticles       = 1,
        particlelife       = 15,
        particlelifespread = 0,
        particlesize       = 2.5,
        particlesizespread = 0,
        particlespeed      = 3,
        particlespeedspread = 0,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0,
        sizemod            = 1.0,
        texture            = [[shell]],
      },
    },
  },

  ["emg_hit_water"] = {
    splash = {
      class              = [[CBitmapMuzzleFlame]],
      count              = 2,
      water              = true,
      properties = {
        colormap           = [[0.45 0.45 0.5 0.5  0.045 0.045 0.05 0.05]],
        dir                = [[-0.1 r0.2, 1, -0.1 r0.2]],
        frontoffset        = 0,
        fronttexture       = [[splashbase]],
        length             = [[10 r4]],
        sidetexture        = [[splashside]],
        size               = [[2 r1]],
        sizegrowth         = 1,
        ttl                = 12,
      },
    },
  },

}

