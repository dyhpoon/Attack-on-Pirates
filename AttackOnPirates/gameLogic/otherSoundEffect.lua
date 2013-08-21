module(..., package.seeall)

function new()
	local group = {}
	local isAndroid = system.getInfo("platformName") == "Android"

	local soundTable
	if isAndroid then
		soundTable = {
			button = media.newEventSound("audio/OGG/select.ogg"),
			back = media.newEventSound("audio/OGG/back.ogg"),
			buy = media.newEventSound("audio/OGG/buy.ogg"),
			choose = media.newEventSound("audio/OGG/choose.ogg"),
			coin = media.newEventSound("audio/OGG/coinpickup.ogg"),
			swipe = media.newEventSound("audio/OGG/swipe.ogg"),
		}
	else
		soundTable = {
			button = audio.loadSound("audio/WAV/select.wav"),
			back = audio.loadSound("audio/WAV/back.wav"),
			buy = audio.loadSound("audio/WAV/buy.wav"),
			choose = audio.loadSound("audio/WAV/choose.wav"),
			coin = audio.loadSound("audio/WAV/coinpickup.wav"),
			swipe = audio.loadSound("audio/WAV/swipe.wav"),
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
