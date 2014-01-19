function widget:GetInfo()
  return {
    name      = "Results Writer",
    desc      = "Prints game results to results.py",
    author    = "KingRaptor (L.J. Lim)",
    date      = "2013.08.28",
    license   = "Public Domain",
    layer     = 0,
    enabled   = true,
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Chili
local Label

local modOptions = Spring.GetModOptions()
local colorRed = "\255\255\64\64"
local colorWhite = "\255\255\255\255"

local stats = {"kills", "damage", "killCost", "damageCost", "repair", "deaths"}
local columns = {"Unit", "Kills", "Evaluation", "Bonus", "Score", "Total Kills", "Total Score"}
local unitNames = {
  [-1] = "Other Units", [0] = "Elsior", "Lucky Star", "Kung-fu Fighter", "Trick Master", "Happy Trigger", "Harvester", "Sharpshooter"
}

local function WriteStats(i, grid)
  local otherUnits = (i == -1)
  local dead = ((Spring.GetGameRulesParam("deaths_" .. i) or 0) > 0) and (not otherUnits)
  local color = dead and colorRed or colorWhite
  
  local kills = Spring.GetGameRulesParam("kills_" .. i) or 0
  
  local evaluation = math.floor((Spring.GetGameRulesParam("killCost_" .. i) or 0) + (Spring.GetGameRulesParam("damageCost_" .. i) or 0))
  if dead then evaluation = 0 end
  
  local bonus = math.floor(Spring.GetGameRulesParam("repair_" .. i) or 0)
  if dead then bonus = 0 end
  
  local score = evaluation + bonus
  
  if score == 0 and (not dead) then	-- absent (FIXME: get a proper way to detect)
    Label:New{ parent = grid, caption = unitNames[i], y = 0, align="left", fontSize = 15, fontShadow = true}
    for i=2,7 do
      Label:New{ parent = grid, caption = "-", y = 0, align="right", fontSize = 15, fontShadow = true}
    end
  else
    Label:New{ parent = grid, caption = unitNames[i], y = 0, align="left", fontSize = 15, fontShadow = true}
    Label:New{ parent = grid, caption = color .. kills .. "\008", y = 0, align="right", fontSize = 14, fontShadow = true }
    Label:New{ parent = grid, caption = color .. evaluation .. "\008", y = 0, align="right", fontSize = 14, fontShadow = true }
    Label:New{ parent = grid, caption = color .. bonus .. "\008", y = 0, align="right", fontSize = 14, fontShadow = true }
    Label:New{ parent = grid, caption = color .. score .. "\008", y = 0, align="right", fontSize = 14, fontShadow = true }
    
    local totalKills = otherUnits and "-" or (kills + (modOptions["kills"..i] or 0))
    Label:New{ parent = grid, caption = color .. totalKills .. "\008", y = 0, align="right", fontSize = 14, fontShadow = true }
    
    local totalScore = otherUnits and "-" or (score + (modOptions["score"..i] or 0))
    Label:New{ parent = grid, caption = color .. totalScore .. "\008", y = 0, align="right", fontSize = 14, fontShadow = true }
  end
  
  
end

local function DisplayStats()
  Chili = WG.Chili
  Label = Chili.Label
  
  local vsx,vsy = Spring.GetWindowGeometry()
  
  local window = Chili.Window:New{
    parent = Chili.Screen0,
    name   = 'gamestats_window';
    width = 720;
    height = 480;
    x = vsx/2 - 300; 
    y = vsy/2 - 300;
    draggable = true,
    resizable = false,
    tweakResizable = false,
    padding = {0, 0, 0, 0},
    itemMargin  = {0, 0, 0, 0},
  }
  local panel = Chili.Panel:New{
    parent = window,
    width = "100%",
    height = "100%",
  }
  local subpanel = panel
  --local subpanel = Chili.Panel:New{
  --  parent = panel,
  --  y = "10%",
  --  width = "100%",
  --  height = "90%",
  --}
  
  local title = Label:New{
    parent = panel, caption = "Performance Evaluation", x = 8, y = 8, align="left", fontSize = 20, fontShadow = true
  }
  local grid = Chili.Grid:New{
    parent = subpanel,
    rows = 9,
    columns = 7,
    y = "10%",
    width = '100%',
    bottom = 32,
  }
  local button_close = Chili.Button:New{
    parent = subpanel,
    caption = 'Close', 
    OnMouseUp = { function(self)
      window:Dispose()
      Spring.SendCommands('quit')
    end }, 
    right = 8,
    height = 24,
    bottom = 4,
  }
  local image = Chili.Image:New{
    parent = subpanel,
    y = 8,
    right = 16,
    width = 64,
    height= 64,
    file = "LuaUI/Images/logo_angels.png",
    keepAspect = true,
    color = {1,1,1,0.5},
  }
  for i=1,#columns do
    Label:New{ parent = grid, caption = columns[i], y = 0, align= (i == 1) and "center" or "right", fontSize = 15, fontShadow = true }
  end
  for i=0,6 do
    WriteStats(i, grid)
  end
  WriteStats(-1, grid)
  
  Spring.SendCommands('endgraph 0')
  Spring.PlaySoundFile("sounds/debriefing.wav", 1.0, "userinterface")
end

function widget:GameOver()
  local results = {
    gameOver = (Spring.GetGameRulesParam("gameOver") == 1 and true) or false
  }
  for i=0,6 do
    results[i] = {}
    for j=1,#stats do
      local stat = stats[j]
      local str = stat.."_"..i
      results[i][stat] = math.floor(Spring.GetGameRulesParam(str))
    end
  end
  WG.SavePythonDict("results.py", results, "combatResults", {endOfFile = true})
  
  DisplayStats()
end

function widget:Initialize()
  --DisplayStats()
end