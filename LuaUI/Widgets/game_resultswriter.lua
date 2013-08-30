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

local stats = {"kills", "damage", "killCost", "damageCost", "repair"}

-- IMPORTANT: do not write any dictionaries, Ren'Py will throw up upon trying to import
function widget:GameOver()
  local results = {
    gameOver = (Spring.GetGameRulesParam("gameOver") == 1 and true) or false
  }
  for i=0,6 do
    for j=1,#stats do
      local stat = stats[j]
      local str = stat.."_"..i
      results[str] = Spring.GetGameRulesParam(str)
    end
  end
  WG.SavePythonDict("results.py", results, "combatResults", {raw = true})
end
