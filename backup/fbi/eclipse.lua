-- UNITDEF -- ECLIPSE --
--------------------------------------------------------------------------------

local unitName = "eclipse"

--------------------------------------------------------------------------------

local unitDef = {
  acceleration       = .04,
  airHoverFactor     = 0,
  airStrafe          = false,
  autoheal		   = 20,
  brakeRate          = .5,
  canAttack          = true,
  canDGun            = true,
  canFly             = true,
  canMove            = true,
  canstop            = "1",
  category           = "LARGE STRONG TARGET ANY",
  collide            = false,
  collisionvolumescales = "160 72 400",
  collisionvolumetype = "Box",
  collisionVolumeOffset = "-60 0 150",
  cruiseAlt          = 65,
  description        = "Heavy assault battlecruiser",
  explodeAs          = "RetroDeathHuge",
  footprintX         = 8,
  footprintZ         = 8,
  hoverAttack        = true,
  iconType           = "eclipse",
  idleAutoHeal       = 0,
  idleTime           = 0,
  levelGround        = false,
  mass               = 10000,
  maxDamage          = 56000,
  maxVelocity        = 1.2,
  name               = "Eclipse",
  noChaseCategory    = "NOCHASE",
  objectName         = "eclipse.s3o",
  power              = 6000,
  radarDistance      = 1800,
  script             = "eclipse.lua",
  selfDestructAs     = "RetroDeathHuge",
  selfDestructCountdown = 10,
  showNanoFrame      = false,
  side               = "ALL",
  sightDistance      = 900,
  smoothAnim         = false,
  turnRate           = 185,
  unitname           = "eclipse",
  customparams = {
    buildTime          = 90,
    cost               = 8500,
    type               = "large",
	nobuild			   = true,
	occupationstrength = 2,
	--minelayer			       = 1.0,
  },
  sfxtypes = {
    explosiongenerators = {
      "custom:death_med",
      "custom:death_large",
      "custom:death_multimed",
      "custom:teleport",
      "custom:muzzlekinetic",
      "custom:muzzlemassdriver",
	  "custom:charge_graser",
	  "custom:sparks",
	  "custom:charge_antimatter",
    },
  },
  sounds = {
    arrived = {
      "commandgiven",
    },
    ok = {
      "commandgiven",
    },
    select = {
      "select",
    },
  },
  weapons = {
	--Antimatter beam
    [1]  = {
      def                = "EclipseAMBeamPrimer",
      mainDir            = "0 0 1",
      maxAngleDif        = 120,
      onlyTargetCategory = "WEAK STRONG",
    },
    [2]  = {
      def                = "EclipseAMBeam",
      onlyTargetCategory = "VOID",
    },
	--Megalaser primer(dgun weapon)
    [3]  = {
      def                = "MegaLaserPrimer",
      mainDir            = "0 0 1",
      maxAngleDif        = 25,
      --badTargetCategory  = "SMALL WEAK",
      --onlyTargetCategory = "TARGET",
    },
	---Gravy gun
	[4]  = {
      def                = "GEclipse",
      onlyTargetCategory = "LARGE",
    },

	--Kinetic blasters
	 --front
    [5]  = {
	  def                = "KMedium",
      badTargetCategory  = "LARGE",
      onlyTargetCategory = "TARGET",
	  mainDir            = "-0.5 0 -0.7",
      maxAngleDif        = 210,
    },
	[6]  = {
	  def                = "KMedium",
      badTargetCategory  = "LARGE",
      onlyTargetCategory = "TARGET",
	  mainDir            = "0.5 0 -0.7",
      maxAngleDif        = 210,
    },
	 --side
	[7]  = {
	  def                = "KMedium",
      badTargetCategory  = "LARGE",
      onlyTargetCategory = "TARGET",
--	mainDir            = "1 0 0.75",
--      maxAngleDif        = 210,
    },
	[8]  = {
	  def                = "KMedium",
      badTargetCategory  = "LARGE",
      onlyTargetCategory = "TARGET",
	  --mainDir            = "-0.2 0 1",
      --maxAngleDif        = 210,
    },
	 --rear
	[9]  = {
	  def                = "KMedium",
      badTargetCategory  = "LARGE",
      onlyTargetCategory = "TARGET",
	  mainDir            = "-0.2 0 1",
      maxAngleDif        = 180,
    },
	[10]  = {
	  def                = "KMedium",
      badTargetCategory  = "LARGE",
      onlyTargetCategory = "TARGET",
	  mainDir            = "0.2 0 1",
      maxAngleDif        = 180,
    },
	--Point defense
    [11]  = {
      def                = "MPointDefense",
      onlyTargetCategory = "TINY",
	  mainDir            = "0 0 -1",
      maxAngleDif        = 210,
    },
	[12]  = {
      def                = "MPointDefense",
      onlyTargetCategory = "TINY",
    },
	[13]  = {
      def                = "MPointDefense",
      onlyTargetCategory = "TINY",
    },
	[14]  = {
      def                = "MPointDefense",
      onlyTargetCategory = "TINY",
	  mainDir            = "0 0 1",
      maxAngleDif        = 210,
    },
	--Gravy flak
    [15]  = {
	  def                = "GFlakEclipse",
      badTargetCategory  = "LARGE",
    },
	--Rear plasma cannons
	[16]  = {
	  def                = "PHeavy",
      badTargetCategory  = "SMALL TINY",
      mainDir            = "-0.2 0 0.8",
      maxAngleDif        = 90,
      onlyTargetCategory = "TARGET",
    },
	[17]  = {
	  def                = "PHeavy",
      badTargetCategory  = "SMALL TINY",
      mainDir            = "0.2 0 0.8",
      maxAngleDif        = 90,
      onlyTargetCategory = "TARGET",
    },
	--Torpedoes
    [18]  = {
      def                = "TEclipse",
      onlyTargetCategory = "TARGET",
    },
	--Missile launchers
    [19]  = {
      def                = "MEclipse",
      onlyTargetCategory = "TARGET",
    },
    [20]  = {
      def                = "MEclipse",
      onlyTargetCategory = "TARGET",
    },
	--The ultimate weapon
    [21]  = {
      def                = "MegaLaser",
      onlyTargetCategory = "VOID",
    },	
  },
}


return lowerkeys({ [unitName] = unitDef })

--------------------------------------------------------------------------------
