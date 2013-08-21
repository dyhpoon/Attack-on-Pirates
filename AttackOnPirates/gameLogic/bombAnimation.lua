module(..., package.seeall)

function new()
	local group = display.newGroup()

	bombAnimationImage = display.newImageRect("images/explosion.png", 40, 40)
	bombAnimationImage.alpha = 0
	group:insert(bombAnimationImage)

	local function removeBomb()
		bombAnimationImage.alpha = 0
		bombAnimationImage.x = -50
		bombAnimationImage.y = -50
	end

	function group:play(x,y)
		bombAnimationImage.x = x --
		bombAnimationImage.y = y --
		bombAnimationImage.alpha = 1
		bombAnimationImage.xScale = 0.3
		bombAnimationImage.yScale = 0.3
		bombAnimationImage:toFront()
		transition.to(bombAnimationImage, {time = 400, xScale = 2, yScale = 2, transition=easing.inOutExpo, onComplete=removeBomb})
	end


	return group
end
