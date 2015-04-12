module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'
local levelSetting = require 'gameLogic.levelSetting'
local statTable = levelSetting.getTable("mainCharStat")

function new(damage, monsters, minimap, health, soundEffect)
	local group = display.newGroup()
	local onHit = false
	local lastSpriteSequence
	local baseDamage = statTable[localStorage.get("charLevel")][3]
	local options = {
		width = 80,
		height = 80,
		numFrames = 20,
		sheetContentWidth = 512,
		sheetContentHeight = 512,
	}
	local imageSheet = graphics.newImageSheet("images/mainChar.png", options)

	local sequenceData = {
		{name="ulting", start=10, count=5, time=1000, loopCount=1},
		{name="dying", start=1, count=4, time=600, loopCount=1},
		{name="running", start=17, count=4, time=700, loopCount=0},
		{name="attacking", start=5, count=5, time=950, loopCount=1},
		{name="chilling", start=15, count=2, time=400, loopCount=0},
	}

	local mainChar = display.newSprite(imageSheet, sequenceData)
	mainChar.xScale = 0.75
	mainChar.yScale = 0.75
	mainChar.x = 70
	mainChar.y = 77
	mainChar.xScale = 0.65
	mainChar.yScale = 0.65
	mainChar:setSequence("running")
	mainChar:play()

	local collisionRect = display.newRect(mainChar.x + 22, mainChar.y - 5, 1, 25)
	collisionRect.strokeWidth = 1
	collisionRect:setFillColor(140/255, 140/255, 140/255)
	collisionRect:setStrokeColor(180/255, 180/255, 180/255)
	collisionRect.alpha = 0

	local function ultDoDamage()
		if monsters and minimap then
			monsters:killMonster(damage:getDamage()*10, true, minimap)
		end
	end

	local function pirateListener(event)
		local thisSprite = event.target
		if thisSprite.sequence == "attacking" and onHit and event.phase == "ended" then
			local damageValue = damage:getDamage()
			damage:setDamage(math.max(math.floor(damageValue*0.7), baseDamage))
			onHit = false
			soundEffect:play("slash")
			monsters:killMonster(damageValue, false, minimap)
		elseif thisSprite.sequence == "ulting" and event.phase == "ended" then
			timer.performWithDelay(30, ultDoDamage)
			thisSprite:setSequence(lastSpriteSequence)
			thisSprite:play()
		end
	end
	mainChar:addEventListener("sprite", pirateListener)

	function group:update(inBattle, isRescuing)
		if health:isDead() and mainChar.sequence ~= "dying" then
			mainChar:setSequence("dying")
			mainChar:play()
		end
		if not health:isDead() then
			if mainChar.sequence ~= "ulting" then
				if isRescuing then
					mainChar:setSequence("chilling")
					mainChar:play()
					onHit = false
				elseif inBattle and damage:getDamage() > 0 and not onHit then
					mainChar:setSequence("attacking")
					mainChar:play()
					onHit = true
				elseif inBattle and damage:getDamage() <= 0 and mainChar.sequence ~= "chilling" then
					mainChar:setSequence("chilling")
					mainChar:play()
					onHit = false
				elseif not inBattle and mainChar.sequence ~= "running" then
					mainChar:setSequence("running")
					mainChar:play()
					onHit = false
				end
			end
		end

		return mainChar.sequence == "running"
	end

	function group:useUlt()
		lastSpriteSequence = mainChar.sequence
		soundEffect:play("slashsuper")
		mainChar:setSequence("ulting")
		mainChar:play()
	end

	function group:isDead()
		return health:isDead()
	end

	function group:getCollisionRect()
		return collisionRect
	end

	group:insert(mainChar)
	group:insert(collisionRect)
	return group
end
