module(..., package.seeall)

function new()
	local group = {}
	local isAndroid = system.getInfo("platformName") == "Android"

	local soundTable
	if isAndroid then
		soundTable = {
			openchest = media.newEventSound("audio/OGG/openchest.ogg"),
			coinpickup = media.newEventSound("audio/OGG/coinpickup.ogg"),
			itemcollect = media.newEventSound("audio/OGG/itemcollect.ogg"),
			button = media.newEventSound("audio/OGG/select.ogg"),
			back = media.newEventSound("audio/OGG/back.ogg"),
		}
	else
		soundTable = {
			openchest = audio.loadSound("audio/WAV/openchest.wav"),
			coinpickup = audio.loadSound("audio/WAV/coinpickup.wav"),
			itemcollect = audio.loadSound("audio/WAV/itemcollect.wav"),
			button = audio.loadSound("audio/WAV/select.wav"),
			back = audio.loadSound("audio/WAV/back.wav"),
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
