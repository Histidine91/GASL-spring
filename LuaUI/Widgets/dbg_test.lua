function widget:GetInfo()
  return {
    name      = "Test widget",
    desc      = "stuff",
    author    = "",
    date      = "",
    license   = "PD",
    layer     = 0,
    enabled   = false,
  }
end
include("keysym.h.lua")
function widget:Initialize()
end

function widget:KeyPress(key, modifier, isRepeat)
  if key == KEYSYMS.N_5 then
    local cam = Spring.GetCameraState()
    for i,v in pairs(cam) do
      Spring.Echo(i,v)
    end
  end
end