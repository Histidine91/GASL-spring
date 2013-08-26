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

local defaultOpts = {
	pitchMod = 0.05,
	gainMod = 0,
}
local replyOpts = {
	pitchMod = 0,
	gainMod = 0,
}

local ignoredExtensions = {
	["svn-base"] = true,
}

local function AutoAdd(subDir, opts)
	opts = opts or {}
	local dirList = RecursiveFileSearch("sounds/" .. subDir)
	--local dirList = RecursiveFileSearch("sounds/")
	for _, fullPath in ipairs(dirList) do
    	local path, key, ext = fullPath:match("sounds/(.*/(.*)%.(.*))")
		local pathPart = fullPath:match("(.*)[.]")
		pathPart = pathPart:sub(8, -1)	-- truncates extension fullstop and "sounds/" part of path
		if path ~= nil and (not ignoredExtensions[ext]) then
			--Spring.Echo(path,key,ext, pathPart)
			Sounds.SoundItems[pathPart] = {file = tostring('sounds/'..path), rolloff = opts.rollOff, dopplerscale = opts.dopplerScale, maxdist = opts.maxDist, maxconcurrent = opts.maxConcurrent, priority = opts.priority, gain = opts.gain, gainmod = opts.gainMod, pitch = opts.pitch, pitchmod = opts.pitchMod}
			--Spring.Echo(Sounds.SoundItems[key].file)
		end
	end
end

-- add sounds
AutoAdd("weapon", defaultOpts)
AutoAdd("explosion", defaultOpts)
AutoAdd("reply", replyOpts)

return Sounds