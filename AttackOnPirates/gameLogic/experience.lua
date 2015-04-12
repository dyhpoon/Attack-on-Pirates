module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'
local levelSetting = require 'gameLogic.levelSetting'
local barYposition = 46
local barXPosition = 97
local barWidth = 130
local maxLevel = 30

-- experience needs to next level
local levelTable = levelSetting.getTable("mainCharExp")
local expTable = levelSetting.getTable("stageExp")

function expGainFromLevel(i)
	return expTable[i][2]
end

function new(soundEffect)
	local group = display.newGroup()

	local currentLevel = localStorage.get("charLevel")
	local currentExp = localStorage.get("charExp")

	local levelText = display.newText("", 85, 18, native.systemFont, 9)
	levelText.text = currentLevel
	group:insert(levelText)

	local greyBar = display.newRect(0, 0, barWidth, 2)
	greyBar.anchorX, greyBar.anchorY = .5, .5
	greyBar.x = barXPosition
	greyBar.y = barYposition
	greyBar:setFillColor(125/255, 125/255, 125/255)
	group:insert(greyBar)

	local yellowBar = display.newRect(0, 0, barWidth, 2)
	yellowBar.anchorX, yellowBar.anchorY = 0, .5
	yellowBar.x = barXPosition - greyBar.width/2 --greyBar.xReference --barXPosition
	yellowBar.y = barYposition
	yellowBar:setFillColor(255/255, 153/255, 51/255, 220/255)
	group:insert(yellowBar)
	
	if currentLevel == maxLevel then
		yellowBar.xScale = 1
	else
		local percent = currentExp/levelTable[currentLevel+1][2]
		if percent == 0 then percent = 0.001 end
		yellowBar.xScale = percent
	end

	local function updateExpSave(n)
		local storageLevel = localStorage.get("charLevel")
		local storageExp = localStorage.get("charExp")
		if storageLevel < maxLevel then
			local expNeedToLevelUp = levelTable[storageLevel+1][2] - storageExp
			local remainingExp = n - expNeedToLevelUp
			if n >= expNeedToLevelUp then
				localStorage.saveWithKey("charLevel", storageLevel+1)
				localStorage.saveWithKey("charExp", 0)
				updateExpSave(remainingExp)
			else
				localStorage.saveWithKey("charExp", storageExp+n)
			end
		end
	end

	local function addExpBy(n)
		local function levelUp(remainingExp)
			return function()
			yellowBar.xScale = 0.001
			currentLevel = currentLevel + 1
			currentExp = 0
			--localStorage.saveWithKey("charLevel", currentLevel)
			--localStorage.saveWithKey("charExp", 0)
			levelText.text = currentLevel
			levelText.anchorX, levelText.anchorY = .5, .5
			levelText.x = 83
			levelText.y = 20
			addExpBy(remainingExp)

			soundEffect:play("levelup")

			local levelUpText = display.newImage("images/result/resultLevelup.png")
			levelUpText.x = 200
			levelUpText.y = 65
			levelUpText.xScale = 0.3
			levelUpText.yScale = 0.3
			levelUpText.alpha = 0
			group:insert(levelUpText)

			local function deleteLevelUpText()
				if levelUpText then
					levelUpText:removeSelf()
					levelUpText = nil
				end
			end
			transition.to(levelUpText, {time=300, y=levelUpText.y-30, xScale=1.3, yScale=1.3, alpha=1, transition=easing.outQuad})
			transition.to(levelUpText, {time=2000, delay=300, alpha=0, onComplete=deleteLevelUpText})
			end
		end

		if currentLevel == maxLevel then
			yellowBar.xScale = 1
		else
			if n > 0 then
				local expNeedToLevelUp = levelTable[currentLevel+1][2] - currentExp
				local remainingExp = n - expNeedToLevelUp
				if n > expNeedToLevelUp then
					currentExp = currentExp + expNeedToLevelUp
				else
					currentExp = currentExp + n
				end

				local percent = currentExp/levelTable[currentLevel+1][2]
				if percent == 0 then 
					percent = 0.001
					transition.to(yellowBar, {time=1000, xScale=percent})
				elseif percent == 1 then
					transition.to(yellowBar, {time=1000, xScale=percent, onComplete=levelUp(remainingExp)})
				else
					transition.to(yellowBar, {time=1000, xScale=percent})
					--localStorage.saveWithKey("charExp", currentExp)
				end
			end
		end
	end

	function group:increaseExpBy(n)
		-- check if there is any exp bonus
		local expBonus = localStorage.get("expBonus")

		-- double the exp(if having exp buff) and update save
		if expBonus >= 1 then
			n = n * 2
			localStorage.saveWithKey("expBonus", expBonus - 1)
		end

		updateExpSave(n)
		addExpBy(n)
	end

	function group:getLevel()
		return currentLevel
	end

	function group:getExp()
		return currentExp
	end

	return group
end
