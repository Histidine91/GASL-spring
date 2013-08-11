-------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "Ship Status",
    desc      = "Shows the status of ships on the battlefield.",
    author    = "KingRaptor",
    date      = "2011-6-2",
    license   = "GNU GPL, v2 or later",
    layer     = 1001,
    enabled   = true,
  }
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local GetUnitDefID      = Spring.GetUnitDefID
local GetUnitHealth     = Spring.GetUnitHealth
local GetUnitStates     = Spring.GetUnitStates
local GetUnitRulesParam	= Spring.GetUnitRulesParam
local DrawUnitCommands  = Spring.DrawUnitCommands
local GetSelectedUnits  = Spring.GetSelectedUnits
local GetFullBuildQueue = Spring.GetFullBuildQueue
local GetUnitIsBuilding = Spring.GetUnitIsBuilding
local GetGameSeconds	= Spring.GetGameSeconds
local GetGameFrame 		= Spring.GetGameFrame
local GetModKeyState	= Spring.GetModKeyState
local SelectUnitArray	= Spring.SelectUnitArray

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local buttonColorRed = {1,0,0,1}
local buttonColorGreen = {0,1,0.2,1}
local buttonColorYellow = {1,1,0,1}
local buttonColorBlue = {0,0.2,1,1}
local buttonAlphaDeselected = 0.7

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Chili
local Button
local Label
local Window
local Panel
local StackPanel
local ScrollPanel
local Image
local Progressbar
local screen0
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local window_status, scroll_main
local stack_angels, stack_ally, stack_neutral, stack_enemy

local echo = Spring.Echo

local BUTTON_WIDTH = 64
local BUTTON_HEIGHT = 52
--local BASE_COLUMNS = 6
--local NUM_FAC_COLUMNS = BASE_COLUMNS - 1	-- unused

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local UPDATE_FREQUENCY = 0.25

local angelDefs = {
  [UnitDefNames.luckystar.id] = {hasSpirit = true},
  [UnitDefNames.kungfufighter.id] = {hasSpirit = true},
  [UnitDefNames.happytrigger.id] = {hasSpirit = true},
}

local hasEnergyDefs = {}
local suppressionImmuneDefs = {}

for i=1,#UnitDefs do
	local energy = UnitDefs[i].customParams.energy
	hasEnergyDefs[i] = tonumber(energy)
	suppressionImmuneDefs[i] = UnitDefs[i].customParams.suppressionimmune
end

local exceptionList = {}

local exceptionArray = {}
for name in pairs(exceptionList) do
	if UnitDefNames[name] then
		exceptionArray[UnitDefNames[name].id] = true
	end
end

local currentStack
local stacks, buttons

options_path = 'Settings/HUD Panels/Ship Status'
options_order = {}
options = {}

-- list and interface vars
local unitsByID = {}	-- [unitID] = index
local units = {} -- [index] = {unitID, unitDefID, panel, button, image, [healthbar] = ProgressBar, [energybar] = ProgressBar, [spiritbar] = ProgressBar}

--local gamestart = GetGameFrame() > 1

-------------------------------------------------------------------------------

local teamColors = {}
local GetTeamColor = Spring.GetTeamColor or function (teamID)
  local color = teamColors[teamID]
  if (color) then return unpack(color) end
  local _,_,_,_,_,_,r,g,b = Spring.GetTeamInfo(teamID)
  teamColors[teamID] = {r,g,b}
  return r,g,b
end

-------------------------------------------------------------------------------
-- SCREENSIZE FUNCTIONS
-------------------------------------------------------------------------------
local vsx, vsy   = widgetHandler:GetViewSizes()

function widget:ViewResize(viewSizeX, viewSizeY)
  vsx = viewSizeX
  vsy = viewSizeY
end

-------------------------------------------------------------------------------
-- helper funcs

local function SetCount(set, numOnly)
	local count = 0
	if numOnly then
		for i=1,#set do
			count = count + 1
		end
	else
		for k in pairs(set) do
			count = count + 1
		end	
	end
	return count
end

local function CountButtons(set)
	local count = 0
	for _,data in pairs(set) do
		if data.button then
			count = count + 1
		end
	end
	return count
end

local function GetHealthColor(fraction, returnType)
	local midpt = (fraction > .5)
	local r, g
	if midpt then 
		r = ((1-fraction)/0.5)
		g = 1
	else
		r = 1
		g = (fraction)/0.5
	end
	if returnType == "char" then
		return string.char(255,math.floor(255*r),math.floor(255*g),0)
	end
	return {r, g, 0, 1}
end

-------------------------------------------------------------------------------
-- core functions

local function AddUnitDisplay(unitID, unitDefID, index, hotkey, parent, persistent)
	local numBars = 0
	units[index].persistent = persistent

	units[index].panel = Panel:New{
		parent = parent,
		width = "100%",
		height = 64,
		backgroundColor = {0, 0, 0, 0},
	}
	
	units[index].button = Button:New{
		parent = units[index].panel;
		x = 0,
		y = 0,
		width = 64,
		height = "100%",
		caption = '',
		padding = {1,1,1,1},
		--keepAspect = true,
		backgroundColor = buttonColor,
		OnClick = { function (self, x, y, mouse)
			if units[index].isDestroyed then
				return
			end
			local alt,_,_,shift = GetModKeyState()
			if alt then
				WG.CreateStatsWindow(unitID, unitDefID)
				return
			end
			SelectUnitArray({unitID}, shift)
			if mouse == 1 then
				local x, y, z = Spring.GetUnitPosition(unitID)
				Spring.SetCameraTarget(x, y, z)
			end
		end},
		OnDblClick = { function()
			if units[index].isDestroyed then
				return
			end
			if WG.SetThirdPersonTrackUnit then
				WG.SetThirdPersonTrackUnit(unitID)
			end
		end},
		tooltip = "Left click: Select and go to\nRight click: Select\nDouble-click: Lock camera (controllable units only)\nShift+click: Append to current selection\nAlt+click: Open info window",
	}
	if (hotkey ~= nil) then 
		Label:New {
			autosize=false;
			x=2,
			y=3,
			align="left";
			valign="top";
			caption = '\255\0\255\0'..hotkey,
			fontSize = 11;
			fontShadow = true;
			parent = units[index].button
		}
	end 
	
	units[index].image = Image:New {
		parent = units[index].button,
		width="91%";
		height="91%";
		x="5%";
		y="5%";
		file = '#'..unitDefID,	-- FIXME
		keepAspect = false,
	}
	
	Label:New{
		parent = units[index].panel,
		autosize=false;
		x = 68,
		y = 1+numBars*25 .. "%",
		caption = 'H',
		fontSize = 10;
		fontShadow = true;
		valign = "ascender",
	}
	units[index].healthbar = Progressbar:New{
		parent  = units[index].panel,
		x	= 80,
		y 	= numBars*25 .. "%",
		right	= 0,
		height	= "25%",
		max     = 1;
		caption = "";
		color   = {0,0.8,0,1};
	}
	numBars = numBars + 1
	if hasEnergyDefs[unitDefID] then
		Label:New{
			parent = units[index].panel,
			autosize=false;
			x = 68,
			y = 1+numBars*25 .. "%",
			caption = 'E',
			fontSize = 10;
			fontShadow = true;
			valign = "ascender",
		}
		units[index].energybar = Progressbar:New{
			parent  = units[index].panel,
			x	= 80,
			y 	= numBars*25 .. "%",
			right	= 0,
			height	= "25%",
			max     = 1;
			caption = "";
			color   = {1,1,0,1};
		}
		numBars = numBars + 1
	end
	if angelDefs[unitDefID] and angelDefs[unitDefID].hasSpirit then
		Label:New{
			parent = units[index].panel,
			autosize=false;
			x = 68,
			y = 1+numBars*25 .. "%",
			caption = 'S',
			fontSize = 10;
			fontShadow = true;
			valign = "ascender",
		}
		units[index].spiritbar = Progressbar:New{
			parent  = units[index].panel,
			x	= 80,
			y 	= numBars*25 .. "%",
			right	= 0,
			height	= "25%",
			max     = 100;
			caption = "";
			color   = {0,0.5,1,1};
		}
		numBars = numBars + 1
	end
	if not suppressionImmuneDefs[unitDefID] then
		Label:New{
			parent = units[index].panel,
			autosize=false;
			x = 68,
			y = 1+numBars*25 .. "%",
			caption = '!',
			fontSize = 10;
			fontShadow = true;
			valign = "ascender",
		}
		units[index].suppressionbar = Progressbar:New{
			parent  = units[index].panel,
			x	= 80,
			y 	= numBars*25 .. "%",
			right	= 0,
			height	= "25%",
			max     = 1;
			caption = "";
			color   = {1,0,0,1};
		}
		numBars = numBars + 1
	end
end

local function UpdateUnitInfo(unitID)
	local index = unitsByID[unitID]
	if not units[index].panel or units[index].isDestroyed then
		return
	end
	
	local health, maxHealth = GetUnitHealth(unitID)
	if not health then
		return
	end
	local spirit = GetUnitRulesParam(unitID, "spirit") or 0
	local energy = GetUnitRulesParam(unitID, "energy") or 0
	local suppression = GetUnitRulesParam(unitID, "suppression") or 0

	units[index].healthbar.color = GetHealthColor(health/maxHealth)
	units[index].healthbar:SetValue(health/maxHealth)
	--units[index].healthbar:SetCaption(math.floor(health*100/maxHealth) .. "%")
	if units[index].spiritbar then
		units[index].spiritbar:SetValue(spirit)
	end
	if units[index].energybar then
		units[index].energybar:SetValue(energy)
	end
	if units[index].suppressionbar then
		units[index].suppressionbar:SetValue(suppression)
	end
	
	--[[
	units[index].button.tooltip = "Commander: "..UnitDefs[comms[index].commDefID].humanName ..
							"\n\255\0\255\255Health:\008 "..GetHealthColor(health/maxHealth, "char")..math.floor(health).."/"..maxHealth.."\008"..
							"\n\255\0\255\0Left-click: Select and go to"..
							"\nRight-click: Select"..
							"\nShift: Append to current selection\008"
	]]
end


local function AddUnit(unitID, unitDefID, teamID)
	local parent = stack_neutral
	if not Spring.IsUnitAllied(unitID) then
		parent = stack_enemy
	else
		if angelDefs[unitDefID] then
			parent = stack_angels
		end
	end

	local index = #units + 1
	unitsByID[unitID] = index
	units[index] = {unitID = unitID, unitDefID = unitDefID}
	AddUnitDisplay(unitID, unitDefID, index, '', parent, parent == stack_angels)	-- FIXME hotkey
	UpdateUnitInfo(unitID)
end

local function RemoveUnit(unitID)
	-- TBD blackout angels instead of removing them
	local index = unitsByID[unitID]
	if units[index].persistent then
		-- do stuff
		units[index].isDestroyed = true
		units[index].button.color = {0.3, 0.3, 0.3, 1}
		units[index].image.color = {0.3, 0.3, 0.3, 1}
		units[index].healthbar:SetValue(0)
		if units[index].energybar then
			units[index].energybar:SetValue(0)
		end
		if units[index].spiritbar then
			units[index].spiritbar:SetValue(0)
		end
		units[index].button:Invalidate()
		units[index].image:Invalidate()
	else
		if units[index].panel then
			units[index].panel:Dispose()
		end
		table.remove(units, index)
		for id, i in pairs(unitsByID) do
			if i > index then
				unitsByID[id] = i - 1
			end
		end
	end
	unitsByID[unitID] = nil
end

local function InitializeUnits()
	local unitList = Spring.GetAllUnits()
	for _,unitID in pairs(unitList) do
		local unitDefID = GetUnitDefID(unitID)
		local teamID = Spring.GetUnitTeam(unitID)
		--Spring.Echo(unitID, unitDefID)
		if unitDefID then
			widget:UnitCreated(unitID, unitDefID, teamID)
			widget:UnitFinished(unitID, unitDefID, teamID)
		end
	end
end

local function ClearData()
	for unitID in pairs(units) do
		RemoveUnit(unitID)
	end
end

local function SetCurrentStack(stackName)
	local stack = stacks[stackName]
	if stack ~= currentStack then
		scroll_main:RemoveChild(currentStack)
		scroll_main:AddChild(stack)
		currentStack = stack
	end
	for name,button in pairs(buttons) do
		if name == stackName then
			button.backgroundColor[4] = 1
		else
			button.backgroundColor[4] = buttonAlphaDeselected
		end
		button:Invalidate()
	end
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- engine callins

--[[
function widget:GameStart()
	gamestart = true
end
]]--

function widget:UnitCreated(unitID, unitDefID, unitTeam)
	AddUnit(unitID, unitDefID, unitTeam)
end

function widget:UnitFinished(unitID, unitDefID, unitTeam)
end

function widget:UnitGiven(unitID, unitDefID, unitTeam, oldTeam)
	widget:UnitCreated(unitID, unitDefID, unitTeam)
	widget:UnitFinished(unitID, unitDefID, unitTeam)  
end

function widget:UnitDestroyed(unitID, unitDefID, unitTeam)
	if unitsByID[unitID] then
		RemoveUnit(unitID)
	end
end

function widget:UnitTaken(unitID, unitDefID, unitTeam, newTeam)
	widget:UnitDestroyed(unitID, unitDefID, unitTeam)
end

local timer = 0
local warningColorPhase = false
function widget:Update(dt)
	timer = timer + dt
	if timer < UPDATE_FREQUENCY then
		return
	end
	
	for unitID in pairs(unitsByID) do
		UpdateUnitInfo(unitID)
	end
	warningColorPhase = not warningColorPhase
	--[[
	for i=1,#comms do
		local comm = comms[i]
		if comm.button and comm.warningTime > 0 then
			comm.warningTime = comm.warningTime - timer
			if comm.warningTime > 0 then
				comms[i].button.backgroundColor = (warningColorPhase and buttonColorWarning) or buttonColor
			else
				comms[i].button.backgroundColor = buttonColor
			end
			comms[i].button:Invalidate()
		end
	end
	]]--
	timer = 0
end


function widget:UnitDamaged(unitID, unitDefID, unitTeam)
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function widget:Initialize()
	if (not WG.Chili) then
		widgetHandler:RemoveWidget(widget)
		return
	end
	
	-- setup Chili
	Chili = WG.Chili
	Button = Chili.Button
	Label = Chili.Label
	Window = Chili.Window
	Panel = Chili.Panel
	StackPanel = Chili.StackPanel
	ScrollPanel = Chili.ScrollPanel
	Image = Chili.Image
	Progressbar = Chili.Progressbar
	screen0 = Chili.Screen0
	
	window_status = Window:New{
		padding = {0,0,0,0},
		itemMargin = {0, 0, 0, 0},
		dockable = true,
		name = "ship_status_window",
		x = 0,
		bottom = 0,
		width  = 160,
		height = 320,
		parent = Chili.Screen0,
		draggable = false,
		tweakDraggable = true,
		tweakResizable = false,
		resizable = false,
		dragUseGrip = false,
		color = {0,0,0,0},
		OnMouseDown={ function(self)
			local alt, ctrl, meta, shift = Spring.GetModKeyState()
			if not meta then return false end
			WG.crude.OpenPath(options_path)
			WG.crude.ShowMenu()
			return true
		end },
	}
	scroll_main = ScrollPanel:New{
		parent = window_status,
		x = 0,
		y = 32,
		width = "100%",
		bottom = 0,
		--backgroundColor = {0,0,0,0},
	}
	stack_angels = StackPanel:New{
		parent = scroll_main,
		padding = {0,0,0,0},
		itemMargin = {0, 0, 0, 0},
		width= '100%',
		backgroundColor = {0, 0, 0, 0},
		resizeItems = false,
		orientation = 'vertical',
		autosize = true,
	}
	stack_ally = StackPanel:New{
		--parent = scroll_main,
		padding = {0,0,0,0},
		itemMargin = {0, 0, 0, 0},
		width= '100%',
		backgroundColor = {0, 0, 0, 0},
		resizeItems = false,
		orientation = 'vertical',
		autosize = true,
	}
	stack_neutral = StackPanel:New{
		--parent = scroll_main,
		padding = {0,0,0,0},
		itemMargin = {0, 0, 0, 0},
		width= '100%',
		backgroundColor = {0, 0, 0, 0},
		resizeItems = false,
		orientation = 'vertical',
		autosize = true,
	}
	stack_enemy = StackPanel:New{
		--parent = scroll_main,
		padding = {0,0,0,0},
		itemMargin = {0, 0, 0, 0},
		width= '100%',
		backgroundColor = {0, 0, 0, 0},
		resizeItems = false,
		orientation = 'vertical',
		autosize = true,
	}
	button_angels = Button:New{
		parent = window_status;
		x = 0,
		y = 0,
		width = "50%",
		height = 16,
		caption = '',
		OnClick = {function() SetCurrentStack("angels") end},
		backgroundColor = buttonColorBlue,
	}
	button_ally = Button:New{
		parent = window_status;
		x = "50%",
		y = 0,
		width = "50%",
		height = 16,
		caption = '',
		OnClick = {function() SetCurrentStack("ally") end},
		backgroundColor = buttonColorGreen,
	}
	button_neutral = Button:New{
		parent = window_status;
		x = 0,
		y = 16,
		width = "50%",
		height = 16,
		caption = '',
		OnClick = {function() SetCurrentStack("neutral") end},
		backgroundColor = buttonColorYellow,
	}
	button_enemy = Button:New{
		parent = window_status;
		x = "50%",
		y = 16,
		width = "50%",
		height = 16,
		caption = '',
		OnClick= {function() SetCurrentStack("enemy") end},
		backgroundColor = buttonColorRed,
	}
	stacks = {angels = stack_angels, ally = stack_ally, neutral = stack_neutral, enemy = stack_enemy}
	buttons = {angels = button_angels, ally = button_ally, neutral = button_neutral, enemy = button_enemy}
	currentStack = stack_angels
	SetCurrentStack("angels")
	
	local viewSizeX, viewSizeY = widgetHandler:GetViewSizes()
	self:ViewResize(viewSizeX, viewSizeY)
	
	InitializeUnits()
end

function widget:Shutdown()
end
