--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Suppression",
		desc = "exactly what it says on the tin",
		author = "KingRaptor (L.J. Lim)",
		date = "2013.06.18",
		license = "Public Domain",
		layer = 0,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (not gadgetHandler:IsSyncedCode()) then
	return false
end

--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local spSetUnitRulesParam = Spring.SetUnitRulesParam
local spGetCommandQueue = Spring.GetCommandQueue
local spGetUnitPosition	= Spring.GetUnitPosition
local spGetUnitVectors	= Spring.GetUnitVectors

local tobool = Spring.Utilities.tobool

local UPDATE_PERIOD = 12
local DECAY_RATE = 0.01*UPDATE_PERIOD/30 -- 1% per second
local DECAY_DELAY = 7.5*30
local CURRENT_TARGET_MOD = 0.4	-- take 40% less suppression if we are engaging our attacker
local NO_TARGET_MOD = 0.9	-- take 10% less suppression if no attack order
local FLANKING_MOD = 0.5	-- scales from -50% suppression from frontal shots to +50% from rear
local SUPPRESSION_LEVELS = {
	{0.8, "severe"},
	{0.5, "moderate"},
	{0.25, "minor"}
}

local suppressionMod = {}
local flankingMod = {}
local weapons = {}
local units = {}	-- [unitID] = {suppression = (0 to 1), frame = gameframe, target = unitID}
local gameframe = 0

for i=1,#UnitDefs do
	suppressionMod[i] = tonumber(UnitDefs[i].customParams.suppressionmod) or 1
	flankingMod[i] = tonumber(UnitDefs[i].customParams.suppressionflankingmod or 1)
end

for i=1,#WeaponDefs do
	local wd = WeaponDefs[i]
	local damage = wd.damages[0]
	weapons[i] = {damage = damage, suppression = wd.customParams and wd.customParams.suppression or damage*0.01/100, noFlank = tobool(wd.customParams.suppression_noflank)}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetAttackerVector(unitID, attackerID)
	local frontDir, upDir = spGetUnitVectors(unitID)
	local ux, uy, uz = spGetUnitPosition(unitID)
	local ax, ay, az = spGetUnitPosition(attackerID)
	local dx, dy, dz = ax - ux, ay - uy, az - uz
	dx, dy, dz, d = GG.Vector.Normalized(dx, dy, dz)
	
	local dotUp = dx * upDir[1] + dy * upDir[2] + dz * upDir[3]
	local dotFront = dx * frontDir[1] + dy * frontDir[2] + dz * frontDir[3]
	return dotUp, dotFront
end

function GG.SetUnitSuppression(unitID, value)
	if not units[unitID] then
		return
	end
	units[unitID].suppression = value
	spSetUnitRulesParam(unitID, "suppression", value, {inlos = true})
end

function gadget:UnitDamaged(unitID, unitDefID, unitTeam, damage, paralyzer, weaponID,
                            attackerID, attackerDefID, attackerTeam, projectileID)
	if not (weaponID and units[unitID]) then
		return
	end
	
	local weaponData = weapons[weaponID]
	local suppressionDelta = weaponData.suppression * suppressionMod[unitDefID] --* damage/weaponData.damage 
	local suppressionDeltaBase = suppressionDelta
	local target = units[unitID].target
	if target == attackerID then
		suppressionDelta = suppressionDelta * CURRENT_TARGET_MOD
	elseif target == nil then
		suppressionDelta = suppressionDelta * NO_TARGET_MOD
	end
	-- flanking effects
	if attackerID and not (weaponData.noFlank) then
		local dotUp, dotFront = GetAttackerVector(unitID, attackerID)
		suppressionDelta = suppressionDelta - suppressionDeltaBase*dotFront*FLANKING_MOD*flankingMod[unitDefID]
	end
	if suppressionDelta < 0 then
		suppressionDelta = 0
	end
	
	local oldSuppression = units[unitID].suppression
	local newSuppression = math.min(oldSuppression + suppressionDelta, 1)
	units[unitID].suppression = newSuppression
	units[unitID].frame = gameframe + DECAY_DELAY
	spSetUnitRulesParam(unitID, "suppression", units[unitID].suppression, {inlos = true})
	GG.attUnits[unitID] = true
	
	-- GUI event
	for i=1,#SUPPRESSION_LEVELS do
		local params = SUPPRESSION_LEVELS[i]
		if newSuppression >= params[1] and oldSuppression < params[1] then
			GG.EventWrapper.AddEvent("unitSuppressed_" .. params[2], damage, unitID, unitDefID, unitTeam, attackerID, attackerDefID, attackerTeam)
			break
		end
	end
end

function gadget:GameFrame(n)
	gameframe = n
	if n%UPDATE_PERIOD == 0 then
		for unitID, data in pairs(units) do
			local queue = spGetCommandQueue(unitID, 1)
			local cmd = queue and queue[1]
			if cmd then
				if cmd.id == CMD.ATTACK then
					data.target = cmd.params[1]
				else
					data.target = nil
				end
			else
				data.target = nil
			end
			if n > data.frame then
				data.suppression = data.suppression - DECAY_RATE
				if data.suppression < 0 then
					data.suppression = 0
				end
				spSetUnitRulesParam(unitID, "suppression", data.suppression)
			end
		end
	end
end

function gadget:Initialize()
	local units = Spring.GetAllUnits()
	for i=1,#units do
		gadget:UnitCreated(units[i])
	end
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	units[unitID] = {suppression = 0, frame = 0}
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	units[unitID] = nil
end

function GG.GetUnitSuppression(unitID)
	return units[unitID] and units[unitID].suppression
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
