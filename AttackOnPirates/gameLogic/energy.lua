module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'

function new()
	local group = display.newGroup()
 	local currentEnergy = localStorage.get("currentEnergy")
 	local maxEnergy = 5
 	local cooldown = 900 -- in seconds (1800)
 	local countDown

    -- Draw Energy(graphic)
    local energyRects = display.newGroup()
    energyRects.anchorX, energyRects.anchorY = 0, 1
	local numOfYellowRect = currentEnergy
	local numOfGreyRect = maxEnergy - currentEnergy
	local xPosition = 58
	local yPosition = 36
	local marginLength = 18

	-- draw rects
	for i = 1, numOfYellowRect, 1 do
		local bar =  display.newRect(0, 0, 15, 8)
		bar.anchorX, bar.anchorY = 0, 1
		bar.x = xPosition + ((i - 1) * marginLength)
		bar.y = yPosition
		bar:setFillColor(255/255, 255/255, 0/255)
		energyRects:insert(bar)
	end
	for i = 1, numOfGreyRect, 1 do
		local bar = display.newRect(0, 0, 15, 8)
		bar.anchorX, bar.anchorY = 0, 1
		bar.x = xPosition + ((i - 1 + numOfYellowRect) * marginLength)
		bar.y = yPosition
		bar:setFillColor(125/255, 125/255, 125/255)
		energyRects:insert(bar)
	end

	group:insert(energyRects)

	local function initTime()
		local time1 = localStorage.get("timestamp")
		local time2 = os.time()
		local changeInTimes = time2 - time1
		if currentEnergy < maxEnergy then
			local cooldownCycle = math.floor(changeInTimes/cooldown)
			local timestampOffset = (changeInTimes % cooldown)
			local cooldownOffset = cooldown - timestampOffset
			currentEnergy = math.min(currentEnergy + cooldownCycle, maxEnergy)
			countDown = cooldownOffset

			localStorage.saveWithKey("currentEnergy", currentEnergy)
			localStorage.saveWithKey("timestamp", time2 - timestampOffset)
		else
			-- save timestamp?
			countDown = -1
		end
	end
	initTime()

	local clock = display.newText("", 179, 19, "Helvetica", 10)
	-- draw clocks
	if currentEnergy == maxEnergy then
		clock.text = "Full"
	else
		local mins = math.floor(countDown / 60)
		local secs = tostring(math.floor(countDown - (mins*60)))
		if (string.len(secs)) == 1 then
			secs = "0" .. secs
		end
		clock.text = mins .. ":" .. secs
	end
	group:insert(clock)

	-- update function
	local function updateEnergyTimer()
		if countDown == 0 then
			currentEnergy = math.min(currentEnergy + 1, maxEnergy)
			--localStorage.saveWithKey("currentEnergy", currentEnergy)
			--localStorage.saveWithKey("timestamp", os.time())
		end

		for i = 1, currentEnergy, 1 do
			energyRects[i]:setFillColor(255/255, 255/255, 0/255)
		end
		for i = currentEnergy + 1, maxEnergy, 1 do
			energyRects[i]:setFillColor(125/255, 125/255, 125/255)
		end

		if currentEnergy ~= maxEnergy and countDown < 0 then
			countDown = cooldown
		end

		if currentEnergy == maxEnergy then
			clock.text = "Full"
		else
			local mins = math.floor(countDown / 60)
			local secs = tostring(math.floor(countDown - (mins*60)))
			if (string.len(secs)) == 1 then
				secs = "0" .. secs
			end
			clock.text = mins .. ":" .. secs
			countDown = countDown - 1
		end
	end
	local updateTimerHandler = timer.performWithDelay(1000, updateEnergyTimer, 0)

	function group:deductEnergyBy(n)
		if currentEnergy >= n and currentEnergy ~= maxEnergy then
			currentEnergy = currentEnergy - n
			localStorage.saveWithKey("currentEnergy", currentEnergy)
			return true
		elseif currentEnergy >= n and currentEnergy == maxEnergy then
			currentEnergy = currentEnergy - n
			localStorage.saveWithKey("currentEnergy", currentEnergy)
			localStorage.saveWithKey("timestamp", os.time())
			initTime()
			return true
		elseif currentEnergy < n then
			return false
		end
	end

	function group:restoreEnergy()
		currentEnergy = maxEnergy
		localStorage.saveWithKey("currentEnergy", currentEnergy)
	end

	function group:getEnergy()
		return currentEnergy
	end

	return {["screen"] = group,
			["timer"] = updateTimerHandler}
end
