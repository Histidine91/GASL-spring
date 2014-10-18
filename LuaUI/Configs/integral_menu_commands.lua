VFS.Include("LuaRules/Configs/customcmds.h.lua")

--FIXME: use this table until state tooltip detection is fixed
local tooltips = {
	priority = "Priority: Set construction priority (low, normal, high)",
	miscpriority = "Misc Priority: Set priority for morph or stockpile (low, normal, high)",
	retreat = "Retreat: Retreat to closest retreat point at 30/60/90% of health (right-click to disable)",
	landat = "Repair level: set the HP % at which this aircraft will go to a repair pad (0, 30, 50, 80)",
	factoryGuard = "Auto Assist: Newly built constructors automatically assist their factory",
	diveBomb = "\255\90\255\90Green\255\255\255\255:Dive For Shielded Target\n\255\255\255\90Yellow\255\255\255\255:Dive For All Target\n\255\255\90\90Red\255\255\255\255:Always Fly Low\n\255\90\90\90Grey\255\255\255\255:Always Fly High", --override tooltip supplied by unit_bomber_dive.lua gadget.
	floatState = "\255\90\255\90Green\255\255\255\255:Always float \n\255\90\90\90Grey\255\255\255\255:Float to fire\n\255\255\90\90Red\255\255\255\255:Never float",
	fireState = "Fire State: Sets under what conditions a unit will fire without an explicit attack order (never, when attacked, always)",
	moveState = "Move State: Sets how far out of its way a unit will move to attack enemies",
	["repeat"] = "Repeat: if on the unit will continously push finished orders to the end of its order queue",
}

local factories = {
	factorycloak = {order = 1},
	factoryshield = {order = 2},
	factoryveh = {order = 3},
	factoryhover = {order = 4},
	factorygunship = {order = 5},
	factoryplane = {order = 6},
	factoryspider = {order = 7},
	factoryjump = {order = 8},
	factorytank = {order = 9},
	factoryamph = {order = 10},
	corsy = {order = 11},
    striderhub = {order = 12},
}

--Integral menu is NON-ROBUST
--all buildings (except facs) need a row or they won't appear!
--you can put too many things into the same row, but the buttons will be squished
local econ = {
	cormex = {order = 1, row = 1},
	armwin = {order = 2, row = 2},
	armsolar = {order = 3, row = 2},
	geo = {order = 4, row = 2},
	armfus = {order = 5, row = 2},
	cafus = {order = 6, row = 2},
	armmstor = {order = 7, row = 3},
	armestor = {order = 8, row = 3},
	armnanotc = {order = 9, row = 3},
	armasp = {order = 10, row = 3},
}

local defense = {
	corrl = {order = 0, row = 1},
	corllt = {order = 1, row = 1},
	armdeva = {order = 2, row = 1},
	armartic = {order = 3, row = 1},
--	corgrav = {order = 4, row = 1},
	armpb = {order = 5, row = 1},
	corhlt = {order = 6, row = 1},
--	armanni = {order = 7, row = 1},

--	corrl = {order = 8, row = 2},
	corrazor = {order = 9, row = 2},
	missiletower = {order = 10, row = 2},
	corflak = {order = 11, row = 2},
	armcir = {order = 12, row = 2},
	screamer = {order = 13, row = 2},

--	armartic = {order = 3, row = 3},
	corgrav = {order = 4, row = 3},
	cortl = {order = 14, row = 3},
	cordoom = {order = 16, row = 3},
	armanni = {order = 17, row = 3},
	corjamt = {order = 18, row = 3},
}

local aux = {	--merged into special
	corrad = {order = 10, row = 1},
	armsonar = {order = 11, row = 1},
	armjamt = {order = 12, row = 1},
	armarad = {order = 14, row = 1},
--	corjamt = {order = 12, row = 1},
	--armasp = {order = 15, row = 1},
}

local super = {	--merged into special
	missilesilo = {order = 15, row = 1},
	armamd = {order = 16, row = 1},
	--missilesilo = {order = 1, row = 2},
	corbhmth = {order = 2, row = 2},
	armbrtha = {order = 3, row = 2},
	corsilo = {order = 4, row = 2},
	zenith = {order = 5, row = 2},
	raveparty = {order = 6, row = 2},
	mahlazer = {order = 7, row = 2},
	--zenith = {order = 1, row = 3},
}

--manual entries not needed; menu has autodetection
local common_commands = {}
local states_commands = {}

local factory_commands = {}
local econ_commands = {}
local defense_commands = {}
local special_commands = {}

local function CopyBuildArray(source, target)
	for name, value in pairs(source) do
		udef = (UnitDefNames[name])
		if udef then
			target[-udef.id] = value
		end
	end
end

CopyBuildArray(factories, factory_commands)
CopyBuildArray(econ, econ_commands)
CopyBuildArray(aux, special_commands)
CopyBuildArray(defense, defense_commands)
CopyBuildArray(super, special_commands)

-- Global commands defined here - they have cmdDesc format + 
local globalCommands = {
--[[	{
		name = "crap",
		texture= 'LuaUi/Images/move_hold.png',
		id = math.huge,
		OnClick = {function() 
			Spring.SendMessage("crap")
		end }
	}
	{
		id      = CMD_RETREAT_ZONE
		type    = CMDTYPE.ICON_MAP,
		tooltip = 'Place a retreat zone. Units will retreat there. Constructors placed in it will repair units.',
		cursor  = 'Repair',
		action  = 'sethaven',
		params  = { }, 
		texture = 'LuaUI/Images/ambulance.png',
	}]]--
}

-- Command overrides. State commands by default expect array of textures, one for each state.
-- You can specify texture, text,tooltip, color
local imageDir = 'LuaUI/Images/commands/'

--[[
local overrides = {
	[CMD.ATTACK] = { texture = imageDir .. 'attack.png',  text= '\255\0\255\0A\008ttack'},
	[CMD.STOP] = { texture = imageDir .. 'cancel.png', color={1,0,0,1.2}, text= '\255\0\255\0S\008top'},
	[CMD.FIGHT] = { texture = imageDir .. 'fight.png',text= '\255\0\255\0F\008ight'},
	[CMD.GUARD] = { texture = imageDir .. 'guard.png', text= '\255\0\255\0G\008uard'},
	[CMD.MOVE] = { texture = imageDir .. 'move.png', text= '\255\0\255\0M\008ove'},
	[CMD.PATROL] = { texture = imageDir .. 'patrol.png', text= '\255\0\255\0P\008atrol'},
	[CMD.WAIT] = { texture = imageDir .. 'wait.png', text= '\255\0\255\0W\008ait'},
	
	[CMD.REPAIR] = {text= '\255\0\255\0R\008epair', texture = imageDir .. 'repair.png'},
	[CMD.RECLAIM] = {text= 'R\255\0\255\0e\008claim', texture = imageDir .. 'reclaim.png'},
	[CMD.RESURRECT] = {text= 'Resurrec\255\0\255\0t\008', texture = imageDir .. 'resurrect.png'},
	[CMD_BUILD] = {text = '\255\0\255\0B\008uild'},
	[CMD.DGUN] = { texture = imageDir .. 'dgun.png', text= '\255\0\255\0D\008Gun'},
	
	[CMD_RAMP] = {text = 'Ramp', texture = imageDir .. 'ramp.png'},
	[CMD_LEVEL] = {text = 'Level', texture = imageDir .. 'level.png'},
	[CMD_RAISE] = {text = 'Raise', texture = imageDir .. 'raise.png'},
	[CMD_SMOOTH] = {text = 'Smooth', texture = imageDir .. 'smooth.png'},
	[CMD_RESTORE] = {text = 'Restore', texture = imageDir .. 'restore.png'},
	
	[CMD_AREA_MEX] = {text = 'Mex', texture = 'LuaUi/Images/ibeam.png'},
	[CMD_JUMP] = {text = 'Jump', texture = imageDir .. 'Bold/jump.png'},	
	
	[CMD.ONOFF] = { texture = {imageDir .. 'states/off.png', imageDir .. 'states/on.png'}, text=''},
	[CMD_UNIT_AI] = { texture = {imageDir .. 'states/bulb_off.png', imageDir .. 'states/bulb_on.png'}, text=''},
	[CMD.REPEAT] = { texture = {imageDir .. 'states/repeat_off.png', imageDir .. 'states/repeat_on.png'}, text=''},
	[CMD.CLOAK] = { texture = {imageDir .. 'states/cloak_off.png', imageDir .. 'states/cloak_on.png'}, text ='', tooltip =  'Unit cloaking state - press \255\0\255\0K\008 to toggle'},
	[CMD_CLOAK_SHIELD] = { texture = {imageDir .. 'states/areacloak_off.png', imageDir .. 'states/areacloak_on.png'}, text ='',},
	[CMD_STEALTH] = { texture = {imageDir .. 'states/stealth_off.png', imageDir .. 'states/stealth_on.png'}, text ='', },
	[CMD_PRIORITY] = { texture = {imageDir .. 'states/wrench_low.png', imageDir .. 'states/wrench_med.png', imageDir .. 'states/wrench_high.png'}, text='', tooltip = tooltips.priority},
	[CMD.MOVE_STATE] = { texture = {imageDir .. 'states/move_hold.png', imageDir .. 'states/move_engage.png', imageDir .. 'states/move_roam.png'}, text=''},
	[CMD.FIRE_STATE] = { texture = {imageDir .. 'states/fire_hold.png', imageDir .. 'states/fire_return.png', imageDir .. 'states/fire_atwill.png'}, text=''},
	[CMD_RETREAT] = { texture = {imageDir .. 'states/retreat_off.png', imageDir .. 'states/retreat_30.png', imageDir .. 'states/retreat_60.png', imageDir .. 'states/retreat_90.png'}, text=''},
}]]

local overrides = {
	[CMD.ATTACK] = { texture = imageDir .. 'Bold/attack.png'},
	[CMD.STOP] = { texture = imageDir .. 'Bold/cancel.png'},
	[CMD.FIGHT] = { texture = imageDir .. 'Bold/fight.png'},
	[CMD.GUARD] = { texture = imageDir .. 'Bold/guard.png'},
	[CMD.MOVE] = { texture = imageDir .. 'Bold/move.png'},
	[CMD.PATROL] = { texture = imageDir .. 'Bold/patrol.png'},
	[CMD.WAIT] = { texture = imageDir .. 'Bold/wait.png'},
	
	[CMD.REPAIR] = {texture = imageDir .. 'Bold/repair.png'},
	[CMD.RECLAIM] = {texture = imageDir .. 'Bold/reclaim.png'},
	[CMD.RESURRECT] = {texture = imageDir .. 'Bold/resurrect.png'},
	[CMD.MANUALFIRE] = { texture = imageDir .. 'Bold/dgun.png'},

	[CMD.LOAD_UNITS] = { texture = imageDir .. 'Bold/load.png'},
	[CMD.UNLOAD_UNITS] = { texture = imageDir .. 'Bold/unload.png'},
	[CMD.AREA_ATTACK] = { texture = imageDir .. 'Bold/areaattack.png'},
	
	[CMD_JUMP] = {texture = imageDir .. 'Bold/jump.png'},	
	
	[CMD_ONECLICK_WEAPON] = {},--texture = imageDir .. 'Bold/action.png'},
	[CMD_UNIT_SET_TARGET_CIRCLE] = {text='', texture = imageDir .. 'Bold/settarget.png'},
	[CMD_UNIT_CANCEL_TARGET] = {text='', texture = imageDir .. 'Bold/canceltarget.png'},
	
	-- states
	[CMD.ONOFF] = { texture = {imageDir .. 'states/off.png', imageDir .. 'states/on.png'}, text=''},
	[CMD_UNIT_AI] = { texture = {imageDir .. 'states/bulb_off.png', imageDir .. 'states/bulb_on.png'}, text=''},
	[CMD.REPEAT] = { texture = {imageDir .. 'states/repeat_off.png', imageDir .. 'states/repeat_on.png'}, text='', tooltip = tooltips["repeat"]},
	[CMD.CLOAK] = { texture = {imageDir .. 'states/cloak_off.png', imageDir .. 'states/cloak_on.png'},
		text ='', tooltip =  'Unit cloaking state - press \255\0\255\0K\008 to toggle'},
	[CMD_CLOAK_SHIELD] = { texture = {imageDir .. 'states/areacloak_off.png', imageDir .. 'states/areacloak_on.png'}, 
		text ='',	tooltip = 'Area Cloaker State'},
	[CMD_STEALTH] = { texture = {imageDir .. 'states/stealth_off.png', imageDir .. 'states/stealth_on.png'}, text ='', },
	[CMD.MOVE_STATE] = { texture = {imageDir .. 'states/move_hold.png', imageDir .. 'states/move_engage.png', imageDir .. 'states/move_roam.png'}, text='', tooltip = tooltips.moveState},
	[CMD.FIRE_STATE] = { texture = {imageDir .. 'states/fire_hold.png', imageDir .. 'states/fire_return.png', imageDir .. 'states/fire_atwill.png'}, text='', tooltip = tooltips.fireState},
	[CMD_RETREAT] = { texture = {imageDir .. 'states/retreat_off.png', imageDir .. 'states/retreat_30.png', imageDir .. 'states/retreat_60.png', imageDir .. 'states/retreat_90.png'},
		text='', tooltip = tooltips.retreat,},
	[CMD.IDLEMODE] = { texture = {imageDir .. 'states/fly_on.png', imageDir .. 'states/fly_off.png'}, text=''},	
	[CMD.AUTOREPAIRLEVEL] = { texture = {imageDir .. 'states/landat_off.png', imageDir .. 'states/landat_30.png', imageDir .. 'states/landat_50.png', imageDir .. 'states/landat_80.png'},
		text = '', tooltip = tooltips.landat,},
	[CMD.TRAJECTORY] = { texture = {imageDir .. 'states/traj_low.png', imageDir .. 'states/traj_high.png'}, text=''},
	[CMD_SET_ATTACK_SPEED] = { texture = {imageDir .. 'states/attackspeed_stationary.png', imageDir .. 'states/attackspeed_combat.png', imageDir .. 'states/attackspeed_full.png'}, text = '' },
	}

-- noone really knows what this table does but it's needed for epic menu to get the hotkey
local custom_cmd_actions = {
	-- states are 2, targeted commands (e.g. attack) are 1, instant commands (e.g. selfd) are 3
	-- can (probably) set to 1 instead of 3 if order doesn't need to be queueable
	--SPRING COMMANDS
	selfd=3,
	attack=1,
	stop=3,
	fight=1,
	guard=1,
	move=1,
	patrol=1,
	wait=3,
	repair=1,
	reclaim=1,
	resurrect=1,
	manualfire=1,
	loadunits=1,
	unloadunits=1,
	areaattack=1,
	
	-- states
	onoff=2,
	['repeat']=2,
	cloak=2,
	movestate=2,
	firestate=2,
	idlemode=2,
	autorepairlevel=2,
	      
	--CUSTOM COMMANDS
	sethaven=1,
	jump=1,
	find_carrier=3,
	embark=3,
	disembark=3,
	oneclickwep=3,
	settarget=1,
	settargetcircle=1,
	canceltarget=3,
	setferry=1, 
	radialmenu=3,
	placebeacon=1,
	buildprev=1,
	
	hypercannon=1,
	anchorclaw=1,
	flierdance=1,
	strikeburst=1,
	repairwave=3,
	fatalarrow=1,
	
	-- terraform
	rampground=1,
	levelground=1,
	raiseground=1,
	smoothground=1,
	restoreground=1,
	--terraform_internal=1,
	
	resetfire=3,
	resetmove=3,
	
	--states
--	stealth=2, --no longer applicable
	cloak_shield=2,
	retreat=2,
	['luaui noretreat']=2,
	dontfireatradar=2,
	antinukezone=2,
	unitai=2,
	unit_kill_subordinates=2,
	autoassist=2,	
	airstrafe=2,
	divestate=2,
	setattackspeed=2,
}


return common_commands, states_commands, factory_commands, econ_commands, defense_commands, special_commands, globalCommands, overrides, custom_cmd_actions