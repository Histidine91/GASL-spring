local MergeTable = Spring.Utilities.MergeTable

local fx = {
  blinkyLightWhite = {
    life        = 60,
    lifeSpread  = 0,
    size        = 20,
    sizeSpread  = 0,
    colormap    = { {1, 1, 1, 0.02}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0} },
    texture     = 'bitmaps/GPL/smallflare.tga',
    count       = 1,
    repeatEffect = true,
  },
  staticLightWhite = {
    life        = math.huge,
    lifeSpread  = 0,
    size        = 20,
    sizeSpread  = 0,
    colormap    = { {1, 1, 1, 0.02} },
    texture     = 'bitmaps/GPL/smallflare.tga',
    count       = 1,
  }
}

local lightColors = {
	Red = {1, 0.1, 0.1, 0.02},
	Pink = {1, 0.1, 0.8, 0.02},
	Blue = {0.1, 0.1, 1, 0.02},
	SkyBlue = {0.1, 0.5, 1, 0.02},
	Green = {0, 1, 0.2, 0.02},
	Orange = {0.8, 0.2, 0., 0.02},
	Violet = {0.5, 0, 0.6, 0.02},
}

for name, color in pairs(lightColors) do
	local key = "blinkyLight"..name
	fx[key] = Spring.Utilities.CopyTable(fx.blinkyLightWhite, true)
	fx[key]["colormap"][1] = color
	
	key = "staticLight"..name
	fx[key] = Spring.Utilities.CopyTable(fx.staticLightWhite, true)
	fx[key]["colormap"][1] = color
end

local tbl = {
  luckystar_phalanx = {
    {class='StaticParticles', options=MergeTable(fx.staticLightPink, {size=100})},
    {class='Ribbon', options={width=3, size=64, color={1, 0.1, 0.8, 1}, texture="bitmaps/phalanxtrail.png", persistAfterDeath=true}},
  },
  happytrigger_phalanx = {
    {class='StaticParticles', options=MergeTable(fx.staticLightSkyBlue, {size=100})},
    {class='Ribbon', options={width=3, size=64, color={0.1, 0.5, 1, 1}, texture="bitmaps/phalanxtrail.png", persistAfterDeath=true}},
  },
  happytrigger_phalanx_sb = {
    {class='StaticParticles', options=MergeTable(fx.staticLightSkyBlue, {size=100})},
    {class='Ribbon', options={width=3, size=64, color={0.1, 0.5, 1, 1}, texture="bitmaps/phalanxtrail.png", persistAfterDeath=true}},
  },
  kungfufighter_anchorclaw_l = {
    {class='StaticParticles', options=MergeTable(fx.staticLightRed, {size=150})},
    {class='Ribbon', options={width=3, size=64, color={1, 0.1, 0.1, 1}, texture="bitmaps/phalanxtrail.png", persistAfterDeath=true}},
  },
  kungfufighter_anchorclaw_r = {
    {class='StaticParticles', options=MergeTable(fx.staticLightRed, {size=150})},
    {class='Ribbon', options={width=3, size=64, color={1, 0.1, 0.1, 1}, texture="bitmaps/phalanxtrail.png", persistAfterDeath=true}},
  },
  --energybomb = {
  --  {class='Ribbon', options={width=3, size=4, color={0.1, 0.5, 1, 1}, texture="bitmaps/phalanxtrail.png", persistAfterDeath=true}},
  --}
  placeholdersior_plasmalance = {
    {class='StaticParticles', options=MergeTable(fx.staticLightSkyBlue, {size=150})},
    {class='Ribbon', options={width=5, size=64, color={0.1, 0.5, 1, 1}, texture="bitmaps/phalanxtrail.png", persistAfterDeath=true}},
  },
}
local tbl2 = {}

for weaponName, data in pairs(tbl) do
  local weaponDef = WeaponDefNames[weaponName] or {}
  local weaponID = weaponDef.id
  if weaponID then
    tbl2[weaponID] = data
  end
end

return tbl2