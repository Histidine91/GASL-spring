function widget:GetInfo()
   return {
      name      = "Groundlines",
      desc      = "Draws a line between units and centerplane",
      author    = "KingRaptor (L.J. Lim)",
      date      = "2013.08.20",
      license   = "GNU GPL, v2 or later",
      layer     = 0,
      enabled   = true,
   }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local spGetUnitTeam		= Spring.GetUnitTeam
local spGetUnitViewPosition	= Spring.GetUnitViewPosition
local spGetVisibleUnits 	= Spring.GetVisibleUnits

local glTexture = gl.Texture
local glTexRect = gl.TexRect
local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local teamColors = {}
local draw = false

local function DrawUnitToGround(ux, uy, uz)
   gl.Vertex(ux, uy, uz)
   gl.Vertex(ux, 0, uz)
end

local function ShowGroundLines()
   draw = true
end

local function HideGroundLines()
   draw = false
end

function widget:Initialize()
   for _,teamID in pairs(Spring.GetTeamList()) do
      teamColors[teamID] = {Spring.GetTeamColor(teamID)}
   end
   
   WG.ShowGroundLines = ShowGroundLines
   WG.HideGroundLines = HideGroundLines
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:Shutdown()
   WG.ShowGroundLines = nil
   WG.HideGroundLines = nil
end

function widget:DrawWorldPreUnit(vsx,vsy)
   if WG.COFC then
      if not WG.COFC.IsOverviewMode() then
	 return
      end
   end
   local units = spGetVisibleUnits(nil, nil, true)

   gl.LineStipple('')
   for i=1,#units do
      local ux, uy, uz = spGetUnitViewPosition(units[i])
      if ux and uy and uz then
	 local team = spGetUnitTeam(units[i])
	 if team then
	    gl.Color(teamColors[team])
	 end
	 gl.BeginEnd(GL.LINES, DrawUnitToGround, ux, uy, uz)
      end
   end
   gl.LineStipple(false)
   gl.Color(1,1,1,1)
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------