local defaults = {
	distanceMod = 0.1,	-- we don't want to have to walk far to our targets
	minDistance = 1500,
	ap = 100,		-- ideally we want just enough armor piercing to defeat the target
	apModOver = 2.5,	-- too much, especially on kinetics (e.g. Chitose's railgun vs. Yng Commando) is just a waste
	apModUnder = 5,
	speedModOver = 2.5,	-- ditto for speed
	speedModUnder = 12.5,	-- low speed is especially bad because we might chase a target but never catch it!
	largeTargetBonus = 0,	-- raise to make bombers go after big guys, lower to make fighters stay away from them
	hpPerCostMod = 50,	-- go for glass cannons and squishy wizards first
	randomMod = 200,	-- random fudge factor; should help spread out targets a bit
}

local unitsByName = {
	luckystar = {},
	kungfufighter = {
		ap = 75,
		distanceMod = 0.07,
		largeTargetBonus = -150,
	},
	happytrigger = {
		distanceMod = 0.125,
		largeTargetBonus = 250,
	},
	sharpshooter = {
		ap = 200,
		minDistance = 2500,
		distanceMod = 0.11,
		largeTargetBonus = 400,
	},
	placeholdersior = {
		ap = 125,
		distanceMod = 0.4,
		largeTargetBonus = 400,
	},
	yngcommando = {
		ap = 50,
		distanceMod = 0.08,
		largeTargetBonus = -400,
	},
	yngtiger = {
		ap = 125,
		apModOver = 1,
		apModUnder = 1,	-- our energy bombs don't get the huge armor penalties that kinetic weapons do
		largeTargetBonus = 800,
	},
	enclavestar = {
		distanceMod = 0.2,
		minDistance = 2000,
	},
}
local units = {}
for unitName, data in pairs(unitsByName) do
	if UnitDefNames[unitName] then
		data = Spring.Utilities.MergeTable(data, defaults)
		units[UnitDefNames[unitName].id] = data
	end
end

return defaults, units