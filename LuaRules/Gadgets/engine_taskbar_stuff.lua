--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Engine Taskbar Stuff",
    desc      = 'Icon, name',
    author    = "KingRaptor",
    date      = "13 July 2011",
    license   = "Public Domain",
    layer     = -math.huge,
    enabled   = true,
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (gadgetHandler:IsSyncedCode()) then
  return false  --  silent removal
end

function gadget:Initialize()
	local name = Game.modName
	Spring.SetWMIcon("LuaUI/Images/angels_logo_32.png")
	Spring.SetWMCaption(name .. " (Spring " .. Game.version .. ")", name)
	gadgetHandler:RemoveGadget()
end