VFS.Include("LuaUI/Configs/chatter/portraits.lua")

local colors = {
	red = "\255\255\0\0",
	pink = "\255\255\128\128",
	yellow = "\255\255\255\0",
	orange = "\255\255\128\0",
	violet = "\255\255\0\255",
}

local pilotDefsPre = {
	luckystar = {
		name = "Milfeulle",
		dialogue = {
			death = {
				{image = portraits.milfeulle_pain, text = "Lucky Star, no longer operational!"},
			},
			kill = {
				{image = portraits.milfeulle_veryhappy, text = "I did it! Enemy down!"},
			},
			unitDamaged_severe = {
				{image = portraits.milfeulle_pain, text = "Lucky Star, I need repairs now!"},
				minor = colors.pink .. "Lucky Star\008 is " .. colors.red .. "75% damaged\008!"
			},
			unitDamaged_moderate = {
				{image = portraits.milfeulle_concerned, text = "Lucky Star, damaged sustained.\nPlease repair me soon."},
				minor = colors.pink .. "Lucky Star\008 is " .. colors.orange .. "50% damaged\008!"
			},
			unitDamaged_minor = {
				{image = portraits.milfeulle_serious, text = "Lucky Star, minor damaged sustained... but I'm not giving up yet!"},
				minor = colors.pink .. "Lucky Star\008 is " .. colors.yellow .. "20% damaged\008!"
			},
			criticalHit = {
				{image = portraits.milfeulle_happy, text = "Tact, I did it! They're really hurting now!"},
			},
			criticalHit_received = {
				{image = portraits.milfeulle_stressed, text = "Owww... My head hurts..."},
			},
			unitSuppressed_severe = {
				{image = portraits.milfeulle_pain, text = "Please... make it stop..."},
				minor = colors.pink .. "Lucky Star\008 is " .. colors.red .. "80% suppressed\008!"
			},
			unitSuppressed_moderate = {
				{image = portraits.milfeulle_stressed, text = "Lucky Star, under heavy fire...\nI'll try to hold on..."},
				minor = colors.pink .. "Lucky Star\008 is " .. colors.orange .. "50% suppressed\008!"
			},
			unitSuppressed_minor = {
				{image = portraits.milfeulle_aggressive, text = "You think I'm scared of you?\nCome and get me if you can!"},
				minor = colors.pink .. "Lucky Star\008 is " .. colors.yellow .. "25% suppressed\008!"
			},
			unitEnergy_critical = {
				{image = portraits.milfeulle_concerned, text = "Tact, I'm running low on energy.\nPlease resupply me soon."},
				minor = colors.pink .. "Lucky Star\008 down to " .. colors.orange .. "30% energy\008!"
			},
			unitEnergy_low = {
				{image = portraits.milfeulle_oh, text = "Lucky Star, down to half energy."},
				minor = colors.pink .. "Lucky Star\008 down to " .. colors.yellow .. "55% energy\008!"
			},
			weaponMiss = {
				{image = portraits.milfeulle_stressed, text = "Awww~\nNo fair dodging like that~"},
				{image = portraits.milfeulle_oh, text = "My attack missed..."},
			},
			spiritFull = {
				{image = portraits.milfeulle_happy, text = "Tact, I'm ready to fire the Hyper Cannon!"},
				minor = colors.pink .. "Lucky Star\008 has " .. colors.yellow .. "maxed spirit\008!"
			},
			engagingEnemy = {
				{image = portraits.milfeulle_oh, text = "According to the radar, the enemy is... over there!"}
			},
			commandReceived = {
				{image = portraits.milfeulle_normal, text = "Yes, sir!"},
				{image = portraits.milfeulle_normal, text = "Lucky Star, roger."},
			},
			specialWeapon = {
				{image = portraits.milfeulle_veryhappy, text = "Now it's my turn!\nHyper Cannon, fire!"},
				{image = portraits.milfeulle_aggressive, text = "Eei!\nHyper Cannon!"},
			},
		}
	},
	kungfufighter = {
		name = "Ranpha",
		dialogue = {
			death = {
				{image = portraits.ranpha_pain, text = "Kung-Fu Fighter, unable to continue combat!"},
			},
			kill = {
				{image = portraits.ranpha_veryhappy, text = "Target destroyed!\nOhohohohoho!"},
			},
			unitDamaged_severe = {
				{image = portraits.ranpha_pain, text = "Kung-fu Fighter, status critical!\nCan't I get those repairs already?!"},
				minor = colors.red .. "Kung-Fu Fighter\008 is " .. colors.red .. "75% damaged\008!"
			},
			unitDamaged_moderate = {
				{image = portraits.ranpha_serious, text = "Kung-fu Fighter, I could use repairs soon."},
				minor = colors.red .. "Kung-Fu Fighter\008 is " .. colors.orange .. "50% damaged\008!"
			},
			unitDamaged_minor = {
				{image = portraits.ranpha_aggressive, text = "You think you can kill me with that kind of fire?"},
				{image = portraits.ranpha_furious, text = "Oooh, you did it...\nNow I'm really pissed off!"},
				minor = colors.red .. "Kung-Fu Fighter\008 is " .. colors.yellow .. "20% damaged\008!"
			},
			criticalHit = {
				{image = portraits.ranpha_aggressive, text = "Take that!\nI got plenty more where that came from!"},
			},
			criticalHit_received = {
				{image = portraits.ranpha_pain, text = "Gah!\nThat was a nasty blow..."},
			},
			unitSuppressed_severe = {
				{image = portraits.ranpha_pain, text = "Huff... huff...\nThere's just too many of them..."},
				minor = colors.red .. "Kung-Fu Fighter\008 is " .. colors.red .. "80% suppressed\008!"
			},
			unitSuppressed_moderate = {
				{image = portraits.ranpha_aggressive, text = "Grr...I'm not going to back down from the likes of you!"},
				minor = colors.red .. "Kung-Fu Fighter\008 is " .. colors.orange .. "50% suppressed\008!"
			},
			unitSuppressed_minor = {
				{image = portraits.ranpha_serious, text = "Tch.. You think I'm going to be intimidated so easily?"},
				minor = colors.red .. "Kung-Fu Fighter\008 is " .. colors.yellow .. "25% suppressed\008!"
			},
			unitEnergy_critical = {
				{image = portraits.ranpha_worried, text = "Energy down to 30%...\nCan I have that resupply yet?"},
				minor = colors.red .. "Kung-Fu Fighter\008 down to " .. colors.orange .. "30% energy\008!"
			},
			unitEnergy_critical = {
				{image = portraits.ranpha_normal, text = "Kung-fu Fighter down to half energy...\nBut it's not a problem yet."},
				minor = colors.red .. "Kung-Fu Fighter\008 down to " .. colors.yellow .. "50% energy\008!"
			},
			weaponMiss = {
				{image = portraits.ranpha_oh, text = "No way, I missed?!"},
			},
			weaponEvaded = {
				{image = portraits.ranpha_normal, text = "Evasion successful!"},
			},
			spiritFull = {
				{image = portraits.ranpha_happy, text = "Anchor Claw, ready!\nTact, what do you want me to hit?"},
				{image = portraits.ranpha_veryhappy, text = "Yes! Yes! Yes!\nVoltage to the max!"},
				minor = colors.red .. "Kung-Fu Fighter\008 has " .. colors.yellow .. "maxed spirit\008!"
			},
			engagingEnemy = {
				{image = portraits.ranpha_normal, text = "Target on radar.\nMoving to intercept."},
				{image = portraits.ranpha_normal, text = "Umm, target at... ah, found it.\nOkay, I'm going after it."}
			},
			commandReceived = {
				{image = portraits.ranpha_normal, text = "Yes, sir."},
				{image = portraits.ranpha_serious, text = "I already knew that obviously."},
				{image = portraits.ranpha_normal, text = "I got it, Tact."},
			},
		}
	},
	happytrigger = {
		name = "Forte",
		dialogue = {
			death = {
				{image = portraits.forte_pain, text = "Happy-Trigger, unable to continue action!"},
			},
			kill = {
				{image = portraits.forte_normal, text = "Splash one bandit.\nOn to the next."},
				{image = portraits.forte_excited, text = "One bad guy down!\nWho's next?"},
			},
			unitDamaged_severe = {
				{image = portraits.forte_pain, text = "Happy Trigger, severely damaged!\nRepairs needed urgently!"},
				minor = colors.violet .. "Happy Trigger\008 is " .. colors.red .. "75% damaged\008!"
			},
			unitDamaged_moderate = {
				{image = portraits.forte_serious, text = "Happy Trigger, damage sustained.\nBut I'm not out of the fight yet."},
				minor = colors.violet .. "Happy Trigger\008 is " .. colors.orange .. "50% damaged\008!"
			},
			unitDamaged_minor = {
				{image = portraits.forte_serious, text = "Tch... it's but a scratch..."},
				{image = portraits.forte_what, text = "Hmph. It's going to take more than that to get through the Happy Trigger's armor."},
				minor = colors.violet .. "Happy Trigger\008 is " .. colors.yellow .. "20% damaged\008!"
			},
			criticalHit = {
				{image = portraits.forte_excited, text = "Do ya feel lucky, punk? Do ya?"},
			},
			criticalHit_received = {
				{image = portraits.forte_pain, text = "Urgh! That was stronger than anticipated..."},
			},
			unitSuppressed_severe = {
				{image = portraits.forte_pain, text = "Happy Trigger, requesting immediate assistance!"},
				minor = colors.violet .. "Happy Trigger\008 is " .. colors.red .. "80% suppressed\008!"
			},
			unitSuppressed_moderate = {
				{image = portraits.forte_concerned, text = "Tch... this is starting to get nasty."},
				{image = portraits.forte_what, text = "Enough playing around...\nI'm going to whoop your ass!"},
				minor = colors.violet .. "Happy Trigger\008 is " .. colors.orange .. "50% suppressed\008!"
			},
			unitSuppressed_minor = {
				{image = portraits.forte_what, text = "You little punk...\nYou really want to pick a fight with me?"},
				{image = portraits.forte_what, text = "Tch... I'm not going to take that lying down."},
				minor = colors.violet .. "Happy Trigger\008 is " .. colors.yellow .. "25% suppressed\008!"
			},
			unitEnergy_critical = {
				{image = portraits.forte_serious, text = "Energy down to critical levels.\nRequesting immediate resupply."},
				minor = colors.violet .. "Happy Trigger\008 down to " .. colors.orange .. "30% energy\008!"
			},
			unitEnergy_critical = {
				{image = portraits.forte_normal, text = "Energy down to 50%...\nI can still keep going, though."},
				minor = colors.violet .. "Happy Trigger\008 down to " .. colors.yellow .. "50% energy\008!"
			},
			weaponMiss = {
				{image = portraits.forte_serious, text = "Tch, they evaded...\nI'll have to try again."},
				{image = portraits.forte_what, text = "You skittish punk!\nI won't let you get away!"},
			},
			weaponEvaded = {
				{image = portraits.forte_happy, text = "Too slow, buddy.\nYou'll have to try harder than that!"},
			},
			spiritFull = {
				{image = portraits.forte_excited, text = "I'm all powered up!\nTime for the bad guys to feel pain!"},
				{image = portraits.forte_excited, text = "Well, well!\nLooks like I just ran out of gum!"},
				minor = colors.violet .. "Happy Trigger\008 has " .. colors.yellow .. "maxed spirit\008!"
			},
			engagingEnemy = {
				{image = portraits.forte_normal, text = "Target on radar.\nMoving to engage."},
				{image = portraits.forte_normal, text = "Target acquired.\nHappy Trigger is oscar mike."}
			},
			commandReceived = {
				{image = portraits.forte_normal, text = "Yes, sir."},
				{image = portraits.forte_normal, text = "Happy Trigger, roger."},
			},
		}
	},	
}

pilotDefs = {}

for unitName, data in pairs(pilotDefsPre) do
	if UnitDefNames[unitName] then
		pilotDefs[UnitDefNames[unitName].id] = data
	end
end