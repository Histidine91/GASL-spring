eventDefs = {
	death = {
		priorityFunc = function(eventDef, params, isEnemy)
			if (not isEnemy) then
				return 100
			end
			return 40
		end,
		staticOverlay = true
	},
	kill = {
		priorityFunc = function(eventDef, params, isEnemy)
			local power = UnitDefs[params.unitDefID2].power^0.5
			return (power)*2 + 10
		end,
	},
	unitDamaged_severe = {
		priority = 100,
		priorityEnemy = 40,
		allowMinorEvent = true,
		maxPeriod = 30*2,
		magnitudeQueueMult = 0.05,
		warningOverlay = true
	},
	unitDamaged_moderate = {
		priority = 70,
		priorityEnemy = 40,
		allowMinorEvent = true,
		magnitudeQueueMult = 0.05
	},
	unitDamaged_minor = {
		priority = 40,
		priorityEnemy = 40,
		allowMinorEvent = true,
		magnitudeQueueMult = 0.05
	},
	energy_critical = {
		priority = 90,
		allowMinorEvent = true,
		maxPeriod = 30*4,
		warningOverlay = true
	},
	unitSuppressed_severe = {
		priority = 90,
		allowMinorEvent = true,
		maxPeriod = 30*4,
	},
	unitSuppressed_moderate = {
		priority = 60,
		allowMinorEvent = true,
	},
	unitSuppressed_minor = {
		priority = 30,
		allowMinorEvent = true,
	},
	unitEnergy_critical = {
		priority = 80,
		allowMinorEvent = true,
		maxPeriod = 30*4,
	},
	unitEnergy_low = {
		priority = 50,
		queueRating = 20,
		allowMinorEvent = true,
	},
	criticalHit = {
		priority = 25,
		queueRating = 40,
		magnitudeQueueMult = 0.05
	},
	criticalHit_received = {
		priority = 25,
		queueRating = 40,
		magnitudeQueueMult = 0.05
	},
	weaponHit = {
		priority = 15,
		queueRating = 20,
		magnitudeQueueMult = 0.05
	},
	weaponMiss = {
		priority = 10,
		queueRating = 20,
		magnitudeQueueMult = 0.05
	},
	weaponEvaded = {
		priority = 10,
		queueRating = 20,
		magnitudeQueueMult = 0.05
	},
	spiritFull = {
		priority = 100,
		allowMinorEvent = true,
		maxPeriod = 30*5,
	},
	repair = {
		priority = 60,
		allowMinorEvent = true,
	},
	resupply = {
		priority = 70,
		allowMinorEvent = true,
	},
	engagingEnemy = {
		priority = 1,
		queueRating = 100,	-- always play at start
		friendlyOnly = true,
	},
	commandReceived = {
		priority = 30,
		queueRating = 100,	-- always play at start
	}
}

for eventName, eventDef in pairs(eventDefs) do
	eventDef.queueRating = eventDef.queueRating or 0
	eventDef.magnitudeQueueMult = eventDef.magnitudeQueueMult or 1
	eventDef.lastEvent = -1000
	eventDef.maxPeriod = eventDef.maxPeriod or 30*8
end