--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Hyper Cannon Handler",
		desc = "HYPAH CANNON, HASSHA! (damage handler)",
		author = "KingRaptor (L.J. Lim)",
		date = "2013-08-27",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local spGetUnitVectors 	= Spring.GetUnitVectors
local spGetUnitPiecePosDir = Spring.GetUnitPiecePosDir
local spGetUnitsInSphere = Spring.GetUnitsInSphere
local spGetUnitPosition = Spring.GetUnitPosition
local spGetUnitRadius	= Spring.GetUnitRadius
--local spGetUnitSeparation = Spring.GetUnitSeparation

local PIECE_NAME = "laserflare"
local DAMAGE_PER_FRAME = 100
local BEAM_RANGE = 2000
local BEAM_WIDTH = 60
local BEAM_LIFETIME = 30*5
local WEAPON_ID = WeaponDefNames.luckystar_hypercannon.id

local gameframe = Spring.GetGameFrame()
local hcUnits = {}

local function FireHyperCannon(unitID)
	hcUnits[unitID] = {life = BEAM_LIFETIME}
	local pieces = Spring.GetUnitPieceMap(unitID)
	hcUnits[unitID].piece = pieces[PIECE_NAME]
end
GG.FireHyperCannon = FireHyperCannon
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	hcUnits[unitID] = nil
end

function gadget:GameFrame(n)
	gameframe = n
	for unitID, data in pairs(hcUnits) do
		local px, py, pz, dx, dy, dz = spGetUnitPiecePosDir(unitID, data.piece)
		
		local possibleTargets = spGetUnitsInSphere(px, py, pz, BEAM_RANGE)
		for i = 1, #possibleTargets do
			local targetID = possibleTargets[i]
			
			local _,_,_,tx, ty, tz = spGetUnitPosition(targetID, true)
			local radius = spGetUnitRadius(targetID), true
			local isInBeam, dist = Spring.Utilities.IsPointInCylinder({px, py, pz}, {dx, dy, dz}, BEAM_RANGE^2, (BEAM_WIDTH + radius)^2, {tx, ty, tz}, true)
			
			if isInBeam then
				Spring.AddUnitDamage(targetID, DAMAGE_PER_FRAME, nil, unitID, WEAPON_ID)
			end			
		end
		data.life = data.life - 1
		if data.life == 0 then
			hcUnits[unitID] = nil
		end
	end
end

function gadget:Initialize()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------

end