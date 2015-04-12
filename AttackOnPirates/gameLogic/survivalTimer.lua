module(..., package.seeall)

function new()
	local group = display.newGroup()

	local timerListener
	local count = 0
	local background = display.newRect(0, 0, 300, 14)
	background.anchorX, background.anchorY = .5, .5
	background:setFillColor(125/255, 125/255, 125/255)
	background.x = display.contentCenterX
	background.y = 147
	group:insert(background)

	local timerText = display.newText("0:00", 0, 0, native.systemFont , 13)
	timerText.anchorX, timerText.anchorY = .5, 1
	timerText.x = display.contentCenterX
	timerText.y = 155
	group:insert(timerText)

	local function updateTimer()
		count = count + 1
		local mins = math.floor(count/60)
		local secs = tostring(math.floor(count - (mins*60)))
		if (string.len(secs)) == 1 then
			secs = "0" .. secs
		end
		timerText.text = mins .. ":" .. secs
		timerText.anchorX, timerText.anchorY = .5, 1
		timerText.x = display.contentCenterX
		timerText.y = 155
	end

	function group:getTime()
		return count
	end

	function group:start()
		timerListener = timer.performWithDelay(1000, updateTimer, 0)
	end

	function group:stop()
		if timerListener then
			timer.cancel(timerListener)
		end
	end

	return group
end
