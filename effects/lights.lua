Spring = Spring or {}
Spring.Utilities = Spring.Utilities or {}
VFS.Include("LuaRules/Utilities/tablefunctions.lua")

local cegs = {
  ["light_white"] = {
    light = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 1,
        colormap           = [[1 1 1 1  0 0 0 0.01]],
        directional        = false,
        emitrot            = 0,
        emitrotspread      = 0,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 1,
        particlelife       = 2,
        particlelifespread = 0,
        particlesize       = 3,
        particlesizespread = 0,
        particlespeed      = 0,
        particlespeedspread = 0,
        pos                = [[0, 0, 0]],
        sizegrowth         = 0,
        sizemod            = 1,
        texture            = [[light_white]],
      },
    },
  },
}


-- CEG cloning
local colors = {
  light_pink = {
    source = "light_white",
    data = {
      light = {
	properties = {texture = "light_pink"},
      },
    },
  },
}

for color, info in pairs(colors) do
  cegs[color] = Spring.Utilities.MergeTable(info.data, cegs[info.source], true)
end

return cegs