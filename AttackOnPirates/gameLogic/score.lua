module(..., package.seeall)

function new()
	local group = display.newGroup()

	local score
	local scoreText

	score = 0
	scoreText = display.newText( "SCORE: 0" , 0, 0, "impact", 13 )
	scoreText.anchorX, scoreText.anchorY = 1, .5
	scoreText.x = display.contentWidth - 8
	scoreText.y = 40

    scoreText.text =  "SCORE:   " .. score --string.format( "SCORE: %6.0f", score )
	scoreText:setTextColor(255, 255, 255)
	group:insert(scoreText)

	function group:addScore(scoreToBeAdded)
		score = score + scoreToBeAdded
		scoreText.text =  "SCORE:   " .. score --string.format( "SCORE: %6.0f", score )
		scoreText.anchorX, scoreText.anchorY = 1, .5
		scoreText.x = display.contentWidth - 8
		scoreText.y = 40
	end

	function group:getScore()
		return score
	end

	return group
end
