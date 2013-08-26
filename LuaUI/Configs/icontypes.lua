-- $Id: icontypes.lua 4585 2009-05-09 11:15:01Z google frog $
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    icontypes.lua
--  brief:   icontypes definitions
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local icontypes = {
	default = {
		size=1,
		radiusadjust=0,
	},
  	tiny = {
		bitmap="icons/trinver.tga",
		size=".25",
		distance=0.5,	-- Multiplier for the distance at which unit turns into icon
	},
	
	luckystar = {
		bitmap="icons/luckystar.png",
		size=2.0,
	},
	kungfufighter = {
		bitmap="icons/kungfufighter.png",
		size=2.0,
	},
	happytrigger = {
		bitmap="icons/happytrigger.png",
		size=2.4,
	},
	
	yngcommando = {
		bitmap="icons/yngcommando.png",
		size=2.0,
	},
	yngtiger = {
		bitmap="icons/yngtiger.png",
		size=2.0,
	},
	enclavestar = {
		bitmap="icons/enclavestar.png",
		size=3.0,
	},
	
	--small ships
	dagger = {
		bitmap="icons/dagger.png",
		size=2.0,
		radiusadjust=0,
	},
	sword = {
		bitmap="icons/sword.png",
		size=2.4,
		radiusadjust=0,
	},	
	mace = {
		bitmap="icons/mace.png",
		size=2.4,
		radiusadjust=0,
	},		
	claymore = {
		bitmap="icons/claymore.png",
		size=2.6,
		radiusadjust=0,
	},		
	longbow = {
		bitmap="icons/longbow.png",
		size=2.6,
		radiusadjust=0,
	},	
	warhammer = {
		bitmap="icons/warhammer.png",
		size=2.8,
		radiusadjust=0,
	},	
	probe = {
		bitmap="icons/probe.png",
		size=2.0,
		radiusadjust=0,
	},
	wraith = {
		bitmap="icons/wraith.png",
		size=2.4,
		radiusadjust=0,
	},	
	chukenu = {
		bitmap="icons/chukenu.png",
		size=2.6,
		radiusadjust=0,
	},
	shuriken = {
		bitmap="icons/shuriken.png",
		size=2.4,
		radiusadjust=0,
	},	
	
	--gunstars
	defense = {
		bitmap="icons/defense.png",
		size=2.0,
		radiusadjust=0,
	},
	defenseheavy = {
		bitmap="icons/defenseheavy.png",
		size=2.4,
		radiusadjust=0,
	},	
	
	--big ships
	carrier = {
		bitmap="icons/carrier.tga",
		size=1,
		radiusadjust=1,
	},
	supportcarrier = {
		bitmap="icons/supportcarrier.tga",
		size=1,
		radiusadjust=1,
	},
	comet = {
		bitmap="icons/comet.tga",
		size=1,
		radiusadjust=1,
	},
	starslayer = {
		bitmap="icons/starslayer.tga",
		size=1,
		radiusadjust=1,
	},
	beacon = {
		bitmap="icons/beacon.tga",
		size=4,
		radiusadjust=0,
		distance=0,
	},
	meteor = {
		bitmap="icons/meteor.tga",
		size=1,
		radiusadjust=1,
	},
	eclipse =	{
		bitmap="icons/eclipse.tga",
		size=1,
		radiusadjust=1,
	},
	imperator =	{
		bitmap="icons/imperator.tga",
		size=1,
		radiusadjust=1,
		distance=9000,
	},	
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return icontypes

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

