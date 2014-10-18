local defs = {
	{unitDefID = UnitDefNames.yngcommando.id, chance = 1, cooldown = 60000},
	{unitDefID = UnitDefNames.yngtiger.id, chance = 1, cooldown = 90000},
}

local sumOfChance = 0
for i=1,#defs do
	local entry = defs[i]
	entry.chance = entry.chance or 1
	sumOfChance = sumOfChance + entry.chance
end
for i=1,#defs do
	local entry = defs[i]
	entry.chance = entry.chance/sumOfChance
end

return defs