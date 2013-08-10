local Sounds = {
	SoundItems = {
		--- RESERVED FOR SPRING, DON'T REMOVE
		IncomingChat = {
			file = "sounds/incoming_chat.wav",
			 rolloff = 0.1, 
			maxdist = 10000,
			priority = 100, --- higher numbers = less chance of cutoff
			maxconcurrent = 1, ---how many maximum can we hear?
		},
		MultiSelect = {
			file = "sounds/multiselect.wav",
			 rolloff = 0.1, 
			maxdist = 10000,
			priority = 100, --- higher numbers = less chance of cutoff
			maxconcurrent = 1, ---how many maximum can we hear?
		},
		MapPoint = {
			file = "sounds/mappoint.wav",
			rolloff = 0.1,
			maxdist = 10000,
			priority = 100, --- higher numbers = less chance of cutoff
			maxconcurrent = 1, ---how many maximum can we hear?
		},
		--- END RESERVED
		},
	}

local VFSUtils = VFS.Include('gamedata/VFSUtils.lua')

local function AutoAdd(subDir, rollOff, dopplerScale, maxDist, maxConcurrent, Priority, Gain, gainMod, Pitch, pitchMod)
	local dirList = RecursiveFileSearch("sounds/" .. subDir)
	--local dirList = RecursiveFileSearch("sounds/")
	for _, fullPath in ipairs(dirList) do
    		local path, key, ext = fullPath:match("sounds/(.*/(.*)%.(.*))")
		if path ~= nil then
			--Spring.Echo(path,key,ext)
			Sounds.SoundItems[key] = {file = tostring('sounds/'..path), rolloff = rollOff, dopplerscale = dopplerScale, maxdist = maxDist, maxconcurrent = maxConcurrent, priority = Priority, gain = Gain, gainmod = gainMod, pitch = Pitch, pitchmod = pitchMod}
			--Spring.Echo(Sounds.SoundItems[key].file)
		end
	end
end

-- Standard Weapons, with random pitch / gain adjustments
rollOff = 3.5
dopplerScale = 0
maxDist = 6000
maxConcurrent = 4
Priority = 10
Gain = 1.0
gainMod = 0.1
Pitch = 1.0
pitchMod = 0.02
AutoAdd("weapons", rollOff, dopplerScale, maxDist, maxConcurrent, Priority, Gain, gainMod, Pitch, pitchMod)

-- Standard Explosions
rollOff = 3.0
dopplerScale = 0
maxDist = 6000
maxConcurrent = 2
Priority = 10
Gain = 1.0
gainMod = 0.1
Pitch = 1.0
pitchMod = 0.02
AutoAdd("explosions", rollOff, dopplerScale, maxDist, maxConcurrent, Priority, Gain, gainMod, Pitch, pitchMod)

-- Standard Voices
rollOff = 0
dopplerScale = 0
maxDist = 10000
maxConcurrent = 1
Priority = 100
Gain = 1.0
gainMod = 0
Pitch = 1.0
pitchMod = 0.02
AutoAdd("voices", rollOff, dopplerScale, maxDist, maxConcurrent, Priority, Gain, gainMod, Pitch, pitchMod)

-- Death Sounds (specific randomized sounds played for death, a feature of P.U.R.E.)
rollOff = 3.5
dopplerScale = 0
maxDist = 6000
maxConcurrent = 1
Priority = 15
Gain = 1.0
gainMod = 0.1
Pitch = 1.0
pitchMod = 0.02
AutoAdd("death", rollOff, dopplerScale, maxDist, maxConcurrent, Priority, Gain, gainMod, Pitch, pitchMod)

-- Vehicle Sounds (sounds played via BOS / Lua for objects in motion, such as footfalls)
rollOff = 3.5
dopplerScale = 0
maxDist = 6000
maxConcurrent = 3
Priority = 7
Gain = 1.0
gainMod = 0.1
Pitch = 1.0
pitchMod = 0.02
AutoAdd("vehicle", rollOff, dopplerScale, maxDist, maxConcurrent, Priority, Gain, gainMod, Pitch, pitchMod)

-- Greeble Sounds (sounds played via BOS / Lua for 'greeble' effects)
rollOff = 3.5
dopplerScale = 0
maxDist = 6000
maxConcurrent = 3
Priority = 7
Gain = 1.0
gainMod = 0.1
Pitch = 1.0
pitchMod = 0.02
AutoAdd("greeble", rollOff, dopplerScale, maxDist, maxConcurrent, Priority, Gain, gainMod, Pitch, pitchMod)

-- Ambient Sounds (ambient noises, background sounds for maps, etc.)
rollOff = 3.5
dopplerScale = 0
maxDist = 6000
maxConcurrent = 1
Priority = 15
Gain = 1.0
gainMod = 0.1
Pitch = 1.0
pitchMod = 0.02
AutoAdd("ambient", rollOff, dopplerScale, maxDist, maxConcurrent, Priority, Gain, gainMod, Pitch, pitchMod)

-- Distortion Loop Sounds (sounds meant to be used in loops, such as doppler'd jet whines)
rollOff = 7
dopplerScale = 15
maxDist = 6000
maxConcurrent = 1
Priority = 6
Gain = 1.0
gainMod = 0.1
Pitch = 1.0
pitchMod = 0.02
AutoAdd("distortionloops", rollOff, dopplerScale, maxDist, maxConcurrent, Priority, Gain, gainMod, Pitch, pitchMod)

--manual overrides
	--death explosions
	
	Sounds.SoundItems["ex_small2"] = {
		file = "sounds/ex_small2.wav",
		gain = 1.3,
		gainmod = 0.1,
		pitch = 1,
		pitchmod = 0.02,
		maxconcurrent = 3,
		}
	Sounds.SoundItems["deathmed"] = {
		file = "sounds/deathmed.wav",
		gain = 1.3,
		gainmod = 0.1,
		pitch = 1,
		pitchmod = 0.02,
		maxconcurrent = 1,
		}
	Sounds.SoundItems["ex_large3"] = {
		file = "sounds/ex_large3.wav",
		gain = 1.5,
		gainmod = 0.1,
		pitch = 1,
		pitchmod = 0.02,
		maxconcurrent = 2,
		}

return Sounds