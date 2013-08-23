function widget:GetInfo()
   return {
      name      = "Unit Target Marker",
      desc      = "boxes and reticules",
      author    = "KingRaptor (L.J. Lim)",
      date      = "2013.08.07.",
      license   = "GNU GPL, v2 or later",
      layer     = 2,
      enabled   = true,
   }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local spGetUnitTeam		= Spring.GetUnitTeam
local spGetUnitDefID		= Spring.GetUnitDefID
local spGetUnitCommands		= Spring.GetUnitCommands
local spGetUnitViewPosition		= Spring.GetUnitViewPosition
local spGetCameraState		= Spring.GetCameraState
local spGetVisibleUnits 	= Spring.GetVisibleUnits
local spWorldToScreenCoords	= Spring.WorldToScreenCoords
local spIsUnitAllied		= Spring.IsUnitAllied

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local scaleMult = 5	--elmos -> meter
local ROTATION_PERIOD = 1

local ssize=30;
local maxDistance=5000;
local minDistance=1200;
local nameRange=1500;
local reticleSize=10;
local arrowSize=10;
local baseDistance = 500^0.5

local square

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local selectedUnit = (Spring.GetSelectedUnits() or {})[1]
local currentTarget
local rotAngle = 0

local colors = {
	blue = {0, 0, 1, 1},
	cyan = {0, 1, 1, 1},
	green = {0, 1, 0, 1},
	red = {1, 0, 0, 1},
}

local footprint = {}
for i=1,#UnitDefs do
	footprint[i] = UnitDefs[i].xsize/2
end

local function GetTwoPointDistance(x1, y1, z1, x2, y2, z2)
	local distSq = (x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2
	return distSq^0.5
end

local function Square(size)
	gl.Vertex(ssize*size,ssize*size,0)
	gl.Vertex(-ssize*size,ssize*size,0)
	gl.Vertex(-ssize*size,-ssize*size,0)
	gl.Vertex(ssize*size,-ssize*size,0)
end

local function UpdateTarget()
	if not selectedUnit then
		return
	end
	local commands = spGetUnitCommands(selectedUnit)
	if commands and commands[1] and commands[1].id == CMD.ATTACK then
		currentTarget = commands[1].params[1]
	else
		currentTarget = nil
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
end

function widget:Shutdown()
end

function widget:SelectionChanged(newSelection)
	selectedUnit = newSelection and newSelection[1]
	UpdateTarget()
end

function widget:GameFrame(n)
	if (n%5 == 0) then
		UpdateTarget()
	end
end

function widget:Update(dt)
	rotAngle = (rotAngle + (dt*360)/ROTATION_PERIOD)%360
end

--local echoFreq = 0
function widget:DrawScreen(vsx,vsy)
	--[[
	if not selectedUnit then
		return
	end
	]]
	
	local cam = spGetCameraState()
	local units = spGetVisibleUnits(nil, nil, false)
	for i=1,#units do
		local unitID = units[i]
		local unitTeam = spGetUnitTeam(unitID)
		local unitDefID = spGetUnitDefID(unitID)
		if true then	--if unitID ~= selectedUnit then
			local x,y,z = spGetUnitViewPosition(unitID)
			if x and y and z then
				local dist = GetTwoPointDistance(x,y,z,cam.px, cam.py, cam.pz)
				local size = (baseDistance/(dist^0.5)) or 1
				if (dist < maxDistance) and (dist > minDistance) then
					--local isTarget = bla
					local color = colors.cyan
				
					local x,y,z = spGetUnitViewPosition(unitID)
					local sx,sy,sz=spWorldToScreenCoords(x,y,z)
					--if echoFreq > 120 then
					--	Spring.Echo(sx,sy,sz)
					--	echoFreq = 0
					--end
					local isAllied = spIsUnitAllied(unitID)
					-- team coloration
					if not isAllied then
						color = colors.red
					end
					gl.Color(color)
					gl.PushMatrix()
					gl.Translate(sx,sy,0)
					
					-- target square
					--gl.CallList(diamond)
					gl.BeginEnd(GL.LINE_LOOP,Square,size)
					
					-- range display
					--[[
					if ((dist < rangeInfoRange) or isWantedTarget) and not isAllied then
						local str
						if dist > 400 then
							str = ("%.1f"):format(dist/(1000/scaleMult)).." km"
						else
							str = math.ceil(dist*scaleMult).." m"
						end
						gl.Text(str, ssize*size + 2, -ssize*size, 14)
					end
					
					
					-- health display
					local hp,mhp= Spring.GetUnitHealth(u)
					if hp < mhp then
						gl.Text(math.floor(100*hp/mhp).."%",0,0,14,"c")
					end
					
					--name display
					if ((dist < nameRange) or isWantedTarget) and UnitDefs[ud].customParams.label then
						gl.Text(UnitDefs[ud].customParams.label,0,ssize*size + 2,16,"c")
					end
					]]
					gl.PopMatrix()
				end
				if unitID == currentTarget then
					local x,y,z = spGetUnitViewPosition(unitID)
					local sx,sy,sz=spWorldToScreenCoords(x,y,z)
					gl.PushMatrix()
					gl.Translate(sx,sy,0)
					gl.Color(1,1,1,1)
					gl.Texture("LuaUI/Images/targetmarker.png")
					gl.Rotate(rotAngle,0,0,1)
					--gl.Billboard()
					local texSize = size*footprint[unitDefID]^0.5
					gl.TexRect(-48*texSize, -48*texSize, 48*texSize, 48*texSize)
					gl.PopMatrix()
				end
			end
		end
	end
	gl.Color(1,1,1,1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------