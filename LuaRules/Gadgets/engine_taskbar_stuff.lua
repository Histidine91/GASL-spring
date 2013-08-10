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

local SetWMIcon = Spring.SetWMIcon
local SetWMCaption = Spring.SetWMCaption

function gadget:Initialize()
	local name = Game.modName
	--SetWMIcon("bitmaps/ZK_logo_square.bmp")	-- get an icon
	SetWMCaption(name .. " (Spring " .. Game.version .. ")", name)
	gadgetHandler:RemoveGadget()
end