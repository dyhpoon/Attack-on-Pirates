module(..., package.seeall)

function new()
	local group = {}
	local isAndroid = system.getInfo("platformName") == "Android"

	local soundTable
	if isAndroid then
		soundTable = {
			stageclear = media.newEventSound("audio/OGG/stageclear.ogg"),
			stagefail = media.newEventSound("audio/OGG/stagefail.ogg"),
			rollingscore = media.newEventSound("audio/OGG/rollingscore.ogg"),
			levelup = media.newEventSound("audio/OGG/levelup.ogg"),
			button = media.newEventSound("audio/OGG/select.ogg"),
		}
	else
		soundTable = {
			stageclear = audio.loadSound("audio/WAV/stageclear.wav"),
			stagefail = audio.loadSound("audio/WAV/stagefail.wav"),
			rollingscore = audio.loadSound("audio/WAV/rollingscore.wav"),
			levelup = audio.loadSound("audio/WAV/levelup.wav"),
			button = audio.loadSound("audio/WAV/select.wav"),
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
