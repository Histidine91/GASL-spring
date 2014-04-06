--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
  return {
    name      = "Map Grid",
    version   = "v1.0",
    desc      = "Draws a vertical grid along map edge",
    author    = "KingRaptor (L.J. Lim)",
    date      = "2013.05.12",
    license   = "OD",
    layer     = 0,	--higher layer is loaded last
    enabled   = true,
    --detailsDefault = 2    
  }
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local GRID_SIZE = 512
local X_BOUND = Game.mapSizeX
local Z_BOUND = Game.mapSizeZ

local boundary, grid
local showGrid = false

local function ShowMapGrid()
  showGrid = true
end
  
local function HideMapGrid()
  showGrid = false
end
  
local function MapBoundary()
  gl.Vertex(0,0,0)
  gl.Vertex(0,0,Z_BOUND)
  gl.Vertex(Game.mapSizeX,0,Z_BOUND)
  gl.Vertex(Game.mapSizeX,0,0)
  gl.Vertex(0,0,0)
end

local function Grid()
  for x=GRID_SIZE, X_BOUND - GRID_SIZE, GRID_SIZE do
    gl.Vertex(x, 0, 0)
    gl.Vertex(x, 0, Z_BOUND)
  end
  for z=GRID_SIZE, Z_BOUND - GRID_SIZE, GRID_SIZE do
    gl.Vertex(0, 0, z)
    gl.Vertex(X_BOUND, 0, z)
  end
end

function widget:DrawWorldPreUnit()
  --gl.LineWidth(2)
  if showGrid and not (WG.Cutscene and WG.Cutscene.IsInCutscene()) then
    gl.Color(1,1,1,0.7)
    gl.CallList(boundary)
    gl.CallList(grid)
    gl.LineWidth(1)
    gl.Color(1,1,1,0.7)
  end
end

function widget:Initialize()
  boundary = gl.CreateList(gl.BeginEnd, GL.LINE_STRIP, MapBoundary)
  grid = gl.CreateList(gl.BeginEnd, GL.LINES, Grid)
  WG.ShowMapGrid = ShowMapGrid
  WG.HideMapGrid = HideMapGrid
end

function widget:Shutdown()
  gl.DeleteList(boundary)
  gl.DeleteList(grid)
  WG.ShowMapGrid = nil
  WG.HideMapGrid = nil
end