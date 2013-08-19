include "LuaRules/Configs/customcmds.h.lua"

local color_skyblue = "\255\0\224\255"

specialCMDs = {
	--[CMD_SPECIAL_WEAPON] = "generic",	-- generic command
	[CMD_HYPER_CANNON] = "hypercannon",
	[CMD_ANCHOR_CLAW] = "anchorclaw",
	[CMD_FLIER_DANCE] = "flierdance",
	[CMD_STRIKE_BURST] = "strikeburst",
	[CMD_REPAIR_WAVE] = "repairwave",
	[CMD_FATAL_ARROW] = "fatalarrow",
}

specialWeapons = {
	hypercannon = {
		minRange = 500,
		maxRange = 2000,
		maxAngle = math.rad(5),
		cmdDesc = {
			id      = CMD_HYPER_CANNON,
			name    = "Hyper Cannon",
			action  = "hypercannon",
			cursor  = "DGun",
			texture = "LuaUI/Images/Commands/Bold/action.png",
			type    = CMDTYPE.ICON_UNIT,
			tooltip = color_skyblue.."Special Attack\008\nFire an immensely powerful beam that wipes anything in its path",
		},
		scriptFunction = "HyperCannonTrigger"
	},
	anchorclaw = {
		minRange = 300,
		maxRange = 1400,
		maxAngle = math.rad(30),
		cmdDesc = {
			id      = CMD_ANCHOR_CLAW,
			name    = "Anchor Claw",
			action  = "anchorclaw",
			cursor  = "DGun",
			texture = "LuaUI/Images/Commands/Bold/action.png",
			type    = CMDTYPE.ICON_UNIT,
			tooltip = color_skyblue.."Special Attack\008\nSmashes a foe with twin crushing blows",
		},
		scriptFunction = "AnchorClawTrigger"
	}
}

unitDefsWithSpecials = {
	[UnitDefNames.luckystar.id] = "hypercannon",
	[UnitDefNames.kungfufighter.id] = "anchorclaw",
}