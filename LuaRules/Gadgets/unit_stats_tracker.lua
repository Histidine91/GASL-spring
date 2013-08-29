--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
	return {
		name = "Stats Tracker",
		desc = "bla",
		author = "KingRaptor (L.J. Lim)",
		date = "2013.08.28",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if not (gadgetHandler:IsSyncedCode()) then
	return
end
--------------------------------------------------------------------------------
--SYNCED
--------------------------------------------------------------------------------
local DAMAGE_LEVELS = {
	{0.25, "severe"},
	{0.5, "moderate"},
	{0.8, "minor"}
}

local unitCosts = {}
--local unitHealth = {}
local angelsByUnitDef = {}
local angels = {}

for i=0,6 do
	angels[i] = {kills = 0, damage = 0, killCost = 0, damageCost = 0, repair = 0, deaths = 0}
end


for i=1,#UnitDefs do
	local angelCP = UnitDefs[i].customParams.angel
	if angelCP then
		angelsByUnitDef[i] = tonumber(angelCP)
	end
	unitCosts[i] = UnitDefs[i].customParams.cost
	--unitHealth[i] = UnitDefs[i].health
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID,
                            attackerID, attackerDefID, attackerTeam, projectileID)
	local health, maxHealth = Spring.GetUnitHealth(unitID)
	if not paralyzer then
		local healthFraction, healthFractionOld = health/maxHealth, (health + damage)/maxHealth
		for i=1,#DAMAGE_LEVELS do
			local params = DAMAGE_LEVELS[i]
			if healthFraction <= params[1] and healthFractionOld > params[1] then
				GG.EventWrapper.AddEvent("unitDamaged_" .. params[2], damage, unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
				break
			end
		end
	end
	
	if attackerDefID and angelsByUnitDef[attackerDefID] then
		local adjustedDamage = damage
		if paralyzer then
			adjustedDamage = adjustedDamage/5
		end
		
		local index = angelsByUnitDef[attackerDefID]
		angels[index].damage = angels[index].damage + adjustedDamage
		angels[index].damageCost = angels[index].damageCost + adjustedDamage/maxHealth * unitCosts[unitDefID]
	end
	--AddEvent("unitDamaged", damage, unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	local attackerID = Spring.GetUnitLastAttacker(unitID)
	local attackerDefID, attackerTeam
	if attackerID and attackerID > 0 then
		attackerDefID = Spring.GetUnitDefID(attackerID)
		attackerTeam = Spring.GetUnitTeam(attackerID)
		GG.EventWrapper.AddEvent("kill", (UnitDefs[unitDefID].power^0.5)*2+10, attackerID, attackerDefID, attackerTeam, unitID, unitDefID, unitTeam)
	end
	GG.EventWrapper.AddEvent("death", (UnitDefs[unitDefID].power^0.5)*2+10, unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
	
	if angelsByUnitDef[attackerDefID] then
		local index = angelsByUnitDef[attackerDefID]
		angels[index].kills = angels[index].kills + 1
		angels[index].killCost = angels[index].killCost + unitCosts[unitDefID]
	end
	if angelsByUnitDef[unitDefID] then
		local index = angelsByUnitDef[unitDefID]
		angels[index].deaths = angels[index].deaths + 1
	end
end

function GG.TrackRepairStats(repairerID, repairerDefID, unitID, unitDefID, amount)
	local index = angelsByUnitDef[repairerDefID]
	angels[index].repair = angels[index].repair + amount
end

function gadget:GameOver()
	for index=0,6 do
		for stat, value in pairs(angels[i]) do
			Spring.SetGameRulesParam(stat.."_"..index, value)
		end
	end
end