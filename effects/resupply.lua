-- based on galiblow.lua from ZK
return {

   ["resupply_fade"] = {
      usedefaultexplosions = false,
      galifading = {
	 air                = true,
	 class              = [[CExploSpikeProjectile]],
	 count              = 4,
	 ground             = true,
	 water              = true,
	 underwater	 = true,
	 properties = {
	    length 		= 55,
	    width		= 86,
	    alpha		= 0.45,
	    alphaDecay 		= 0.01,
	    lengthGrowth	= -25,
	    dir 		= [[0, -1 2r, 0]],
	    color 		= [[0.8, 0.3, 0.15]],
	},
      },	
   },


  ["resupply_spike"] = {
      usedefaultexplosions = false,
      gravspike1 = {
	 air                = true,
	 class              = [[CExploSpikeProjectile]],
	 count              = 6,
	 ground             = true,
	 water              = true,
	 underwater	 = true,
	 properties = {
	    length 		= 75,
	    width		= 20,
	    alpha		= 0.67,
	    alphaDecay 		= 0.02,
	    lengthGrowth	= 35,
	    dir 		= [[dir]],
	    color 		= [[1, 1, 0.2]],
	 },
      },
   },

   ["resupply"] = {
    usedefaultexplosions = false,
    foom = {
      air                = true,
      class              = [[CExpGenSpawner]],
      count              = 1,
      ground             = true,
      water              = true,
      underwater	 = true,
      properties = {
        delay              = 2,
        explosiongenerator = [[custom:resupply_spike]],
        pos                = [[0, 0, 0]],
	dir                = [[0, 1, 0]]
      },
    },
    foom2 = {
      air                = true,
      class              = [[CExpGenSpawner]],
      count              = 1,
      ground             = true,
      water              = true,
      underwater	 = true,
      properties = {
        delay              = 2,
        explosiongenerator = [[custom:resupply_spike]],
        pos                = [[0, 0, 0]],
	dir                = [[0, -1, 0]]
      },
    },    
    fade = {
      air                = true,
      class              = [[CExpGenSpawner]],
      count              = 1,
      ground             = true,
      water              = true,
      underwater	 = true,
      properties = {
        delay              = 7,
        explosiongenerator = [[custom:resupply_fade]],
        pos                = [[0, 0, 0]],
      },
    },
  },
}

