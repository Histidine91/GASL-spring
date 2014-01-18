local CopyTable = Spring.Utilities.CopyTable

local function MergeTableReverse(table1, table2)
  return Spring.Utilities.MergeTable(table2, table1)
end

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
    {class='StaticParticles', options=MergeTableReverse(corona, {pos={0,0,3}, piece="engine_l"})},
    {class='StaticParticles', options=MergeTableReverse(corona, {pos={0,0,3}, piece="engine_r"})},
    {class='AirJet', options={color={0.2,0.6,1}, width=3, length=40, distortion=0, piece="engine_l"}},    
    {class='AirJet', options={color={0.2,0.6,1}, width=3, length=40, distortion=0, piece="engine_r"}},  
  },
  kungfufighter = {
    {class='StaticParticles', options=MergeTableReverse(corona, {pos={0,0,3}, piece="engine_l"})},
    {class='StaticParticles', options=MergeTableReverse(corona, {pos={0,0,3}, piece="engine_r"})},
    {class='AirJet', options={color={0.2,0.6,1}, width=3, length=40, distortion=0, piece="engine_l"}},    
    {class='AirJet', options={color={0.2,0.6,1}, width=3, length=40, distortion=0, piece="engine_r"}},     
  },
  happytrigger = {
    {class='StaticParticles', options=MergeTableReverse(corona, {pos={0,0,3}, piece="engine_l"})},
    {class='StaticParticles', options=MergeTableReverse(corona, {pos={0,0,3}, piece="engine_r"})},
    {class='AirJet', options={color={0.2,0.6,1}, width=3, length=40, distortion=0, piece="engine_l"}},    
    {class='AirJet', options={color={0.2,0.6,1}, width=3, length=40, distortion=0, piece="engine_r"}},      
  },
  sharpshooter = {
    {class='StaticParticles', options=MergeTableReverse(corona, {pos={0,0,3}, piece="engine_l"})},
    {class='StaticParticles', options=MergeTableReverse(corona, {pos={0,0,3}, piece="engine_r"})},
    {class='AirJet', options={color={0.2,0.6,1}, width=3, length=40, distortion=0, piece="engine_l"}},    
    {class='AirJet', options={color={0.2,0.6,1}, width=3, length=40, distortion=0, piece="engine_r"}},      
  },
  placeholdersior = {
    maxDeltaSpeed = 0.4,
    {class='StaticParticles', options=MergeTableReverse(corona, {size=100, pos={0,0,10}, piece="engine_l"})},
    {class='StaticParticles', options=MergeTableReverse(corona, {size=100, pos={0,0,10}, piece="engine_r"})},
    {class='AirJet', options={color={0.2,0.6,1}, width=14, length=120, distortion=0, piece="engine_l"}},    
    {class='AirJet', options={color={0.2,0.6,1}, width=14, length=120, distortion=0, piece="engine_r"}},      
  }, 
  yngcommando = {
    {class='StaticParticles', options=MergeTableReverse(coronaOrange, {size=12, piece="engine"}, true)},
    {class='AirJet', options={color={1,0.6,0.2}, width=2.5, length=32, distortion=0, piece="engine"}},
  },
  yngtiger = {
    {class='StaticParticles', options=MergeTableReverse(coronaOrange, {size=12, piece="exhaust_l"}, true)},
    {class='StaticParticles', options=MergeTableReverse(coronaOrange, {size=12, piece="exhaust_r"}, true)},
    {class='AirJet', options={color={1,0.6,0.2}, width=2.5, length=32, distortion=0, piece="exhaust_l"}},
    {class='AirJet', options={color={1,0.6,0.2}, width=2.5, length=32, distortion=0, piece="exhaust_r"}},
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