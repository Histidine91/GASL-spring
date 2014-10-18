function widget:GetInfo()
	return {
		name = "Unit Nametags",
		desc = "Name, health and serial number!",
		author = "KingRaptor",
		date = "2011.5.6",
		license = "Public Domain",
		layer = 0,
		enabled = false,
	}
end

------------------------
-- speedups
local spGetCameraState = Spring.GetCameraState
local spGetMouseState = Spring.GetMouseState
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitHealth = Spring.GetUnitHealth
local spGetUnitViewPosition = Spring.GetUnitViewPosition
local spIsUnitSelected = Spring.IsUnitSelected
local spIsUnitInView = Spring.IsUnitInView
local spTraceScreenRay = Spring.TraceScreenRay
local spWorldToScreenCoords = Spring.WorldToScreenCoords

------------------------
--  CONFIG
------------------------
options_path = 'Settings/Interface/Unit Name Tags'
options = {
	toDisplay = {
		name = 'Display for Units',
		type = 'list',
		items = {
			{ key = 'none', name = 'None', },
			{ key = 'selected', name = 'Selected', },
			{ key = 'distant', name = 'Distant', },
			{ key = 'selected_and_distant', name = 'Selected & Distant', },
			{ key = 'all', name = 'All', },
		},
		value = 'selected',
	},
}

local PANEL_WIDTH, PANEL_HEIGHT = 160, 32
local DISTANT_VIEW_THRESHOLD = 2000

local units = {}

local updateFrequency = 0.2
local gameframe = Spring.GetGameFrame()
local currentMouseOverUnit
local cam = spGetCameraState()

-- Chili classes
local Chili
local Panel
local Label
local Progressbar

-- Chili instances
local screen0

------------------------
------------------------
local function GetTwoPointDistance(x1, y1, z1, x2, y2, z2)
	local distSq = (x1-x2)^2 + (y1-y2)^2 + (z1-z2)^2
	return distSq^0.5
end


local function DisposePanel(unitID)
	if not unitID then return end
	
	if units[unitID] and units[unitID].panel then
		units[unitID].panel:Dispose()
	end
	units[unitID] = nil
end

local function GetPanelPosition(unitID, invert)
	--local height = Spring.GetUnitHeight(unitID)
	local cx, cy, cz = cam.px, cam.py, cam.pz
	local ux, uy, uz = spGetUnitViewPosition(unitID)
	local distFromCam = (cx-ux)^2 + (cy-uy)^2 + (cz-uz)^2
	distFromCam = distFromCam^0.5
	--uy = uy + height
	local x,y,z = spWorldToScreenCoords(ux, uy, uz)
	x = x  - PANEL_WIDTH/2
	y = y + PANEL_HEIGHT + 12 + math.floor(32*(400/distFromCam)) --Spring.GetUnitRadius(unitID)
	if not invert then
		y = screen0.height - y
	end
	
	return x, y
end

local function MakeLabel(unitDef, parent)
	return Label:New{
		parent = parent,
		caption = unitDef.customParams.shortname or unitDef.humanName,
		fontsize = 12,
		align = "center",
		width = "100%",
		y = 0
	}
end

local function MakePanel(unitID, unitDefID, unitTeam)
	units[unitID] = {unitDefID = unitDefID}
	local unitDef = UnitDefs[unitDefID]
	local x, y = GetPanelPosition(unitID)
	units[unitID].panel = Panel:New{
		parent = screen0,
		x = x,
		y = y,
		width = PANEL_WIDTH,
		height = PANEL_HEIGHT,
	}
	units[unitID].name = MakeLabel(unitDef, units[unitID].panel)
	local hp, maxHP = Spring.GetUnitHealth(unitID)
	units[unitID].health = Progressbar:New{
		parent  = units[unitID].panel,
		x = 4,
		right = 4,
		bottom = 2,
		y = 16,
		max     = 1;
		value	= hp/maxHP;
		color   = {1,1,0,1};
	}
	-- TBD shield bar; HP loss bar
end

local function ShouldDisplayNametag(unitID)
	local setting = options.toDisplay.value
	if setting == "none" then
		return false
	elseif not spIsUnitInView(unitID) then
		return false
	end
	
	if setting == "selected" then
		return (spIsUnitSelected(unitID) or (WG.COFC and WG.COFC.GetThirdPersonTrackUnit() == unitID) or currentMouseOverUnit == unitID)
	elseif setting == "distant" then
		local x,y,z = spGetUnitViewPosition(unitID)
		local dist = GetTwoPointDistance(x, y, z, cam.px, cam.py, cam.pz)
		return dist > DISTANT_VIEW_THRESHOLD
	elseif setting == "selected_and_distant" then
		if (spIsUnitSelected(unitID) or (WG.COFC and WG.COFC.GetThirdPersonTrackUnit() == unitID) or currentMouseOverUnit == unitID) then
			return true
		end
		local x,y,z = spGetUnitViewPosition(unitID)
		local dist = GetTwoPointDistance(x, y, z, cam.px, cam.py, cam.pz)
		return dist > DISTANT_VIEW_THRESHOLD
	end
	return true
end
------------------------
------------------------

local timer = 0

function widget:Update(dt)
	cam = spGetCameraState()
	
	timer = timer + dt
	for unitID, data in pairs(units) do
		if ShouldDisplayNametag(unitID) then
			local panel = data.panel
			if panel.hidden then
				screen0:AddChild(panel)
				data.name:Dispose()	-- workaround for vanishing text
				data.name = MakeLabel(UnitDefs[data.unitDefID], panel)
				panel.hidden = false
			end
			local x, y = GetPanelPosition(unitID)	
			panel:SetPos(x, y)
			if timer > updateFrequency then
				local hp, maxHP = Spring.GetUnitHealth(unitID)
				data.health:SetValue(hp/maxHP)
			end
		elseif not data.panel.hidden then
			screen0:RemoveChild(data.panel)
			data.panel.hidden = true
		end
	end
	if timer > updateFrequency then
		local mx, my = spGetMouseState()
		local type, data = spTraceScreenRay(mx, my)
		if type == 'unit' then
			currentMouseOverUnit = data
		end
		timer = 0
	end
end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
	units[unitID] = true
	MakePanel(unitID, unitDefID, unitTeam)
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if units[unitID] then
		units[unitID].panel:Dispose()
	end
	units[unitID] = nil
end

function widget:UnitEnteredLos(unitID, unitTeam)
	if not units[unitID] then
		local unitDefID = Spring.GetUnitDefID(unitID)
		widget:UnitFinished(unitID, unitDefID, unitTeam)
	end
end

function widget:UnitLeftLos(unitID, unitTeam)
	widget:UnitDestroyed(unitID, unitDefID, teamID)
end

function widget:UnitGiven(unitID, unitDefID, newTeamID, teamID)
	widget:UnitDestroyed(unitID, unitDefID, teamID)
	widget:UnitFinished(unitID, unitDefID, teamID)
end

function widget:GameFrame(n)
	gameframe = n
end


function widget:UnitDamaged(unitID, unitDefID, unitTeam)

end

function widget:SelectionChanged(newSelection)
end

function widget:Initialize()
	local selection = Spring.GetSelectedUnits()
	widget:SelectionChanged(selection)
	
	Chili = WG.Chili
	Panel = Chili.Panel
	Label = Chili.Label
	Progressbar = Chili.Progressbar
	screen0 = Chili.Screen0
	
	-- reload compatibility
	local units = Spring.GetAllUnits()
	for i=1,#units do
		widget:UnitFinished(units[i], Spring.GetUnitDefID(units[i]), Spring.GetUnitTeam(units[i]))
	end
end
