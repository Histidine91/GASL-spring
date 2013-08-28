--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:GetInfo()
	return {
		name = "Flight Control",
		desc = "Makes your spacecraft go zoom",
		author = "KingRaptor (L.J. Lim), KDR_11k (David Becker)",
		date = "2009-09-06",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- TODO:
-- orbit
-- test!
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
include("LuaRules/Configs/customcmds.h.lua")

local pi = math.pi
local spGetUnitPosition		= Spring.GetUnitPosition
local spGetUnitCommands		= Spring.GetUnitCommands
local spGetUnitDefID		= Spring.GetUnitDefID
local spGetUnitHeading		= Spring.GetUnitHeading
local spGetUnitRulesParam	= Spring.GetUnitRulesParam
local spGetUnitSeparation	= Spring.GetUnitSeparation
local spGetUnitStates		= Spring.GetUnitStates
local spGetHeadingFromVector	= Spring.GetHeadingFromVector
local spSetUnitRotation		= Spring.SetUnitRotation
local spValidUnitID		= Spring.ValidUnitID

local tobool = Spring.Utilities.tobool

if (gadgetHandler:IsSyncedCode()) then

--------------------------------------------------------------------------------
--SYNCED
--------------------------------------------------------------------------------
include "LuaRules/Configs/special_weapon_defs.lua"

local cmdSetAttackSpeed = {
	id      = CMD_SET_ATTACK_SPEED,
	type    = CMDTYPE.ICON_MODE,
	name    = 'Attack Speed',
	action  = 'attackspeed',
	tooltip	= 'Sets speed of attack passes',
	params 	= {1, 'Stationary', 'Combat', 'Full'}
}


local COMMAND_CACHE_TTL = 3
local TIME_BEFORE_SHAKE_PURSUER = 30*4
local MOVE_DISTANCE_THRESHOLD = 30
local MIN_AVOID_DISTANCE = 250
local INERTIA_FACTOR = 0.99
local BASE_THRUSTER_ENERGY_USAGE = 0.1	-- used every update interval, so a lot more than it looks!
local ACCELERATION_ENERGY_USAGE_MULT = 3
local TARGET_SEEK_RANGE = 3000
local MOVE_COMMANDS = {
	[CMD.MOVE] = true,
	[CMD.FIGHT] = true,
	[CMD.PATROL] = true,
}
local AUTOENGAGE_COMMANDS = {
	[CMD.GUARD] = true,
	[CMD.FIGHT] = true,
	[CMD.PATROL] = true,
}

local BEHAVIOR_STRINGS = {
	[0] = "idle",
	[1] = "moving",
	[2] = "closing",
	[3] = "avoiding",
	--[4] = "orbit",
}

local spacecraftDefs = {}
local spacecraft = {}
local waitWaitList = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetDistance(x1, y1, z1, x2, y2, z2)
	local dist = ((x1 - x2)^2 + (z1 - z2)^2)
	dist = (dist + (z1 - z2)^2)^0.5
	return dist
end

local function GetUnitMidPos(unitID)
	local _,_,_,x,y,z = spGetUnitPosition(unitID, true)
	return x,y,z
end

local function NormalizeHeading(heading)
	if heading > pi then
		heading = heading - 2*pi
	elseif heading < - pi then
		heading = heading + 2*pi
	end
	return heading
end

local function GetNewSpeed(old, wanted, accel, brake)
	local new = old
	if old < wanted then
		new = old + accel
		if new > wanted then
			new = wanted
		end
	else
		new = old - brake
		if new < wanted then
			new = wanted
		end
	end
	return new
end

local function GetNewPitch(old, wanted, turnrate)
	local new = old
	if old < wanted then
		new = old + turnrate
		if new > wanted then
			new = wanted
		end
	else
		new = old - turnrate
		if new < wanted then
			new = wanted
		end
	end
	return new
end

--[[
local function GetNewPitch(old, wanted, turnrate)
	old = NormalizeHeading(old)
	
	local new = old
	if old < wanted then
		dir = 1	-- up
	else
		dir = -1 -- down
	end
	if math.abs(old - wanted) > math.rad(180) then
		dir = dir * -1
	end
	new = new + turnrate*dir
	if old < wanted and new > wanted then
		new = wanted
	elseif old > wanted and new < wanted then
		new = wanted
	end
	return new
end]]--

local function GetNewHeading(old, wanted, turnrate)
	old = NormalizeHeading(old)
	
	local new = old
	if old < wanted then
		dir = 1	-- right
	else
		dir = -1 	-- left
	end
	if math.abs(old - wanted) > math.rad(180) then
		dir = dir * -1
	end
	new = new + turnrate*dir
	if old < wanted and new > wanted then
		new = wanted
	elseif old > wanted and new < wanted then
		new = wanted
	end
	return new, dir
end

local function GetDistanceFromTargetMoveGoal(tx, ty, tz, initialHeading, distance, minAngle, maxAngle)
	local angleXZ = math.random(-100, 100)
	
	-- tend to send units back to y = 0
	local minY, maxY = -60, 60
	if ty < 0 then
		minY = math.min(minY - ty/5, 30)
		minY = math.floor(minY)
	elseif ty > 0 then
		maxY = math.max(maxY - ty/5, -30)
	end
	local angleYZ = math.random(minY, maxY)
	
	angleXZ = angleXZ * maxAngle/100 + initialHeading
	angleYZ = angleYZ * maxAngle/100
	
	local px = tx + math.sin(angleXZ)*distance
	local py = ty --+ math.sin(angleYZ)*distance --* 0.4
	local pz = tz + math.cos(angleXZ)*distance
	
	--py = py - ty/10		
	
	--Spring.Echo(px - tx, py - ty, pz - tz)
	return {px, py, pz}
end

local function GetWantedSpeed(distance, data, def)
	local wantedSpeed = def.speed
	if (distance < def.combatRange) then
		if data.attackSpeedState == 0 then
			wantedSpeed = 0
		elseif data.attackSpeedState == 1 then
			wantedSpeed = def.combatSpeed
		end
	end
	return wantedSpeed
end

local function RequestNewTarget(unitID, unitDefID, addGUIEvent)
	local states = spGetUnitStates(unitID)
	if states.firestate == 0 or states.movestate == 0 then
		return
	end
	local seekRange = (states.movestate == 1 and TARGET_SEEK_RANGE) or nil
	local enemy = Spring.GetUnitNearestEnemy(unitID, TARGET_SEEK_RANGE)
	if enemy then
		Spring.GiveOrderToUnit(unitID, CMD.INSERT, {0, CMD.ATTACK, 0, enemy}, {"alt"})
		if addGUIEvent then
			GG.EventWrapper.AddEvent("engagingEnemy", 1, unitID, unitDefID, Spring.GetUnitTeam(unitID), enemy, spGetUnitDefID(enemy), Spring.GetUnitTeam(enemy))
		end
	end
end

-- GG functions
local function GetUnitSpeed(unitID)
	return spacecraft[unitID] and spacecraft[unitID].speed
end

local function SetUnitSpeed(unitID, speed)
	local data = spacecraft[unitID]
	if not data then
		return
	end
	data.speed = speed
	local vx = math.sin(data.heading) * speed
	local vy = math.sin(data.pitch) * speed
	local vz = math.cos (data.heading) * speed
	data.velocity = {vx, vy, vz}
end

local function BreakOffTarget(unitID)
	local data = spacecraft[unitID]
	if not data then
		return
	end
	local unitDefID = data.unitDefID
	local def = spacecraftDefs[unitDefID]
	local cmd = data.commandCache
	if not (cmd and cmd.id == CMD.ATTACK) then
		return
	end
	
	local targetID = data.commandCache and data.commandCache.params[1]
	data.behavior = 3
	local heading = spGetUnitHeading(unitID)
	heading = NormalizeHeading(heading)
	local tx, ty, tz = GetUnitMidPos(targetID)
	data.moveGoal = GetDistanceFromTargetMoveGoal(tx, ty, tz, heading, def.combatRange, def.minAvoidanceAngle, def.maxAvoidanceAngle)
	data.lastDistance = distance
	data.wantedSpeed = def.speed
end

local function SetUnitHeading(unitID, heading)
	if not spacecraft[unitID] then
		return
	end
	spacecraft[unitID].heading = NormalizeHeading(heading)
end

local function SetChaseTarget(unitID, targetID)
	if not spacecraft[unitID] then
		return
	end
	spacecraft[unitID].forceChaseTarget = targetID
end

local function SetUnitPosition(unitID, x, y, z)
	if not spacecraft[unitID] then
		return
	end
	Spring.MoveCtrl.SetPosition(unitID, x, y, z)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function gadget:Initialize()
	for i=1,#UnitDefs do
		local ud = UnitDefs[i]
		local customParams = ud.customParams
		spacecraftDefs[i]={
			enable = tobool(ud.customParams.useflightcontrol),
			speed = ud.speed/30,
			combatSpeed = tonumber(customParams.combatspeed) or 0.6*ud.speed/30,
			combatRange = tonumber(customParams.combatrange) or 1000,
			minimumRange = tonumber(customParams.minimumrange) or 0,
			turnrate = ud.turnRate/30/360/pi,
			acceleration = tonumber(customParams.acceleration) or 0.5,	-- unused
			brakerate = tonumber(customParams.brakerate) or 1,		-- unused
			inertiaFactor = tonumber(customParams.inertiafactor) or INERTIA_FACTOR,
			avoidDistance = tonumber(customParams.avoiddistance) or ud.xsize*15 + 200,
			minAvoidanceAngle = math.rad(tonumber(customParams.minavoidanceangle) or 0),
			maxAvoidanceAngle = math.rad(tonumber(customParams.maxavoidanceangle) or 90),
			rollAngle = tonumber(customParams.rollangle) or 0,
			rollSpeed = tonumber(customParams.rollspeed) or ud.turnRate/30/360/pi * 0.25,
			orbitTarget = customParams.orbittarget,
			hasEnergy = customParams.energy and true,
			thrusterEnergyUse = customParams.thrusterenergyuse or 1,
			initAttackSpeedState = tonumber(customParams.attackspeedstate or 1)
			--standoff = (customParams.standoff and true) or false,	-- unimplemented
		}
		--Spring.Echo(ud.name, ud.xsize, spacecraftDefs[i].avoidDistance)
	end
	local units = Spring.GetAllUnits()
	for i=1,#units do
		local unitID = units[i]
		local unitDefID = Spring.GetUnitDefID(unitID)
		local unitTeam = Spring.GetUnitTeam(unitID)
		gadget:UnitCreated(unitID, unitDefID, unitTeam)
	end
	
	GG.FlightControl = {
		GetUnitSpeed = GetUnitSpeed,
		SetUnitSpeed = SetUnitSpeed,
		SetUnitHeading = SetUnitHeading,
		SetUnitPosition = SetUnitPosition,
		SetChaseTarget = SetChaseTarget,
		BreakOffTarget = BreakOffTarget,
	}
end

function gadget:Shutdown()
	GG.FlightControl = nil
end

local up = false
function gadget:UnitCreated(unitID, unitDefID, team)
	if team ~= Spring.GetGaiaTeamID() then
		if spacecraftDefs[unitDefID] then
			spacecraft[unitID] = {
				unitDefID = unitDefID,
				behavior = 0,
				roll = 0,
				pitch = 0,
				heading = (spGetUnitHeading(unitID)/65536*2*pi or 0),
				moveGoal = nil,
				speed = 0,
				wantedSpeed = 0,
				attackSpeedState = spacecraftDefs[unitDefID].initAttackSpeedState,
				velocity = {0,0,0},
				commandCache = nil,
				commandCacheTTL = 0,
				timeBeforeShakePursuer = TIME_BEFORE_SHAKE_PURSUER,
				forceChaseTarget = nil,
			}
			spacecraft[unitID].heading = NormalizeHeading(spacecraft[unitID].heading)
			cmdSetAttackSpeed.params[1] = spacecraft[unitID].attackSpeedState
			Spring.InsertUnitCmdDesc(unitID, cmdSetAttackSpeed)
			
			Spring.SetUnitBlocking(unitID, true, true)
			local x,y,z=Spring.GetUnitPosition(unitID)
			--Spring.SetUnitPosition(u,x,0,z)
			Spring.MoveCtrl.Enable(unitID)
			Spring.MoveCtrl.SetPosition(unitID,x,0,z)
			--Spring.MoveCtrl.SetPosition(unitID,x,up and 150 or 0,z)
			up = not up
		end
	end
end

function gadget:UnitDestroyed(u,ud,team)
	--if spacecraft[u] then
	--	Spring.Echo(spacecraft[u].pitch)
	--end
	spacecraft[u] = nil
end


function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if spacecraft[unitID] then
		if cmdID == CMD.ATTACK and not cmdOptions.shift then	-- explicit attack order makes unit stop avoidance behavior
			local target = #cmdParams == 1 and cmdParams[1]
			if target and spValidUnitID(target) then
				spacecraft[unitID].moveGoal = {GetUnitMidPos(target)}
				spacecraft[unitID].behavior = 2
			end
			return true
		elseif cmdID == CMD_SET_ATTACK_SPEED then
			local state = cmdParams[1]
			if cmdOptions.right then
				state = (state - 2)%3
			end
			
			local cmdDescID = Spring.FindUnitCmdDesc(unitID, CMD_SET_ATTACK_SPEED)
			if (cmdDescID) then
				cmdSetAttackSpeed.params[1] = state
				Spring.EditUnitCmdDesc(unitID, cmdDescID, { params = cmdSetAttackSpeed.params})
				spacecraft[unitID].attackSpeedState = state
				
				--waitWaitList[unitID] = true
			end
			return false
		end
	end
	return true
end

function gadget:GameFrame(f)
	for unitID, data in pairs(spacecraft) do
		--[[
		if waitWaitList[unitID] then
			Spring.GiveOrderToUnit(unitID, CMD.WAIT, {}, 0)
			Spring.GiveOrderToUnit(unitID, CMD.WAIT, {}, 0)
			waitWaitList[unitID] = nil
		end
		]]
	
		local unitDefID = data.unitDefID
		local def = spacecraftDefs[unitDefID]
		local px, py, pz = GetUnitMidPos(unitID)
		
		-- first determine what we should do
		if data.commandCacheTTL <= 0 then
			local commands = spGetUnitCommands(unitID, 2)
			if commands and commands[1] and commands[1].id ~= 0 and commands[1].id ~= 70 and commands[1].id ~= CMD.WAIT then
				data.commandCache = commands[1]
			else
				data.commandCache = nil
				data.behavior = 0
				data.wantedSpeed = 0
				data.moveGoal = nil
			end
			data.commandCacheTTL = COMMAND_CACHE_TTL
		else
			data.commandCacheTTL = data.commandCacheTTL - 1
		end
		if data.commandCache and ((f+unitID)%3 == 0) then
			local command = data.commandCache
			local cmdID = command.id
			local orbitTarget = def.orbitTarget
			if data.forceChaseTarget then
				cmdID = CMD.ATTACK
				--orbitTarget = false
			end
			if specialCMDs[cmdID] then
				local ux, uy, uz = GetUnitMidPos(unitID)
				local tx, ty, tz
				if (#command.params == 1) then
					tx, ty, tz = GetUnitMidPos(command.params[1])
				else
					tx, ty, tz = unpack(command.params)
				end
				if tx and ty and tz then
					local distance = GetDistance(ux, uy, uz, tx, ty, tz)
					local minRange = specialWeapons[specialCMDs[cmdID]].minRange
					local maxRange = specialWeapons[specialCMDs[cmdID]].maxRange
					if distance > maxRange then
						data.behavior = 2
						data.moveGoal = {tx, ty, tz}
						data.wantedSpeed = def.speed
					elseif distance < minRange then
						data.behavior = 3
						data.wantedSpeed = def.speed
						
						local heading = spGetUnitHeading(unitID)
						heading = NormalizeHeading(heading)
						data.moveGoal = GetDistanceFromTargetMoveGoal(tx, ty, tz, heading, minRange + 150, def.minAvoidanceAngle, def.maxAvoidanceAngle)
					else
						data.behavior = 2
						data.wantedSpeed = GetWantedSpeed(distance, data, def)
						data.moveGoal = {tx, ty, tz}
					end
				end
			elseif cmdID == CMD_RESUPPLY then
				data.behavior = 2
				local tx, ty, tz = GetUnitMidPos(command.params[1])
				data.wantedSpeed = def.speed
				data.moveGoal = {tx, ty, tz}
			elseif orbitTarget or cmdID == CMD.GUARD then
				local targetID = command.params[1]
				if targetID and spValidUnitID(targetID) then
					local distance = spGetUnitSeparation(unitID, targetID, false)
					local targetDefID = spGetUnitDefID(targetID)
					local targetDef = spacecraftDefs[targetDefID] or {}
					local targetData = spacecraft[targetID]
					
					local orbitDistance = def.combatRange
					if cmdID == CMD.GUARD then
						orbitDistance = targetDef.avoidDistance + 100
					end
					if distance > (orbitDistance) then
						data.behavior = 2
						data.moveGoal = {GetUnitMidPos(targetID)}
						data.wantedSpeed = def.speed
					elseif data.behavior == 2 then
						local heading = spGetUnitHeading(unitID)/65536*2*math.pi
						heading = NormalizeHeading(heading)
						local tx, ty, tz = GetUnitMidPos(targetID)
						data.moveGoal = GetDistanceFromTargetMoveGoal(tx, ty, tz, heading, orbitDistance, def.minAvoidanceAngle, def.maxAvoidanceAngle)
						data.wantedSpeed = ((cmdID == CMD.GUARD) or (def.combatSpeed < targetData.wantedSpeed)) and def.speed or def.combatSpeed
						data.behavior = 3
					end
				end
			elseif cmdID == CMD.ATTACK then
				local targetID = data.forceChaseTarget or command.params[1]
				if targetID and spValidUnitID(targetID) then
					local distance = spGetUnitSeparation(unitID, targetID, false)
					local targetDefID = spGetUnitDefID(targetID)
					local targetDef = spacecraftDefs[targetDefID] or {}
					
					if data.behavior == 2 then
						-- too close, switch to avoid behavior
						data.moveGoal = {GetUnitMidPos(targetID)}
						data.wantedSpeed = GetWantedSpeed(distance, data, def)
						local avoidDistance = math.max(def.minimumRange, targetDef.avoidDistance, MIN_AVOID_DISTANCE)
						if distance < avoidDistance then
							data.behavior = 3
							local heading = spGetUnitHeading(unitID)
							heading = NormalizeHeading(heading)
							local tx, ty, tz = GetUnitMidPos(targetID)
							data.moveGoal = GetDistanceFromTargetMoveGoal(tx, ty, tz, heading, def.combatRange, def.minAvoidanceAngle, def.maxAvoidanceAngle)
							data.lastDistance = distance
							data.wantedSpeed = def.speed
							--Spring.Echo(unitID .. " last distance = " .. distance)
						end
					elseif data.behavior == 3 then
						-- if target is on our tail, attempt to shake
						data.timeBeforeShakePursuer = data.timeBeforeShakePursuer - 1
						if data.timeBeforeShakePursuer == 0 then
							if distance <= (data.lastDistance or 0) + (def.speed*60) then
								data.behavior = 2
								data.moveGoal = {GetUnitMidPos(targetID)}
								data.wantedSpeed = def.combatSpeed
								--Spring.Echo(unitID .. " is jinking (distance " .. distance .. ", was " .. data.lastDistance .. ")")
							end
							data.lastDistance = distance
							data.timeBeforeShakePursuer = TIME_BEFORE_SHAKE_PURSUER
						end
						-- far enough, switch to closing behavior
						local distance2 = GetDistance(px, py, pz, data.moveGoal[1], data.moveGoal[2], data.moveGoal[3])
						if distance > def.combatRange or distance2 < MOVE_DISTANCE_THRESHOLD then
							data.behavior = 2
							data.moveGoal = {GetUnitMidPos(targetID)}
							data.wantedSpeed = GetWantedSpeed(distance, data, def)
							data.timeBeforeShakePursuer = TIME_BEFORE_SHAKE_PURSUER
							--Spring.Echo("Got enough distance, closing in again")
						end
					--elseif def.standoff then
						-- FIXME unimplemented
						--data.behavior = 6
					else
						data.behavior = 2
						data.moveGoal = {GetUnitMidPos(targetID)}
						data.wantedSpeed = GetWantedSpeed(distance, data, def)
						data.timeBeforeShakePursuer = TIME_BEFORE_SHAKE_PURSUER
					end
					--if f%120 == 0 and data.lastMoveGoal and data.moveGoal and data.lastMoveGoal[1] == data.lastMoveGoal[1] and data.lastMoveGoal[3] == data.moveGoal[3] then
					--	Spring.Echo("FFS", data.moveGoal[1], data.moveGoal[3])
					--end
					--data.lastMoveGoal = data.moveGoal
				else
					RequestNewTarget(unitID, unitDefID)
				end
			elseif MOVE_COMMANDS[cmdID] then
				data.moveGoal = command.params
				local distance = GetDistance(px, py, pz, data.moveGoal[1], data.moveGoal[2], data.moveGoal[3])
				data.wantedSpeed = (distance > 100) and def.speed or def.combatSpeed
				if distance <= MOVE_DISTANCE_THRESHOLD then	-- close enough
					Spring.GiveOrderToUnit(unitID, CMD.REMOVE, {data.commandCache.tag}, {})
				end
			end
		end
		
		if f%30 == 0 then
			if (not data.commandCache) or AUTOENGAGE_COMMANDS[data.commandCache.id] then
				RequestNewTarget(unitID, unitDefID, data.commandCache == nil)
			end
		end
		--if f%120 == 0 then
		--	if data.commandCache then Spring.Echo(data.commandCache.id) end
		--end
		
		-- decided what we want to do, now to get there
		local wantedPitch, wantedHeading
		local speed = 0
		local moveGoal = data.moveGoal
		local energy = GG.Energy and GG.Energy.GetUnitEnergy(unitID)
		if energy and energy == 0 then	-- stranded!
			-- make no changes to our facing or speed
		else
			if moveGoal then
				local dy = moveGoal[2] - py
				local vectorX, vectorZ = px - moveGoal[1], pz - moveGoal[3] 
				local dxz = math.sqrt(vectorX^2 + vectorZ^2)
				wantedPitch = -math.atan2(dy, dxz)
				wantedHeading = spGetHeadingFromVector(vectorX, vectorZ)/65536*2*pi + pi
				wantedHeading = NormalizeHeading(wantedHeading)
				if math.abs(wantedHeading - data.heading) < 0.03 then
					wantedHeading = data.heading
				end
				if math.abs(wantedPitch - data.pitch) < 0.03 then
					wantedPitch = data.pitch
				end
			else
				wantedPitch = data.pitch
				wantedHeading = data.heading
			end
		
			-- fixes wrong-way turning with pitch after an Immelmann/split-S
			--local correction = 1
			--if data.pitch > pi/2 or data.pitch < -pi/2 then		
			--	correction = -1
			--end
			--wantedHeading = wantedHeading*correction
			
			local slowState = spGetUnitRulesParam(unitID,"slowState") or 0
			local turnrate = def.turnrate * (1 - slowState)
			data.pitch = GetNewPitch(data.pitch, wantedPitch, turnrate)
			local rollDir = 0
		
			if wantedHeading ~= data.heading then
				data.heading, rollDir = GetNewHeading(data.heading, wantedHeading, turnrate)
			end
			data.roll = GetNewPitch(data.roll, -rollDir*def.rollAngle, def.rollSpeed)
			
			Spring.MoveCtrl.SetRotation(unitID,data.pitch,data.heading,data.roll)
			--spSetUnitRotation(unitID,data.pitch,data.heading,data.roll)
			
			local oldSpeed = data.speed
			speed = data.wantedSpeed --GetNewSpeed(data.speed, data.wantedSpeed, def.acceleration, def.brakerate)
			local maxSpeed = def.speed * (1 - slowState)
			if speed > maxSpeed then
				speed = maxSpeed
			end
			data.speed = speed
			
			-- energy usage
			if GG.Energy and def.hasEnergy then
				local deltaV = speed - oldSpeed
				if deltaV < 0 then
					deltaV = deltaV * -0.5	--braking only uses half as much E
				end
				local energyUsage = BASE_THRUSTER_ENERGY_USAGE*(speed + deltaV*ACCELERATION_ENERGY_USAGE_MULT)/maxSpeed*def.thrusterEnergyUse
				if energyUsage > 0 then
					local enoughEnergyLeft = GG.Energy.UseUnitEnergy(unitID, energyUsage)
					if not enoughEnergyLeft then
						GG.Energy.SetUnitEnergy(unitID, 0)	-- drain the last drop of fuel
					end
				end
			end
			--if f%120 == 0 then Spring.Echo(data.speed, data.wantedSpeed) end
			--if f%120 == 0 then Spring.Echo(data.heading, wantedHeading) end	
		end
				
		-- calculate velocity
		--Spring.MoveCtrl.SetRelativeVelocity(p.unit,0,0,speed)
		local vx = math.sin(data.heading) *(math.cos(data.pitch))*speed
		local vy = -math.sin(data.pitch)*speed
		local vz = math.cos(data.heading) *(math.cos(data.pitch))*speed
		
		local vx1, vy1, vz1 = unpack(data.velocity)
		local inertiaFactor = def.inertiaFactor
		
		vx = vx*(1-inertiaFactor) + vx1*inertiaFactor
		vy = vy*(1-inertiaFactor) + vy1*inertiaFactor
		vz = vz*(1-inertiaFactor) + vz1*inertiaFactor
		
		data.velocity = {vx, vy, vz}
		Spring.MoveCtrl.SetVelocity(unitID, vx, vy, vz)
		--Spring.SetUnitVelocity(unitID, vx, vy, vz)
	end
end

else
--------------------------------------------------------------------------------
--UNSYNCED
--------------------------------------------------------------------------------

end
