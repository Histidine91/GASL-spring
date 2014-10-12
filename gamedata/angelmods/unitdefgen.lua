--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    unitdefgen.lua
--  brief:   procedural generation of unitdefs for modular comms
--  author:  KingRaptor (L.J. Lim)
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
Spring.Utilities = Spring.Utilities or {}
VFS.Include("LuaRules/Utilities/base64.lua")

Spring.Log = Spring.Log or function() end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

VFS.Include("gamedata/angelmods/moduledefs.lua")

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- for examples see testdata.lua

local modOptions = (Spring and Spring.GetModOptions and Spring.GetModOptions()) or {}
local err, success

local moduleDataRaw = modOptions.angelmods
local moduleDataFunc, moduleData

if not (moduleDataRaw and type(moduleDataRaw) == 'string') then
	err = "Module data entry in modoption is empty or in invalid format"
	moduleData = {}
else
	moduleDataRaw = string.gsub(moduleDataRaw, '_', '=')
	moduleDataRaw = Spring.Utilities.Base64Decode(moduleDataRaw)
	--Spring.Echo(moduleDataRaw)
	moduleDataFunc, err = loadstring("return "..moduleDataRaw)
	if moduleDataFunc then
		success, moduleData = pcall(moduleDataFunc)
		if not success then	-- execute Borat
			err = moduleData
			moduleData = {}
		end
	end
end
if err then 
	Spring.Log("gamedata/angelmods/unitdefgen.lua", "warning", 'Angel Mods warning: ' .. err)
end

if not moduleData then moduleData = {} end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function ProcessEmblemFrame(config)
	if config.base and UnitDefs[config.base] then
		Spring.Log("gamedata/angelmods/unitdefgen.lua", "debug", "\tangelmods: Processing Emblem Frame: " .. config.base)
		ud = CopyTable(UnitDefs[config.base]
		ud.customparams = ud.customparams or {}
		local cp = ud.customparams
		
		-- store base values
		cp.basespeed = tostring(ud.maxvelocity)
		cp.basehp = tostring(ud.maxdamage)
		for i,v in pairs(ud.weapondefs or {}) do
			v.customparams = v.customparams or {}
			v.customparams.rangemod = 0
			v.customparams.reloadmod = 0
			v.customparams.damagemod = 0
		end

		local attributeMods = { -- add a mod for everythings that can have a negative adjustment
			health = 0,
			speed = 0,
			reload = 0,
		}
		
		-- process modules
		if config.modules then
			local modules = CopyTable(config.modules)
			local numWeapons = 0
			if config.prev then
				modules = MergeModuleTables(modules, config.prev)
			end
			-- sort: weapons first, weapon mods next, regular modules last
			-- individual modules can have different order values as defined in moduledefs.lua
			table.sort(modules,
				function(a,b)
					local order_a = (upgrades[a] and upgrades[a].order) or 4
					local order_b = (upgrades[b] and upgrades[b].order) or 4
					return order_a < order_b
				end )

			-- process all modules (including weapons)
			for _,moduleName in ipairs(modules) do
				if upgrades[moduleName] then
					--Spring.Echo("\tApplying upgrade: "..moduleName)
					if upgrades[moduleName].func then --apply upgrade function
						upgrades[moduleName].func(ud, attributeMods) 
					end
					if upgrades[moduleName].useWeaponSlot then
						numWeapons = numWeapons + 1
					end
				else
					Spring.Log("gamedata/angelmods/unitdefgen.lua", "error", "\tERROR: Upgrade "..moduleName.." not found")
				end
			end
			cp.modules = config.modules
		end
		
		-- apply attributemods
		if attributeMods.speed > 0 then
			ud.maxvelocity = ud.maxvelocity*(1+attributeMods.speed)
		else
			ud.maxvelocity = ud.maxvelocity*(1+attributeMods.speed)
			--ud.maxvelocity = ud.maxvelocity/(1-attributeMods.speed)
		end
		ud.maxdamage = ud.maxdamage*(1+attributeMods.health)
		
		if config.name then
			ud.name = config.name
		end
		if config.description then
			ud.description = config.description
		end
		if config.helptext then
			ud.customparams.helptext = config.helptext
		end
		
		-- apply decorations
		if config.decorations then
			for key,dec in pairs(config.decorations) do
				local decName = dec
				if type(dec) == "table" then
					decName = dec.name or key
				elseif type(dec) == "bool" then
					decName = key
				end
				
				if decorations[decName] then
					if decorations[decName].func then --apply upgrade function
						decorations[decName].func(ud, config) 
					end
				else
					Spring.Log("gamedata/angelmods/unitdefgen.lua", "warning", "\tDecoration "..decName.." not found")
				end
			end
		end
	end
end

for _, config in pairs(moduleData) do
	ProcessEmblemFrame(config)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- postprocessing

for _, config in pairs(moduleData) do
	--Spring.Echo("\tPostprocessing commtype: ".. name)
	local data = UnitDefs[config.base]
	
	-- apply intrinsic bonuses
	local damBonus = data.customparams.damagebonus or 0
	ModifyWeaponDamage(data, damBonus, true)
	local rangeBonus =  data.customparams.rangebonus or 0
	ModifyWeaponRange(data, rangeBonus, true)

	if data.customparams.speedbonus then
		commDefs[name].customparams.basespeed = commDefs[name].customparams.basespeed or commDefs[name].maxvelocity
		commDefs[name].maxvelocity = commDefs[name].maxvelocity + (commDefs[name].customparams.basespeed*data.customparams.speedbonus)
	end
	
	-- calc lightning real damage based on para damage
	-- TODO: use for slow-beams
	if data.weapondefs then
		for name, weaponData in pairs(data.weapondefs) do
			if (weaponData.customparams or {}).extra_damage_mult then
				weaponData.customparams.extra_damage = weaponData.customparams.extra_damage_mult * weaponData.damage.default
				weaponData.customparams.extra_damage_mult = nil
			end
		end
	end	
	
	-- set mass
	data.mass = ((data.buildtime/2 + data.maxdamage/10)^0.55)*9
	--Spring.Echo("mass " .. (data.mass or "nil") .. " BT/HP " .. (data.buildtime or "nil") .. "  " .. (data.maxdamage or "nil"))
	
	-- rez speed
	if data.canresurrect then 
		data.resurrectspeed = data.workertime*0.8
	end
	
	-- make sure weapons can hit their max range
	if data.weapondefs then
		for name, weaponData in pairs(data.weapondefs) do
			if weaponData.weapontype == "MissileLauncher" then
				weaponData.flighttime = math.max(weaponData.flighttime or 3, 1.2 * weaponData.range/weaponData.weaponvelocity)
			elseif weaponData.weapontype == "Cannon" then
				weaponData.weaponvelocity = math.max(weaponData.weaponvelocity, math.sqrt(weaponData.range * (weaponData.mygravity or 0.14)*1000))
			end
		end
	end
end
