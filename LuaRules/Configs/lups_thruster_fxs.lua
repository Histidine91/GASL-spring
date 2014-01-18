local CopyTable = Spring.Utilities.CopyTable
local MergeTable = Spring.Utilities.MergeTable

local corona = {
  life        = math.huge,
  lifeSpread  = 0,
  size        = 16,
  sizeGrowth  = 0,
  sizeSpread  = 0,
  --colormap    = { {0.7, 0.6, 0.5, 0.01} },
  colormap    = { {0.4, 0.7, 1, 0.01} },
  texture     = 'bitmaps/GPL/thrusterflare.tga',
  count       = 1,
  repeatEffect = true,
  rotSpeed    = 4,
}

local coronaRed = CopyTable(corona, true)
coronaRed.colormap = {{1, 0.2, 0, 0.01}}
local coronaOrange = CopyTable(corona, true)
coronaOrange.colormap = {{1, 0.5, 0, 0.01}}

local tbl = {
  luckystar = {
    {class='StaticParticles', options=MergeTable(corona, {pos={0,0,3}, piece="engine_l"})},
    {class='StaticParticles', options=MergeTable(corona, {pos={0,0,3}, piece="engine_r"})},
    {class='CrossJet', options={color={0.2,0.6,1}, width=3, length=40, piece="engine_l"}},    
    {class='CrossJet', options={color={0.2,0.6,1}, width=3, length=40, piece="engine_r"}},  
  },
  kungfufighter = {
    {class='StaticParticles', options=MergeTable(corona, {pos={0,0,3}, piece="engine_l"})},
    {class='StaticParticles', options=MergeTable(corona, {pos={0,0,3}, piece="engine_r"})},
    {class='CrossJet', options={color={0.2,0.6,1}, width=3, length=40, piece="engine_l"}},    
    {class='CrossJet', options={color={0.2,0.6,1}, width=3, length=40, piece="engine_r"}},     
  },
  happytrigger = {
    {class='StaticParticles', options=MergeTable(corona, {pos={0,0,3}, piece="engine_l"})},
    {class='StaticParticles', options=MergeTable(corona, {pos={0,0,3}, piece="engine_r"})},
    {class='CrossJet', options={color={0.2,0.6,1}, width=3, length=40, piece="engine_l"}},    
    {class='CrossJet', options={color={0.2,0.6,1}, width=3, length=40, piece="engine_r"}},      
  },
  sharpshooter = {
    {class='StaticParticles', options=MergeTable(corona, {pos={0,0,3}, piece="engine_l"})},
    {class='StaticParticles', options=MergeTable(corona, {pos={0,0,3}, piece="engine_r"})},
    {class='CrossJet', options={color={0.2,0.6,1}, width=3, length=40, piece="engine_l"}},    
    {class='CrossJet', options={color={0.2,0.6,1}, width=3, length=40, piece="engine_r"}},      
  },  
  yngcommando = {
    {class='StaticParticles', options=MergeTable(coronaOrange, {size=12, piece="engine"}, true)},
    {class='CrossJet', options={color={1,0.6,0.2}, width=2.5, length=32, piece="engine"}},
  },
  yngtiger = {
    {class='StaticParticles', options=MergeTable(coronaOrange, {size=12, piece="exhaust_l"}, true)},
    {class='StaticParticles', options=MergeTable(coronaOrange, {size=12, piece="exhaust_r"}, true)},
    {class='CrossJet', options={color={1,0.6,0.2}, width=2.5, length=32, piece="exhaust_l"}},
    {class='CrossJet', options={color={1,0.6,0.2}, width=2.5, length=32, piece="exhaust_r"}},
  },  
}
local tbl2 = {}

for unitName, data in pairs(tbl) do
  local unitDef = UnitDefNames[unitName] or {}
  data.baseSpeed = data.baseSpeed or (unitDef and unitDef.speed/30)
  data.maxDeltaSpeed = data.maxDeltaSpeed or 1
  data.accelMod = data.accelMod or 2
  data.minSpeed = data.minSpeed or 0
  for index, fx in ipairs(data) do
    local opts = fx.options
    if opts.length then
      opts.baseLength = opts.length
    end
    if opts.width then
      opts.baseWidth = opts.width
    end
    if opts.size then
      opts.baseSize = opts.size
    end
  end
  
  local unitDefID = unitDef.id
  if unitDefID then
    tbl2[unitDefID] = data
  end
end

return tbl2