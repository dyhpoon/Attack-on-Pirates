module(..., package.seeall)

local streakTextXPosition = 300
local streakTextYPosition = 105

function new()
	local group = display.newGroup()
	local timers = {}
	local streak = 0
	local streakTimer = 0
	local streakTransition
	local highestStreak = 0

	local streakText = display.newText( "STREAK:", 0, 0, "impact", 13 )
	streakText:setReferencePoint(display.BottomRightReferencePoint)
	streakText.alpha = 0
	streakText.x = streakTextXPosition
	streakText.y = streakTextYPosition
	streakText:setTextColor(255, 255, 255)
	group:insert(streakText)

	local function resetStreakTimer()
		streakTimer = 2.5
	end
	local function setStreakToZero()
		streakTimer = streakTimer - 1
		if streakTimer < 0 then
			streak = 0
		end
	end
	local streakTimerUpdate = timer.performWithDelay(1000, setStreakToZero, 0)

	function group:getHighestStreak()
		return highestStreak
	end

	function group:getStreak()
		return streak
	end

	function group:updateStreak(numberOfMarkedToDestroy)
		if numberOfMarkedToDestroy == 0 then return end
		streak = streak + 1
		highestStreak = math.max(highestStreak, streak)
		resetStreakTimer()
		streakText.text = string.format( "STREAK: %4.0f", streak)
		streakText.x = streakTextXPosition
		streakText.y = streakTextYPosition
		streakText.alpha = 1
		if streakTransition then 
			transition.cancel(streakTransition)
			streakTransition = nil
		end
		streakTransition = transition.to( streakText, { time = 1500, delay= 1000,alpha=0, transition=easing.inOutExpo} )
	end

	table.insert(timers, streakTimerUpdate)

	return {["timers"] = timers,
			["screen"] = group}
end
