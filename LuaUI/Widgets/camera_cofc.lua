--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "Combo Overhead/Free Camera (experimental)",
    desc      = "v0.121 Camera featuring 6 actions. Type \255\90\90\255/luaui cofc help\255\255\255\255 for help.",
    author    = "CarRepairer, msafwan",
    date      = "2011-03-16", --2013-June-30
    license   = "GNU GPL, v2 or later",
    layer     = 1002,
    handler   = true,
    enabled   = true,
  }
end

include("keysym.h.lua")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local init = true
local trackmode = false --before options
local thirdPerson_trackunit = nil

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

options_path = 'Settings/Camera/Camera Controls'
local cameraFollowPath = 'Settings/Camera/Camera Following'
options_order = { 
	'helpwindow', 
	
	'lblRotate',
	'targetmouse', 
	'rotateonedge', 
	'rotfactor',
    'inverttilt',
    'groundrot',
	
	'lblScroll',
	'edgemove', 
	'smoothscroll',
	'speedFactor', 
	'speedFactor_k', 
	'invertscroll', 
	'smoothmeshscroll', 
	
	'lblZoom',
	'invertzoom', 
	'invertalt', 
	'zoomintocursor', 
	'zoomoutfromcursor', 
	'zoominfactor', 
	'zoomoutfactor',
	
	'lblMisc',
	'overviewmode', 
	'smoothness',
	'fov',
	--'restrictangle',
	--'mingrounddist',
	'resetcam',
	
	--following:
	
	'lblFollowCursor',
	'follow',
	'followautozoom',
	'followminscrollspeed',
	'followmaxscrollspeed',
	--'followzoominspeed',
	--'followzoomoutspeed',
	
	'lblFollowUnit',
	'trackmode',
	'persistenttrackmode',
	'thirdpersontrack',
	
	'lblMisc2',
	'enableCycleView',

}

local OverviewAction = function() end
local SetFOV = function(fov) end
local SelectNextPlayer = function() end

options = {
	
	lblblank1 = {name='', type='label'},
	lblRotate = {name='Rotation', type='label'},
	lblScroll = {name='Scrolling', type='label'},
	lblZoom = {name='Zooming', type='label'},
	lblMisc = {name='Misc.', type='label'},
	
	lblFollowCursor = {name='Cursor Following', type='label', path=cameraFollowPath},
	lblFollowUnit = {name='Unit Following', type='label', path=cameraFollowPath},
	lblMisc2 = {name='Misc.', type='label', path = cameraFollowPath},
	
	
	helpwindow = {
		name = 'COFCam Help',
		type = 'text',
		value = [[
			Complete Overhead/Free Camera has six main actions...
			
			Zoom..... <Mousewheel>
			Tilt World..... <Ctrl> + <Mousewheel>
			Altitude..... <Alt> + <Mousewheel>
			Mouse Scroll..... <Middlebutton-drag>
			Rotate World..... <Ctrl> + <Middlebutton-drag>
			Rotate Camera..... <Alt> + <Middlebutton-drag>
			
			Additional actions:
			Keyboard: <arrow keys> replicate middlebutton drag while <pgup/pgdn> replicate mousewheel. You can use these with ctrl, alt & shift to replicate mouse camera actions.
			Use <Shift> to speed up camera movements.
			Reset Camera..... <Ctrl> + <Alt> + <Middleclick>
		]],
	},
	smoothscroll = {
		name = 'Smooth scrolling',
		desc = 'Use smoothscroll method when mouse scrolling.',
		type = 'bool',
		value = true,
	},
	smoothmeshscroll = {
		name = 'Smooth Mesh Scrolling',
		desc = 'A smoother way to scroll. Applies to all types of mouse/keyboard scrolling.',
		type = 'bool',
		value = false,
	},
	
	targetmouse = {
		name = 'Rotate world origin at cursor',
		desc = 'Rotate world using origin at the cursor rather than the center of screen.',
		type = 'bool',
		value = false,
	},
	edgemove = {
		name = 'Scroll camera at edge',
		desc = 'Scroll camera when the cursor is at the edge of the screen.',
		springsetting = 'WindowedEdgeMove',
		type = 'bool',
		value = true,
		
	},
	speedFactor = {
		name = 'Mouse scroll speed',
		desc = 'This speed applies to scrolling with the middle button.',
		type = 'number',
		min = 10, max = 40,
		value = 25,
	},
	speedFactor_k = {
		name = 'Keyboard/edge scroll speed',
		desc = 'This speed applies to edge scrolling and keyboard keys.',
		type = 'number',
		min = 1, max = 50,
		value = 20,
	},
	zoominfactor = {
		name = 'Zoom-in speed',
		type = 'number',
		min = 0.1, max = 0.5, step = 0.05,
		value = 0.2,
	},
	zoomoutfactor = {
		name = 'Zoom-out speed',
		type = 'number',
		min = 0.1, max = 0.5, step = 0.05,
		value = 0.2,
	},
	invertzoom = {
		name = 'Invert zoom',
		desc = 'Invert the scroll wheel direction for zooming.',
		type = 'bool',
		value = true,
	},
	invertalt = {
		name = 'Invert altitude',
		desc = 'Invert the scroll wheel direction for altitude.',
		type = 'bool',
		value = false,
	},
    inverttilt = {
		name = 'Invert tilt',
		desc = 'Invert the tilt direction when using ctrl+mousewheel.',
		type = 'bool',
		value = false,
	},
    
	zoomoutfromcursor = {
		name = 'Zoom out from cursor',
		desc = 'Zoom out from the cursor rather than center of the screen.',
		type = 'bool',
		value = false,
	},
	zoomintocursor = {
		name = 'Zoom in to cursor',
		desc = 'Zoom in to the cursor rather than the center of the screen.',
		type = 'bool',
		value = true,
	},
	
	
	rotfactor = {
		name = 'Rotation speed',
		type = 'number',
		min = 0.001, max = 0.020, step = 0.001,
		value = 0.005,
	},	
	rotateonedge = {
		name = "Rotate camera at edge",
		desc = "Rotate camera when the cursor is at the edge of the screen (edge scroll must be off).",
		type = 'bool',
		value = false,
	},
    
	smoothness = {
		name = 'Smoothness',
		desc = "Controls how smooth the camera moves.",
		type = 'number',
		min = 0.0, max = 0.8, step = 0.1,
		value = 0.2,
	},
	fov = {
		name = 'Field of View (Degrees)',
		--desc = "FOV (25 deg - 100 deg).",
		type = 'number',
		min = 10, max = 100, step = 5,
		value = Spring.GetCameraFOV(),
		springsetting = 'CamFreeFOV', --save stuff in springsetting. reference: epicmenu_conf.lua
		OnChange = function(self) SetFOV(self.value) end
	},
	invertscroll = {
		name = "Invert scrolling direction",
		desc = "Invert scrolling direction (doesn't apply to smoothscroll).",
		type = 'bool',
		value = false,
	},
	restrictangle = {
		name = "Restrict Camera Angle",
		desc = "If disabled you can point the camera upward, but end up with strange camera positioning.",
		type = 'bool',
		advanced = true,
		value = true,
		OnChange = function(self) init = true; end
	},
	
	overviewmode = {
		name = "COFC Overview",
		desc = "Go to overview mode, then restore view to cursor position.",
		type = 'button',
		hotkey = {key='tab', mod=''},
		OnChange = function(self) OverviewAction() end,
	},
	resetcam = {
		name = "Reset Camera",
		desc = "Reset the camera position and orientation. Map a hotkey or use <Ctrl> + <Alt> + <Middleclick>",
		type = 'button',
        -- OnChange defined later
	},
	groundrot = {
		name = "Rotate When Camera Hits Ground",
		desc = "If world-rotation motion causes the camera to hit the ground, camera-rotation motion takes over. Doesn't apply in Free Mode.",
		type = 'bool',
		value = false,
	},
	
	
	
	-- follow cursor
	follow = {
		name = "Follow player's cursor",
		desc = "Follow the cursor of the player you're spectating (needs Ally Cursor widget to be on). Mouse midclick to pause tracking for 4 second.",
		type = 'bool',
		value = false,
		hotkey = {key='l', mod='alt+'},
		path = cameraFollowPath,
		OnChange = function(self) Spring.Echo("COFC: follow cursor " .. (self.value and "active" or "inactive")) end,		
	},
	followautozoom = {
		name = "Auto zoom",
		desc = "Auto zoom in and out while following player's cursor (zoom level will represent player's focus). \n\nDO NOT enable this if you want to control the zoom level yourself. If enabled, try to use the recommended follow cursor speed.",
		type = 'bool',
		value = false,
		path = cameraFollowPath,
	},
	followminscrollspeed = {
		name = "On Screen Follow Speed",
		desc = "Follow speed for on-screen cursor. \n\nRecommend: Lowest (prevent jerky movement)",
		type = 'number',
		min = 1, max = 14, step = 1,
		mid = ((14-1)/2) + 1,
		value = 1,
		path = cameraFollowPath,
	},	
	followmaxscrollspeed = {
		name = "Off Screen Follow Speed",
		desc = "Follow speed for off-screen cursor. \n\nRecommend: Highest (prevent missed action), faster tracking during auto-zoom will also prevent auto-zoom from zooming out too far",
		type = 'number',
		min = 2, max = 15, step = 1,
		mid = ((15-2)/2) + 2,
		value = 15,
		path = cameraFollowPath,
	},
	followzoominspeed = {
		name = "Follow Zoom-in Speed",
		desc = "Zoom-in speed (only when auto-zoom is enabled). \n\nRecommend: Low (better leave this option to low for smoother zoom. Tweak follow speed instead!)",
		type = 'number',
		min = 0.1, max = 0.5, step = 0.05,
		value = 0.2,
		path = cameraFollowPath,
	},
	followzoomoutspeed = {
		name = "Follow Zoom-out Speed",
		desc = "Zoom-out speed (only when auto-zoom is enabled). \n\nRecommend: Low (better leave this option to low for smoother zoom. Use faster follow speed to prevent zoom-out)",
		type = 'number',
		min = 0.1, max = 0.5, step = 0.05,
		value = 0.2,
		path = cameraFollowPath,
	},
	-- end follow cursor
	
	-- follow unit
	trackmode = {
		name = "Activate Trackmode",
		desc = "Track the selected unit (mouse midclick to exit mode)",
		type = 'button',
        hotkey = {key='t', mod='alt+'},
		path = cameraFollowPath,
		OnChange = function(self) trackmode = true; Spring.Echo("COFC: Unit tracking ON") end,
	},
	
	persistenttrackmode = {
		name = "Persistent trackmode state",
		desc = "Trackmode will not cancel when deselecting unit. Trackmode will always attempt to track newly selected unit. Press mouse midclick to cancel this mode.",
		type = 'bool',
		value = false,
		path = cameraFollowPath,
	},
    
    thirdpersontrack = {
		name = "Enter 3rd Person Trackmode",
		desc = "3rd Person track the selected unit (mouse midclick to exit mode).",
		type = 'button',
		hotkey = {key='k', mod='alt+'},
		path = cameraFollowPath,
		OnChange = function(self)
			local selUnits = Spring.GetSelectedUnits()
			if selUnits and selUnits[1] and thirdPerson_trackunit ~= selUnits[1] then --check if 3rd Person into same unit or if there's any unit at all
				--Spring.SendCommands("track")
				--Spring.SendCommands("viewfps")
				thirdPerson_trackunit = selUnits[1]
				TrackUnit(thirdPerson_trackunit)
			else
				--Spring.SendCommands("trackoff")
				thirdPerson_trackunit = nil
				--Spring.SendCommands("viewfree")
			end
        end,
	},
	
	enableCycleView = {
		name = "Group recall cycle within group",
		type = 'bool',
		value = false,
		path = cameraFollowPath,
		desc = "Tap the same group numbers to focus camera view toward each units within the same group. This option use \'Receive Indicator\' widget to intelligently cycle focus when appropriate.",
		OnChange = function(self) 
			if self.value==true then
				Spring.SendCommands("luaui enablewidget Receive Units Indicator")
			end
		end,
	},
	-- end follow unit
	
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local GL_LINES		= GL.LINES
local GL_GREATER	= GL.GREATER
local GL_POINTS		= GL.POINTS

local glBeginEnd	= gl.BeginEnd
local glColor		= gl.Color
local glLineWidth	= gl.LineWidth
local glVertex		= gl.Vertex
local glAlphaTest	= gl.AlphaTest
local glPointSize 	= gl.PointSize
local glTexture 	= gl.Texture
local glTexRect 	= gl.TexRect

local red   = { 1, 0, 0 }
local green = { 0, 1, 0 }
local black = { 0, 0, 0 }
local white = { 1, 1, 1 }


local spGetCameraState		= Spring.GetCameraState
local spGetCameraVectors	= Spring.GetCameraVectors
--local spGetGroundHeight		= Spring.GetGroundHeight
local spGetSmoothMeshHeight	= Spring.GetSmoothMeshHeight
local spGetActiveCommand	= Spring.GetActiveCommand
local spGetModKeyState		= Spring.GetModKeyState
local spGetMouseState		= Spring.GetMouseState
local spGetSelectedUnits	= Spring.GetSelectedUnits
local spGetGameSpeed		= Spring.GetGameSpeed
local spGetUnitPosition		= Spring.GetUnitPosition
local spGetUnitViewPosition	= Spring.GetUnitViewPosition
local spGetUnitDirection	= Spring.GetUnitDirection
local spGetUnitVelocity		= Spring.GetUnitVelocity
local spIsAboveMiniMap		= Spring.IsAboveMiniMap
local spSendCommands		= Spring.SendCommands
local spSetCameraState		= Spring.SetCameraState
local spSetMouseCursor		= Spring.SetMouseCursor
local spTraceScreenRay		= Spring.TraceScreenRay
local spWarpMouse			= Spring.WarpMouse
local spGetCameraDirection	= Spring.GetCameraDirection
local spSetCameraTarget		= Spring.SetCameraTarget
local spGetTimer 			= Spring.GetTimer
local spDiffTimers 			= Spring.DiffTimers

local spGetGroundHeight = function(x,z)
  local val = Spring.GetGroundHeight(x,z)
  if val < 0 then val = 0 end
  return val
end

local abs	= math.abs
local min 	= math.min
local max	= math.max
local sqrt	= math.sqrt
local sin	= math.sin
local cos	= math.cos

local echo = Spring.Echo

local helpText = {}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local ls_x, ls_y, ls_z --lockspot position
local ls_dist, ls_have, ls_onmap --lockspot flag
local tilting
local overview_mode, last_rx, last_ls_dist = false, nil, nil --overview_mode's variable
local follow_timer = 0
local epicmenuHkeyComp = {} --for saving & reapply hotkey system handled by epicmenu.lua

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local vsx, vsy = widgetHandler:GetViewSizes()
local cx,cy = vsx * 0.5,vsy * 0.5
function widget:ViewResize(viewSizeX, viewSizeY)
	vsx = viewSizeX
	vsy = viewSizeY
	cx = vsx * 0.5
	cy = vsy * 0.5
end

local PI 			= math.pi
--local TWOPI			= PI*2	
local HALFPI		= PI/2
--local HALFPIPLUS	= HALFPI+0.01
local HALFPIMINUS	= HALFPI-0.01
local RADperDEGREE = PI/180

local CAM_TRACK_PERIOD = 0.01
local OVERVIEW_DISTICON = 100

local fpsmode = false
local mx, my = 0,0
local msx, msy = 0,0
local smoothscroll = false
local springscroll = false
local lockspringscroll = false
local rotate, movekey
local move, rot = {}, {}
local key_code = {
	left 		= 276,
	right 		= 275,
	up 			= 273,
	down 		= 274,
	pageup 		= 280,
	pagedown 	= 281,
}
local keys = {
	[276] = 'left',
	[275] = 'right',
	[273] = 'up',
	[274] = 'down',
}
local icon_size = 20
local cycle = 1
local camcycle = 1
local trackcycle = 1
local hideCursor = false


local mwidth, mheight = Game.mapSizeX, Game.mapSizeZ
local averageEdgeHeight = -300
local mcx, mcz 	= mwidth / 2, mheight / 2
local mcy 		= spGetGroundHeight(mcx, mcz)
local maxDistY = max(mheight, mwidth) * 2
do
	local northEdge = spGetGroundHeight(mwidth/2,0)
	local eastEdge = spGetGroundHeight(0,mheight/2)
	local southEdge = spGetGroundHeight(mwidth/2,mheight)
	local westEdge = spGetGroundHeight(mwidth,mheight/2)
	--averageEdgeHeight =(northEdge+eastEdge+southEdge+westEdge)/4 --is used for estimating coordinate in null space
	
	local currentFOVhalf_rad = (Spring.GetCameraFOV()/2)*PI/180
	local mapLenght = (max(mheight, mwidth)+4000)/2
	maxDistY =  mapLenght/math.tan(currentFOVhalf_rad) --adjust TAB/Overview distance based on camera FOV
end

local trackCam = {dist = 200, heading = PI, pitch = 0}
local trackCamOverview = {dist = 1500, heading = PI, pitch = PI*0.35}

local origIconDistance = Spring.GetConfigInt("UnitIconDist", 150)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local rotate_transit --switch for smoothing "rotate at mouse position instead of screen center"
local last_move = spGetTimer() --switch for reseting lockspot for Edgescroll
local last_zoom = {spGetTimer(),spGetTimer()} --switch for delaying zooming updates for FollowCursorAutoZoom
local thirdPerson_transit = spGetTimer() --switch for smoothing "3rd person trackmode edge screen scroll"
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function GetDist(x1,y1,z1, x2,y2,z2)
	local d1 = x2-x1
	local d2 = y2-y1
	local d3 = z2-z1
	
	return sqrt(d1*d1 + d2*d2 + d3*d3)
end

local function explode(div,str)
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
end

local function GetRotationFromVector(dx, dy, dz)
	local rx = math.atan2(dy, dz)
	local rz = math.atan2(dy, dx)
	local ry = math.atan2(dz, dx)
	return rx, ry, rz
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local previousFov=-1
local prevInclination =99
local prevAzimuth = 299
local prevX = 9999
local prevY = 9999
local cachedResult = {0,0,0}
local function OverrideTraceScreenRay(x,y,cs) --this function provide an adjusted TraceScreenRay for null-space outside of the map (by msafwan)
	local halfViewSizeY = vsy/2
	local halfViewSizeX = vsx/2
	y = y- halfViewSizeY --convert screen coordinate to 0,0 at middle
	x = x- halfViewSizeX
	local currentFov = cs.fov/2 --in Spring: 0 degree is directly ahead and +FOV/2 degree to the left and -FOV/2 degree to the right
	--//Speedup//--
	if previousFov==currentFov and prevInclination == cs.rx and prevAzimuth == cs.ry and prevX ==x and prevY == y then --if camera Sphere coordinate & mouse position not change then use cached value
		return cachedResult[1],cachedResult[2],cachedResult[3] 
	end
	
	--//Opengl FOV scaling logic//--
	local referenceScreenSize = halfViewSizeY --because Opengl Glut use vertical screen size for FOV setting
	local referencePlaneDistance = referenceScreenSize -- because Opengl use 45 degree as default FOV, in which case tan(45)=1= referenceScreenSize/referencePlaneDistance
	local currentScreenSize = math.tan(currentFov*RADperDEGREE)*referencePlaneDistance --calculate screen size for current FOV if the distance to perspective projection plane is the default for 45 degree
	local resizeFactor = referenceScreenSize/currentScreenSize --the ratio of the default screen size to new FOV's screen size
	local perspectivePlaneDistance = resizeFactor*referencePlaneDistance --move perspective projection plane (closer or further away) so that the size appears to be as the default size for 45 degree
	--Note: second method is "perspectivePlaneDistance=halfViewSizeY/math.tan(currentFov*RADperDEGREE)" which yield the same result with 1 line.
	
	--//mouse-to-Sphere projection//--
	local distanceFromCenter = sqrt(x*x+y*y) --mouse cursor distance from center screen. We going to simulate a Sphere dome which we will position the mouse cursor.
	local inclination = math.atan(distanceFromCenter/perspectivePlaneDistance) --translate distance in 2d plane to angle projected from the Sphere
	inclination = inclination -PI/2 --offset 90 degree because we want to place the south hemisphere (bottom) of the dome on the screen
	local azimuth = math.atan2(-x,y) --convert x,y to angle, so that left is +degree and right is -degree. Note: negative x flip left-right or right-left (flip the direction of angle)
	--//Sphere-to-coordinate conversion//--
	local sphere_x = 100* sin(azimuth)* cos(inclination) --convert Sphere coordinate back to Cartesian coordinate to prepare for rotation procedure
	local sphere_y = 100* sin(inclination)
	local sphere_z = 100* cos(azimuth)* cos(inclination)
	--//coordinate rotation 90+x degree//--
	local rotateToInclination = PI/2+cs.rx --rotate to +90 degree facing the horizon then rotate to camera's current facing.
	local new_x = sphere_x --rotation on x-axis
	local new_y = sphere_y* cos (rotateToInclination) + sphere_z* sin (rotateToInclination) --move points of Sphere to new location 
	local new_z = sphere_z* cos (rotateToInclination) - sphere_y* sin (rotateToInclination)
	--//coordinate-to-Sphere conversion//--
	local cursorTilt = math.atan2(new_y,sqrt(new_z*new_z+new_x*new_x)) --convert back to Sphere coordinate
	local cursorHeading = math.atan2(new_x,new_z) --Sphere's azimuth
	
	--//Sphere-to-groundPosition translation//--
	local tiltSign = abs(cursorTilt)/cursorTilt --Sphere's inclination direction (positive upward or negative downward)
	local cursorTiltComplement = (PI/2-abs(cursorTilt))*tiltSign --return complement angle for cursorTilt
	cursorTiltComplement = min(1.5550425,abs(cursorTiltComplement))*tiltSign --limit to 89 degree to prevent infinity in math.tan() 
	local cursorxzDist = math.tan(cursorTiltComplement)*(averageEdgeHeight-cs.py) --how far does the camera angle look pass the ground beneath
	local cursorxDist = sin(cs.ry+cursorHeading)*cursorxzDist ----break down the ground beneath into x and z component.  Note: using Sin() instead of regular Cos() because coordinate & angle is left handed
	local cursorzDist = cos(cs.ry+cursorHeading)*cursorxzDist
	local gx, gy, gz = cs.px+cursorxDist,averageEdgeHeight,cs.pz+cursorzDist --estimated ground position infront of camera 
	--Finish
	if false then
		-- Spring.Echo("MouseCoordinate")
		-- Spring.Echo(y .. " y")
		-- Spring.Echo(x .. " x")
		-- Spring.Echo("Before_Angle")
		-- Spring.Echo(inclination*(180/PI) .. " inclination")
		-- Spring.Echo(azimuth*(180/PI).. " azimuth")
		-- Spring.Echo(distanceFromCenter.. " distanceFromCenter")
		-- Spring.Echo(perspectivePlaneDistance.. " perspectivePlaneDistance")
		-- Spring.Echo( halfViewSizeY/math.tan(currentFov*RADperDEGREE) .. " perspectivePlaneDistance(2ndMethod)")
		-- Spring.Echo("CameraAngle")
		-- Spring.Echo(cs.rx*(180/PI))
		-- Spring.Echo(cs.ry*(180/PI))
		-- Spring.Echo("After_Angle")
		-- Spring.Echo(cursorTilt*(180/PI))
		-- Spring.Echo((cs.ry+cursorHeading)*(180/PI) .. " cursorComponent: " .. cursorHeading*(180/PI))
		Spring.MarkerAddPoint(gx, gy, gz, "here")
	end
	--//caching for efficiency
	cachedResult[1] = gx
	cachedResult[2] = gy
	cachedResult[3] = gz
	prevInclination =cs.rx
	prevAzimuth = cs.ry
	prevX = x
	prevY = y
	previousFov = currentFov	

	return gx,gy,gz
	--Most important credit to!:
	--0: Google search service
	--1: "Perspective Projection: The Wrong Imaging Model" by Margaret M. Fleck (http://www.cs.illinois.edu/~mfleck/my-papers/stereographic-TR.pdf)
	--2: http://www.scratchapixel.com/lessons/3d-advanced-lessons/perspective-and-orthographic-projection-matrix/perspective-projection-matrix/
	--3: http://stackoverflow.com/questions/5278417/rotating-body-from-spherical-coordinates
	--4: http://en.wikipedia.org/wiki/Spherical_coordinate_system
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--[[ --NOTE: is not yet used for the moment
local function MoveRotatedCam(cs, mxm, mym)
	if not cs.dy then
		return cs
	end
	
	-- forward, up, right, top, bottom, left, right
	local camVecs = spGetCameraVectors()
	local cf = camVecs.forward
	local len = sqrt((cf[1] * cf[1]) + (cf[3] * cf[3]))
	local dfx = cf[1] / len
	local dfz = cf[3] / len
	local cr = camVecs.right
	local len = sqrt((cr[1] * cr[1]) + (cr[3] * cr[3]))
	local drx = cr[1] / len
	local drz = cr[3] / len
	
	local vecDist = (- cs.py) / cs.dy
	
	local ddx = (mxm * drx) + (mym * dfx)
	local ddz = (mxm * drz) + (mym * dfz)
	
	local gx1, gz1 = cs.px + vecDist*cs.dx,			cs.pz + vecDist*cs.dz --note me: what does cs.dx mean?
	local gx2, gz2 = cs.px + vecDist*cs.dx + ddx,	cs.pz + vecDist*cs.dz + ddz 
	
	local extra = 500
	
	if gx2 > mwidth + extra then
		ddx = mwidth + extra - gx1
	elseif gx2 < 0 - extra then
		ddx = -gx1 - extra
	end
	
	if gz2 > mheight + extra then
		ddz = mheight - gz1 + extra
	elseif gz2 < 0 - extra then
		ddz = -gz1 - extra
	end
	
	cs.px = cs.px + ddx
	cs.pz = cs.pz + ddz
	return cs
end
--]]

--Note: If the x,y is not pointing at an onmap point, this function traces a virtual ray to an
--          offmap position using the camera direction and disregards the x,y parameters.
local function VirtTraceRay(x,y, cs, useWater)
	local _, gpos = spTraceScreenRay(x, y, true, false, true, not useWater)
	
	if gpos then
		local gx, gy, gz = gpos[1], gpos[2], gpos[3]
		
		--gy = spGetSmoothMeshHeight (gx,gz)
		
		if gx < 0 or gx > mwidth or gz < 0 or gz > mheight then --out of map
			return false, gx, gy, gz	
		else
			return true, gx, gy, gz
		end
	end
	
	if not cs or not cs.dy or cs.dy == 0 then
		return false, false
	end
	--[[ 
	local vecDist = (- cs.py) / cs.dy
	local gx, gy, gz = cs.px + vecDist*cs.dx, 	cs.py + vecDist*cs.dy, 	cs.pz + vecDist*cs.dz  --note me: what does cs.dx mean?
	--]]

	local gx,gy,gz = OverrideTraceScreenRay(x,y,cs) --use override if spTraceScreenRay() do not have results
	
	--gy = spGetSmoothMeshHeight (gx,gz)
	return false, gx, gy, gz
end

local function SetLockSpot2(cs, x, y, useWater) --set an anchor on the ground for camera rotation
	if not useWater then
	  useWater = true
	end
	if ls_have then --if lockspot is locked
		return
	end
	
	local x, y = x, y
	if not x then
		x, y = cx, cy --center of screen
	end

	--local gpos
	--_, gpos = spTraceScreenRay(x, y, true)
	local onmap, gx,gy,gz = VirtTraceRay(x, y, cs, useWater) --convert screen coordinate to ground coordinate
	
	if gx then
		ls_x,ls_y,ls_z = gx,gy,gz
		local px,py,pz = cs.px,cs.py,cs.pz
		local dx,dy,dz = ls_x-px, ls_y-py, ls_z-pz
		ls_onmap = onmap
		ls_dist = sqrt(dx*dx + dy*dy + dz*dz) --distance to ground coordinate
		ls_have = true
	end
end


local function UpdateCam(cs)
	local cs = cs
	if not (cs.rx and cs.ry and ls_dist) then
		--return cs
		return false
	end
	
	local alt = sin(cs.rx) * ls_dist
	local opp = cos(cs.rx) * ls_dist --OR same as: sqrt(ls_dist * ls_dist - alt * alt)
	cs.px = ls_x - sin(cs.ry) * opp
	cs.py = ls_y - alt
	cs.pz = ls_z - cos(cs.ry) * opp
	
	return cs
end

local function Zoom(zoomin, shift, forceCenter)
	local zoomin = zoomin
	if options.invertzoom.value then
		zoomin = not zoomin
	end

	local cs = spGetCameraState()
	-- [[
	if
	(not forceCenter) and
	((zoomin and options.zoomintocursor.value) or ((not zoomin) and options.zoomoutfromcursor.value)) --zoom to cursor or zoom-out from cursor
	then
		
		local onmap, gx,gy,gz = VirtTraceRay(mx, my, cs, true)
		
		if gx then
			dx = gx - cs.px
			dy = gy - cs.py
			dz = gz - cs.pz
		else
			return false
		end
		
		local sp = (zoomin and options.zoominfactor.value or -options.zoomoutfactor.value) * (shift and 3 or 1)
		
		local new_px = cs.px + dx * sp --a zooming that get slower the closer you are to the target.
		local new_py = cs.py + dy * sp
		local new_pz = cs.pz + dz * sp
		
		cs.px = new_px
		cs.py = new_py
		cs.pz = new_pz
		
		spSetCameraState(cs, options.smoothness.value)
		ls_have = false
		return
		
	end
	--]]
	ls_have = false --unlock lockspot 
	SetLockSpot2(cs) --set lockspot
	if not ls_have then
		return
	end
    
	-- if zoomin and not ls_onmap then --prevent zooming into null area (outside map)
		-- return
	-- end
    
	local sp = (zoomin and -options.zoominfactor.value or options.zoomoutfactor.value) * (shift and 3 or 1)
	
	local ls_dist_new = ls_dist + ls_dist*sp -- a zoom in that get faster the further away from target
	ls_dist_new = max(ls_dist_new, 20)
	ls_dist_new = min(ls_dist_new, maxDistY)
	
	ls_dist = ls_dist_new

	local cstemp = UpdateCam(cs)
	if cstemp then cs = cstemp; end
	if zoomin or ls_dist < maxDistY then
		spSetCameraState(cs, options.smoothness.value)
	end

	return true
end


local function Altitude(up, s)
	ls_have = false
	
	local up = up
	if options.invertalt.value then
		up = not up
	end
	
	local cs = spGetCameraState()
	local py = max(1, abs(cs.py) )
	local dy = py * (up and 1 or -1) * (s and 0.3 or 0.1)
	local new_py = py + dy
    if new_py < -maxDistY  then
        new_py = -maxDistY
    elseif new_py > maxDistY then
        new_py = maxDistY 
    end
	cs.py = new_py
	spSetCameraState(cs, options.smoothness.value)
	return true
end
--==End camera utility function^^ (a frequently used function. Function often used for controlling camera).


SetFOV = function(fov)
	local cs = spGetCameraState()
	cs.fov = fov
    spSetCameraState(cs,0)
	Spring.Echo(fov .. " degree")
	
	local currentFOVhalf_rad = (fov/2)*PI/180
	local mapLenght = (max(mheight, mwidth)+4000)/2
	maxDistY =  mapLenght/math.tan(currentFOVhalf_rad) --adjust maximum TAB/Overview distance based on camera FOV
end

local function ResetCam()
	local cs = spGetCameraState()
	cs.px = Game.mapSizeX/2
	cs.py = maxDistY
	cs.pz = Game.mapSizeZ/2
	cs.rx = -HALFPI
	cs.ry = PI
	spSetCameraState(cs, 1)
end
options.resetcam.OnChange = ResetCam

-- TRACK UNIT
local baseDelta = 1
TrackUnit = function(unitID, instant)
	--spSendCommands("viewta")
	local paused = select(3, spGetGameSpeed())
	local cam = {}
	local oldcam = spGetCameraState()
	--local _, _, _, tx, ty, tz = spGetUnitPosition(unitID, true)
	local tx, ty, tz = spGetUnitViewPosition(unitID)
	--local vx, vy, vz = spGetUnitDirection(unitID)
	--local rotX, rotY, rotZ = GetRotationFromVector(vx, vy, vz)
	--local oldcam = cam
	--local velocity = {spGetUnitVelocity(unitID)}
	--tx = tx + velocity[1]*Game.gameSpeed*4/3
	--ty = ty + velocity[2]*Game.gameSpeed*4/3
	--tz = z + velocity[3]*Game.gameSpeed*4/3
	
	local tcam = overview_mode and trackCamOverview or trackCam
	
	if tcam.pitch > HALFPI then
		tcam.pitch = HALFPI *0.999
		--tcam.heading = PI - tcam.heading
	elseif tcam.pitch < -HALFPI then
		tcam.pitch = -HALFPI *0.999
		--tcam.heading = PI - tcam.heading
	end
	
	local dist = tcam.dist
	local pitch = tcam.pitch -- + (overview_mode and 0 or rotX)
	local yaw = tcam.heading -- + (overview_mode and 0 or rotY)
	
	if overview_mode then
		--yaw = 0
		--thirdPerson_pitch = 0.7*HALFPI
	end
	
	local targetPos = {
		tx - math.sin(yaw) * math.cos(pitch) * dist,
		ty + math.sin(pitch) * dist,
		tz - math.cos(yaw) * math.cos(pitch) * dist,
	}
	
	local deltaPos = {
		targetPos[1] - oldcam.px,
		targetPos[2] - oldcam.py,
		targetPos[3] - oldcam.pz,
	}
	--cam.dx = deltaPos[1]
	--cam.dy = deltaPos[2]
	--cam.dz = deltaPos[3]
	cam.px = targetPos[1]
	cam.py = targetPos[2]
	cam.pz = targetPos[3]
	cam.oldHeight = y
	cam.rx = 0-pitch
	cam.ry = yaw
	cam.rz = thirdPerson_roll
	
	local delta = (((cam.px - oldcam.px)^2 + (cam.py - oldcam.py)^2 + (cam.pz - oldcam.pz)^2)^0.5)
	--Spring.Echo(cam.px, cam.py, cam.pz, cam.rx, cam.ry, cam.rz)
	if delta <= 0 then delta = 0 end --CAM_TRACK_PERIOD end
	spSetCameraState(cam, instant and 0 or 0.25) -- 4.5
	--Spring.SetCameraTarget(cam.px, cam.py, cam.pz, 0.5)
end

OverviewAction = function()
	if not overview_mode then
		if thirdPerson_trackunit then
			
		else
			local cs = spGetCameraState()
			SetLockSpot2(cs)
			last_ls_dist = ls_dist
			last_rx = cs.rx
			
			cs.px = Game.mapSizeX/2
			cs.py = maxDistY
			cs.pz = Game.mapSizeZ/2
			cs.rx = -HALFPI
			spSetCameraState(cs, 0.2)
		end
		if WG.ShowMapGrid then
			WG.ShowMapGrid()
		end
		Spring.SendCommands("disticon " .. OVERVIEW_DISTICON)
	else --if in overview mode
		if thirdPerson_trackunit then
			local selUnits = spGetSelectedUnits() --player's new unit to track
			if not (selUnits and selUnits[1]) then --if player has no new unit to track
				Spring.SelectUnitArray({thirdPerson_trackunit}) --select the original unit
				selUnits = spGetSelectedUnits()
			end
			thirdPerson_trackunit = nil
			if selUnits and selUnits[1] then 
				thirdPerson_trackunit = selUnits[1]
				TrackUnit(thirdPerson_trackunit)
			end
		else
			local cs = spGetCameraState()
			mx, my = spGetMouseState()
			local onmap, gx, gy, gz = VirtTraceRay(mx,my,cs,true) --create a lockstop point.
			if gx then --Note:  Now VirtTraceRay can extrapolate coordinate in null space (no need to check for onmap)
				local cs = spGetCameraState()			
				cs.rx = last_rx
				ls_dist = last_ls_dist 
				ls_x = gx
				ls_z = gz
				ls_y = gy
				ls_have = true
				local cstemp = UpdateCam(cs) --set camera position & orientation based on lockstop point
				if cstemp then cs = cstemp; end
				spSetCameraState(cs, 1)
			end
		end
		
		if WG.HideMapGrid then
			WG.HideMapGrid()
		end
		Spring.SendCommands("disticon 1000")
	end
	
	overview_mode = not overview_mode
end
--==End option menu function (function that is attached to epic menu button)^^


local function AutoZoomInOutToCursor() --options.followautozoom (auto zoom camera while in follow cursor mode)
	if smoothscroll or springscroll or rotate then
		return
	end
	local lclZoom = function(cs,zoomin, smoothness, no_2)
		if not (spDiffTimers(spGetTimer(),last_zoom[1])>=1) and not (spDiffTimers(spGetTimer(),last_zoom[2])>=1 and no_2)  then
			return
		end
		if no_2 then
			last_zoom[2] = spGetTimer() --saperate update rate for special off-screen zoom-out
		else
			last_zoom[1] = spGetTimer()  --saperate update rate for on-screen zoom-out/zoom-in
		end
		ls_have = false --unlock lockspot 
		SetLockSpot2(cs) --set lockspot
		if not ls_have then
			return
		end
		local sp = (zoomin and -1*options.followzoomoutspeed.value or options.followzoominspeed.value)
		local ls_dist_new = ls_dist + ls_dist*sp
		ls_dist_new = max(ls_dist_new, 20)
		ls_dist_new = min(ls_dist_new, maxDistY)
		ls_dist = ls_dist_new
		local cstemp = UpdateCam(cs)
		if cstemp then cs = cstemp; end
		if zoomin or ls_dist < maxDistY then
			spSetCameraState(cs, smoothness)
		end
	end
	local teamID = Spring.GetLocalTeamID()
	local _, playerID = Spring.GetTeamInfo(teamID)
	local pp = WG.alliedCursorsPos[ playerID ]
	if pp then
		local groundY = max(0,spGetGroundHeight(pp[1],pp[2]))
		local scrnsize_X,scrnsize_Y = Spring.GetViewGeometry() --get current screen size
		local scrn_x,scrn_y = Spring.WorldToScreenCoords(pp[1],groundY,pp[2]) --get cursor's position on screen
		local cs = spGetCameraState()
		if (scrn_x<scrnsize_X*4/6 and scrn_x>scrnsize_X*2/6) and (scrn_y<scrnsize_Y*4/6 and scrn_y>scrnsize_Y*2/6) then --if cursor near center:
			local camHeight = cs.py - groundY --get camera height with respect to ground
			if camHeight >1000 then --if cam height from ground greater than 1000elmo: do
				lclZoom(cs,true, 1) --zoom in
			end
		elseif (scrn_x<scrnsize_X*5/6 and scrn_x>scrnsize_X*1/6) and (scrn_y<scrnsize_Y*5/6 and scrn_y>scrnsize_Y*1/6) then --if cursor between center & edge: do nothing 
		elseif (scrn_x<scrnsize_X*6/6 and scrn_x>scrnsize_X*0/6) and (scrn_y<scrnsize_Y*6/6 and scrn_y>scrnsize_Y*0/6) then --if cursor near edge: do
			lclZoom(cs,false, 1) --zoom out
		end				
		if (scrn_x>scrnsize_X or scrn_x<0) or (scrn_y>scrnsize_Y or scrn_y<0) then --if cursor outside screen: do
			local fastSpeed = (8 - options.followmaxscrollspeed.value)+8 --reverse value (ie: if 15 return 1, if 1 return 15, ect)
			lclZoom(cs,false, 1,true) --zoom out using special update rate
			spSetCameraTarget(pp[1], groundY, pp[2], fastSpeed) --fast go-to speed
		else --if cursor within screen: do
			local slowSpeed = (8 - options.followminscrollspeed.value)+8 --reverse value (ie: if 15 return 1, if 1 return 15, ect)
			spSetCameraTarget(pp[1], groundY, pp[2], slowSpeed) --slow go-to speed
		end
	end
end

local function RotateCamera(x, y, dx, dy, smooth, lock)
	if thirdPerson_trackunit then
		local tcam = overview_mode and trackCamOverview or trackCam
		tcam.heading = tcam.heading + dx/2 * options.rotfactor.value
		tcam.pitch = tcam.pitch + dy/2 * options.rotfactor.value
		return
	end

	local cs = spGetCameraState()
	local cs1 = cs
	if cs.rx then
		
		cs.rx = cs.rx + dy * options.rotfactor.value
		cs.ry = cs.ry - dx * options.rotfactor.value
		
		--local max_rx = options.restrictangle.value and -0.1 or HALFPIMINUS
		local max_rx = HALFPIMINUS
		
		if cs.rx < -HALFPIMINUS then
			cs.rx = -HALFPIMINUS
		elseif cs.rx > max_rx then
			cs.rx = max_rx 
		end
		
		-- [[
		if trackmode then --always rotate world instead of camera in trackmode
		    lock = true
		    ls_have = false
		    SetLockSpot2(cs)
		end
		--]]
		if lock then
			local cstemp = UpdateCam(cs)
			if cstemp then
				cs = cstemp;
			else
				return
			end
		else
			ls_have = false
		end
		spSetCameraState(cs, smooth and options.smoothness.value or 0)
	end
end

local function Tilt(s, dir)
	if not tilting then
		ls_have = false	
	end
	tilting = true
	local cs = spGetCameraState()
	SetLockSpot2(cs)
	if not ls_have then
		return
	end
    local dir = dir * (options.inverttilt.value and -1 or 1)
    

	local speed = dir * (s and 30 or 10)
	RotateCamera(vsx * 0.5, vsy * 0.5, 0, speed, true, true) --smooth, lock

	return true
end

local function ScrollCam(cs, mxm, mym, smoothlevel)
	SetLockSpot2(cs)
	if not cs.dy or not ls_have then
		--echo "<COFC> scrollcam fcn fail"
		return
	end
	if not ls_onmap then
		smoothlevel = 0.5
	end

	-- forward, up, right, top, bottom, left, right
	local camVecs = spGetCameraVectors()
	local cf = camVecs.forward
	local len = sqrt((cf[1] * cf[1]) + (cf[3] * cf[3])) --get hypotenus of x & z vector only
	local dfx = cf[1] / len
	local dfz = cf[3] / len
	local cr = camVecs.right
	local len = sqrt((cr[1] * cr[1]) + (cr[3] * cr[3]))
	local drx = cr[1] / len
	local drz = cr[3] / len
	
	local vecDist = (- cs.py) / cs.dy
	
	local ddx = (mxm * drx) + (mym * dfx)
	local ddz = (mxm * drz) + (mym * dfz)
	
	ls_x = ls_x + ddx
	ls_z = ls_z + ddz
	ls_x = min(ls_x, mwidth-3) --limit camera movement to map area
	ls_x = max(ls_x, 3)
		
	ls_z = min(ls_z, mheight-3)
	ls_z = max(ls_z, 3)
	if options.smoothmeshscroll.value then
		ls_y = spGetSmoothMeshHeight(ls_x, ls_z) or 0
	else
		ls_y = spGetGroundHeight(ls_x, ls_z) or 0
	end
	
	
	local csnew = UpdateCam(cs)
	if csnew then
		spSetCameraState(csnew, smoothlevel)
	end
	
end

local function PeriodicWarning()
	local c_widgets, c_widgets_list = '', {}
	for name,data in pairs(widgetHandler.knownWidgets) do
		if data.active and
			(
			name:find('SmoothScroll')
			or name:find('Hybrid Overhead')
			or name:find('Complete Control Camera')
			)
			then
			c_widgets_list[#c_widgets_list+1] = name
		end
	end
	for i=1, #c_widgets_list do
		c_widgets = c_widgets .. c_widgets_list[i] .. ', '
	end
	if c_widgets ~= '' then
		echo('<COFCam> *Periodic warning* Please disable other camera widgets: ' .. c_widgets)
	end
end
--==End camera control function^^ (functions that actually do camera control)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local updateTimer = 0
local wantReturnCam = false
function widget:Update(dt)
	local framePassed = math.ceil(dt/0.0333) --estimate how many gameframe would've passes based on difference in time??
	updateTimer = updateTimer + dt
	if updateTimer >= CAM_TRACK_PERIOD then
		if thirdPerson_trackunit then
			TrackUnit(thirdPerson_trackunit)
		end
		
		local command = spGetActiveCommand()
		if command ~= 0 and not overview_mode then
			wantReturnCam = true
			OverviewAction()
		elseif command == 0 and wantReturnCam and overview_mode then
			wantReturnCam = false
			OverviewAction()
		end
		updateTimer = 0
	end
	if hideCursor then
        spSetMouseCursor('%none%')
    end
	
	--//HANDLE TIMER FOR VARIOUS SECTION
	--timer to block tracking when using mouse
	if follow_timer > 0  then 
		follow_timer = follow_timer - dt
	end
	--timer to block unit tracking
	trackcycle = trackcycle + framePassed 
	if trackcycle >=6 then 
		trackcycle = 0 --reset value to Zero (0) every 6th frame. Extra note: dt*trackcycle would be the estimated number of second elapsed since last reset.
	end
	--timer to block cursor tracking
	camcycle = camcycle + framePassed 
	if camcycle >=12 then
		camcycle = 0 --reset value to Zero (0) every 12th frame. NOTE: a reset value a multiple of trackcycle's reset is needed to prevent conflict 
	end
	--timer to block periodic warning
	cycle = cycle + framePassed
	if cycle >=32*15 then
		cycle = 0 --reset value to Zero (0) every 32*15th frame.
	end	

	--//HANDLE TRACK UNIT
	--trackcycle = trackcycle%(6) + 1 --automatically reset "trackcycle" value to Zero (0) every 6th iteration.
	if (trackcycle == 0 and
	trackmode and
	not overview_mode and
	(follow_timer <= 0) and --disable tracking temporarily when middle mouse is pressed or when scroll is used for zoom
	not thirdPerson_trackunit and
	(not rotate)) --update trackmode during non-rotating state (doing both will cause a zoomed-out bug)
	then 
		local selUnits = spGetSelectedUnits()
		if selUnits and selUnits[1] then
			local vx,vy,vz = Spring.GetUnitVelocity(selUnits[1])
			local x,y,z = spGetUnitPosition( selUnits[1] )
			--MAINTENANCE NOTE: the following smooth value is obtained from trial-n-error. There's no formula to calculate and it could change depending on engine (currently Spring 91). 
			--The following instruction explain how to get this smooth value:
			--1) reset Spring.SetCameraTarget to: (x+vx,y+vy,z+vz, 0.0333)
			--2) increase value A until camera motion is not jittery, then stop: (x+vx,y+vy,z+vz, 0.0333*A)
			--3) increase value B until unit center on screen, then stop: (x+vx*B,y+vy*B,z+vz*B, 0.0333*A)
			spSetCameraTarget(x+vx*40,y+vy*40,z+vz*40, 0.0333*137)
		elseif (not options.persistenttrackmode.value) then --cancel trackmode when no more units is present in non-persistent trackmode.
			trackmode=false --exit trackmode
			Spring.Echo("COFC: Unit tracking OFF")
		end
	end
	
	--//HANDLE TRACK CURSOR
	--camcycle = camcycle%(12) + 1  --automatically reset "camcycle" value to Zero (0) every 12th iteration.
	if (camcycle == 0 and
	not trackmode and
	not overview_mode and
	(follow_timer <= 0) and --disable tracking temporarily when middle mouse is pressed or when scroll is used for zoom
	not thirdperson_trackunit and
	options.follow.value)  --if follow selected player's cursor:
	then 
		if WG.alliedCursorsPos then 
			if options.followautozoom.value then
				AutoZoomInOutToCursor()
			else
				local teamID = Spring.GetLocalTeamID()
				local _, playerID = Spring.GetTeamInfo(teamID)
				local pp = WG.alliedCursorsPos[ playerID ]
				if pp then
					local groundY = max(0,spGetGroundHeight(pp[1],pp[2]))
					local scrnsize_X,scrnsize_Y = Spring.GetViewGeometry() --get current screen size
					local scrn_x,scrn_y = Spring.WorldToScreenCoords(pp[1],groundY,pp[2]) --get cursor's position on screen
					if (scrn_x>scrnsize_X or scrn_x<0) or (scrn_y>scrnsize_Y or scrn_y<0) then --if cursor outside screen: do
						local fastSpeed = (options.followmaxscrollspeed.mid - options.followmaxscrollspeed.value)+options.followmaxscrollspeed.mid --reverse value (ie: if 15 return 1, if 1 return 15, ect)
						spSetCameraTarget(pp[1], groundY, pp[2], fastSpeed) --fast go-to speed
					else --if cursor within screen: do
						local slowSpeed = (options.followminscrollspeed.mid - options.followminscrollspeed.value)+options.followminscrollspeed.mid --reverse value (ie: if 15 return 1, if 1 return 15, ect)
						spSetCameraTarget(pp[1], groundY, pp[2], slowSpeed) --slow go-to speed
					end
				end
			end
		end
	end
	
	
	-- Periodic warning
	--cycle = cycle%(32*15) + framePassed --automatically reset "cycle" value to Zero (0) every 32*15th iteration.
	if cycle == 0 then
		PeriodicWarning()
	end

	local cs = spGetCameraState()
	
	local use_lockspringscroll = lockspringscroll and not springscroll

	local a,c,m,s = spGetModKeyState()
	
	--//HANDLE ROTATE CAMERA
	if ((not thirdPerson_trackunit) and (rot.right or rot.left or rot.up or rot.down)) then
		local speed = options.rotfactor.value * (s and 400 or 150)
		if rot.right then
			RotateCamera(vsx * 0.5, vsy * 0.5, speed, 0, true)
		elseif rot.left then
			RotateCamera(vsx * 0.5, vsy * 0.5, -speed, 0, true)
		end
		
		if rot.up then
			RotateCamera(vsx * 0.5, vsy * 0.5, 0, speed, true)
		elseif rot.down then
			RotateCamera(vsx * 0.5, vsy * 0.5, 0, -speed, true)
		end
		
	end
	
	--//HANDLE MOVE CAMERA
	if ((not thirdPerson_trackunit) and (smoothscroll or move.right or move.left or move.up or move.down or use_lockspringscroll))
		then
		
		local x, y, lmb, mmb, rmb = spGetMouseState()
		
		if (c) then
			return
		end
		
		local smoothlevel = 0
		
		-- clear the velocities
		cs.vx  = 0; cs.vy  = 0; cs.vz  = 0
		cs.avx = 0; cs.avy = 0; cs.avz = 0
				
		local mxm, mym = 0,0
		
		local heightFactor = (cs.py/1000)
		if smoothscroll then
			--local speed = dt * options.speedFactor.value * heightFactor 
			local speed = math.max( dt * options.speedFactor.value * heightFactor, 0.005 )
			mxm = speed * (x - cx)
			mym = speed * (y - cy)
		elseif use_lockspringscroll then
			--local speed = options.speedFactor.value * heightFactor / 10
			local speed = math.max( options.speedFactor.value * heightFactor / 10, 0.05 )
			local dir = options.invertscroll.value and -1 or 1
			mxm = speed * (x - mx) * dir
			mym = speed * (y - my) * dir
			
			spWarpMouse(cx, cy)		
		else --edge screen scroll
			--local speed = options.speedFactor_k.value * (s and 3 or 1) * heightFactor
			local speed = math.max( options.speedFactor_k.value * (s and 3 or 1) * heightFactor, 1 )
			
			if move.right then
				mxm = speed
			elseif move.left then
				mxm = -speed
			end
			
			if move.up then
				mym = speed
			elseif move.down then
				mym = -speed
			end
			smoothlevel = options.smoothness.value
			
			if spDiffTimers(spGetTimer(),last_move)>1 then --if edge scroll is 'first time': unlock lockspot once 
				ls_have = false
			end			
			last_move = spGetTimer()
		end
		
		ScrollCam(cs, mxm, mym, smoothlevel)
		
	end
	
	mx, my = spGetMouseState()
	
	--//HANDLE MOUSE'S SCREEN-EDGE SCROLL/ROTATION
	if thirdPerson_trackunit and not overview_mode then
		local update = false
		local tcam = overview_mode and trackCamOverview or trackCam
		if mx > vsx-2 then 
			tcam.heading = tcam.heading + dt*(s and 3 or 1)
			update = true
		elseif mx < 2 then
			tcam.heading = tcam.heading- dt*(s and 3 or 1)
			update = true
		end
		if my > vsy-2 then
			tcam.pitch = tcam.pitch - dt*(s and 3 or 1)
			update = true
		elseif my < 2 then
			tcam.pitch = tcam.pitch + dt*(s and 3 or 1)
			update = true
		end
		if update then
			TrackUnit(thirdPerson_trackunit)
		end
	elseif options.edgemove.value then
		if not movekey then --if not doing arrow key on keyboard: reset
			move = {}
		end
		
		if mx > vsx-2 then 
			move.right = true
		elseif mx < 2 then
			move.left = true
		end
		if my > vsy-2 then
			move.up = true
		elseif my < 2 then
			move.down = true
		end
		
	elseif options.rotateonedge.value then
		rot = {}
		if mx > vsx-2 then 
			rot.right = true 
		elseif mx < 2 then
			rot.left = true
		end
		if my > vsy-2 then
			rot.up = true
		elseif my < 2 then
			rot.down = true
		end
	end
	
	--//MISC
	--fpsmode = cs.name == "fps"
	if init or ((cs.name ~= "free") and (cs.name ~= "ov") and not thirdPerson_trackunit) then
		init = false
		spSendCommands("viewfree") 
		local cs = spGetCameraState()
		cs.tiltSpeed = 0
		cs.scrollSpeed = 0
		--cs.gndOffset = options.mingrounddist.value
		cs.gndOffset = 0
		spSetCameraState(cs,0)
	end
	
end

function widget:MouseMove(x, y, dx, dy, button)
	if rotate then
		local smoothed
		if rotate_transit then --if "rotateAtCursor" flag is True, then this will run 'once' to smoothen camera motion
			if spDiffTimers(spGetTimer(),rotate_transit)<1 then --smooth camera for in-transit effect
				smoothed = true
			else
				rotate_transit = nil --cancel in-transit flag
			end
		end
		if abs(dx) > 0 or abs(dy) > 0 then
			RotateCamera(x, y, dx, dy, smoothed, ls_have)
		end
		
		spWarpMouse(msx, msy)
		
		follow_timer = 0.6 --disable tracking for 1 second when middle mouse is pressed or when scroll is used for zoom
	elseif springscroll then
		
		if abs(dx) > 0 or abs(dy) > 0 then
			lockspringscroll = false
		end
		local dir = options.invertscroll.value and -1 or 1
					
		local cs = spGetCameraState()
		
		local speed = options.speedFactor.value * cs.py/1000 / 10
		local mxm = speed * dx * dir
		local mym = speed * dy * dir
		ScrollCam(cs, mxm, mym, 0)
		
		follow_timer = 0.6 --disable tracking for 1 second when middle mouse is pressed or when scroll is used for zoom
	end
end


function widget:MousePress(x, y, button) --called once when pressed, not repeated
	ls_have = false
	--overview_mode = false
    --if fpsmode then return end
	if lockspringscroll then
		lockspringscroll = false
		return true
	end
	
	-- Not Middle Click --
	if (button ~= 2) then
		return false
	end
	
	follow_timer = 4 --disable tracking for 4 second when middle mouse is pressed or when scroll is used for zoom
	
	local a,c,m,s = spGetModKeyState()
	
	if thirdPerson_trackunit then
		msx = cx
		msy = cy
		rotate = true
		return true
	end
	--[[
	spSendCommands('trackoff')
	spSendCommands('viewfree')
	if not (options.persistenttrackmode.value and (c or a)) then --Note: wont escape trackmode if pressing Ctrl or Alt in persistent trackmode, else: always escape.
		if trackmode then
			Spring.Echo("COFC: Unit tracking OFF")
		end
		trackmode = false
	end
	thirdPerson_trackunit = nil
	]]
	
	-- Reset --
	if a and c then
		ResetCam()
		return true
	end
	
	-- Above Minimap --
	if (spIsAboveMiniMap(x, y)) then
		return false
	end
	
	local cs = spGetCameraState()
	
	msx = x
	msy = y
	
	spSendCommands({'trackoff'})
	
	rotate = false
	-- Rotate --
	if a then
		spWarpMouse(cx, cy)
		ls_have = false
		rotate = true
		return true
	end
	-- Rotate World --
	if c then
		rotate_transit = nil
		if options.targetmouse.value then --if rotate world at mouse cursor: 
			
			local onmap, gx, gy, gz = VirtTraceRay(x,y, cs,true)
			if gx then  --Note: we don't block offmap position since VirtTraceRay() now work for offmap position.
				SetLockSpot2(cs,x,y) --lockspot at cursor position
				spSetCameraTarget(gx,gy,gz, 1) 
				
				--//update "ls_dist" with value from mid-screen's LockSpot because rotation is centered on mid-screen and not at cursor//--
				_,gx,gy,gz = VirtTraceRay(cx,cy,cs,true) --get ground position traced from mid of screen
				local dx,dy,dz = gx-cs.px, gy-cs.py, gz-cs.pz
				ls_dist = sqrt(dx*dx + dy*dy + dz*dz) --distance to ground 
				
				rotate_transit = spGetTimer() --trigger smooth in-transit effect in widget:MouseMove()
			end
			
		else
			SetLockSpot2(cs) --lockspot at center of screen
		end
		
		spWarpMouse(cx, cy) --move cursor to center of screen
		rotate = true
		msx = cx
		msy = cy
		return true
	end
	
	-- Scrolling --
	if options.smoothscroll.value then
		spWarpMouse(cx, cy)
		smoothscroll = true
	else
		springscroll = true
		lockspringscroll = not lockspringscroll
	end
	
	return true
	
end

function widget:MouseRelease(x, y, button)
	if (button == 2) then
		rotate = false
		smoothscroll = false
		springscroll = false
		return -1
	end
end

function widget:MouseWheel(wheelUp, value)
    if fpsmode then return end
	local alt,ctrl,m,shift = spGetModKeyState()
	local tcam = overview_mode and trackCamOverview or trackCam
	if thirdPerson_trackunit then  --move key for edge Scroll in 3rd person trackmode
		local delta = (wheelUp and -10 or 10)*math.log(tcam.dist)
		if overview_mode then
			delta = delta*5
		end
		tcam.dist = tcam.dist + delta
		if tcam.dist < 10 then
			tcam.dist = 10
		end
		return
	end
	
	if ctrl then
		return Tilt(shift, wheelUp and 1 or -1)
	elseif alt then
		--[[
		if overview_mode then --cancel overview_mode if Overview_mode + descending 
			local zoomin = not wheelUp
			if options.invertalt.value then
				zoomin = not zoomin
			end
			if zoomin then 
				overview_mode = false
			else return; end-- skip wheel if Overview_mode + ascending
		end
		]]
		return Altitude(wheelUp, shift)
	end
	
	--[[
	if overview_mode then --cancel overview_mode if Overview_mode + ZOOM-in
		local zoomin = not wheelUp
		if options.invertzoom.value then
			zoomin = not zoomin
		end
		if zoomin then
			overview_mode = false
		else return; end --skip wheel if Overview_mode + ZOOM-out
	end
	]]--
	
	follow_timer = 0.6 --disable tracking for 1 second when middle mouse is pressed or when scroll is used for zoom
	return Zoom(not wheelUp, shift)
end

function widget:KeyPress(key, modifier, isRepeat)
	local intercept = GroupRecallFix(key, modifier, isRepeat)
	if intercept then
		return true
	end

	--ls_have = false
	tilting = false
	
	if thirdPerson_trackunit then
		if keys[key] then
			local tcam = overview_mode and trackCamOverview or trackCam
			if key == key_code.left then
				tcam.heading = tcam.heading - 0.05
			elseif key == key_code.right then
				tcam.heading = tcam.heading + 0.05
			
			elseif key == key_code.up then
				tcam.pitch = tcam.pitch - 0.05
			
			elseif key == key_code.down then
				tcam.pitch = tcam.pitch + 0.05
			end
			TrackUnit(thirdPerson_trackunit)
		end
	end
	if fpsmode then return end
	if keys[key] then
		if modifier.ctrl or modifier.alt then
		
			local cs = spGetCameraState()
			SetLockSpot2(cs)
			if not ls_have then
				return
			end
			
		
			local speed = modifier.shift and 30 or 10 
			
			if key == key_code.right then 		RotateCamera(vsx * 0.5, vsy * 0.5, speed, 0, true, not modifier.alt)
			elseif key == key_code.left then 	RotateCamera(vsx * 0.5, vsy * 0.5, -speed, 0, true, not modifier.alt)
			elseif key == key_code.down then 	RotateCamera(vsx * 0.5, vsy * 0.5, 0, -speed, true, not modifier.alt)
			elseif key == key_code.up then 		RotateCamera(vsx * 0.5, vsy * 0.5, 0, speed, true, not modifier.alt)
			end
			return
		else
			movekey = true
			move[keys[key]] = true
		end
	elseif key == key_code.pageup then
		if modifier.ctrl then
			Tilt(modifier.shift, 1)
			return
		elseif modifier.alt then
			Altitude(true, modifier.shift)
			return
		else
			Zoom(true, modifier.shift, true)
			return
		end
	elseif key == key_code.pagedown then
		if modifier.ctrl then
			Tilt(modifier.shift, -1)
			return
		elseif modifier.alt then
			Altitude(false, modifier.shift)
			return
		else
			Zoom(false, modifier.shift, true)
			return
		end
	end
	tilting = false
end
function widget:KeyRelease(key)
	if keys[key] then
		move[keys[key]] = nil
	end
	if not (move.up or move.down or move.left or move.right) then
		movekey = nil
	end
end

local function DrawLine(x0, y0, c0, x1, y1, c1)
  glColor(c0); glVertex(x0, y0)
  glColor(c1); glVertex(x1, y1)
end

local function DrawPoint(x, y, c, s)
  --FIXME reenable later - ATIBUG glPointSize(s)
  glColor(c)
  glBeginEnd(GL_POINTS, glVertex, x, y)
end

function widget:DrawScreen()
    hideCursor = false
	if not cx then return end
    
	local x, y
	if smoothscroll then
		x, y = spGetMouseState()
		glLineWidth(2)
		glBeginEnd(GL_LINES, DrawLine, x, y, green, cx, cy, red)
		glLineWidth(1)
		
		DrawPoint(cx, cy, black, 14)
		DrawPoint(cx, cy, white, 11)
		DrawPoint(cx, cy, black,  8)
		DrawPoint(cx, cy, red,    5)
	
		DrawPoint(x, y, { 0, 1, 0 },  5)
	end
	
	local filefound	
	if smoothscroll or (rotate and ls_have) then
		filefound = glTexture(LUAUI_DIRNAME .. 'Images/ccc/arrows-dot.png')
	elseif rotate or lockspringscroll or springscroll then
		filefound = glTexture(LUAUI_DIRNAME .. 'Images/ccc/arrows.png')
	end
	
	if filefound then
	
		if smoothscroll then
			glColor(0,1,0,1)
		elseif (rotate and ls_have) then
			glColor(1,0.6,0,1)
		elseif rotate then
			glColor(1,1,0,1)
		elseif lockspringscroll then
			glColor(1,0,0,1)
		elseif springscroll then
			if options.invertscroll.value then
				glColor(1,0,1,1)
			else
				glColor(0,1,1,1)
			end
		end
		
		glAlphaTest(GL_GREATER, 0)
		
		if not (springscroll and not lockspringscroll) then
		    hideCursor = true
		end
		if smoothscroll then
			local icon_size2 = icon_size
			glTexRect(x-icon_size, y-icon_size2, x+icon_size, y+icon_size2)
		else
			glTexRect(cx-icon_size, cy-icon_size, cx+icon_size, cy+icon_size)
		end
		glTexture(false)

		glColor(1,1,1,1)
		glAlphaTest(false)		
	end
end

function widget:Initialize()
	helpText = explode( '\n', options.helpwindow.value )
	cx = vsx * 0.5
	cy = vsy * 0.5
	
	spSendCommands( 'unbindaction toggleoverview' )
	spSendCommands( 'unbindaction trackmode' )
	spSendCommands( 'unbindaction track' )
	spSendCommands( 'unbindaction mousestate' ) --//disable screen-panning-mode toggled by 'backspace' key
	
	--Note: the following is for compatibility with epicmenu.lua's zkkey framework
	if WG.crude then
		if WG.crude.GetHotkey then
			epicmenuHkeyComp[1] = WG.crude.GetHotkey("toggleoverview") --get hotkey
			epicmenuHkeyComp[2] = WG.crude.GetHotkey("trackmode")
			epicmenuHkeyComp[3] = WG.crude.GetHotkey("track")
			epicmenuHkeyComp[4] = WG.crude.GetHotkey("mousestate")
		end
		if 	WG.crude.SetHotkey then
			WG.crude.SetHotkey("toggleoverview",nil) --unbind hotkey
			WG.crude.SetHotkey("trackmode",nil)
			WG.crude.SetHotkey("track",nil)
			WG.crude.SetHotkey("mousestate",nil)
		end
	end
	
	--spSendCommands("luaui disablewidget SmoothScroll")
	if WG.SetWidgetOption then
		WG.SetWidgetOption("Settings/Camera","Settings/Camera","Camera Type","COFC") --tell epicmenu.lua that we select COFC as our default camera (since we enabled it!)
	end
	--OverviewAction()
	
	WG.COFC = {
	  GetThirdPersonTrackUnit = function() return thirdPerson_trackunit end,
	  SetThirdPersonTrackUnit = function(unitID, instant)
	    thirdPerson_trackunit = unitID
	    TrackUnit(unitID, instant)
	  end,
	  SetThirdPersonTrackParams = function(params)
	    local tcam = overview_mode and trackCamOverview or trackCam
	    tcam.dist = params.dist or tcam.dist
	    tcam.heading = params.heading or tcam.heading
	    tcam.pitch = params.pitch or tcam.pitch
	  end,
	  IsOverviewMode = function() return overview_mode end,
	}
end

function widget:Shutdown()
	spSendCommands{"viewta"}
	spSendCommands( 'bind any+tab toggleoverview' )
	spSendCommands( 'bind any+t track' )
	spSendCommands( 'bind ctrl+t trackmode' )
	spSendCommands( 'bind backspace mousestate' ) --//re-enable screen-panning-mode toggled by 'backspace' key
	spSendCommands("disticon " .. origIconDistance)
	
	--Note: the following is for compatibility with epicmenu.lua's zkkey framework
	if WG.crude and WG.crude.SetHotkey then
		WG.crude.SetHotkey("toggleoverview",epicmenuHkeyComp[1]) --rebind hotkey
		WG.crude.SetHotkey("trackmode",epicmenuHkeyComp[2])
		WG.crude.SetHotkey("track",epicmenuHkeyComp[3])
		WG.crude.SetHotkey("mousestate",epicmenuHkeyComp[4])
	end
	
	WG.COFC = nil
end

function widget:TextCommand(command)
	
	if command == "cofc help" then
		for i, text in ipairs(helpText) do
			echo('<COFCam['.. i ..']> '.. text)
		end
		return true
	elseif command == "cofc reset" then
		ResetCam()
		return true
	end
	return false
end   

function widget:UnitDestroyed(unitID) --transfer 3rd person trackmode to other unit or exit to freeStyle view
	if thirdPerson_trackunit and thirdPerson_trackunit == unitID then --return user to normal view if tracked unit is destroyed
		local isSpec = Spring.GetSpectatingState()
		local attackerID= Spring.GetUnitLastAttacker(unitID)
		if not isSpec then
			spSendCommands('trackoff')
			spSendCommands('viewfree')
			thirdPerson_trackunit = nil
			return
		end
		if Spring.ValidUnitID(attackerID) then --shift tracking toward attacker if it is alive (cinematic).
			Spring.SelectUnitArray({attackerID})
		end
		local selUnits = spGetSelectedUnits()--test select unit
		if not (selUnits and selUnits[1]) then --if can't select, then, check any unit in vicinity
			local x,_,z = spGetUnitPosition(unitID)
			local units = Spring.GetUnitsInCylinder(x,z, 100)
			if units and units[1] then
				Spring.SelectUnitArray({units[1]})
			end
		end
		selUnits = spGetSelectedUnits()--test select unit
		if selUnits and selUnits[1] and (not Spring.GetUnitIsDead(selUnits[1]) ) then --if we can select unit, and those unit is not dead in this frame, then: track them
			thirdPerson_trackunit = selUnits[1]
			TrackUnit(thirdPerson_trackunit)
		else
			thirdPerson_trackunit = false
		end
	end
end

--------------------------------------------------------------------------------
--Group Recall Fix--- (by msafwan, 9 Jan 2013)
--Remake Spring's group recall to trigger ZK's custom Spring.SetCameraTarget (which work for freestyle camera mode).
--------------------------------------------------------------------------------
local spGetUnitGroup = Spring.GetUnitGroup
local spGetGroupList  = Spring.GetGroupList 


--include("keysym.h.lua")
local previousGroup =99
local currentIteration = 1
local previousKey = 99
local previousTime = spGetTimer()
local groupNumber = {
	[KEYSYMS.N_1] = 1,
	[KEYSYMS.N_2] = 2,
	[KEYSYMS.N_3] = 3,
	[KEYSYMS.N_4] = 4,
	[KEYSYMS.N_5] = 5,
	[KEYSYMS.N_6] = 6,
	[KEYSYMS.N_7] = 7,
	[KEYSYMS.N_8] = 8,
	[KEYSYMS.N_9] = 9,
	[KEYSYMS.N_0] = 0,
}

function GroupRecallFix(key, modifier, isRepeat)
	if ( not modifier.ctrl and not modifier.alt and not modifier.meta) then --check key for group. Reference: unit_auto_group.lua by Licho
		local group
		if (key ~= nil and groupNumber[key]) then 
			group = groupNumber[key]	
		end
		if (group ~= nil) then
			local selectedUnits = spGetSelectedUnits()
			local groupCount = spGetGroupList() --get list of group with number of units in them
			if groupCount[group] ~= #selectedUnits then
				return false
			end
			for i=1,#selectedUnits do
				local unitGroup = spGetUnitGroup(selectedUnits[i])
				if unitGroup~=group then
					return false
				end
			end
			local unitID = selectedUnits[math.random(1,#selectedUnits)]
			thirdPerson_trackunit = unitID
			TrackUnit(unitID, false)
			return true
		end
		return false
	end
end
