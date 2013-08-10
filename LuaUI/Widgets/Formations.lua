local CMDTYPE_ICON_FRONT  = CMDTYPE.ICON_FRONT
local CMD_AUTOREPAIRLEVEL = CMD.AUTOREPAIRLEVEL
local CMD_FIGHT           = CMD.FIGHT
local CMD_IDLEMODE        = CMD.IDLEMODE
local CMD_INSERT          = CMD.INSERT
local CMD_MOVE            = CMD.MOVE
local CMD_REMOVE          = CMD.REMOVE
local spFindUnitCmdDesc   = Spring.FindUnitCmdDesc
local spGetUnitCommands   = Spring.GetUnitCommands
local spGetUnitDefID      = Spring.GetUnitDefID
local spGetUnitPosition   = Spring.GetUnitPosition
local spGiveOrderToUnit   = Spring.GiveOrderToUnit
local spInsertUnitCmdDesc = Spring.InsertUnitCmdDesc
local spRemoveUnitCmdDesc = Spring.RemoveUnitCmdDesc

function widget:GetInfo()
	return {
		name = "Formations",
		desc = "Makes move orders not result in clumps",
		author = "KDR_11k (David Becker) - Modified for use as widget by SkyStar",
		date = "2008-03-21",
		license = "Public Domain",
		layer = 1,
		enabled = true
	}
end

local formationType = 2 --- Controls what formation the units take (1-5)

local orders={}
local validCommand={
	[CMD.FIGHT]=CMD_FIGHT,
	[CMD.MOVE]=CMD_MOVE,
}
local roles={}
local roleCode={
	large=1,
	attacker=2,
	brawler=3,
	sniper=4,
	support=5,
}

local function sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

local function GetRolePos(role, count, x, z, dirx, dirz, width)
	sidex=dirz
	sidez=-dirx
	local offx, offz =0,0
	local step=0
	if role==1 then
		offx=math.floor((1+count)/2) * 120 * (1-(count%2)*2)
		offz=-150
		step = 100
	elseif role==2 then
		offx=math.floor((1+count)/2) * 60 * (1-(count%2)*2)
		offz=15 -- - math.floor((1+count)/2) * 20
		step = 60 --width and width/6
	elseif role==3 then
		offx=math.floor((1+count)/2) * 50 * (1-(count%2)*2)
		offz=80 + math.floor((1+count)/2) * 10
	elseif role==4 then
		offx=math.floor((1+count)/2) * 80 * (1-(count%2)*2)
		offz=-120 + math.floor((1+count)/2) * 20
		step = width and width/3
	elseif role==5 then
		offx=math.floor((1+count)/2) * 40 * (1-(count%2)*2)
		offz=-150
		step = 40
	end
	if width then
		offz = offz - step * math.floor(math.abs(offx) / width)
		offx = sign(offx) * (math.abs(offx) % width)
	end
	return x+(offx*sidex)+(offz*dirx), z+(offx*sidez)+(offz*dirz)
end

function widget:Initialize()
	for i,d in ipairs(UnitDefs) do
		if d.customParams.type == "large" then
			roles[i]=roleCode.large
		elseif d.customParams.role then
			roles[i]=roleCode[d.customParams.role] or formationType
		end
	end
end

function widget:UnitCommand(u, ud, team, cmd, opts, params)
	if not validCommand[cmd] then
		return true
	elseif not roles[ud] then
		return false
	end
	if not orders[team] then
		orders[team]={}
	end
	if not orders[team][cmd] then
		orders[team][cmd]={count = 0, units = {}}
	end
	table.insert(orders[team][cmd].units, {
		unit=u,
		params=params,
	})
	orders[team][cmd].count = orders[team][cmd].count + 1
	return true
end

function widget:GameFrame(f)
	for t,tCs in pairs(orders) do
		for c,cData in pairs(tCs) do
			local units = cData.units
			local count = cData.count
			local done = false
			while not done do
				if count == 0 then
					break
				end
				local currentList={}
				local x,z = 0,0
				local currentParams
				local taken = 0
				for _,u in pairs(units) do
					currentParams=u.params
					break
				end
				for i,u in pairs(units) do
					local match = true
					for pi,p in ipairs(u.params) do
						if p ~= currentParams[pi] then
							match = false
							break
						end
					end
					if match then
						currentList[u.unit]=true
						units[i]=nil
						taken = taken + 1
						count = count -1
						local px,_,pz = spGetUnitPosition(u.unit)
						x=x+px
						z=z+pz
					end
				end
				if count ==0 then
					done=true
				end
				if taken > 1 then
					local roleCount={0,0,0,0,0}
					x=(x / taken)
					z=(z / taken)
					local dirx = currentParams[1] - x
					local dirz = currentParams[3] - z
					if currentParams[4] then
						dirz = -(currentParams[4] - currentParams[1])
						dirx = currentParams[6] - currentParams[3]
					end
					local dirlen = math.sqrt(dirx*dirx + dirz*dirz)
					dirx = dirx/dirlen
					dirz = dirz/dirlen
					local width = (currentParams[4] and dirlen) or 620
					for u,_ in pairs(currentList) do
						local ud = spGetUnitDefID(u)
						local rc = roleCount[roles[ud]]
						roleCount[roles[ud]]=rc+1
						local tx, tz = GetRolePos(roles[ud], rc, currentParams[1], currentParams[3], dirx, dirz, width)
						for _,com in ipairs(spGetUnitCommands(u)) do
							if validCommand[com.id] then
							local posx, posy, posz = Spring.GetUnitPosition(u)
								spGiveOrderToUnit(u, CMD_INSERT, {com.tag, validCommand[com.id], 0, tx,posy,tz},{})
								spGiveOrderToUnit(u, CMD_REMOVE, {com.tag},{})
								break
							end
						end
					end
				else
					for u,_ in pairs(currentList) do
						for _,com in ipairs(spGetUnitCommands(u)) do
							if validCommand[com.id] then
							local posx, posy, posz = Spring.GetUnitPosition(u)
								spGiveOrderToUnit(u, CMD_INSERT, {com.tag, validCommand[com.id], 0, com.params[1],posy,com.params[3]},{})
								spGiveOrderToUnit(u, CMD_REMOVE, {com.tag},{})
								break
							end
						end
					end
				end
			end
		end
	end
	orders={}
end
