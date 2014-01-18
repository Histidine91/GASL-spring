VFS.Include("LuaUI/Configs/chatter/portraits.lua")

idleChatter = VFS.Include("LuaUI/Configs/chatter/idlechatter.lua")

local colors = {
	red = "\255\255\0\0",
	pink = "\255\255\128\128",
	yellow = "\255\255\255\0",
	orange = "\255\255\128\0",
	green = "\255\0\255\0",
	violet = "\255\255\0\255",
	skyblue = "\255\0\224\255",
	midnightblue = "\255\0\0\160"
}

local pilotDefsPre = {
	luckystar = {
		name = "Milfeulle",
		dialogue = {
			death = {
				{image = portraits.milfeulle_pain, text = "Lucky Star, no longer operational!"},
			},
			kill = {
				{image = portraits.milfeulle_happy, text = "Lucky Star, enemy has been destroyed!"},
				{image = portraits.milfeulle_veryhappy, text = "I did it! Enemy down!"},
			},
			unitDamaged_severe = {
				{image = portraits.milfeulle_pain, text = "Lucky Star, I need repairs now!"},
				{image = portraits.milfeulle_pain, text = "Lucky Star, I need repairs now!"},
				minor = colors.pink .. "Lucky Star\008 is " .. colors.red .. "75% damaged\008!"
			},
			unitDamaged_moderate = {
				{image = portraits.milfeulle_concerned, text = "Lucky Star, damaged sustained.\nPlease repair me soon."},
				{image = portraits.milfeulle_serious, text = "Hull strength greatly reduced!\n...But I can keep going!"},
				{image = portraits.milfeulle_sad, text = "I've taken more damage. I'm starting to worry..."},
				minor = colors.pink .. "Lucky Star\008 is " .. colors.orange .. "50% damaged\008!"
			},
			unitDamaged_minor = {
				{image = portraits.milfeulle_serious, text = "Minor damaged sustained... but I'm not giving up yet!"},
				minor = colors.pink .. "Lucky Star\008 is " .. colors.yellow .. "20% damaged\008!"
			},
			criticalHit = {
				{image = portraits.milfeulle_happy, text = "Tact, I did it! They're really hurting now!"},
			},
			criticalHit_received = {
				{image = portraits.milfeulle_stressed, text = "Owww... My head hurts..."},
				{image = portraits.milfeulle_pain, text = "Kyaaaaa!\nWhat power..."},
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
				{image = portraits.milfeulle_stressed, text = "Please resplenish my energy soon."},
				minor = colors.pink .. "Lucky Star\008 down to " .. colors.orange .. "30% energy\008!"
			},
			unitEnergy_low = {
				{image = portraits.milfeulle_oh, text = "Lucky Star, down to half energy."},
				{image = portraits.milfeulle_concerned, text = "My energy is down to 50%."},
				minor = colors.pink .. "Lucky Star\008 down to " .. colors.yellow .. "55% energy\008!"
			},
			weaponMiss = {
				{image = portraits.milfeulle_stressed, text = "Awww~\nNo fair dodging like that~"},
				{image = portraits.milfeulle_oh, text = "My attack missed..."},
				{image = portraits.milfeulle_oh, text = "The enemy evaded."},
			},
			spiritFull = {
				{image = portraits.milfeulle_happy, text = "Tact, I'm ready to fire the Hyper Cannon!"},
				{image = portraits.milfeulle_veryhappy, text = "I did it somehow!\nI feel like I can do anything!"},
				minor = colors.pink .. "Lucky Star\008 has " .. colors.yellow .. "maxed spirit\008!"
			},
			resupply = {
				{image = portraits.milfeulle_happy, text = "Lucky Star, resupply complete."},
				minor = colors.pink .. "Lucky Star\008 has " .. colors.green .. "completed resupply\008!"
			},
			engagingEnemy = {
				{image = portraits.milfeulle_oh, text = "According to the radar, the enemy is... over there!"},
				{image = portraits.milfeulle_serious, text = "Enemy sighted. Attacking opponent now."},
				{image = portraits.milfeulle_serious, text = "I've found the enemy.\nHere I go, Tact!"},
			},
			commandReceived = {
				{image = portraits.milfeulle_normal, text = "Yes, sir!"},
				{image = portraits.milfeulle_normal, text = "Lucky Star, roger."},
			},
			specialWeapon = {
				{image = portraits.milfeulle_veryhappy, text = "Now it's my turn to strike!\nHyper Cannon, fire!"},
				{image = portraits.milfeulle_aggressive, text = "Eei!\nHyper Cannon!"},
				{image = portraits.milfeulle_serious, text = "Hyper Cannon, fire!"},
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
				{image = portraits.ranpha_relaxed, text = "Shot them down.\nMy enemy is no more."},
				{image = portraits.ranpha_happy, text = "That was too easy.\nTact, give me more!"},
			},
			unitDamaged_severe = {
				{image = portraits.ranpha_pain, text = "Kung-fu Fighter, status critical!\nCan't I get those repairs already?!"},
				minor = colors.red .. "Kung-Fu Fighter\008 is " .. colors.red .. "75% damaged\008!"
			},
			unitDamaged_moderate = {
				{image = portraits.ranpha_serious, text = "Kung-fu Fighter, I could use repairs soon."},
				{image = portraits.ranpha_angry, text = "Damage up to 50%...? But the fight's not over yet!"},
				{image = portraits.ranpha_serious, text = "Is my hull okay...?\nWell, I can keep going!"},
				minor = colors.red .. "Kung-Fu Fighter\008 is " .. colors.orange .. "50% damaged\008!"
			},
			unitDamaged_minor = {
				{image = portraits.ranpha_aggressive, text = "Is that all you got?"},
				{image = portraits.ranpha_furious, text = "Oooh, you did it...\nNow I'm really pissed off!"},
				minor = colors.red .. "Kung-Fu Fighter\008 is " .. colors.yellow .. "20% damaged\008!"
			},
			criticalHit = {
				{image = portraits.ranpha_aggressive, text = "Take that!\nI got plenty more where that came from!"},
				{image = portraits.ranpha_aggressive, text = "All right! A direct hit!"},
			},
			criticalHit_received = {
				{image = portraits.ranpha_pain, text = "Gah!\nThat was a nasty blow..."},
				{image = portraits.ranpha_pain, text = "Kyaa!\nDamn, I was hit."},
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
			unitEnergy_low = {
				{image = portraits.ranpha_normal, text = "Kung-fu Fighter down to half energy...\nBut it's not a problem yet."},
				minor = colors.red .. "Kung-Fu Fighter\008 down to " .. colors.yellow .. "50% energy\008!"
			},
			weaponMiss = {
				{image = portraits.ranpha_oh, text = "No way, I missed?!"},
				{image = portraits.ranpha_worried, text = "They evaded it.\nGot to be chance..."},
				{image = portraits.ranpha_aggressive, text = "My aim was off.\nIt won't be next time!"},
				{image = portraits.ranpha_serious, text = "They just evaded my attack.\nI am not amused by this."},
			},
			weaponEvaded = {
				{image = portraits.ranpha_normal, text = "Evasion successful!"},
				{image = portraits.ranpha_normal, text = "All right, I evaded that. My Emblem Frame is moving awesomely!"},
				{image = portraits.ranpha_aggressive, text = "Attack evaded. Your movement can't keep up with mine!"},
				{image = portraits.ranpha_amused, text = "That weak attack won't hit me!"},
				
			},
			spiritFull = {
				{image = portraits.ranpha_happy, text = "Anchor Claw, launch preparations complete!\nTact, what do you want me to hit?"},
				{image = portraits.ranpha_veryhappy, text = "Yes! Yes! Yes!\nVoltage to the max!"},
				{image = portraits.ranpha_veryhappy, text = "Yeaaaah!\nDanger zone!"},
				minor = colors.red .. "Kung-Fu Fighter\008 has " .. colors.yellow .. "maxed spirit\008!"
			},
			repair = {
				{image = portraits.ranpha_veryhappy, text = "Resupply complete.\nYou sure know the way to a girl's heart..."},
				minor = colors.red .. "Kung-Fu Fighter\008 has " .. colors.green .. "completed resupply\008!"
			},
			resupply = {
				{image = portraits.ranpha_starryeyed, text = "Resupply complete.\nYou sure know the way to a girl's heart..."},
				minor = colors.red .. "Kung-Fu Fighter\008 has " .. colors.green .. "completed resupply\008!"
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
			specialWeapon = {
				{image = portraits.ranpha_aggressive, text = "Crush them!\nAnchor Claw!"},
				{image = portraits.ranpha_aggressive, text = "Iron Fisted Judgement!\nAnchor Claw!"},
				{image = portraits.ranpha_aggressive, text = "Finishing strike!\nAnchor Claw!"},
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
				{image = portraits.forte_excited, text = "Wooo! Jester's dead!"},
				{image = portraits.forte_happy, text = "Target eliminated. My enemy's finished."},
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
				{image = portraits.forte_excited, text = "Good, a clean hit!\nDid you see that, Tact?"},
				{image = portraits.forte_happy, text = "That was a good hit.\nThe next one will finish them."},
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
			unitEnergy_low = {
				{image = portraits.forte_normal, text = "Energy down to 50%...\nI can still keep going, though."},
				minor = colors.violet .. "Happy Trigger\008 down to " .. colors.yellow .. "50% energy\008!"
			},
			weaponMiss = {
				{image = portraits.forte_serious, text = "Tch, they evaded...\nI'll have to try again."},
				{image = portraits.forte_oh, text = "They dodged that barrage?\nWhat an enemy."},
				{image = portraits.forte_what, text = "You skittish punk!\nI won't let you get away!"},
				{image = portraits.forte_what, text = "They dodged it.\nThe next one won't miss."},
				{image = portraits.forte_normal, text = "Oh, they avoided that attack.\nMaybe I can have some fun."},
			},
			weaponEvaded = {
				{image = portraits.forte_happy, text = "Too slow, buddy.\nYou'll have to try harder than that!"},
			},
			spiritFull = {
				{image = portraits.forte_excited, text = "I'm all powered up!\nTime for the bad guys to feel pain!"},
				{image = portraits.forte_excited, text = "Well, well!\nLooks like I just ran out of gum!"},
				{image = portraits.forte_happy, text = "Feeling good. I'm hot right now.\nTact, give me the order to fire!"},
				minor = colors.violet .. "Happy Trigger\008 has " .. colors.yellow .. "maxed spirit\008!"
			},
			resupply = {
				{image = portraits.forte_normal, text = "Unit #4, energy restored.\nI'm ready to rumble again."},
				{image = portraits.forte_happy, text = "You saved me, Tact.\nNow it's my turn to save you!"},
				minor = colors.violet .. "Happy Trigger\008 has " .. colors.green .. "completed resupply\008!"
			},
			engagingEnemy = {
				{image = portraits.forte_normal, text = "Target on radar.\nMoving to engage."},
				{image = portraits.forte_normal, text = "Target acquired.\nHappy Trigger is oscar mike."},
				{image = portraits.forte_normal, text = "Target detected on radar.\nI'm on it, Tact."},
			},
			commandReceived = {
				{image = portraits.forte_normal, text = "Yes, sir."},
				{image = portraits.forte_normal, text = "Happy Trigger, roger."},
			},
			specialWeapon = {
				{image = portraits.forte_excited, text = "Get out of the way!\nStrike Burst!"},
				{image = portraits.forte_excited, text = "It's Harrington time!\nStrike Burst!"},
				{image = portraits.forte_serious, text = "I will eradicate you!\nStrike Burst!"},
			},
		}
	},
	-- incomplete
	--[[
	trickmaster = {
		name = "Mint",
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
				minor = colors.skyblue .. "Trick Master\008 is " .. colors.red .. "75% damaged\008!"
			},
			unitDamaged_moderate = {
				{image = portraits.mint_normal, text = "Damage accumulated.\nBut I'm still okay."},
				minor = colors.skyblue .. "Trick Master\008 is " .. colors.orange .. "50% damaged\008!"
			},
			unitDamaged_minor = {
				{image = portraits.forte_serious, text = "Tch... it's but a scratch..."},
				{image = portraits.forte_what, text = "Hmph. It's going to take more than that to get through the Happy Trigger's armor."},
				minor = colors.skyblue .. "Trick Master\008 is " .. colors.yellow .. "20% damaged\008!"
			},
			criticalHit = {
				{image = portraits.mint_veryhappy text = "That appeared to be a good hit.\nIt was better than I anticipated."},
			},
			criticalHit_received = {
				{image = portraits.forte_pain, text = "Urgh! That was stronger than anticipated..."},
			},
			unitSuppressed_severe = {
				{image = portraits.forte_pain, text = "Happy Trigger, requesting immediate assistance!"},
				minor = colors.skyblue .. "Trick Master\008 is " .. colors.red .. "80% suppressed\008!"
			},
			unitSuppressed_moderate = {
				{image = portraits.forte_concerned, text = "Tch... this is starting to get nasty."},
				{image = portraits.forte_what, text = "Enough playing around...\nI'm going to whoop your ass!"},
				minor = colors.skyblue .. "Trick Master\008 is " .. colors.orange .. "50% suppressed\008!"
			},
			unitSuppressed_minor = {
				{image = portraits.forte_what, text = "You little punk...\nYou really want to pick a fight with me?"},
				{image = portraits.forte_what, text = "Tch... I'm not going to take that lying down."},
				minor = colors.skyblue .. "Trick Master\008 is " .. colors.yellow .. "25% suppressed\008!"
			},
			unitEnergy_critical = {
				{image = portraits.forte_serious, text = "Energy down to critical levels.\nRequesting immediate resupply."},
				minor = colors.skyblue .. "Trick Master\008 down to " .. colors.orange .. "30% energy\008!"
			},
			unitEnergy_low = {
				{image = portraits.vanilla_normal, text = "Energy decreased... Resupply, please, Tact."},
				minor = colors.skyblue .. "Trick Master\008 down to " .. colors.yellow .. "50% energy\008!"
			},
			weaponMiss = {
				{image = portraits.mint_sigh, text = "It's no good... my attack has been evaded."},
				{image = portraits.mint_worried, text = "Did they just evade my attack?\nI can't take them lightly."},
				{image = portraits.mint_surprised, text = "Umm... I missed?\nNo, I should say they evaded!"},
				{image = portraits.mint_surprised, text = "My aim was slightly off.\nBut I'll hit them next time."},
				{image = portraits.mint_serious, text = "The target has evaded my attack.\nNext time, I will not miss."},
			},
			weaponEvaded = {
				{image = portraits.mint_normal, text = "Enemy attack has been evaded.\nTheir aiming is naive."},
				{image = portraits.mint_veryhappy, text = "Evasion was successful.\nI am still okay."},
			},
			spiritFull = {
				{image = portraits.mint_angry, text = "I cannot go easy on you... Are you prepared?"},
				{image = portraits.mint_aggressive, text = "Systems fully tuned!\nAll Fliers on standby!"},
				minor = colors.skyblue .. "Trick Master\008 has " .. colors.yellow .. "maxed spirit\008!"
			},
			engagingEnemy = {
				{image = portraits.forte_normal, text = "Target on radar.\nMoving to engage."},
				{image = portraits.mint_normal, text = "Target acquired. You cannot escape the Trick Master's radar."}
			},
			commandReceived = {
				{image = portraits.forte_normal, text = "Yes, sir."},
				{image = portraits.forte_normal, text = "Happy Trigger, roger."},
			},
			specialWeapon = {
				{image = portraits.mint_aggressive, text = "I'm really going to enjoy this.\nFlier Dance!"},
			},
		}
	},
	harvester = {
		name = "Vanilla",
		dialogue = {
			death = {
				{image = portraits.chitose_pain, text = "Unit #6, no longer combat-capable!"},
			},
			kill = {
				{image = portraits.forte_normal, text = "Splash one bandit.\nOn to the next."},
				{image = portraits.forte_excited, text = "One bad guy down!\nWho's next?"},
			},
			unitDamaged_severe = {
				{image = portraits.forte_pain, text = "Happy Trigger, severely damaged!\nRepairs needed urgently!"},
				minor = colors.green .. "Harvester\008 is " .. colors.red .. "75% damaged\008!"
			},
			unitDamaged_moderate = {
				{image = portraits.chitose_normal, text = "This is Unit #6, requesting repairs."},
				minor = colors.green .. "Harvester\008 is " .. colors.orange .. "50% damaged\008!"
			},
			unitDamaged_minor = {
				{image = portraits.vanilla_pain, text = "Unit #5, hull damaged."},
				{image = portraits.forte_what, text = "Hmph. It's going to take more than that to get through the Happy Trigger's armor."},
				minor = colors.green .. "Harvester\008 is " .. colors.yellow .. "20% damaged\008!"
			},
			criticalHit = {
				{image = portraits.vanilla_normal text = "I hit the center of the target...\nI was successful, Tact."},
				{image = portraits.vanilla_normal, text = "Harvester, attack on the target was successful."},
				{image = portraits.vanilla_normal, text = "...I seem to have inflicted singificant damage."},
			},
			criticalHit_received = {
				{image = portraits.forte_pain, text = "Urgh! That was stronger than anticipated..."},
			},
			unitSuppressed_severe = {
				{image = portraits.forte_pain, text = "Happy Trigger, requesting immediate assistance!"},
				minor = colors.green .. "Harvester\008 is " .. colors.red .. "80% suppressed\008!"
			},
			unitSuppressed_moderate = {
				{image = portraits.forte_concerned, text = "Tch... this is starting to get nasty."},
				{image = portraits.forte_what, text = "Enough playing around...\nI'm going to whoop your ass!"},
				minor = colors.green .. "Harvester\008 is " .. colors.orange .. "50% suppressed\008!"
			},
			unitSuppressed_minor = {
				{image = portraits.forte_what, text = "You little punk...\nYou really want to pick a fight with me?"},
				{image = portraits.forte_what, text = "Tch... I'm not going to take that lying down."},
				minor = colors.green .. "Harvester\008 is " .. colors.yellow .. "25% suppressed\008!"
			},
			unitEnergy_critical = {
				{image = portraits.forte_serious, text = "Energy down to critical levels.\nRequesting immediate resupply."},
				minor = colors.green .. "Harvester\008 down to " .. colors.orange .. "30% energy\008!"
			},
			unitEnergy_low = {
				{image = portraits.forte_normal, text = "Energy down to 50%...\nI can still keep going, though."},
				minor = colors.green .. "Harvester\008 down to " .. colors.yellow .. "50% energy\008!"
			},
			weaponMiss = {
				{image = portraits.mint_sigh, text = "It's no good... my attack has been evaded."},
				{image = portraits.mint_worried, text = "Did they just evade my attack?\nI can't take them lightly."},
				{image = portraits.mint_surprised, text = "Umm... I missed?\nNo, I should say they evaded!"},
			},
			weaponEvaded = {
				{image = portraits.chitose_happy, text = "Your aiming is naive.\nEvasion successful."},
			},
			spiritFull = {
				{image = portraits.forte_excited, text = "I'm all powered up!\nTime for the bad guys to feel pain!"},
				{image = portraits.forte_excited, text = "Well, well!\nLooks like I just ran out of gum!"},
				minor = colors.green .. "Harvester\008 has " .. colors.yellow .. "maxed spirit\008!"
			},
			engagingEnemy = {
				{image = portraits.forte_normal, text = "Target on radar.\nMoving to engage."},
				{image = portraits.forte_normal, text = "Target acquired.\nHappy Trigger is oscar mike."}
			},
			commandReceived = {
				{image = portraits.forte_normal, text = "Yes, sir."},
				{image = portraits.forte_normal, text = "Happy Trigger, roger."},
			},
			specialWeapon = {
				{image = portraits.vanilla_aggressive, text = "Healing light...\nRepair Wave!"},
				{image = portraits.vanilla_aggressive, text = "Nanomachines, scatter in all directions...\nRepair Wave!"},
			},
		}
	},
	]]
	sharpshooter = {
		name = "Chitose",
		dialogue = {
			death = {
				{image = portraits.chitose_pain, text = "Unit #6, no longer combat-capable!"},
			},
			kill = {
				{image = portraits.chitose_angry, text = "Sharpshooter, target has been defeated."},
				{image = portraits.chitose_happy, text = "Unit #6, target is no longer a threat."},
				{image = portraits.chitose_aggressive, text = "Enemy down!\nI won't let you hurt my friends."},
			},
			unitDamaged_severe = {
				{image = portraits.chitose_pain, text = "Sharpshooter, damage critical...\nCan't hold on much longer..."},
				{image = portraits.chitose_pain, text = "Unit #6, hull integrity failing!\nPlease repair me!"},
				minor = colors.midnightblue .. "Sharpshooter\008 is " .. colors.red .. "75% damaged\008!"
			},
			unitDamaged_moderate = {
				{image = portraits.chitose_normal, text = "This is the Sharpshooter, requesting repairs."},
				{image = portraits.chitose_normal, text = "Unit #6, hull integrity at 50%.\nI can still make it."},
				minor = colors.midnightblue .. "Sharpshooter\008 is " .. colors.orange .. "50% damaged\008!"
			},
			unitDamaged_minor = {
				{image = portraits.chitose_normal, text = "Sharpshooter, minor damage sustained."},
				{image = portraits.chitose_annoyed, text = "A minor wound. I won't go down so easily."},
				minor = colors.midnightblue .. "Sharpshooter\008 is " .. colors.yellow .. "20% damaged\008!"
			},
			criticalHit = {
				{image = portraits.chitose_happy, text = "Full of holes, aren't you?\nI Hit the bulls-eye."},
				{image = portraits.chitose_aggressive, text = "Perfect hit!\nDo not take Unit #6 lightly."},
				{image = portraits.chitose_happy, text = "A good hit.\nI'll keep trying my best."},
			},
			criticalHit_received = {
				{image = portraits.chitose_pain, text = "Kyaaaa!\nSpirits, the pain..."},
			},
			unitSuppressed_severe = {
				{image = portraits.chitose_pain, text = "Spirits, there's so many of them...\nI can't do this..."},
				minor = colors.midnightblue .. "Sharpshooter\008 is " .. colors.red .. "80% suppressed\008!"
			},
			unitSuppressed_moderate = {
				{image = portraits.chitose_concerned, text = "Unit #6, under heavy fire...\nTact, please keep an eye out for me."},
				{image = portraits.chitose_stressed, text = "Huff... huff... I must not fear..."},
				minor = colors.midnightblue .. "Sharpshooter\008 is " .. colors.orange .. "50% suppressed\008!"
			},
			unitSuppressed_minor = {
				{image = portraits.chitose_angry, text = "Do not think you can intimidate me into backing down."},
				{image = portraits.chitose_normal, text = "Sharpshooter is engaged.\nSituation under control."},
				minor = colors.midnightblue .. "Sharpshooter\008 is " .. colors.yellow .. "25% suppressed\008!"
			},
			unitEnergy_critical = {
				{image = portraits.chitose_concerned, text = "Unit #6, energy levels critical.\nPlease resupply me, Tact."},
				{image = portraits.chitose_concerned, text = "Sharpshooter, requesting resupply ASAP."},
				minor = colors.midnightblue .. "Sharpshooter\008 down to " .. colors.orange .. "30% energy\008!"
			},
			unitEnergy_low = {
				{image = portraits.chitose_normal, text = "Unit #6, energy levels 50% of nominal."},
				minor = colors.midnightblue .. "Sharpshooter\008 down to " .. colors.yellow .. "50% energy\008!"
			},
			weaponMiss = {
				{image = portraits.chitose_surprised, text = "Oh, a miss... I need to stay calm."},
				{image = portraits.chitose_surprised, text = "No way. Why didn't it hit?"},
			},
			weaponEvaded = {
				{image = portraits.chitose_happy, text = "Your aiming is naive.\nEvasion successful."},
			},
			spiritFull = {
				{image = portraits.chitose_angry, text = "Power at maximum.\nThey will not escape justice today."},
				{image = portraits.chitose_happy, text = "I'm ready to put an arrow through their hearts.\nTact, please give the order."},
				minor = colors.midnightblue .. "Sharpshooter\008 has " .. colors.yellow .. "maxed spirit\008!"
			},
			repair = {
				{image = portraits.chitose_happy, text = "Repairs complete.\nThank you very much."},
				minor = colors.midnightblue .. "Sharpshooter\008 has " .. colors.green .. "completed resupply\008!"
			},
			resupply = {
				{image = portraits.chitose_happy, text = "Repairs complete.\nThank you very much."},
				minor = colors.midnightblue .. "Sharpshooter\008 has " .. colors.green .. "completed resupply\008!"
			},
			engagingEnemy = {
				{image = portraits.chitose_angry, text = "Target confirmed, engaging."},
				{image = portraits.chitose_normal, text = "Sharpshooter has acquired target."},
			},
			commandReceived = {
				{image = portraits.chitose_normal, text = "Yes, sir."},
				{image = portraits.chitose_normal, text = "Unit #6, moving as ordered."},
			},
			specialWeapon = {
				{image = portraits.chitose_aggressive, text = "Judgement!\nFatal Arrow!"},
				{image = portraits.chitose_aggressive, text = "This is your end!\nFatal Arrow!"},
			},
		}
	},
	
	elsior = {
		name = "Tact",
		dialogue = {
			--death = {
			--	{name = "Almo", image = portraits.almo_shocked, text = "Critical systems failure!\nPrimary engine overloading!"},
			--},
			kill = {
				{name = "Lester", image = portraits.lester_amused, text = "Target destroyed!\nWe survived somehow, Tact."},
				{name = "Almo", image = portraits.almo_happy, text = "Target is breaking up!\nWell done, commander!"},
				{image = portraits.tact_normal, text = "Alright, threat eliminated!\nHelm, get us to safety."},
			},
			unitDamaged_severe = {
				{name = "Almo", image = portraits.almo_shocked, text = "It's too dangerous! Commander, please recall the Angel Wing!"},
				{name = "Almo", image = portraits.almo_shocked, text = "Breach in starboard fusion chamber!"},
				{image = portraits.tact_angry, text = "No, we can't die here!\nI won't allow it!"},
				{name = "Lester", image = portraits.lester_aggresive, text = "Systems are critical! All non-essential personnel, prepare to abandon ship!"},
				minor = colors.yellow .. "Elsior\008 is " .. colors.red .. "75% damaged\008!"
			},
			unitDamaged_moderate = {
				{name = "Lester", image = portraits.lester_bitter, text = "We can't keep going like this.\nTact, get us out of the line of fire!"},
				{name = "Lester", image = portraits.lester_aggresive, text = "Multiple hull breaches! We're trailing atmosphere!"},
				{name = "Almo", image = portraits.almo_surprised, text = "Commander, we're taking heavy damage!\nGet the Angel Wing to cover us!"},
				{name = "Almo", image = portraits.almo_surprised, text = "We're under heavy fire!\nDamage control teams are reaching capacity!"},
				minor = colors.yellow .. "Elsior\008 is " .. colors.orange .. "50% damaged\008!"
			},
			unitDamaged_minor = {
				{name = "Almo", image = portraits.almo_normal, text = "Minor damage sustained.\nSir, please be more careful."},
				{name = "Lester", image = portraits.lester_serious, text = "The ship's taking damage.\nTact, mind the field of battle."},
				minor = colors.yellow .. "Elsior\008 is " .. colors.yellow .. "20% damaged\008!"
			},
			criticalHit = {
				{name = "Lester", image = portraits.lester_serious, text = "Good hit on target! Keep up the fire!"},
				{name = "Coco", image = portraits.coco_happy, text = "Alright! A direct hit!"},
			},
			criticalHit_received = {
				{image = portraits.tact_stressed, text = "Gah!\nThat was a nasty hit..."},
				{name = "Lester", image = portraits.lester_bitter, text = "Tch... that left a nasty hole in our hull."},
			},
			unitSuppressed_severe = {
				{name = "Almo", image = portraits.almo_shocked, text = "Kyaa!\nWe're getting overwhelmed!"},
				minor = colors.yellow .. "Elsior\008 is " .. colors.red .. "80% suppressed\008!"
			},
			unitSuppressed_moderate = {
				{name = "Lester", image = portraits.lester_bitter, text = "Under heavy fire. The crew isn't taking it well..."},
				{image = portraits.tact_stressed, text = "Everyone, hang in there!\nWe're not going to roll over from this!"},
				{name = "Coco", image = portraits.coco_surprised, text = "Uwaah!\nSo much fire..."},
				minor = colors.yellow .. "Elsior\008 is " .. colors.orange .. "50% suppressed\008!"
			},
			unitSuppressed_minor = {
				{name = "Coco", image = portraits.coco_normal, text = "Under intense enemy fire...\nI hope we can pull through this..."},
				minor = colors.yellow .. "Elsior\008 is " .. colors.yellow .. "25% suppressed\008!"
			},
			unitEnergy_critical = {
				{name = "Lester", image = portraits.lester_serious, text = "We're dangerously low on energy.\nTact, call your targets carefully."},
				minor = colors.yellow .. "Elsior\008 down to " .. colors.orange .. "30% energy\008!"
			},
			unitEnergy_low = {
				{name = "Almo", image = portraits.almo_normal, text = "Energy levels down to 50%."},
				minor = colors.yellow .. "Elsior\008 down to " .. colors.yellow .. "50% energy\008!"
			},
			weaponMiss = {
				{name = "Lester", image = portraits.lester_aggressive, text = "Gunner, where are you looking?!\nCan't you see the enemy!?"},
				{name = "Coco", image = portraits.coco_surprised, text = "No way... our attack missed?!"},
				{image = tact_angry, text = "Ah, our attack missed!\nGet ready for the return fire!"},
			},
		}
	},
}
pilotDefsPre.placeholdersior = pilotDefsPre.elsior

pilotDefs = {}

for unitName, data in pairs(pilotDefsPre) do
	if idleChatter[unitName] then
		data.dialogue.idle = idleChatter[unitName]
	end

	if UnitDefNames[unitName] then
		pilotDefs[UnitDefNames[unitName].id] = data
	end
end