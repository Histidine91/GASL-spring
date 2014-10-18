--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	file:		gui_music.lua
--	brief:	yay music
--	author:	cake
--
--	Copyright (C) 2007.
--	Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name	= "Simple Music Player",
		desc	= "Plays specified tracks",
		author	= "cake, trepan, Smoth, Licho, xponen",
		date	= "Mar 01, 2008, Aug 20 2009, Nov 23 2011",
		license	= "GNU GPL, v2 or later",
		layer	= 0,
		enabled	= true	--	loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
options_path = 'Settings/Audio/Music'
options = {
	pausemusic = {
		name='Pause Music',
		type='bool',
		value=false,
		desc = "Music pauses with game",
	},
}

local LOOP_BUFFER = 0.015	-- if looping track is this close to the end, go ahead and loop
local curTrack, loopTrack
local haltMusic = false
local looping = false
local paused = false
local timeframetimer, timeframetimer_short = 0, 0

-- misnomer: both track types actually loop
local function StartLoopingTrack(trackInit, trackLoop)
	if not (VFS.FileExists(trackInit) and VFS.FileExists(trackLoop)) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Missing one or both tracks for looping")
	end
	haltMusic = true
	Spring.StopSoundStream()
	
	curTrack = trackInit
	loopTrack = trackLoop
	Spring.PlaySoundStream(trackInit, WG.music_volume or 0.5)
	looping = 0.5
end

local function StartTrack(track, loop)
	if not track then
		return
	end
	haltMusic = false
	looping = loop and 1 or false
	curTrack = track
	if loop then
		loopTrack = track
	end
	Spring.StopSoundStream()
	Spring.PlaySoundStream(track,WG.music_volume or 0.5)
	WG.music_start_volume = WG.music_volume
end

local function StopTrack(noContinue)
	looping = false
	Spring.StopSoundStream()
	if noContinue then
		haltMusic = true
	end
end

function widget:Update(dt)
	timeframetimer_short = timeframetimer_short + dt
	if timeframetimer_short > 0.03 then
		local playedTime, totalTime = Spring.GetSoundStreamTime()
		playedTime = tonumber( ("%.2f"):format(playedTime) )
		paused = (playedTime == lastTrackTime)
		lastTrackTime = playedTime
		if looping then
			if looping == 0.5 then
				looping = 1
			elseif playedTime >= totalTime - LOOP_BUFFER then
				Spring.StopSoundStream()
				Spring.PlaySoundStream(loopTrack,WG.music_volume or 0.5)
			end
		end
		timeframetimer_short = 0
	end
	
	timeframetimer = timeframetimer + dt
	if (timeframetimer > 1) then	-- every second
		timeframetimer = 0
		local playedTime, totalTime = Spring.GetSoundStreamTime()
		playedTime = math.floor(playedTime)
		totalTime = math.floor(totalTime)

		if (playedTime >= totalTime)	-- both zero means track stopped
		 and not(haltMusic or looping) then
			StartTrack()
		end
		local _, _, paused = Spring.GetGameSpeed()
		if (paused ~= wasPaused) and options.pausemusic.value then
			Spring.PauseSoundStream()
			wasPaused = paused
		end
	end
end

function widget:GameStart()
	gameStarted = true
	StartTrack()	
end

function widget:Initialize()
	WG.Music = WG.Music or {}
	WG.Music.StartTrack = StartTrack
	WG.Music.StartLoopingTrack = StartLoopingTrack
	WG.Music.StopTrack = StopTrack
end

function widget:Shutdown()
	Spring.StopSoundStream()
	WG.Music = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------