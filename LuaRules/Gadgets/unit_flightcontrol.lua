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
local spGetUnitVelocity		= Spring.GetUnitVelocity
local spGetUnitHeading		= Spring.GetUnitHeading
local spGetUnitDirection	= Spring.GetUnitDirection
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
local CONTROL_MODE = "rotvel"	-- can be fixedrot, rotvel or hybrid, but only rotvel really works

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
local TARGET_SEEK_RANGE_LONG = 9000
local MAX_COLLISION_AVOIDANCE_PERIOD = 30*8
local COLLISION_AVOIDANCE_TTL = 120

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
--local waitWaitList = {}
local disabledUnits = {}
local noCollideUnits = {}

_G.spacecraft = spacecraft
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

local function GetUnitAimPos(unitID)
	local _,_,_,_,_,_,x,y,z = spGetUnitPosition(unitID, true, true)
	return x,y,z
end

local function NormalizeHeading(heading)
	if heading > pi then
		heading = NormalizeHeading(heading - 2*pi)
	elseif heading < - pi then
		heading = NormalizeHeading(heading + 2*pi)
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

local function GetWantedRotation(delta, turnrate)
	if delta == 0 then
		return 0
	elseif delta < 0 then
		return math.max(delta, -turnrate)
	else
		return math.min(delta, turnrate)
	end
end

local function GetDistanceFromTargetMoveGoal(tx, ty, tz, initialHeading, distance, minAngle, maxAngle)
	maxAngle = maxAngle or math.pi
	local angleXZ = math.random(0, 100)
	
	-- tend to send units back to y = 0
	local minY, maxY = -60, 60
	if ty < 0 then
		minY = math.min(minY - ty*0.4, 30)
		minY = math.floor(minY)
	elseif ty > 0 then
		maxY = math.max(maxY - ty*0.4, -30)
	end
	local angleYZ = math.random(minY, maxY)
	
	angleXZ = angleXZ * maxAngle/100 + initialHeading
	angleYZ = angleYZ * maxAngle/100
	angleXZ = math.max(minAngle, angleXZ)
	
	if math.random() > 0.5 then
		angleXZ = -angleXZ
	end
	
	local px = tx + math.sin(angleXZ)*distance
	local py = ty + math.sin(angleYZ)*distance --* 0.4
	local pz = tz + math.cos(angleXZ)*distance
	
	local gh = Spring.GetGroundHeight(px, pz)
	if py < (gh + 100) then
		py = gh + 100
	end
	
	--py = py - ty/10		
	
	--Spring.Echo(px - tx, py - ty, pz - tz)
	return {px, py, pz}
end

local function GetCollisionAvoidanceMoveGoal(tx, ty, tz, sideVector, topVector, dist)
	local basePos = {tx, ty, tz}
	local avoidAngle = math.random(0, 360)
	avoidAngle = math.rad(avoidAngle)
	local xmult, ymult = math.cos(avoidAngle), math.sin(avoidAngle)
	local pos = {}
	for i=1,3 do
		pos[i] = basePos[i] + (sideVector[i] * xmult + topVector[i]*ymult)*dist
	end
	return pos
end

local function GetWantedSpeed(unitID, distance, data, def)
	if spacecraft[unitID].forcedSpeed then
		return spacecraft[unitID].forcedSpeed
	end
	local wantedSpeed = def.speed
	local threeSecondDist = def.speed * 60
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
	
	local teamID = Spring.GetUnitTeam(unitID)
	
	local seekRange = (states.movestate == 1 and TARGET_SEEK_RANGE) or TARGET_SEEK_RANGE_LONG
	local enemy = GG.PickTarget(unitID, unitDefID, teamID, seekRange) 	--Spring.GetUnitNearestEnemy(unitID, seekRange)
	if enemy then
		Spring.GiveOrderToUnit(unitID, CMD.INSERT, {0, CMD.ATTACK, 0, enemy}, {"alt"})
		if addGUIEvent then
			GG.EventWrapper.AddEvent("engagingEnemy", 1, unitID, unitDefID, teamID, enemy, spGetUnitDefID(enemy), Spring.GetUnitTeam(enemy))
		end
	end
end

-- GG functions
local function GetUnitSpeed(unitID)
	return spacecraft[unitID] and spacecraft[unitID].speed
end

local function GetUnitTrueSpeed(unitID)
	local data = spacecraft[unitID]
	if not data then
		return
	end
	local vel = data.velocity
	return math.sqrt(vel[1]^2 + vel[2]^2 + vel[3]^2)
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

local function SetUnitForcedSpeed(unitID, speed)
	local data = spacecraft[unitID]
	if not data then
		return
	end
	data.forcedSpeed = speed
end

local function GetUnitTurnrate(unitID)
	if spacecraft[unitID] then
		return spacecraft[unitID].turnrate
	end
end

local function SetUnitTurnrate(unitID, turnrate)
	local data = spacecraft[unitID]
	if not data then
		return
	end
	data.turnrate = turnrate
end

local function GetUnitVelocity(unitID)
	if spacecraft[unitID] then
		local vx, vy, vz = unpack(spacecraft[unitID].velocity)
		return vx, vy, vz
	end
end

local function SetUnitVelocity(unitID, vx, vy, vz)
	local data = spacecraft[unitID]
	if not data then
		return
	end
	data.velocity = {vx, vy, vz}
	Spring.MoveCtrl.SetVelocity(unitID, vx, vy, vz)
	--data.speed = (vx^2 + vy^2 + vz^2)^0.5
end

local function SetUnitHeading(unitID, heading)
	local data = spacecraft[unitID]
	if not data then
		return
	end
	
	heading = NormalizeHeading(heading)
	data.heading = heading
	Spring.MoveCtrl.SetHeading(unitID, heading*65536/2/pi)
end

local function SetUnitRotationVelocity(unitID, rvx, rvy, rvz)
	local data = spacecraft[unitID]
	if not data then
		return
	end
	local rotVel = data.rotationVelocity
	rotVel[1] = rvx
	rotVel[2] = rvy
	rotVel[3] = rvz
	Spring.MoveCtrl.SetRotationVelocity(unitID, rvx, rvy, rvz)
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

local function DisableUnitManeuvering(unitID, bool)
	local data = spacecraft[unitID]
	if not data then
		return
	end
	data.maneuveringDisabled = bool
end

local function DisableUnit(unitID)
	if not spacecraft[unitID] then
		return
	end
	disabledUnits[unitID] = true
end

local function EnableUnit(unitID)
	if not spacecraft[unitID] then
		return
	end
	disabledUnits[unitID] = nil
end

-- this one isn't a GG function though
local function GetTargetIntercept(unitID, targetID, distance)
	local tx, ty, tz = GetUnitAimPos(targetID)
	local vx, vy, vz = spGetUnitVelocity(targetID)
	distance = distance or spGetUnitSeparation(unitID, targetID)
	if distance == 0 or distance == nil then
		return tx, ty, tz
	end
	local travelTime = GetUnitSpeed(unitID)/distance
	if travelTime > 2 then
		travelTime = 2
	elseif travelTime < 0 then
		travelTime = 0
	end
	return tx + vx*travelTime, ty + vy*travelTime, tz + vz*travelTime
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
			turnrate = ud.turnRate/30/360/pi,	-- 0.1 means turn 180‹ in one second
			acceleration = tonumber(customParams.acceleration) or 0.5,	-- unused
			brakerate = tonumber(customParams.brakerate) or 1,		-- unused
			inertiaFactor = tonumber(customParams.inertiafactor) or INERTIA_FACTOR,
			avoidDistance = tonumber(customParams.avoiddistance) or ud.xsize*16 + 200,
			minAvoidanceAngle = math.rad(tonumber(customParams.minavoidanceangle) or 40),
			maxAvoidanceAngle = math.rad(tonumber(customParams.maxavoidanceangle) or 150),
			rollAngle = (tonumber(customParams.rollangle) or 0)/180*pi,
			rollSpeed = (tonumber(customParams.rollspeed) or ud.turnRate/30 * 0.1)/180*pi,
			orbitTarget = customParams.orbittarget,
			hasEnergy = customParams.energy and true,
			thrusterEnergyUse = customParams.thrusterenergyuse or 1,
			initAttackSpeedState = tonumber(customParams.attackspeedstate or 1),
			--standoff = (customParams.standoff and true) or false,	-- unimplemented
			mass = ud.mass,
		}
		spacecraftDefs[i].turnDiameter = 0.2/spacecraftDefs[i].turnrate * ud.speed
		spacecraftDefs[i].maxTurnAngle = math.max(spacecraftDefs[i].turnrate*3, 0.15)
		--Spring.Echo(ud.name, spacecraftDefs[i].turnrate)
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
		GetUnitTrueSpeed = GetUnitTrueSpeed,
		SetUnitSpeed = SetUnitSpeed,
		SetUnitForcedSpeed = SetUnitForcedSpeed,
		GetUnitVelocity = GetUnitVelocity,
		SetUnitVelocity = SetUnitVelocity,
		GetUnitTurnrate = GetUnitTurnrate,
		SetUnitTurnrate = SetUnitTurnrate,
		SetUnitHeading = SetUnitHeading,
		SetUnitRotationVelocity = SetUnitRotationVelocity,
		SetUnitPosition = SetUnitPosition,
		SetChaseTarget = SetChaseTarget,
		BreakOffTarget = BreakOffTarget,
		DisableUnitManeuvering = DisableUnitManeuvering,
		DisableUnit = DisableUnit,
		EnableUnit = EnableUnit,
	}
end

function gadget:Shutdown()
	GG.FlightControl = nil
end

function gadget:UnitCreated(unitID, unitDefID, team)
	if team ~= Spring.GetGaiaTeamID() then
		if spacecraftDefs[unitDefID] then
			spacecraft[unitID] = {
				unitDefID = unitDefID,
				behavior = 0,
				roll = 0,
				pitch = 0,
				heading = (spGetUnitHeading(unitID)/65536*2*pi or 0),
				invert = false,
				moveGoal = nil,
				speed = 0,
				wantedSpeed = 0,
				attackSpeedState = spacecraftDefs[unitDefID].initAttackSpeedState,
				velocity = {0,0,0},
				turnrate = spacecraftDefs[unitDefID].turnrate,
				rotationVelocity = {0,0,0},
				radius = Spring.GetUnitRadius(unitID)*2,--UnitDefs[unitDefID].xsize * 8,
				commandCache = nil,
				commandCacheTTL = 0,
				timeBeforeShakePursuer = TIME_BEFORE_SHAKE_PURSUER,
				forceChaseTarget = nil,
				fresh = true,
				lastCollisionAvoidance = -99999,
			}
			spacecraft[unitID].heading = NormalizeHeading(spacecraft[unitID].heading)
			cmdSetAttackSpeed.params[1] = spacecraft[unitID].attackSpeedState
			Spring.InsertUnitCmdDesc(unitID, cmdSetAttackSpeed)
			
			Spring.SetUnitBlocking(unitID, true, true)
			local x,y,z=Spring.GetUnitPosition(unitID)
			Spring.MoveCtrl.Enable(unitID)
			Spring.MoveCtrl.SetPosition(unitID,x,0,z)
			--Spring.MoveCtrl.SetPosition(unitID,x,math.random(-100, 200),z)
			--Spring.MoveCtrl.SetPosition(unitID,x, unitDefID == UnitDefNames.placeholdersior.id and 1000 or 0,z)
			Script.SetWatchUnit(unitID, true)
		end
	end
end

function gadget:UnitDestroyed(unitID ,unitDefID,unitTeam)
	spacecraft[unitID] = nil
	disabledUnits[unitID] = nil
	--waitWaitList[unitID] = nil
	noCollideUnits[unitID] = nil
end


function gadget:AllowCommand(unitID, unitDefID, unitTeam, cmdID, cmdParams, cmdOptions, cmdTag, synced)
	if spacecraft[unitID] then
		if cmdID == CMD.ATTACK and not cmdOptions.shift then	-- explicit attack order makes unit stop avoidance behavior
			local target = #cmdParams == 1 and cmdParams[1]
			if target and spValidUnitID(target) then
				spacecraft[unitID].moveGoal = {GetUnitAimPos(target)}
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

local wantedInvert = false
local lastDeltaPitch = 0
function gadget:GameFrame(f)
	for unitID, data in pairs(spacecraft) do
		--[[
		if waitWaitList[unitID] then
			Spring.GiveOrderToUnit(unitID, CMD.WAIT, {}, 0)
			Spring.GiveOrderToUnit(unitID, CMD.WAIT, {}, 0)
			waitWaitList[unitID] = nil
		end
		]]
		if not disabledUnits[unitID] then
			local unitDefID = data.unitDefID
			local def = spacecraftDefs[unitDefID]
			local px, py, pz = GetUnitMidPos(unitID)
			
			local distance = 0
			local waiting = false	-- for Godot
			
			local cmdID
			
			local frontVector, topVector, rightVector = Spring.GetUnitVectors(unitID)
			local dx, dy, dz = unpack(frontVector) 
			local heading = spGetHeadingFromVector(dx, dz)/65536*2*pi
			local pitch = -math.atan2(dy, (dx^2+dz^2)^0.5)
			--if pitch < -pi then pitch = -pi - pitch end
			
			data.invert = topVector[2] < 0
			
			local _,_,roll = Spring.GetUnitRotation(unitID)
			
			local fresh = data.fresh
			if fresh then	-- fix for units instantly pointing south on first turn
				--pitch = math.pi	-- debug
				--local pitch = math.rad(-80)
				Spring.MoveCtrl.SetRotation(unitID,pitch,heading,data.roll)
			end
			data.fresh = nil
			
			-- first determine what we should do
			if data.commandCacheTTL <= 0 then
				local commands = spGetUnitCommands(unitID, 2) or {}
				local command1 = commands[1]
				if command1 and command1.id ~= 0 and command1.id ~= CMD.SET_WANTED_MAX_SPEED and command1.id ~= CMD.WAIT then
					data.commandCache = commands[1]
				else
					if command1 and command1.id == CMD.WAIT then
						waiting = true
					end
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
				cmdID = command.id
				local orbitTarget = def.orbitTarget
				if data.forceChaseTarget then
					cmdID = CMD.ATTACK
					--orbitTarget = false
				end
				
				-- check commands
				if specialCMDs[cmdID] then
					local tx, ty, tz
					if (#command.params == 1) then
						tx, ty, tz = GetTargetIntercept(unitID, command.params[1])
					else
						tx, ty, tz = unpack(command.params)
					end
					if tx and ty and tz then
						distance = GetDistance(px, py, pz, tx, ty, tz)
						local minRange = specialPowers[specialCMDs[cmdID]].minRange
						local maxRange = specialPowers[specialCMDs[cmdID]].maxRange
						if distance > maxRange then
							data.behavior = 2
							data.moveGoal = {tx, ty, tz}
							data.wantedSpeed = def.speed
						elseif distance < minRange then
							if data.behavior ~= 3 then
								data.behavior = 3
								data.wantedSpeed = def.speed
								data.moveGoal = GetDistanceFromTargetMoveGoal(tx, ty, tz, heading, minRange + 150, def.minAvoidanceAngle, def.maxAvoidanceAngle)
							end
						else
							data.behavior = 2
							data.wantedSpeed = GetWantedSpeed(unitID, distance, data, def)
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
						distance = spGetUnitSeparation(unitID, targetID, false)
						local targetDefID = spGetUnitDefID(targetID)
						local targetDef = spacecraftDefs[targetDefID] or {}
						local targetData = spacecraft[targetID]
						
						local orbitDistance = def.combatRange
						if cmdID == CMD.GUARD then
							orbitDistance = targetDef.avoidDistance + 100
						end
						if distance > (orbitDistance) then
							data.behavior = 2
							data.moveGoal = {GetTargetIntercept(unitID, targetID, distance)}
							data.wantedSpeed = def.speed
						elseif data.behavior == 2 then
							local tx, ty, tz = GetUnitMidPos(targetID)
							data.moveGoal = GetDistanceFromTargetMoveGoal(tx, ty, tz, heading, orbitDistance, def.minAvoidanceAngle, def.maxAvoidanceAngle)
							data.wantedSpeed = ((cmdID == CMD.GUARD) or (def.combatSpeed < targetData.wantedSpeed)) and def.speed or def.combatSpeed
							data.behavior = 3
						end
					end
				elseif cmdID == CMD.ATTACK then
					local targetID = data.forceChaseTarget or command.params[1]
					if targetID and spValidUnitID(targetID) then
						distance = spGetUnitSeparation(unitID, targetID, false)
						local targetDefID = spGetUnitDefID(targetID)
						local targetDef = spacecraftDefs[targetDefID] or {}
						
						if data.behavior == 2 then
							-- too close, switch to avoid behavior
							local avoidDistance = math.max(def.minimumRange, targetDef.avoidDistance, MIN_AVOID_DISTANCE)
							if distance < avoidDistance then
								data.behavior = 3
								local tx, ty, tz = GetUnitMidPos(targetID)
								data.moveGoal = GetDistanceFromTargetMoveGoal(tx, ty, tz, heading, def.combatRange + 150, def.minAvoidanceAngle, def.maxAvoidanceAngle)
								data.lastDistance = distance
								data.wantedSpeed = def.speed
								--Spring.Echo(unitID .. " last distance = " .. distance)
							else
								data.moveGoal = {GetUnitAimPos(targetID)}
								data.wantedSpeed = GetWantedSpeed(unitID, distance, data, def)
							end
						elseif data.behavior == 3 then
							-- if target is on our tail, attempt to shake
							if distance <= (data.lastDistance or 0) + (def.speed) then
								data.timeBeforeShakePursuer = data.timeBeforeShakePursuer - 1
								if data.timeBeforeShakePursuer == 0 then
									data.behavior = 2
									data.moveGoal = {GetTargetIntercept(unitID, targetID, distance)}
									data.wantedSpeed = def.combatSpeed
									--Spring.Echo(unitID .. " is attempting to shake (distance " .. distance .. ", was " .. data.lastDistance .. ")")
								end
								data.lastDistance = distance
								data.timeBeforeShakePursuer = TIME_BEFORE_SHAKE_PURSUER
							end
							-- far enough, switch to closing behavior
							local distance2 = GetDistance(px, py, pz, data.moveGoal[1], data.moveGoal[2], data.moveGoal[3])
							if distance > def.combatRange or distance2 < MOVE_DISTANCE_THRESHOLD then
								data.behavior = 2
								data.moveGoal = {GetTargetIntercept(unitID, targetID, distance)}
								data.wantedSpeed = GetWantedSpeed(unitID, distance, data, def)
								data.timeBeforeShakePursuer = TIME_BEFORE_SHAKE_PURSUER
								--Spring.Echo("Got enough distance, closing in again")
							end
						--elseif def.standoff then
							-- FIXME unimplemented
							--data.behavior = 6
						else
							data.behavior = 2
							data.moveGoal = {GetTargetIntercept(unitID, targetID, distance)}
							data.wantedSpeed = GetWantedSpeed(unitID, distance, data, def)
							data.timeBeforeShakePursuer = TIME_BEFORE_SHAKE_PURSUER
						end
						--if f%120 == 0 and data.lastMoveGoal and data.moveGoal and data.lastMoveGoal[1] == data.lastMoveGoal[1] and data.lastMoveGoal[3] == data.moveGoal[3] then
						--	Spring.Echo("FFS", data.moveGoal[1], data.moveGoal[3])
						--end
						--data.lastMoveGoal = data.moveGoal
					else
						RequestNewTarget(unitID, unitDefID)
					end
				elseif cmdID == CMD_TURN then
					data.moveGoal = command.params
					data.wantedSpeed = 0
				elseif MOVE_COMMANDS[cmdID] then
					data.moveGoal = command.params
					distance = GetDistance(px, py, pz, data.moveGoal[1], data.moveGoal[2], data.moveGoal[3])
					data.wantedSpeed = (distance > 100) and def.speed or def.combatSpeed
					if distance <= MOVE_DISTANCE_THRESHOLD then	-- close enough
						Spring.GiveOrderToUnit(unitID, CMD.REMOVE, {data.commandCache.tag}, {})
					end
				end
				
				-- collision warning: dodge if needed
				if data.speed > 0 then
					local radius = data.radius
					local safetyRange = radius*2 + 250
					local potentialColidees = Spring.GetUnitsInSphere(px, py, pz, safetyRange)
					for i=1,#potentialColidees do
						local otherUnitID = potentialColidees[i]
						local otherUnitData = spacecraft[otherUnitID] and spacecraftDefs[spacecraft[otherUnitID].unitDefID]
						if spacecraft[otherUnitID] and otherUnitID ~= unitID and otherUnitID ~= command.params[1] and def.mass/otherUnitData.mass < 3 then
							local ox, oy, oz = GetUnitMidPos(otherUnitID)
							local otherUnitPos = {ox, oy, oz}
							local vec = {ox - px, oy - py, oz - pz}
							local otherRadius = spacecraft[otherUnitID].radius
							local radiusSum = radius + otherRadius
							local inCylinder, dist = Spring.Utilities.IsPointInCylinder({px, py, pz}, vec, safetyRange^2, radiusSum^2, otherUnitPos, false)
							if inCylinder then
								-- avoid
								if data.lastCollisionAvoidance + MAX_COLLISION_AVOIDANCE_PERIOD < f then
									data.lastCollisionAvoidance = f
									local frontVector, rightVector, topVector = Spring.GetUnitVectors(unitID)
									local avoidMoveGoal = GetCollisionAvoidanceMoveGoal(ox, oy, oz, rightVector, topVector, radiusSum + 50)
									data.avoidanceMoveGoal = avoidMoveGoal
									--Spring.GiveOrderToUnit(unitID, CMD.FIGHT, {avoidMoveGoal[1], avoidMoveGoal[2], avoidMoveGoal[3]}, 0)
									--Spring.GiveOrderToUnit(unitID, CMD.INSERT, {0, CMD.FIGHT, 0, avoidMoveGoal[1], avoidMoveGoal[2], avoidMoveGoal[3]}, {"alt"})
									--Spring.Echo(avoidMoveGoal[1] - ox, avoidMoveGoal[2] - oy, avoidMoveGoal[3] - oz)
									--Spring.Echo("Unit " .. unitID .. " is avoiding other unit " .. otherUnitID .. " due to collision risk")
								else
									distance = GetDistance(px, py, pz, data.moveGoal[1], data.moveGoal[2], data.moveGoal[3])
									data.wantedSpeed = (distance > 100) and def.speed or def.combatSpeed
									if distance <= MOVE_DISTANCE_THRESHOLD then	-- close enough
										data.avoidanceMoveGoal = nil
									end
								end
								break
							end
						end
					end
					
					if data.lastCollisionAvoidance + COLLISION_AVOIDANCE_TTL < f then
						data.avoidanceMoveGoal = nil
					end
				end
			end
			
			if f%30 == 0 then
				if ((not data.commandCache) or AUTOENGAGE_COMMANDS[data.commandCache.id]) and not waiting then
					RequestNewTarget(unitID, unitDefID, data.commandCache == nil)
				end
			end
			
			-- decided what we want to do, now to get there
			
			local speed = 0
			local moveGoal = data.avoidanceMoveGoal or data.moveGoal
			local deltaHeading, deltaPitch = 0, 0
			
			local energy = GG.Energy and GG.Energy.GetUnitEnergy(unitID)
			if energy and energy == 0 then	-- stranded!
				Spring.MoveCtrl.SetDrag(unitID, 0.1)	-- space friction (keeps 'em from wandering offmap)
				-- make no changes to our facing or speed
			else
				Spring.MoveCtrl.SetDrag(unitID, 0)
				if moveGoal then
					local wantedPitch, wantedHeading
					local vectorY = moveGoal[2] - py
					local vectorX, vectorZ = moveGoal[1] - px , moveGoal[3] - pz
					local dxz = math.sqrt(vectorX^2 + vectorZ^2)
					
					wantedPitch = -math.atan2(vectorY, dxz)
					wantedHeading = spGetHeadingFromVector(vectorX, vectorZ)/65536*2*pi
					deltaHeading = NormalizeHeading(wantedHeading - heading)
					deltaPitch = wantedPitch - pitch
					
					if math.abs(deltaHeading) < 0.02 then
						deltaHeading = 0
					end
					
					if math.abs(wantedPitch - pitch) < 0.02 then
						deltaPitch = 0
					end
					
					-- faster to Immelmann/split-S then turn around
					-- FIXME: doesn't work
					-- meh, no-one will notice if they don't do this
					--[[
					local wantInvert = false
					if math.abs(deltaHeading) > math.abs(deltaPitch) then
						wantInvert = true
						deltaPitch = -deltaPitch
						deltaHeading = math.pi - deltaHeading
					end
					--if (lastDeltaPitch > 0 and deltaPitch < 0) or (lastDeltaPitch < 0 and deltaPitch > 0) then
					--	Spring.Echo("stuck")					
					--end
					lastDeltaPitch = deltaPitch 
					if wantInvert ~= wantedInvert then
						if wantInvert then
							--Spring.Echo("Want invert", deltaHeading, wantedPitch)
						else
							--Spring.Echo("Don't want invert", deltaHeading, wantedPitch)
						end
						wantedInvert = wantInvert
					end
					]]
				end
				
				local slowState = spGetUnitRulesParam(unitID,"slowState") or 0
				local turnrate = data.turnrate * (1 - slowState)
				if data.maneuveringDisabled then
					turnrate = 0
				end
				
				local rvx = 0
				if deltaPitch ~= 0 then
					rvx = GetWantedRotation(deltaPitch, turnrate)
				end
				local rvy, rvz = 0, 0
				local rollDir = 0
				
				if deltaHeading ~= 0 then
					rvy = GetWantedRotation(deltaHeading, turnrate)
				end
				
				if deltaHeading > 0 then
					if roll < def.rollAngle then
						rvz = -def.rollSpeed
					else
						rvz = 0
					end
				elseif deltaHeading < 0 then
					if roll > -def.rollAngle then
						rvz = def.rollSpeed
					else
						rvz = 0
					end
				else
					if roll < 0.01 and roll > -0.01 then
						rvz = 0
					else
						rvz = GetWantedRotation(roll, def.rollSpeed)
					end
				end
				if rvz < 0.01 and rvz > -0.01 then
					rvz = 0
				end
				
				Spring.MoveCtrl.SetRotationVelocity(unitID, rvx, rvy, rvz)
				
				local oldSpeed = data.speed
				speed = data.wantedSpeed --GetNewSpeed(data.speed, data.wantedSpeed, def.acceleration, def.brakerate)
				-- prevents problems with moving to destination inside our turning circle
				if distance < def.turnDiameter and math.abs(deltaHeading) > def.maxTurnAngle then
					speed = cmdID == CMD.MOVE and 0 or def.combatSpeed
				end
				
				local maxSpeed = def.speed * (1 - slowState)
				if speed > maxSpeed then
					speed = maxSpeed
				end
				
				if data.forcedSpeed then
					speed = data.forcedSpeed
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
			end
					
			-- calculate velocity
			--Spring.MoveCtrl.SetRelativeVelocity(p.unit,0,0,speed)
			local vx = math.sin(heading) *(math.cos(pitch))*speed
			local vy = -math.sin(pitch)*speed
			local vz = math.cos(heading) *(math.cos(pitch))*speed
			
			local vx1, vy1, vz1 = unpack(data.velocity)
			local inertiaFactor = def.inertiaFactor
			
			vx = vx*(1-inertiaFactor) + vx1*inertiaFactor
			vy = vy*(1-inertiaFactor) + vy1*inertiaFactor
			vz = vz*(1-inertiaFactor) + vz1*inertiaFactor
			
			data.pitch = pitch
			data.heading = heading
			data.roll = roll
			data.velocity = {vx, vy, vz}
			--Spring.SetUnitVelocity(unitID, vx, vy, vz)
			Spring.MoveCtrl.SetVelocity(unitID, vx, vy, vz)
			
			Spring.SetUnitRulesParam(unitID, "heading", heading)
			Spring.SetUnitRulesParam(unitID, "pitch", pitch)
			Spring.SetUnitRulesParam(unitID, "roll", data.roll)
			
			-- collision: knock units apart
			if (not noCollideUnits[unitID]) then
				local radius = data.radius
				local potentialColidees = Spring.GetUnitsInSphere(px, py, pz, radius)
				for i=1,#potentialColidees do
					local otherUnitID = potentialColidees[i]
					if spacecraft[otherUnitID] and otherUnitID ~= unitID and (not noCollideUnits[otherUnitID]) then
						local distance = spGetUnitSeparation(unitID, otherUnitID)
						local otherRadius = spacecraft[otherUnitID].radius
						local radiusSum = radius + otherRadius
						--Spring.Echo(radiusSum, distance)
						if distance < radiusSum then
							--Spring.Echo("collision")
							-- something tells me this is totally wrong
							local vx1, vy1, vz1 = GetUnitVelocity(unitID)
							local vx2, vy2, vz2 = GetUnitVelocity(otherUnitID)
							local vx, vy, vz = vx1 - vx2, vy1 - vy2, vz1 - vz2
							local ox, oy, oz = GetUnitMidPos(otherUnitID)
							local vector = {GG.Vector.Normalized(px - ox, py - oy, pz - oz)}
							local mass1, mass2 = def.mass, spacecraftDefs[spacecraft[otherUnitID].unitDefID].mass
							local mass = mass1 + mass2
							
							local mx1, my1, mz1 = vx1*mass1, vy1*mass1, vz1*mass1	-- per-axis momentum of unit 1 at collision
							local mx2, my2, mz2 = vx2*mass2, vy2*mass2, vz2*mass2	-- per-axis momentum of unit 2 at collision
							--local mx, my, mz = mx1 - mx2, my1 - my2, mz1 - mz2
							
							-- protip: get the dot product of the two units' positioning vector and the movement vector of the unit whose impulse is being applied to the system
							-- multiply that by raw impulse to get the actual impulse to apply
							local vx1n, vy1n, vz1n = GG.Vector.Normalized(vx1, vy1, vz1)
							local vx2n, vy2n, vz2n = GG.Vector.Normalized(vx2, vy2, vz2)
							local dotProduct1 = vx1n * vector[1] + vy1n * vector[2] + vz1n * vector[3]
							local dotProduct2 = vx2n * -vector[1] + vy2n * -vector[2] + vz2n * -vector[3]
							--if dotProduct1 < 0 then dotProduct1 = 0 end
							--if dotProduct2 < 0 then dotProduct2 = 0 end
							
							local impulseMult1 = mass2/mass*dotProduct1
							local impulseMult2 = mass1/mass*dotProduct2
							
							-- protip: momentum is conserved
							-- apply the momentum caused by unit1 on unit2 to unit1 in reverse as well
							
							-- apply each unit's momentum to both units
							local ix1, iy1, iz1 = mx1*impulseMult1, my1*impulseMult1, mz1*impulseMult1
							local ix2, iy2, iz2 = mx2*impulseMult2, my2*impulseMult2, mz2*impulseMult2
						
							
							SetUnitVelocity(unitID, vx1 + (ix1 - ix2)/mass1, vy1 + (iy1 -iy2)/mass1, vz1 + (iz1 - iz2)/mass1)
							SetUnitVelocity(otherUnitID, vx2 + (-ix1 + ix2)/mass2, vy1 + (-iy1 + iy2)/mass2, vz2 + (-iz1 + iz2)/mass2)
							noCollideUnits[unitID] = f + 30
							noCollideUnits[otherUnitID] = f + 30
							
							--FIXME play sound; apply collision damage; add CEG
						end
					end
				end
			end
		end
	end
	
	for unitID, expireFrame in pairs(noCollideUnits) do
		if f - expireFrame > 0 then
			noCollideUnits[unitID] = nil
		end
	end
end

else
--------------------------------------------------------------------------------
--UNSYNCED
--------------------------------------------------------------------------------
--[[
local function GetUnitMidPos(unitID)
	local _,_,_,x,y,z = spGetUnitPosition(unitID, true)
	return x,y,z
end

local function DrawLine(x1, y1, z1, x2, y2, z2)
	gl.Vertex(x1, y1, z1)
	gl.Vertex(x2, y2, z2)
end

function gadget:DrawWorld()
	local spacecraft = SYNCED.spacecraft
	for unitID,data in spairs(spacecraft) do
		local amg = data.avoidanceMoveGoal
		local ux, uy, uz = GetUnitMidPos(unitID)
		if amg then
			gl.BeginEnd(GL.LINES, DrawLine, ux, uy, uz, amg[1], amg[2], amg[3])
		end
		gl.BeginEnd(GL.LINES, DrawLine, ux - data.radius, uy + 20, uz, ux + data.radius, uy + 20, uz)
	end
end
]]

end