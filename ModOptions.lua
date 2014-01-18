local options= {
	{
		key="changewaterlevel",
		name="Change water level",
		desc="Changes the water level (useful for sinking islands).",
		type="number",
		def=0,
		min=-5000,
		max=5000,
		step=1,
		section="Experimental",
	},
	{
		key="enableabilities",
		name="Enable special abilities",
		desc="Set whether special abilities are available (super attacks will always be enabled)",
		type="bool",
		def=1,
		section="Experimental",
	},	
}

return options
