module(..., package.seeall)

local barYposition = 112
local barXPosition = 10
local barWidth = 300
local healthViewXPosition
local healthViewYPosition

local localStorage = require 'gameLogic.localStorage'
local levelSetting = require 'gameLogic.levelSetting'
local statTable = levelSetting.getTable("mainCharStat")

function new(streakBonus)
	local group = display.newGroup()
	local healthView = display.newGroup()

	group.maxHealth = statTable[localStorage.get("charLevel")][2]
 	group.currentHealth = group.maxHealth

 	local isDead = false

	local greyBar = display.newRect(0, 0, barWidth, 11)
	greyBar.anchorX, greyBar.anchorY = 0, 0
	greyBar.x = barXPosition
	greyBar.y = barYposition
	greyBar:setFillColor(125/255, 125/255, 125/255)
	healthView:insert(greyBar)

	local redBar = display.newRect(0, 0, barWidth, 11)
	redBar.anchorX, redBar.anchorY = 0, 0
	redBar.x = barXPosition
	redBar.y = barYposition
	redBar:setFillColor(255/255, 0/255, 0/255, 220/255)
	healthView:insert(redBar)
	
	local healthText = display.newText("0/0", 0, 0, "impact",13)
	healthText.anchorX, healthText.anchorY = 1, 1
	healthText.x = 305
	healthText.y = 125
	healthView:insert(healthText)

	healthView.anchorX, healthView.anchorY = 0, 0
	healthViewXPosition = healthView.x
	healthViewYPosition = healthView.y

	group:insert(healthView)

	function group:setHealth(current, max)
		current = math.floor(current)
		if current <= 0 then current = 0 end
		if current > max then current = max end
		local percent = current / max
		if percent == 0 then
			transition.to(redBar, {time = 700, xScale = 0.0001, onComplete=function() redBar.alpha = 0 end})
		else
			redBar.alpha = 1
			transition.to(redBar, {time = 700, xScale = percent})
		end
		self.currentHealth = current
		local newHealthText = current .. "/" .. max
		healthText.text = newHealthText
		healthText.anchorX, healthText.anchorY = 1, 1
		healthText.x = 305
		healthText.y = 125

		if current == 0 then
			isDead = true
		end
	end
 
	function group:isDead()
		return isDead
	end

	function group:getHealth()
		return self.currentHealth
	end

	function group:getMaxHealth()
		return self.maxHealth
	end

	function group:minusHpBy(n)
		if self.currentHealth > 0 then
			group:setHealth(self.currentHealth-n, self.maxHealth)

			local minusHpText = display.newText("- " .. n, 0, 0, "verdana", 13)
			minusHpText:setTextColor(255/255, 0/255, 0/255)
			minusHpText.x = 280
			minusHpText.y = 112
			group:insert(minusHpText)
			local function removeMinusHpText()
				if minusHpText then
					minusHpText:removeSelf()
					minusHpText = nil
				end
			end
			transition.to(minusHpText, {time=600, y=minusHpText.y-50, x=minusHpText.x+math.random(-20, 20), onComplete=removeMinusHpText})

			healthView.anchorX, healthView.healthView = 0, 0
			transition.to(healthView, {time=60, x=healthViewXPosition+math.random(-10, 10), y=healthViewYPosition+math.random(-10, 10)})
			transition.to(healthView, {time=60, delay=60, x=healthViewXPosition, y=healthViewYPosition})
		end
	end

	local function textAnimation(hp)
		if hp > 0 then
			local addHpText = display.newText("+ " .. hp, 0, 0, "impact", 13)
			addHpText.anchorX, addHpText.anchorY = .5, 5
			addHpText:setTextColor(0/255, 255/255, 0/255)
			addHpText.x = 160
			addHpText.y = 115
			addHpText.xScale = 2
			addHpText.yScale = 2
			addHpText.alpha = 0
			group:insert(addHpText)
			transition.to(addHpText, {time=500, alpha=1, xScale=1, yScale=1})
			transition.to(addHpText, {time=500, delay=500, y=addHpText.y - 40, onComplete=function(target) target:removeSelf() end})
		end
	end

	function group:addHpBy(n, healType)
		if n > 0 then

			if healType == "percent" then
				n = n*2
				n = n*self.maxHealth/100
			end
			n = math.floor(n)
			-- normal heal
			self:setHealth(self.currentHealth+n, self.maxHealth)
			textAnimation(n)

			--streak bonus
			local streak = streakBonus:getStreak()
			if streak >= 1 and healType == "percent" then
				n = math.max(math.floor(n/10 * streak/5), 1)
				self:setHealth(self.currentHealth+n, self.maxHealth)
				timer.performWithDelay(200, function() textAnimation(n) end)
			end
		end
	end

	return group
end
