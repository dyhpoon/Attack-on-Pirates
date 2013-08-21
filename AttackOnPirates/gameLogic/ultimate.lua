module(..., package.seeall)

function new(manaBar, monsters, mainChar, minimap)
	local group = display.newGroup()

	local options = {
			width = 320/5,
			height = 320/5,
			numFrames = 24,
			sheetContentWidth = 320,
			sheetContentHeight = 320
	}
	local imageSheet = graphics.newImageSheet("images/ultimateFlame.png", options)
	local sequenceData = {
		{name="startBuring", start=1, count=5, time=600, loopCount=1},
		{name="buring", start=6, count=10, time=600, loopCount=0},
		{name="endBuring", start=21, count=4, time=600, loopCount=1},
	}
	local ultimate = display.newSprite(imageSheet, sequenceData)
	ultimate.x = 70
	ultimate.y = 70
	ultimate.xScale = 1
	ultimate.yScale = 1.2
	ultimate.alpha = 0
	group:insert(ultimate)

	local function useUltimate(event)
		if manaBar:getMana() == 100 then
			manaBar:setMana(0, 100)
			ultimate:setSequence("endBuring")
			ultimate:play()
			mainChar:useUlt()
		end
		return true
	end

	local animatingUltimate = false
	local animatingDeadSprite = false
	function group:update()
		--print(ultimate.sequence)
		if mainChar:isDead() and not animatingDeadSprite then
			animatingDeadSprite = true
			ultimate:setSequence("endBuring")
			ultimate:play()
		elseif manaBar:getMana() == 100 and not animatingUltimate and not mainChar:isDead() then
			animatingUltimate = true
			ultimate:setSequence("startBuring")
			ultimate:play()
			ultimate.alpha = 1
		end
	end

	local function pirateSpriteListener(event)
		local target = event.target
		if event.phase == "ended" and target.sequence == "startBuring" then
			target:setSequence("buring")
			target:play()
		elseif event.phase == "ended" and target.sequence == "endBuring" then
			target.alpha = 0
			animatingUltimate = false
		end
	end

	function group:start()
		mainChar:addEventListener("touch", useUltimate)
		ultimate:addEventListener("sprite", pirateSpriteListener)
	end

	function group:stop()
		mainChar:removeEventListener("touch", useUltimate)
		ultimate:removeEventListener("sprite", pirateSpriteListener)
	end

	return group
end
