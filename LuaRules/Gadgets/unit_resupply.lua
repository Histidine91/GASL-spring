--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:GetInfo()
  return {
    name      = "Resupply",
    desc      = "Refills your ammo and fuel",
    author    = "KingRaptor",
    date      = "22 Jan 2011",
    license   = "GNU LGPL, v2.1 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
-- speedups
--------------------------------------------------------------------------------
local spGetUnitTeam		= Spring.GetUnitTeam
--local spGetUnitAllyTeam	= Spring.GetUnitAllyTeam
local spGetUnitDefID	= Spring.GetUnitDefID
local spGetUnitIsDead	= Spring.GetUnitIsDead
local spGetUnitRulesParam	= Spring.GetUnitRulesParam
local spGetUnitFuel		= Spring.GetUnitFuel

local tobool = Spring.Utilities.tobool

include "LuaRules/Configs/customcmds.h.lua"

local fighterDefs = {}
local carrierDefs = {}

for i=1,#UnitDefs do
	local cp = UnitDefs[i].customParams
	if tobool(cp.canresupply) then
		fighterDefs[i] = {noAutoResupply = tobool(cp.noautoresupply) or true}
	end
	if cp.resupplyrange then
		carrierDefs[i] = {resupplyRange = tonumber(cp.resupplyrange)}
	end
end

if (gadgetHandler:IsSyncedCode()) then
--------------------------------------------------------------------------------
-- SYNCED
--------------------------------------------------------------------------------
local spGiveOrderToUnit = Spring.GiveOrderToUnit

--------------------------------------------------------------------------------
-- config
--------------------------------------------------------------------------------
local combatCommands = {	-- commands that require ammo to execute
	[CMD.ATTACK] = true,
	[CMD.AREA_ATTACK] = true,
	[CMD.FIGHT] = true,
	[CMD.PATROL] = true,
	[CMD.GUARD] = true,
	[CMD.MANUALFIRE] = true,
}

local ENERGY_PER_UNIT_HEALTH = 1	-- spend this much energy to repair 1 health
local GIVE_UP_FRAMES = 300

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local resupplyCMD = {
	id      = CMD_RESUPPLY,
	name    = "Resupply",
	action  = "resupply",
	cursor  = 'Repair',
	type    = CMDTYPE.ICON_UNIT,
	tooltip = "Select a carrier to return to for resupply",
	hidden	= true,
}

local findCarrierCMD = {
	id      = CMD_FIND_CARRIER,
	name    = "Resupply",
	action  = "find_carrier",
	cursor  = 'Repair',
	type    = CMDTYPE.ICON,
	tooltip = "Search for nearest available carrier to return to for resupply",
	texture = "LuaUI/Images/Commands/Bold/rearm.png",
	hidden	= false,
}

local fighterUnitIDs = {}	-- [unitID] = unitDefID
local fighterToCarrier = {}	-- [fighterID] = detination carrier ID
local refuelling = {} -- [fighterID] = true
local carriers = {}	-- stores data
local carriersPerTeam = {}	-- [team] = {[carrier1ID] = true, [carrier2ID] = true, ..}
local teams = Spring.GetTeamList()
for i=1,#teams do
	carriersPerTeam[teams[i]] = {}
end
local scheduleResupplyRequest = {} -- [fighterID] = true	(used to avoid recursion in UnitIdle)

_G.carriers = carriers

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function MakeOptsWithShift(cmdOpt)
	local opts = {"shift"} -- appending
	if (cmdOpt.alt)   then opts[#opts+1] = "alt"   end
	if (cmdOpt.ctrl)  then opts[#opts+1] = "ctrl"  end
	if (cmdOpt.right) then opts[#opts+1] = "right" end
	return opts
end

local function NeedRepairOrResupply(unitID)
	local health, maxHealth = Spring.GetUnitHealth(unitID)
	local energy, maxEnergy = GG.Energy.GetUnitEnergy(unitID)
	energy = energy or 0
	maxEnergy = maxEnergy or 0
	return (maxHealth > health + 1) or (maxEnergy > energy + 1)
end

--[[
local function InsertCommandAfter(unitID, afterCmd, cmdID, params, opts)
	-- workaround for STOP not clearing attack order due to auto-attack
	-- we set it to hold fire temporarily, revert once commands have been reset
	local queue = Spring.GetUnitCommands(unitID)
	local firestate = Spring.GetUnitStates(unitID).firestate
	Spring.GiveOrderToUnit(unitID, CMD.FIRE_STATE, {0}, {})
	Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, {})
	if queue then
		opts = opts or {}
		local i = 1
		local toInsert = nil
		local commands = #queue
		while i <= commands do
			
			if toInsert then
				Spring.GiveOrderToUnit(unitID, cmdID, params, MakeOptsWithShift(opts))
				toInsert = false
			else
				local cmd = queue[i]
				Spring.GiveOrderToUnit(unitID, cmd.id, cmd.params, MakeOptsWithShift(cmd.options))
				if cmd.id == afterCmd and toInsert == nil then
					toInsert = true
				end
				i = i + 1
			end
			--local cq = Spring.GetUnitCommands(unitID) for i = 1, #cq do Spring.Echo(cq[i].id) end
		end
		if toInsert then
			Spring.GiveOrderToUnit(unitID, cmdID, params, MakeOptsWithShift(opts))
		end
	end
	Spring.GiveOrderToUnit(unitID, CMD.FIRE_STATE, {firestate}, {})
end
--]]

local function InsertCommand(unitID, index, cmdID, params, opts)
	-- workaround for STOP not clearing attack order due to auto-attack
	-- we set it to hold fire temporarily, revert once commands have been reset
	local queue = Spring.GetUnitCommands(unitID)
	local firestate = Spring.GetUnitStates(unitID).firestate
	Spring.GiveOrderToUnit(unitID, CMD.FIRE_STATE, {0}, {})
	Spring.GiveOrderToUnit(unitID, CMD.STOP, {}, {})
	if queue then
		opts = opts or {}
		local i = 1
		local toInsert = (index >= 0)
		local commands = #queue
		while i <= commands do
			if i-1 == index and toInsert then
				Spring.GiveOrderToUnit(unitID, cmdID, params, MakeOptsWithShift(opts))
				toInsert = false
			else
				local cmd = queue[i]
				Spring.GiveOrderToUnit(unitID, cmd.id, cmd.params, MakeOptsWithShift(cmd.options))
				i = i + 1
			end
			--local cq = Spring.GetUnitCommands(unitID) for i = 1, #cq do Spring.Echo(cq[i].id) end
		end
		if toInsert or index < 0 then
			Spring.GiveOrderToUnit(unitID, cmdID, params, MakeOptsWithShift(opts))
		end
	end
	Spring.GiveOrderToUnit(unitID, CMD.FIRE_STATE, {firestate}, {})
end
GG.InsertCommand = InsertCommand

local function ResupplyUnit(fighterID, carrierID)
	GG.FlightControl.SetUnitSpeed(fighterID, 0)
	fighterToCarrier[fighterID] = nil
	local fighterDefID = fighterUnitIDs[fighterID]
	local carrierDefID = carriers[carrierID].unitDefID
	
	--first transfer energy
	local energy, maxEnergy = GG.Energy.GetUnitEnergy(fighterID)
	if energy then
		local energyToTransfer = maxEnergy - energy
		local success, energyLeft = GG.Energy.UseUnitEnergy(carrierID, energyToTransfer)
		if success then
			GG.Energy.SetUnitEnergy(fighterID, maxEnergy)
		else
			GG.Energy.SetUnitEnergy(fighterID, energy + energyLeft)
			GG.Energy.SetUnitEnergy(carrierID, 0)
		end
	end
	-- now perform repairs
	local health, maxHealth = Spring.GetUnitHealth(fighterID)
	local energyRequired = (maxHealth - health) * ENERGY_PER_UNIT_HEALTH
	local success, energyLeft = GG.Energy.UseUnitEnergy(carrierID, energyRequired)
	if success then
		Spring.SetUnitHealth(fighterID, maxHealth)
	else
		Spring.SetUnitHealth(fighterID, health + energyLeft*ENERGY_PER_UNIT_HEALTH)
		GG.Energy.SetUnitEnergy(carrierID, 0)
	end
	GG.SetUnitSuppression(fighterID, 0)
	
	local _,_,_,x,y,z = Spring.GetUnitPosition(fighterID, true)
	Spring.SpawnCEG("resupply", x, y, z, 0, 1, 0, 20)
	
	GG.EventWrapper.AddEvent("resupply", 1, fighterID, fighterDefID, Spring.GetUnitTeam(fighterID), carrierID, carrierDefID, Spring.GetUnitTeam(carrierID))
	GG.TrackRepairStats(carrierID, carrierDefID, fighterID, fighterDefID, maxHealth - health)
	
	if Spring.GetUnitStates(fighterID)["repeat"] then 
		--spGiveOrderToUnit(fighterID, CMD_RESUPPLY, {carrierID}, {"shift"})
		InsertCommand(fighterID, 99999, CMD_RESUPPLY, {targetCarrier})
	end
	--refuelling[fighterID] = n + GIVE_UP_FRAMES
	--Spring.SetUnitRulesParam(fighterID, "noammo", 2)	-- refuelling
end

local function FindNearestCarrier(unitID, team)
	--Spring.Echo(unitID.." checking for closest carrier")
	local freeCarriers = {}
	local freeCarrierCount = 0
	if not carriersPerTeam[team] then
		return
	end
	-- first go through all the carriers to see which ones are unbooked
	for carrierID in pairs(carriersPerTeam[team]) do
		if not spGetUnitIsDead(carrierID) --[[and carriers[carrierID].reservations.count < carriers[carrierID].cap]] then
			freeCarriers[carrierID] = true
			freeCarrierCount = freeCarrierCount + 1
		end
	end
	-- if no free carriers, just use all of them
	if freeCarrierCount == 0 then
		--Spring.Echo("No free carriers, directing to closest one")
		freeCarriers = carriersPerTeam[team]
	end
	
	local minDist = 999999
	local closestCarrier
	for carrierID in pairs(freeCarriers) do
		local dist = Spring.GetUnitSeparation(unitID, carrierID, true) or minDist
		if (dist < minDist) then
			minDist = dist
			closestCarrier = carrierID
		end
	end
	return closestCarrier
end

local function RequestResupply(unitID, team, forceNow)
	team = team or spGetUnitTeam(unitID)
	if spGetUnitRulesParam(unitID, "noammo") ~= 1 then
		if not NeedRepairOrResupply(unitID) then
			return
		end
	end
	--Spring.Echo(unitID.." requesting resupply")
	local queue = Spring.GetUnitCommands(unitID) or {}
	local index = #queue + 1
	for i=1, #queue do
		if combatCommands[queue[i].id] then
			index = i-1
			break
		elseif queue[i].id == CMD_RESUPPLY or queue[i].id == CMD_FIND_CARRIER then	-- already have manually set resupply point, we have nothing left to do here
			return
		end
	end
	if forceNow then
		index = 0
	end
	local targetCarrier = FindNearestCarrier(unitID, team)
	if targetCarrier then
		--Spring.Echo(unitID.." directed to carrier "..targetCarrier)
		InsertCommand(unitID, index, CMD_RESUPPLY, {targetCarrier})
		--spGiveOrderToUnit(unitID, CMD.INSERT, {index, CMD_RESUPPLY, 0, targetCarrier}, {"alt"})
		return targetCarrier
	end
end
GG.RequestResupply = RequestResupply

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:Initialize()
	local unitList = Spring.GetAllUnits()
	for i=1,#(unitList) do
		local ud = spGetUnitDefID(unitList[i])
		local team = spGetUnitTeam(unitList[i])
		gadget:UnitCreated(unitList[i], ud, team)
		gadget:UnitFinished(unitList[i], ud, team)
	end
end


function gadget:UnitCreated(unitID, unitDefID, team)
	if fighterDefs[unitDefID] then
		Spring.InsertUnitCmdDesc(unitID, 400, resupplyCMD)
		Spring.InsertUnitCmdDesc(unitID, 401, findCarrierCMD)
		fighterUnitIDs[unitID] = unitDefID
	end
	--[[
	local id = Spring.FindUnitCmdDesc(unitID, CMD.WAIT)
	local desc = Spring.GetUnitCmdDescs(unitID, id, id)
	for i,v in ipairs(desc) do
		if type(v) == "table" then
			for a,b in pairs(v) do
				Spring.Echo(a,b)
			end
		end
	end
	]]--
end

function gadget:UnitFinished(unitID, unitDefID, team)
	if carrierDefs[unitDefID] then
		--Spring.Echo("Adding unit "..unitID.." to carrier list")
		local team = spGetUnitTeam(unitID)
		carriers[unitID] = Spring.Utilities.CopyTable(carrierDefs[unitDefID], true)
		carriers[unitID].unitDefID = unitDefID
		carriers[unitID].reservations = {count = 0, units = {}}
		carriersPerTeam[team][unitID] = true
	end
end

-- we don't need the carrier for now, free up a slot
--[[
local function CancelCarrierReservation(unitID)
	local targetCarrier = fighterToCarrier[unitID]
	if not targetCarrier then return end
	
	--Spring.Echo("Clearing reservation by "..unitID.." at carrier "..targetCarrier)
	fighterToCarrier[unitID] = nil
	if not carriers[targetCarrier] then return end
	local reservations = carriers[targetCarrier].reservations
	if reservations.units[unitID] then
		reservations.units[unitID] = nil
		reservations.count = math.max(reservations.count - 1, 0)
	end
end
]]

function gadget:UnitDestroyed(unitID, unitDefID, team)
	if carriers[unitID] then
		--Spring.Echo("Removing unit "..unitID.." from carrier list")
		carriersPerTeam[team][unitID] = nil
		for fighterID in pairs(carriers[unitID].reservations.units) do
			--CancelCarrierReservation(fighterID)	-- send anyone who was going here elsewhere
		end
		carriers[unitID] = nil
	elseif fighterDefs[unitDefID] then
		--CancelCarrierReservation(unitID)
		fighterUnitIDs[unitID] = nil
		refuelling[unitID] = nil
	end
end

function gadget:AllowUnitTransfer(unitID, unitDefID, oldteam, newteam)
	gadget:UnitDestroyed(unitID, unitDefID, oldteam)
	gadget:UnitFinished(unitID, unitDefID, newteam)
	return true
end

function gadget:GameFrame(n)
	if n%10 == 2 then
		--[[
		for fighterID, giveUpFrame in pairs(refuelling) do
			local fuel = spGetUnitFuel(fighterID) or 0
			if fuel >= MAX_FUEL then
				refuelling[fighterID] = nil
				Spring.SetUnitRulesParam(fighterID, "noammo", 0)	-- ready to go
				--Spring.GiveOrderToUnit(fighterID,CMD.WAIT, {}, {})
				--Spring.GiveOrderToUnit(fighterID,CMD.WAIT, {}, {})
			end
		end
		]]
	end
	-- track proximity to fighters
	if n%6 == 0 then
		for fighterID in pairs(scheduleResupplyRequest) do
			RequestResupply(fighterID, nil, true)
		end
		scheduleResupplyRequest = {}
		for fighterID, carrierID in pairs(fighterToCarrier) do
			local queue = Spring.GetUnitCommands(fighterID, 1)
			if (queue and queue[1] and queue[1].id == CMD_RESUPPLY) and (Spring.GetUnitSeparation(fighterID, carrierID, true) < carriers[carrierID].resupplyRange) then
				local tag = queue[1].tag
				--Spring.Echo("Fighter "..fighterID.." cleared for landing")
				--CancelCarrierReservation(fighterID)
				spGiveOrderToUnit(fighterID, CMD.REMOVE, {tag}, {})	-- clear resupply order
				ResupplyUnit(fighterID, carrierID)
			end
		end
		
		for unitID in pairs(fighterUnitIDs) do -- CommandFallback doesn't seem to activate for inbuilt commands!!!
			if spGetUnitRulesParam(unitID, "noammo") == 1 then
				local queue = Spring.GetUnitCommands(unitID, 1)
				if queue and #queue > 0 and combatCommands[queue[1].id] then
					RequestResupply(unitID, nil, true)
				end
			end
		end
	end
end

function gadget:UnitIdle(unitID, unitDefID, team)
	if fighterDefs[unitDefID] and spGetUnitRulesParam(unitID, "noammo") == 1 then
		scheduleResupplyRequest[unitID] = true
	end
end

--[[
function gadget:UnitCmdDone(unitID, unitDefID, team, cmdID, cmdTag)
	if fighterDefs[unitDefID] then RequestResupply(unitID) end
end
]]--

function gadget:CommandFallback(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
	if cmdID == CMD_RESUPPLY then	-- return to carrier
		if spGetUnitRulesParam(unitID, "noammo") == 2 then
			return true, true -- attempting to resupply while already resupplying, abort
		end
		--Spring.Echo("Returning to base")
		local targetCarrier = cmdParams[1]
		if not carriers[targetCarrier] then
			return true, true	-- trying to land on an unregistered (probably under construction) carrier, abort
		end
		fighterToCarrier[unitID] = targetCarrier
		return true, false	-- command used, don't remove
	elseif cmdID == CMD_FIND_CARRIER then
		scheduleResupplyRequest[unitID] = true
		return true, true	-- command used, remove
	end
	return false -- command not used
end


function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions)
	if not fighterDefs[unitDefID] then
		return true
	end
	if (cmdID == CMD_RESUPPLY or cmdID == CMD_FIND_CARRIER) then
		local health, maxHealth = Spring.GetUnitHealth(unitID)
		local energy, maxEnergy = 0, 0
		if GG.Energy and GG.Energy.GetUnitEnergy then
			energy, maxEnergy = GG.Energy.GetUnitEnergy(unitID, unitDefID)
		end
		if not (cmdOptions.shift or NeedRepairOrResupply(unitID)) then -- don't allow resupplying unless damaged or need energy
			return false 
		end	
	else
		if combatCommands[cmdID] and not fighterDefs[unitDefID].noAutoResupply then	-- trying to fight without ammo, go get ammo first!
			scheduleResupplyRequest[unitID] = true
		end
	end
	--[[
	if fighterToCarrier[unitID] then
		if cmdID ~= CMD_RESUPPLY and not cmdOptions.shift then
			CancelCarrierReservation(unitID)
		end
	end
	]]
	return true
end


else
--------------------------------------------------------------------------------
-- UNSYNCED
--------------------------------------------------------------------------------
local carriers = SYNCED.carriers
local spGetUnitTeam = Spring.GetUnitTeam
--local spGetUnitAllyTeam = Spring.GetUnitAllyTeam
local spGetLocalTeamID = Spring.GetLocalTeamID
local spAreTeamsAllied = Spring.AreTeamsAllied
local spGetSpectatingState = Spring.GetSpectatingState
local spValidUnitID = Spring.ValidUnitID

--[[
function gadget:DefaultCommand(type, targetID)
	if (type == 'unit') then
		local targetTeam = spGetUnitTeam(targetID)
		local selfTeam = spGetLocalTeamID()
		if not (spAreTeamsAllied(targetTeam, selfTeam)) then
			return
		end

		local selUnits = Spring.GetSelectedUnits()
		if (not selUnits[1]) then
			return  -- no selected units
		end

		local unitID, unitDefID
		for i = 1, #selUnits do
			unitID    = selUnits[i]
			unitDefID = spGetUnitDefID(unitID)
			if (not fighterDefs[unitDefID]) then
				return
			end
		end

		if carriers[targetID] then
			return CMD_RESUPPLY
		end
		return
	end
end
]]
function gadget:Initialize()
	gadgetHandler:RegisterCMDID(CMD_RESUPPLY)
	Spring.SetCustomCommandDrawData(CMD_RESUPPLY, "Repair", {0, 1, 1, 0.7})
	Spring.SetCustomCommandDrawData(CMD_FIND_CARRIER, "Guard", {0, 1, 1, 0.7})
end

end