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
local function GetUnitPosition(unitID)
	local _,_,_,x,y,z = Spring.GetUnitPosition(unitID, true)
	return x,y,z
end

local scaleMult = 5	--elmos -> meter

local dsize=36
local ssize=30;
local csize=20;
local maxDistance=5000;
local minDistance=1200;
local nameRange=1500;
local reticleSize=10;
local arrowSize=10;
local baseDistance = 500^0.5

local selectedUnit = (Spring.GetSelectedUnits() or {})[1]

local square

local colors = {
	blue = {0, 0, 1, 1},
	cyan = {0, 1, 1, 1},
	green = {0, 1, 0, 1},
	red = {1, 0, 0, 1},
}

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


function widget:Initialize()
end

function widget:Shutdown()
end

function widget:SelectionChanged(newSelection)
	selectedUnit = newSelection and newSelection[1]
end

--local echoFreq = 0
function widget:DrawScreen(vsx,vsy)
	--[[
	if not selectedUnit then
		return
	end
	]]
	
	local cam = Spring.GetCameraState()
	local units = Spring.GetVisibleUnits(nil, nil, false)
	for i=1,#units do
		local unitID = units[i]
		local unitTeam = Spring.GetUnitTeam(unitID)
		local unitDefID = Spring.GetUnitDefID(unitID)
		if true then	--if unitID ~= selectedUnit then
			local x,y,z = GetUnitPosition(unitID)
			if x and y and z then
				local dist = GetTwoPointDistance(x,y,z,cam.px, cam.py, cam.pz)
				if (dist < maxDistance) and (dist > minDistance) then
					local size = (baseDistance/(dist^0.5)) or 1
					--local isTarget = bla
					local color = colors.cyan
				
					local x,y,z = GetUnitPosition(unitID)
					local sx,sy,sz=Spring.WorldToScreenCoords(x,y,z)
					--if echoFreq > 120 then
					--	Spring.Echo(sx,sy,sz)
					--	echoFreq = 0
					--end
					local isAllied = Spring.IsUnitAllied(unitID)
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
			end
		end
	end
	gl.Color(1,1,1,1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------