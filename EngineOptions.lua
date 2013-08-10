return {
	{
		key    = 'Rules',
		name   = 'Game Rules',
		desc   = 'The rules for the game',
		type   = 'section',
	},
	{
		key="Money",
		name="Resource Settings",
		desc="Settings for the resources",
		type="section",
	},
	{
		key="Planet",
		name="Planet Pattern Generation",
		desc="Settings for the planets",
		type="section",
	},
	{
		key="Perks",
		name="Perk Settings",
		desc="Settings for perks",
		type="section",
	},
	{
		key="Chicken",
		name="Chicken/DotG Settings",
		desc="Settings for Defenders of the Galaxy game mode",
		type="section",
	},
	{
		key    = 'Experimental',
		name   = 'Experimental Settings',
		desc   = 'For testing/development',
		type   = 'section',
	},

--  {
--    key    = 'MaxUnits',
--    name   = 'Max units',
--    desc   = 'Determines the ceiling of how many units and buildings a player is allowed  to own at the same time',
--    type   = 'number',
--    def    = 1000,
--    min    = 100,
--    max    = 10000,
--    section = "Rules";
--    step   = 100,  -- quantization is aligned to the def value
--                    -- (step <= 0) means that there is no quantization
--  },

  {
    key    = 'FixedAllies',
    name   = 'Lock teams',
    desc   = 'Prevent players from forming alliances ingame',
    type   = 'bool',
    def    = true,
    section = "Rules";
  },

  {
    key    = 'LimitSpeed',
    name   = 'Speed Restriction',
    desc   = 'Limits maximum and minimum speed that the players will be allowed to change to',
    type   = 'section',
  },

  {
    key    = 'MaxSpeed',
    name   = 'Maximum game speed',
    desc   = 'Sets the maximum speed that the players will be allowed to change to',
    type   = 'number',
    section= 'LimitSpeed',
    def    = 3,
    min    = 0.1,
    max    = 100,
    step   = 0.1,  -- quantization is aligned to the def value
                    -- (step <= 0) means that there is no quantization
  },

  {
    key    = 'MinSpeed',
    name   = 'Minimum game speed',
    desc   = 'Sets the minimum speed that the players will be allowed to change to',
    type   = 'number',
    section= 'LimitSpeed',
    def    = 0.3,
    min    = 0.1,
    max    = 100,
    step   = 0.1,  -- quantization is aligned to the def value
                    -- (step <= 0) means that there is no quantization
  },
}
