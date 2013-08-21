module(..., package.seeall)

function new()
	local group = {}
	local isAndroid = system.getInfo("platformName") == "Android"

	local soundTable
	if isAndroid then
		soundTable = {
			useitem = media.newEventSound("audio/OGG/useitem.ogg"),
			slash = media.newEventSound("audio/OGG/slash.ogg"),
			slashsuper = media.newEventSound("audio/OGG/slashsuper.ogg"),
			enemyattack = media.newEventSound("audio/OGG/enemyattack.ogg"),
			swaptiles = media.newEventSound("audio/OGG/swaptiles.ogg"),
			explosion = media.newEventSound("audio/OGG/explosion.ogg"),
			bomb = media.newEventSound("audio/OGG/bomb.ogg"),
			choose = media.newEventSound("audio/OGG/choose.ogg"),
			chest = media.newEventSound("audio/OGG/chest.ogg"),
			endgame = media.newEventSound("audio/OGG/endgame.ogg"),
		}
	else
		soundTable = {
			useitem = audio.loadSound("audio/WAV/useitem.wav"),
			slash = audio.loadSound("audio/WAV/slash.wav"),
			slashsuper = audio.loadSound("audio/WAV/slashsuper.wav"),
			enemyattack = audio.loadSound("audio/WAV/enemyattack.wav"),
			swaptiles = audio.loadSound("audio/WAV/swaptiles.wav"),
			explosion = audio.loadSound("audio/WAV/explosion.wav"),
			bomb = audio.loadSound("audio/WAV/bomb.wav"),
			choose = audio.loadSound("audio/WAV/choose.wav"),
			chest = audio.loadSound("audio/WAV/chest.wav"),
			endgame = audio.loadSound("audio/WAV/endgame.wav"),
		}
	end

	function group:play(id)
		if isAndroid then
			media.playEventSound(soundTable[id])
		else
			audio.play(soundTable[id])
		end
	end

	function group:dispose()
		if isAndroid then
		else
			for i=1, audio.totalChannels, 1 do
				if i ~= _G.backgroundMusicChannel then
					audio.stop(i)
				end
			end

			for s,v in pairs(soundTable) do
				audio.dispose(soundTable[s])
				soundTable[s] = nil
			end
		end
	end

	return group
end
