module(..., package.seeall)

local isAndroid = system.getInfo("platformName") == "Android"	

function play(id)
	if _G.songName == nil or _G.songName ~= id then

		if _G.songName and _G.songName ~= id then
			audio.stop(1)
		end
		
		if id == "main" then
			if isAndroid then
				_G.backgroundMusic = audio.loadStream("audio/OGG/BGM/mainbgm.ogg")
			else
				_G.backgroundMusic = audio.loadStream("audio/WAV/BGM/mainbgm.wav")
			end
			_G.backgroundMusicChannel = audio.play(_G.backgroundMusic, {channel=1, loops=-1, fadein=5000,})
		elseif id == "map" then
			if isAndroid then
				_G.backgroundMusic = audio.loadStream("audio/OGG/BGM/bigmapbgm.ogg")
			else
				_G.backgroundMusic = audio.loadStream("audio/WAV/BGM/bigmapbgm.wav")
			end
			_G.backgroundMusicChannel = audio.play(_G.backgroundMusic, {channel=1, loops=-1, fadein=5000,})
		elseif id == "game" then
			if isAndroid then
				_G.backgroundMusic = audio.loadStream("audio/OGG/BGM/ingamebgm.ogg")
			else
				_G.backgroundMusic = audio.loadStream("audio/WAV/BGM/ingamebgm.wav")
			end
			_G.backgroundMusicChannel = audio.play(_G.backgroundMusic, {channel=1, loops=-1, fadein=5000,})
		elseif id == "shop" then
			if isAndroid then
				_G.backgroundMusic = audio.loadStream("audio/OGG/BGM/shopbgm.ogg")
			else
				_G.backgroundMusic = audio.loadStream("audio/WAV/BGM/shopbgm.wav")
			end
			_G.backgroundMusicChannel = audio.play(_G.backgroundMusic, {channel=1, loops=-1, fadein=5000,})			
		end
		_G.songName = id
	end
end

function stop()
	audio.stop(_G.backgroundMusicChannel)
	_G.backgroundMusic = nil
	_G.backgroundMusicChannel = nil
	_G.songName = nil
end