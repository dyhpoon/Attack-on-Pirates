module(..., package.seeall)

function new(mainCharStatus)
	local group = display.newGroup()

	local speed = 0.5
	local hostage
	local clickMeImage
	function group:spawnHostage()
		hasCheckedStatus = false

		local options = {
			width = 128,
			height = 128,
			numFrames = 16,
			sheetContentWidth = 512,
			sheetContentHeight = 512
		}

		local imageSheet = graphics.newImageSheet("images/mm.png", options)

		local sequenceData = {
			{name="crying", start=1, count=4, time=400, loopCount = 0},
			{name="releasing", start=5, count=4, time=1000, loopCount = 1},
			{name="kissing", start=9, count=4, time=1300, loopCount = 1},
			{name="laughing", start=13, count=4, time=400, loopCount = 0},
		}

		hostage = display.newSprite(imageSheet, sequenceData)
		hostage:play()
		hostage.x = 400
		hostage.y = 70
		hostage.xScale = 0.35
		hostage.yScale = 0.35
		hostage.isClicked = false
		hostage.clickMeHasShown = false
		group:insert(hostage)
		
	end

	local function moveUpAndDown(target)
        transition.to(target, {time=500, y=target.y+10})
        transition.to(target, {time=500, delay=500, y=target.y, onComplete=function() moveUpAndDown(target) end})
    end
	local function clickMeListener(event)
		if event.phase == "began" and not hasCheckedStatus then
			if clickMeImage then
				clickMeImage:removeSelf()
				clickMeImage = nil
			end
			hostage.isClicked = true
		end
	end

	function group:addClickMe()
		clickMeImage = display.newImage("images/buttons/buttonHostage.png")
		clickMeImage.x = hostage.x
		clickMeImage.y = hostage.y -30
		moveUpAndDown(clickMeImage)
		clickMeImage:addEventListener("touch", clickMeListener)
		hostage:addEventListener("touch", clickMeListener)
		group:insert(clickMeImage)
	end

	function group:updateHostage(collisionRectX, shouldMove)
		if hostage then
			if not hostage.clickMeHasShown and hostage.x <= collisionRectX + 120 then
				self.addClickMe()
				hostage.clickMeHasShown = true
			end

			collisionRectX = collisionRectX + 15

			if shouldMove then
				hostage.x = hostage.x - speed
				if hostage.clickMeHasShown and clickMeImage then 
					clickMeImage.x = clickMeImage.x - speed
				end
			end

			if hostage.x <= collisionRectX and hostage.sequence == "crying" and hostage.isClicked then
				hostage:setSequence("releasing")
				hostage:play()
			elseif hostage.sequence == "releasing" and not hostage.isPlaying then
				hostage:setSequence("kissing")
				hostage:play()
			elseif hostage.sequence == "kissing" and not hostage.isPlaying then
				hostage:setSequence("laughing")
				mainCharStatus["coins"]:increaseCoinsByN(math.random(3,5))
				hostage:play()
			end

			if not hasCheckedStatus and hostage.x <= collisionRectX then
				hasCheckedStatus = true
				if clickMeImage then
					clickMeImage:removeSelf()
					clickMeImage = nil
				end
			end

			if hostage.x <= -100 then
				group:removeHostage()
			end

			if hostage then
				return (hostage.sequence == "releasing" or hostage.sequence == "kissing")
			else
				return nil
			end
		end
	end

	function group:isExist()
		if hostage then return true else return false end
	end

	function group:removeHostage()
		if clickMeImage then
			clickMeImage:removeSelf()
			clickMeImage = nil
		end
		hostage:removeSelf()
		hostage = nil
	end


	return group
end
