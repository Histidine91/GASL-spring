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
local buttonAlphaDeselected = 0.4
local damageColor1 = {1,0.2,0.2,0.7}
local damageColor2 = {1,0.2,0.2,0.5}
local swirlColor1 = {1,1,0.5,0.5}
local swirlColor2 = {1,1,0.5,0.2}

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
local BUTTON_OVERLAY_X = (BUTTON_WIDTH-4)/2
local BUTTON_OVERLAY_Y = (BUTTON_HEIGHT-4)/2

--local damageWarningPing	-- display list

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
local UPDATE_FREQUENCY = 0.25
local DAMAGE_WARNING_PERIOD = 0.7
local DAMAGE_WARNING_MIN_SIZE_MOD = 0.3
local DAMAGE_WARNING_SIZE_RATIO = 0.5	-- inner ring vs. outer ring
local SPIRIT_SWIRL_SIZE_RATIO = 0.2
local SPIRIT_SWIRL_PERIOD = 1

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
local units = {} -- [index] = {unitID, unitDefID, panel, button, image, [healthbar] = ProgressBar, [energybar] = ProgressBar, [spiritbar] = ProgressBar, [suppressionbar] = ...}
local overlayPhase = 0
local spiritSwirls = {}	-- [unitID] = phase

--local gamestart = GetGameFrame() > 1

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- FUNCTIONS
-------------------------------------------------------------------------------
-- drawing stuff

local vsx, vsy   = widgetHandler:GetViewSizes()

function widget:ViewResize(viewSizeX, viewSizeY)
  vsx = viewSizeX
  vsy = viewSizeY
end

local function PingOrSwirl(vx, vy, color1, color2, sizeRatio)
	gl.Color(color1)
	gl.Vertex(-vx*sizeRatio,vy*sizeRatio,0)
	gl.Vertex(vx*sizeRatio,vy*sizeRatio,0)
	gl.Color(color2)
	gl.Vertex(vx,vy,0)
	gl.Vertex(-vx,vy,0)
	
	gl.Color(color1)
	gl.Vertex(vx*sizeRatio,vy*sizeRatio,0)
	gl.Vertex(vx*sizeRatio,-vy*sizeRatio,0)
	gl.Color(color2)
	gl.Vertex(vx,-vy,0)
	gl.Vertex(vx,vy,0)
	
	gl.Color(color1)
	gl.Vertex(vx*sizeRatio,-vy*sizeRatio,0)
	gl.Vertex(-vx*sizeRatio,-vy*sizeRatio,0)
	gl.Color(color2)
	gl.Vertex(-vx,-vy,0)
	gl.Vertex(vx,-vy,0)
	
	gl.Color(color1)
	gl.Vertex(-vx*sizeRatio,-vy*sizeRatio,0)
	gl.Vertex(-vx*sizeRatio,vy*sizeRatio,0)
	gl.Color(color2)
	gl.Vertex(-vx,vy,0)
	gl.Vertex(-vx,-vy,0)
end

local function SpiritGlow()
	gl.Vertex(-BUTTON_OVERLAY_X,-BUTTON_OVERLAY_Y,0)
	gl.Vertex(BUTTON_OVERLAY_X,-BUTTON_OVERLAY_Y,0)
	gl.Vertex(BUTTON_OVERLAY_X,BUTTON_OVERLAY_Y,0)
	gl.Vertex(-BUTTON_OVERLAY_X,BUTTON_OVERLAY_Y,0)
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
		OnClick = { function (self, x, y, mouse)
			if units[index].isDead then
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
			if units[index].isDead then
				return
			end
			if WG.SetThirdPersonTrackUnit then
				WG.SetThirdPersonTrackUnit(unitID)
			end
		end},
		tooltip = "\255\0\255\0" .. UnitDefs[unitDefID].humanName .. "\008\n"..
			"Left click: Select and go to\n"..
			"Right click: Select\n"..
			"Double-click: Lock camera (controllable units only)\n"..
			"Shift+click: Append to current selection\n"..
			"Alt+click: Open info window",
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
		width="90%";
		height="90%";
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
		units[index].energyLowIndicator = Image:New{
			--parent = units[index].image,
			width = 24,
			height = 24,
			right = 0,
			bottom = 0,
			file = "LuaUI/Images/energy.png",
			hidden = true
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
	local unitData = units[index]
	if (not unitData.panel) or unitData.isDead then
		return
	end
	
	local health, maxHealth = GetUnitHealth(unitID)
	if not health then
		return
	end
	local spirit = GetUnitRulesParam(unitID, "spirit") or 0
	local energy = GetUnitRulesParam(unitID, "energy")
	local suppression = GetUnitRulesParam(unitID, "suppression") or 0

	unitData.healthbar.color = GetHealthColor(health/maxHealth)
	unitData.healthbar:SetValue(health/maxHealth)
	if unitData.spiritbar then
		unitData.spiritbar:SetValue(spirit)
	end
	if unitData.energybar then
		unitData.energybar:SetValue(energy or 0)
	end
	if unitData.suppressionbar then
		unitData.suppressionbar:SetValue(suppression)
	end
	
	
	if energy then
		if energy <= 0.3 then
			if unitData.energyLowIndicator.hidden then
				unitData.image:AddChild(unitData.energyLowIndicator)
				unitData.energyLowIndicator.hidden = false
			end
		elseif (not unitData.energyLowIndicator.hidden) then
			unitData.image:RemoveChild(unitData.energyLowIndicator)
			unitData.energyLowIndicator.hidden = true
		end
	end
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
	units[index] = {unitID = unitID, unitDefID = unitDefID, parent = parent}
	AddUnitDisplay(unitID, unitDefID, index, '', parent, parent == stack_angels)	-- FIXME hotkey
	UpdateUnitInfo(unitID)
end

local function RemoveUnit(unitID)
	local index = unitsByID[unitID]
	local unitData = units[index]
	if unitData.persistent then
		-- do stuff
		unitData.isDead = true
		unitData.button.color = {0.3, 0.3, 0.3, 1}
		unitData.image.color = {0.3, 0.3, 0.3, 1}
		unitData.healthbar:SetValue(0)
		if unitData.energybar then
			unitData.energybar:SetValue(0)
		end
		if unitData.spiritbar then
			unitData.spiritbar:SetValue(0)
		end
		if unitData.suppressionbar then
			unitData.suppressionbar:SetValue(0)
		end
		unitData.button:Invalidate()
		unitData.image:Invalidate()
	else
		if unitData.panel then
			unitData.panel:Dispose()
		end
		table.remove(units, index)
		for id, i in pairs(unitsByID) do
			if i > index then
				unitsByID[id] = i - 1
			end
		end
	end
	unitsByID[unitID] = nil
	spiritSwirls[unitID] = nil
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

local function SpiritFull(unitID)
	if unitsByID[unitID] then
		spiritSwirls[unitID] = 1
	end
end

local function DrawWarningFlash(x, y)
	--TODO make display list ?
	gl.PushMatrix()
	gl.Translate(x,y,0)
	local size = DAMAGE_WARNING_MIN_SIZE_MOD+(1-DAMAGE_WARNING_MIN_SIZE_MOD)*overlayPhase
	local vx = BUTTON_OVERLAY_X*size
	local vy = BUTTON_OVERLAY_Y*size
	gl.BeginEnd(GL.QUADS, PingOrSwirl, vx, vy, damageColor1, damageColor2, DAMAGE_WARNING_SIZE_RATIO)
	gl.PopMatrix()
end

local function DrawSpiritGlow(x,y)
	gl.PushMatrix()
	gl.Translate(x,y,0)
	gl.Color(1,1,0.4,0.7*math.sin(overlayPhase*math.pi))
	gl.BeginEnd(GL.QUADS, SpiritGlow)
	gl.PopMatrix()
end

local function DrawSpiritSwirl(x,y,phase)
	local size = (phase*5 + 1)
	local vx = BUTTON_OVERLAY_X*size
	local vy = BUTTON_OVERLAY_X*size
	gl.PushMatrix()
	gl.Translate(x,y,0)
	gl.Rotate(phase*180,0,0,1)
	gl.BeginEnd(GL.QUADS, PingOrSwirl, vx, vy, swirlColor1, swirlColor2, SPIRIT_SWIRL_SIZE_RATIO)
	gl.PopMatrix()
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
function widget:Update(dt)
	overlayPhase = (overlayPhase + dt/DAMAGE_WARNING_PERIOD)%1
	for unitID, phase in pairs(spiritSwirls) do
		if phase <= 0 then
			spiritSwirls[unitID] = nil
		else
			spiritSwirls[unitID] = phase - dt/SPIRIT_SWIRL_PERIOD
		end
	end
	
	timer = timer + dt
	if timer < UPDATE_FREQUENCY then
		return
	end
	
	for unitID in pairs(unitsByID) do
		UpdateUnitInfo(unitID)
	end
	timer = 0
end

function widget:DrawScreen()
	for i=1,#units do
		local unitData = units[i]
		if unitData.parent == currentStack and (not unitData.isDead) then
			local x, y = unitData.button:LocalToScreen(BUTTON_WIDTH/2, BUTTON_HEIGHT/2)
			y = screen0.height - y
			if currentStack ~= stack_enemy then
				local health = unitData.healthbar.value
				if health <= 0.3 then
					DrawWarningFlash(x, y)
				end
			end
			if unitData.spiritbar and unitData.spiritbar.value == 100 then
				DrawSpiritGlow(x, y)
			end
			local swirlPhase = spiritSwirls[unitData.unitID]
			if swirlPhase then
				DrawSpiritSwirl(x, y, swirlPhase)
			end
		end
		
	end
	gl.Color(1,1,1,1)
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
	
	widgetHandler:RegisterGlobal("SpiritFullEvent", SpiritFull)
end

function widget:Shutdown()
	widgetHandler:DeregisterGlobal("SpiritFullEvent")
end