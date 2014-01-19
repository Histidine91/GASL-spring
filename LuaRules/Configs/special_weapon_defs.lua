include "LuaRules/Configs/customcmds.h.lua"

local color_skyblue = "\255\1\224\255"
local color_orange = "\255\255\128\1"

specialCMDs = {
	--[CMD_SPECIAL_WEAPON] = "generic",	-- generic command
	[CMD_HYPER_CANNON] = "hypercannon",
	[CMD_ANCHOR_CLAW] = "anchorclaw",
	--[CMD_FLIER_DANCE] = "flierdance",
	[CMD_STRIKE_BURST] = "strikeburst",
	--[CMD_REPAIR_WAVE] = "repairwave",
	[CMD_FATAL_ARROW] = "fatalarrow",
	
	[CMD_BURN_DRIVE] = "burndrive"
}

specialPowers = {
	hypercannon = {
		minRange = 800,
		maxRange = 3000,
		maxAngle = math.rad(5),
		cmdDesc = {
			id      = CMD_HYPER_CANNON,
			name    = "Hyper Cannon",
			action  = "specialweapon",
			cursor  = "DGun",
			texture = "LuaUI/Images/Commands/Bold/action.png",
			type    = CMDTYPE.ICON_UNIT,
			tooltip = color_skyblue.."Special Attack: Hyper Cannon\008\nFire an immensely powerful beam that wipes anything in its path",
		},
		scriptFunction = "HyperCannonTrigger",
		isSpiritAttack = true,
	},
	anchorclaw = {
		minRange = 400,
		maxRange = 1800,
		maxAngle = math.rad(30),
		cmdDesc = {
			id      = CMD_ANCHOR_CLAW,
			name    = "Anchor Claw",
			action  = "specialweapon",
			cursor  = "DGun",
			texture = "LuaUI/Images/Commands/Bold/action.png",
			type    = CMDTYPE.ICON_UNIT,
			tooltip = color_skyblue.."Special Attack: Anchor Claw\008\nSmashes a foe with twin crushing blows",
		},
		scriptFunction = "AnchorClawTrigger",
		isSpiritAttack = true,
	},
	strikeburst = {
		minRange = 600,
		maxRange = 1750,
		maxAngle = math.rad(5),
		cmdDesc = {
			id      = CMD_STRIKE_BURST,
			name    = "Strike Burst",
			action  = "specialweapon",
			cursor  = "DGun",
			texture = "LuaUI/Images/Commands/Bold/action.png",
			type    = CMDTYPE.ICON_UNIT,
			tooltip = color_skyblue.."Special Attack: Strike Burst\008\nGo to maximum rate of fire on all weapons, concentrated on a single target",
		},
		scriptFunction = "StrikeBurstTrigger",
		isSpiritAttack = true,
	},
	fatalarrow = {
		minRange = 1600,
		maxRange = 6000,
		maxAngle = math.rad(5),
		cmdDesc = {
			id      = CMD_FATAL_ARROW,
			name    = "Fatal Arrow",
			action  = "specialweapon",
			cursor  = "DGun",
			texture = "LuaUI/Images/Commands/Bold/action.png",
			type    = CMDTYPE.ICON_UNIT,
			tooltip = color_skyblue.."Special Attack: Fatal Arrow\008\nFire three railgun shots to erase target(s) at extreme range",
		},
		scriptFunction = "FatalArrowTrigger",
		isSpiritAttack = true,
		noEvent = true,
	},	
	burndrive = {
		minRange = 0,
		maxRange = 999999,
		maxAngle = math.rad(5),
		cmdDesc = {
			id      = CMD_BURN_DRIVE,
			name    = "Burn Drive",
			action  = "burndrive",
			cursor  = "Move",
			texture = "LuaUI/Images/Commands/Bold/sprint.png",
			type    = CMDTYPE.ICON_MAP,
			tooltip = color_orange.."Ability: Burn Drive\008\nAn extreme speed boost in a straight line",
		},
		scriptFunction = "BurnDriveTrigger",
		afterCommand = CMD.MOVE,
		cooldown = 30*60,
		energy = 1000,	-- it already uses a ton of energy just for the flying
	},
	
}

unitDefsWithSpecials = {
	[UnitDefNames.luckystar.id] = {"hypercannon"},
	[UnitDefNames.kungfufighter.id] = {"burndrive", "anchorclaw"},
	[UnitDefNames.happytrigger.id] = {"strikeburst"},
	[UnitDefNames.sharpshooter.id] = {"fatalarrow"},
}