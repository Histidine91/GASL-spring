--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Fatal Arrow Handler",
		desc = "Shot through the heart",
		author = "KingRaptor (L.J. Lim)",
		date = "2014-01-19",
		license = "GNU GPL, v2 or later",
		layer = 0,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local CONE_ANGLE = math.rad(15)
local MAX_RANGE = 6000

local unitDefsWithArrows = {
	[UnitDefNames.sharpshooter.id] = {piece = "railgunflare", texture = "LuaRules/Images/wingbow.png", color = {0.8,0.8,1,0.8}, bounds = {-36,36,12,-36}, ttl = 90},
}

local function GetTargetCircleRadius(distance)
	return distance*math.tan(CONE_ANGLE)
end

local function GetUnitMidPos(unitID)
	local _,_,_,x,y,z = Spring.GetUnitPosition(unitID, true)
	return x,y,z
end

if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local targets = {}	-- [unitID] = {target1, target2, target3}
local targetsByTargetID = {}	-- [unitID] = attackerID
local allow = false
local reinitialized = false
local toClearBows = {}

_G.targets = targets

local function GetTarget(unitID)
	local targetArray = targets[unitID]
	if not targetArray then
		return nil
	end
	if #targetArray == 0 then
		targets[unitID] = nil
		return nil
	end
	local targetID = targetArray[1]
	allow = true
	Spring.GiveOrderToUnit(unitID, CMD.ATTACK, {targetID}, 0)
	Spring.SetUnitTarget(unitID, targetID)
	allow = false
	return targetID
end

local function ClearTargets(unitID)
	local targetArray = targets[unitID]
	if not targetArray then
		return nil
	end
	for i=1,#targetArray do
		local targetID = targetArray[i]
		targetsByTargetID[targetID] = nil
	end
	targets[unitID] = nil
	local unitDefID = Spring.GetUnitDefID(unitID)
	toClearBows[unitID] = unitDefID
end

--[[
local function GetTargetStatus(unitID)
	local targetArray = targets[unitID]
	if not targetArray then
		return
	end
	for i=#targetArray,1,-1 do
		local targetID = targetArray[i]
		if Spring.GetUnitIsDead(targetID) then
			targetArray[i] = nil
		end
	end
end
]]

local function SearchForTargets(unitID, targetID)
	if not targetID then return end
	local tx, ty, tz = GetUnitMidPos(targetID, true)
	if not tx and ty and tz then return end
	
	targets[unitID] = {targetID}
	targetsByTargetID[targetID] = unitID
	local count = 1
	local unitTeam = Spring.GetUnitTeam(unitID)
	local distance = Spring.GetUnitSeparation(unitID, targetID, false)
	local radius = GetTargetCircleRadius(distance)
	local extraTargets = Spring.GetUnitsInSphere(tx, ty, tz, radius)
	for _,etID in pairs(extraTargets) do
		local etTeam = Spring.GetUnitTeam(etID)
		if not Spring.AreTeamsAllied(unitTeam, etTeam) then
			count = count + 1
			targets[unitID][count] = etID
			targetsByTargetID[etID] = unitID
			if count == 5 then
				break
			end
		end
	end
	SendToUnsynced("fatalArrow_AddBowUnit", unitID)
end

function gadget:UnitDestroyed(unitID, unitDefID, unitTeam)
	local attackerID = targetsByTargetID[unitID]
	if attackerID then
		local targetArray = targets[attackerID]
		for i=#targetArray,1,-1 do
			if targetArray[i] == unitID then
				table.remove(targetArray, i)
			end
		end
	end
	targetsByTargetID[unitID] = nil
	if unitDefsWithArrows[unitDefID] then
		SendToUnsynced("fatalArrow_UnitDestroyed", unitID, unitDefID, unitTeam)
	end
end

function gadget:AllowCommand(unitID, unitDefID, teamID, cmdID, cmdParams, cmdOptions)
	if allow then
		return true
	end
	return (not targets[unitID])
end

function gadget:Initialize()
	GG.FatalArrow = {
		GetTarget = GetTarget,
		SearchForTargets = SearchForTargets,
		ClearTargets = ClearTargets,
	}
	local unitList = Spring.GetAllUnits()
end

function gadget:GameFrame(n)
	if not reinitialized then
		local unitList = Spring.GetAllUnits()
		for i=1,#(unitList) do
			local ud = Spring.GetUnitDefID(unitList[i])
			local team = Spring.GetUnitTeam(unitList[i])
			gadget:UnitCreated(unitList[i], ud, team)
		end
		reinitialized = true
	end
	for unitID, unitDefID in pairs(toClearBows) do
		SendToUnsynced("fatalArrow_RemoveBowUnit", unitID, unitDefID)
		toClearBows[unitID] = nil
	end
	SendToUnsynced("fatalArrow_GameFrame", n)
end

function gadget:UnitCreated(unitID, unitDefID, unitTeam)
	if unitDefsWithArrows[unitDefID] then
		SendToUnsynced("fatalArrow_UnitCreated", unitID, unitDefID, unitTeam)
	end
end

function gadget:Shutdown()
	GG.FatalArrow = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
else
--------------------------------------------------------------------------------
-- unsynced
--------------------------------------------------------------------------------
VFS.Include("LuaRules/Configs/customcmds.h.lua")

local spGetMouseState = Spring.GetMouseState
local spTraceScreenRay = Spring.TraceScreenRay
local spGetUnitPiecePosDir = Spring.GetUnitPiecePosDir
local spGetUnitHeading = Spring.GetUnitHeading
local spGetUnitRulesParam = Spring.GetUnitRulesParam
local spGetFeaturePosition = Spring.GetFeaturePosition
local spGetCameraPosition = Spring.GetCameraPosition
local spGetActiveCommand = Spring.GetActiveCommand
local spGetSelectedUnits = Spring.GetSelectedUnits
local spIsUnitVisible = Spring.IsUnitVisible

local unitsWithArrows = {}	-- [unitID] = {piece = piece, unitDefID = unitDefID}
local drawBows = {}	--[unitID] = expireFrame
local lastTexture
local gameframe = Spring.GetGameFrame()

local UPDATE_PERIOD = 0.05
local circleDivs = 65
local radstep = (2.0 * math.pi) / circleDivs
local color1 = {1, 0.2, 0.2, 0}
local color2 = {1, 0.2, 0.2, 0.5}

local selectedUnit = (Spring.GetSelectedUnits() or {})[1]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function UnitCreated(_, unitID, unitDefID, unitTeam)
	local data = unitDefsWithArrows[unitDefID]
	local pieceMap = Spring.GetUnitPieceMap(unitID)
	local piece = pieceMap[data.piece]
	unitsWithArrows[unitID] = {piece = piece, unitDefID = unitDefID}
end

local function UnitDestroyed(_, unitID, unitDefID, unitTeam)
	unitsWithArrows[unitID] = nil
	drawBows[unitID] = nil
end

local function AddBowUnit(_, unitID, unitDefID)
	drawBows[unitID] = -1
end

local function RemoveBowUnit(_, unitID, unitDefID)
	drawBows[unitID] = unitDefsWithArrows[unitDefID].ttl + gameframe
end

local function GameFrame(_, frame)
	gameframe = frame
	for unitID, expireFrame in pairs(drawBows) do
		if expireFrame ~= -1 and expireFrame < frame then
			drawBows[unitID] = nil
		end
	end
end

local function DrawCircle(radius)
	local radstep = (2.0 * math.pi) / circleDivs
	for i = 1, circleDivs do
		local a1 = (i * radstep)
		local a2 = ((i+1) * radstep)
		gl.Color(color1)
		gl.Vertex(0, 0, 0)
		gl.Color(color2)
		gl.Vertex(math.sin(a1)*radius, 0, math.cos(a1)*radius)
		gl.Vertex(math.sin(a2)*radius, 0, math.cos(a2)*radius)
	end
end

-- look for a unit or feature first
-- if none, then just get us the water level
local function GetMouseTargetPosition(recurse)
	local mx, my = spGetMouseState()
	local mouseTargetType, mouseTarget = spTraceScreenRay(mx, my, false, false, false, not recurse)
  
	if (mouseTargetType == "ground") then
		if recurse then
			return mouseTarget[1], mouseTarget[2], mouseTarget[3]
		else
			return GetMouseTargetPosition(true)
		end
	elseif (mouseTargetType == "unit") then
		return GetUnitMidPos(mouseTarget)
	elseif (mouseTargetType == "feature") then
		return spGetFeaturePosition(mouseTarget)
	else
		return nil
	end
end

function gadget:DrawWorldPreUnit()
	for unitID, expireFrame in pairs(drawBows) do
		if unitsWithArrows[unitID] and spIsUnitVisible(unitID) then
			local unitData = unitsWithArrows[unitID]
			local px,py,pz,pdx,pdy,pdz = spGetUnitPiecePosDir(unitID, unitData.piece)
			local unitDefData = unitDefsWithArrows[unitData.unitDefID]
			local tx1, ty1, tx2, ty2 = unpack(unitDefData.bounds)
			local rx = spGetUnitRulesParam(unitID, "pitch")	-- -math.atan2(pdy, (pdx^2+pdz^2)^0.5)
			local ry = spGetUnitRulesParam(unitID, "heading")	-- spGetUnitHeading(unitID)/65536*2*math.pi
			local rz = spGetUnitRulesParam(unitID, "roll")
			local wantedTexture = unitDefData.texture
			local alpha = (expireFrame == -1) and 1 or (expireFrame - gameframe)/unitDefData.ttl
			if alpha > 1 then
				alpha = 1
			end
			gl.PushMatrix()
			local r,g,b,a = unpack(unitDefData.color)
			a = a * alpha
			gl.Color(r,g,b,a)
			if lastTexture ~= wantedTexture then
				gl.Texture(wantedTexture)
				lastTexture = wantedTexture
			end
			gl.Translate(px, py, pz)
			gl.Rotate(math.deg(rx), 1, 0, 0)
			gl.Rotate(math.deg(ry)-90, 0, 1, 0)
			gl.Rotate(math.deg(rz), pdx, pdy, pdz)
			gl.TexRect(tx1, ty1, tx2, ty2)
			--gl.Rotate()
			gl.Color(1,1,1,1)
			gl.Texture(false)
			lastTexture = nil
			gl.PopMatrix()
		end
	end
end

function gadget:DrawWorld()
	local selectedUnits = spGetSelectedUnits()
	local command = select(2, spGetActiveCommand())
	if selectedUnit and command == CMD_FATAL_ARROW then
		local distance
		local command = select(2, spGetActiveCommand())
		local cx, cy, cz = GetMouseTargetPosition()
		local ux, uy, uz = GetUnitMidPos(selectedUnit)
		if ux and uy and uz and cx and cy and cz then
			distance = ((ux-cx)^2 + (uy-cy)^2 + (uz-cz)^2 )^0.5
		end
		if distance then
			if distance > MAX_RANGE then
				distance = MAX_RANGE
			end
			local radius = GetTargetCircleRadius(distance)
			gl.PushMatrix()
			gl.Translate(cx, cy, cz)
			--gl.DrawGroundCircle(cx, cy, cz, radius, 64)
			gl.BeginEnd(GL.TRIANGLES, DrawCircle, radius)
			gl.Color(1,1,1,1)
			gl.PopMatrix()
		end
	end
end

function gadget:Initialize()
	gadgetHandler:AddSyncAction("fatalArrow_UnitCreated", UnitCreated)
	gadgetHandler:AddSyncAction("fatalArrow_UnitDestroyed", UnitDestroyed)
	gadgetHandler:AddSyncAction("fatalArrow_AddBowUnit", AddBowUnit)
	gadgetHandler:AddSyncAction("fatalArrow_RemoveBowUnit", RemoveBowUnit)
	gadgetHandler:AddSyncAction("fatalArrow_GameFrame", GameFrame)
end

function gadget:Shutdown()
	gadgetHandler:RemoveSyncAction("fatalArrow_UnitCreated")
	gadgetHandler:RemoveSyncAction("fatalArrow_UnitDestroyed")
	gadgetHandler:RemoveSyncAction("fatalArrow_AddBowUnit")
	gadgetHandler:RemoveSyncAction("fatalArrow_RemoveBowUnit")
	gadgetHandler:RemoveSyncAction("fatalArrow_GameFrame")
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end