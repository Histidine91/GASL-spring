--------------------------------------------------------------------------------
-- system functions
--------------------------------------------------------------------------------
Spring.Utilities = Spring.Utilities or {}
VFS.Include("LuaRules/Utilities/base64.lua")
VFS.Include("LuaRules/Utilities/tablefunctions.lua")
local CopyTable = Spring.Utilities.CopyTable
local MergeTable = Spring.Utilities.MergeTable

VFS.Include("gamedata/modularcomms/functions.lua")
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

weapons = {}

upgrades = {
	-- WEAPON MODS
	weaponmod_ap_ammo = {
		name = "Armor Piercing Ammo",
		description = "Autocannons/Railguns: +50% armor penetration",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.customparams.category.ballistic then
						v.customparams.ap = v.customparams.ap * 1.5
					end
				end
		end,
	},
	weaponmod_rail_accel = {
		name = "Rail Accelerator",
		description = "Railguns: +40% damage, +10% range, +25% energy usage",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.customparams.category.railgun then
						v.range = v.range * 1.1
						v.customparams.energypershot = v.customparams.energypershot * 1.25
						for armorname, dmg in pairs(v.damage) do
							v.damage[armorname] = dmg * 1.4
						end
					end
				end
		end,
	},
	weaponmod_high_freq_beam = {
		name = "High Frequency Beam",
		description = "Lasers: +40% damage, +10% range, +25% energy usage",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.customparams.category.laser then
						v.range = v.range * 1.1
						v.customparams.energypershot = v.customparams.energypershot * 1.25
						for armorname, dmg in pairs(v.damage) do
							v.damage[armorname] = dmg * 1.4
						end
					end
				end
		end,
	},
	weaponmod_eccm = {
		name = "ECCM Package",
		description = "Missiles/Phalanxes: +20 ECCM",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.customparams.category.seeker then
						v.customparams.eccm = (v.customparams.eccm or 0) + 20
					end
				end
		end,
	},
	weaponmod_high_impact_missiles = {
		name = "Hi-Impact Missiles",
		description = "Missiles: +50% damage",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.customparams.category.missile then
						v.customparams.eccm = (v.customparams.eccm or 0) + 20
					end
				end
		end,
	},
	weaponmod_particle_ionizer = {
		name = "Particle Ionizer",
		description = "Particle Accelerator: +25% damage, +200% EMP damage, +10% energy usage",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.customparams.category.laser then
						v.customparams.energypershot = v.customparams.energypershot * 1.1
						for armorname, dmg in pairs(v.damage) do
							v.damage[armorname] = dmg * 1.25
						end
						v.customparams.empdamage = v.damage.default * 2
					end
				end
		end,
	},
	weaponmod_disruptor_ammo = {
		name = "Disruptor Ammo",
		description = "Ballistics/Missiles: +100% EMP damage",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.customparams.category.ballistic or v.customparams.category.missile then
						v.customparams.empdamage = v.damage.default * 1
					end
				end
		end,
		order = 1.1,
	},
	weaponmod_overcharger = {
		name = "Overcharger",
		description = "Energy weapons: +40% damage, +40% energy usage",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.customparams.category.energy then
						v.customparams.energypershot = v.customparams.energypershot * 1.4
						for armorname, dmg in pairs(v.damage) do
							v.damage[armorname] = dmg * 1.4
						end
					end
				end
		end,
		order = 1.1,
	},
	
	weaponmod_antimatter = {
		name = "Antimatter Containment System",
		description = "All weapons: +50% damage",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					for armorname, dmg in pairs(v.damage) do
						v.damage[armorname] = dmg * 1.5
					end
				end
		end,
	},
	
	-- COMPUTERS
	computer_fire_control = {
		name = "Trueshot Fire Control System",
		description = "+20% accuracy",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.accuracy then
						v.accuracy = v.accuracy*0.8
					end
					if v.sprayangle then
						v.sprayangle = v.sprayangle*0.8
					end
				end
		end,
	},
	computer_impact_convergence = {
		name = "Impact Convergence Control System",
		description = "+50% critical chance",
		func = function(unitDef)
				local weapons = unitDef.weapondefs or {}
				for i,v in pairs(weapons) do
					if v.customparams.critchance then
						v.customparams.critchance = v.customparams.critchance * 1.5
					end
				end
		end,
	},
	computer_flight_control = {
		name = "Fleetfoot Flight Control System",
		description = "+20% turn rate and maneuverability",
		func = function(unitDef)
				unitDef.turnrate = unitDef.turnrate*1.2
				local maneuverability = (1 - unitDef.customparams.inertiafactor)*1.2
				unitDef.customparams.inertiafactor = 1 - maneuverability
		end,
	},
	computer_empathic_feedback = {
		name = "Empathic Feedback System",
		description = "+25% morale",
		func = function(unitDef)
				unitDef.customparams.morale = unitDef.customparams.morale*1.25
		end,
	},
	
	-- UTILITY
	utility_super_capacitor = {
		name = "High-Density Capacitors",
		description = "+25% energy",
		func = function(unitDef)
				unitDef.customparams.energy = unitDef.customparams.energy*1.25
		end,
	},
	utility_power_thrusters = {
		name = "High-Impulse Thrusters",
		description = "+10% speed, +20% maneuverability, +20% turnrate, +15% energy usage",
		func = function(unitDef)
				unitDef.maxvelocity = unitDef.maxvelocity*1.1
				unitDef.turnrate = unitDef.turnrate*1.2
				local maneuverability = (1 - unitDef.customparams.inertiafactor)*1.2
				unitDef.customparams.inertiafactor = 1 - maneuverability
				unitDef.customparams.thrusterenergyuse = (unitDef.customparams.thrusterenergyuse or 1)*1.15
		end,
	},
	utility_ecm = {
		name = "Advanced ECM Suite",
		description = "+30% ECM rating",
		func = function(unitDef)
				unitDef.customparams.ecm = (unitDef.customparams.ecm or 1)*1.3
		end,
	},
	utility_autorepair = {
		name = "Autorepair System",
		description = "25 HP/s self-repair",
		func = function(unitDef)
				unitDef.autoheal = 25
		end,
	},
	utility_heavy_armor = {
		name = "Heavy Composite Armor",
		description = "+20 armor, +5000 HP, -10% speed, -20% maneuverability, -20% turnrate",
		func = function(unitDef)
				unitDef.maxdamage = unitDef.maxdamage + 5000
				unitDef.customparams.armor = unitDef.customparams.armor + 20
				unitDef.maxvelocity = unitDef.maxvelocity*0.9
				unitDef.turnrate = unitDef.turnrate*0.8
				local maneuverability = (1 - unitDef.customparams.inertiafactor)*0.8
				unitDef.customparams.inertiafactor = 1 - maneuverability
				--unitDef.customparams.thrusterenergyuse = (unitDef.customparams.thrusterenergyuse or 1)*1.1
		end,
	}
	utility_adamantite_plating = {
		name = "Adamantite Hull Plating",
		description = "+20 armor, +5000 HP, +10% speed, +20% maneuverability, +20% turnrate",
		func = function(unitDef)
				unitDef.maxdamage = unitDef.maxdamage + 5000
				unitDef.customparams.armor = unitDef.customparams.armor + 20
				unitDef.maxvelocity = unitDef.maxvelocity*1.1
				unitDef.turnrate = unitDef.turnrate*1.2
				local maneuverability = (1 - unitDef.customparams.inertiafactor)*1.2
				unitDef.customparams.inertiafactor = 1 - maneuverability
		end,
	}
}

decorations = {
	shield_red = {
		func = function(unitDef)
				unitDef.customparams.lups_unit_fxs = unitDef.customparams.lups_unit_fxs or {}
				table.insert(unitDef.customparams.lups_unit_fxs, "commandShieldRed")		
			end,
	},
	shield_green = {
		func = function(unitDef)
				unitDef.customparams.lups_unit_fxs = unitDef.customparams.lups_unit_fxs or {}
				table.insert(unitDef.customparams.lups_unit_fxs, "commandShieldGreen")
			end,
	},
	shield_blue = {
		func = function(unitDef)
				unitDef.customparams.lups_unit_fxs = unitDef.customparams.lups_unit_fxs or {}
				table.insert(unitDef.customparams.lups_unit_fxs, "commandShieldBlue")
			end,
	},
	shield_orange = {
		func = function(unitDef)
				unitDef.customparams.lups_unit_fxs = unitDef.customparams.lups_unit_fxs or {}
				table.insert(unitDef.customparams.lups_unit_fxs, "commandShieldOrange")	
			end,
	},
	shield_violet = {
		func = function(unitDef)
				unitDef.customparams.lups_unit_fxs = unitDef.customparams.lups_unit_fxs or {}
				table.insert(unitDef.customparams.lups_unit_fxs, "commandShieldViolet")	
			end,
	},
}


for name,data in pairs(upgrades) do
	local order = data.order
	if not order then
		if name:find("weaponmod_") then
			order = 1
		elseif name:find("utility_") then
			order = 2
		elseif name:find("computer_") then
			order = 3
		else
			order = 4
		end
		data.order = order
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
