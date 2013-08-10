#include "constants.h"

#define PERK_BETTER_KINETICS 2049
#define KLIGHT_ROF_BOOST 16
#define KLIGHT_SPRAY_BOOST 50
#define KDUAL_ROF_BOOST 12
#define KLIGHT_DUAL_BOOST 100
#define KMEDIUM_ROF_BOOST 48
#define KMEDIUMD_ROF_BOOST 24
#define KMEDIUM_SPRAY_BOOST 50
#define KHEAVY_ROF_BOOST 96
#define KHEAVY_SPRAY_BOOST 10
#define PERK_MORE_GUNS 2050
#define PERK_BETTER_GRAV 2054
#define GSTANDARD_RANGE_BOOST [650]
#define PERK_GRAV_FLAK 2060
#define GFLAK_RANGE_BOOST [650]
#define PERK_ANTIMATTER_WARHEAD 2059

#define DRONE_K 1
#define TORPEDO 2
#define FTORPEDO 3

//#define SIG_Aim1 1
//#define SIG_Aim2 2
//#define SIG_Aim3 4
//#define SIG_Aim4 8
//#define SIG_Aim5 16
//#define SIG_Aim6 32
//#define SIG_Aim7 64
//#define SIG_Damage 128
//#define SIG_RestoreStealth 256

#define SIG_Aim1 1
#define SIG_Aim2 2
#define SIG_Aim3 4
#define SIG_Aim4 8
#define SIG_Aim5 16
#define SIG_Aim6 32
#define SIG_Aim7 64
#define SIG_Aim8 128
#define SIG_Aim9 256
#define SIG_Aim10 512
#define SIG_Aim11 1024
#define SIG_Aim12 2048
#define SIG_Aim13 4096
#define SIG_Aim14 8192
#define SIG_Aim15 16384
#define SIG_Aim16 32768
#define SIG_Aim17 65536
#define SIG_Aim18 131072
#define SIG_Aim19 262144
#define SIG_Aim20 524288

#define SIG_Damage 1048576
#define SIG_RestoreStealth 2097152


/*SoundDefs() {
	play-sound ("deathsmall",1);
	#define S_DEATH_SMALL 0
	play-sound ("deathmed",1);
	#define S_DEATH_MED 1
	play-sound ("deathlarge",1);
	#define S_DEATH_LARGE 2
}*/

static-var isMoving;
static-var fireStealthTime;
static-var permaStealth;


fireStealthTime = 1000;
permaStealth = 0;

RestoreStealth() {
	signal SIG_RestoreStealth;
	set-signal-mask SIG_RestoreStealth;
	sleep fireStealthTime;
	if (not isMoving) {set STEALTH to 1;}
}

lua_AddTrail() {
	return 0;
}

lua_RemoveTrail() {
	return 0;
}

lua_LaunchDroneWeapon() {
	return 0;
}

lua_GetGameFrame() {
	return 0;
}

#define TRAIL(p,width,ttl,rate) static-var EngineEnabled;\
\
MoveRate0() {\
	if (!permaStealth) {\
		isMoving = 0;\
		start-script RestoreStealth();}\
	if (EngineEnabled) {\
		call-script lua_RemoveTrail(p);\
		EngineEnabled=0;\
	}\
}\
\
MoveRate1() {\
	if (!permaStealth) {\
		isMoving = 1;\
		set STEALTH to 0;}\
	if (!EngineEnabled) {\
		call-script lua_AddTrail(p,width,ttl,rate);\
		EngineEnabled=1;\
	}\
}\
MoveRate2() {\
	call-script MoveRate1();\
}