include "LuaRules/Configs/customcmds.h.lua"

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
			tooltip = "Fire an immensely powerful beam that wipes anything in its path",
		},
		scriptFunction = "HyperCannonTrigger"
	},
}

unitDefsWithSpecials = {
	[UnitDefNames.luckystar.id] = "hypercannon",
}