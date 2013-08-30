local defaults = {
	distanceMod = 0.1,	-- we don't want to have to walk far to our targets
	minDistance = 1500,
	ap = 100,		-- ideally we want just enough armor piercing to defeat the target
	apModOver = 0.5,	-- too much, especially on kinetics (e.g. Chitose's railgun vs. Yng Commando) is just a waste
	apModUnder = 2,
	speedModOver = 3,	-- ditto for speed
	speedModUnder = 15,	-- low speed is especially bad because we might chase a target but never catch it!
	hpPerCostMod = -100,	-- go for glass cannons and squishy wizards first
	randomMod = 300,	-- random fudge factor; should help spread out targets a bit
}

local unitsByName = {
	luckystar = {},
	kungfufighter = {
		ap = 75,
		distanceMod = 0.07,
	},
	happytrigger = {
		distanceMod = 0.125,
	},
	placeholdersior = {
		distanceMod = 2,
	},
	yngcommando = {
		ap = 50,
		distanceMod = 0.08,
	},
	yngtiger = {
		ap = 125,
		apModOver = 0.4,
		apModUnder = 0.4,	-- our energy bombs don't get the huge armor penalties that kinetic weapons do
	},
	enclavestar = {
		distanceMod = 1.5,
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