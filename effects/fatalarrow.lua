-- based on galiblow.lua from ZK
return {

   ["fatalarrow_fade"] = {
      usedefaultexplosions = false,
      galifading = {
	 air                = true,
	 class              = [[CExploSpikeProjectile]],
	 count              = 4,
	 ground             = true,
	 water              = true,
	 underwater	 = true,
	 properties = {
	    length 		= 16,
	    width		= 20,
	    alpha		= 0.6,
	    alphaDecay 		= 0.01,
	    lengthGrowth	= -4,
	    dir 		= [[0, -1 2r, 0]],
	    color 		= [[0.8, 0.8, 1]],
	},
      },	
   },


  ["fatalarrow_spike"] = {
      usedefaultexplosions = false,
      gravspike1 = {
	 air                = true,
	 class              = [[CExploSpikeProjectile]],
	 count              = 6,
	 ground             = true,
	 water              = true,
	 underwater	 = true,
	 properties = {
	    length 		= 24,
	    width		= 8,
	    alpha		= 0.7,
	    alphaDecay 		= 0.02,
	    lengthGrowth	= 8,
	    dir 		= [[dir]],
	    color 		= [[0.8, 0.8, 1]],
	 },
      },
   },

   ["fatalarrow_activate"] = {
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
        explosiongenerator = [[custom:fatalarrow_spike]],
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
        explosiongenerator = [[custom:fatalarrow_spike]],
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
        explosiongenerator = [[custom:fatalarrow_fade]],
        pos                = [[0, 0, 0]],
      },
    },
  },
}

