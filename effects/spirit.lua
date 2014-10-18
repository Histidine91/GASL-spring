return {
  ["feather"] = {
    usedefaultexplosions = false,
    shells = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 1,
        colormap           = [[1 1 1 1   1 1 1 1]],
        directional        = true,
        emitrot            = 180,
        emitrotspread      = 30,
        emitvector         = [[dir]],
        gravity            = [[0, 0, 0]],
        numparticles       = 1,
        particlelife       = 120,
        particlelifespread = 15,
        particlesize       = 2.5,
        particlesizespread = 0,
        particlespeed      = 5,
        particlespeedspread = 0,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0,
        sizemod            = 1.0,
        texture            = [[feather]],
      },
    },
  },
}

