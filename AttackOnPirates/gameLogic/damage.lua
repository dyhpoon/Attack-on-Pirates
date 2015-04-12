module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'
local levelSetting = require 'gameLogic.levelSetting'
local statTable = levelSetting.getTable("mainCharStat")


function new(streak)
	local group = display.newGroup()
	group.damage = statTable[localStorage.get("charLevel")][3]
	group.bonus = 0
	local updateTimer

	local damageText = display.newText( "0" , 0, 0, "impact", 13 )
	damageText.anchorX, damageText.anchorY = 1, .5
	damageText.x = 68
	damageText.y = 15
	damageText.text = group.damage
	group:insert(damageText)

	function group:setDamage(dmg)
		self.damage = dmg
		damageText.text = self.damage + self.bonus
		damageText.anchorX, damageText.anchorY = 1, .5
		damageText.x = 68
		damageText.y = 15
	end

	function group:increaseDamageByN(n)
		self.damage = self.damage + n
		damageText.text = self.damage + self.bonus
		damageText.anchorX, damageText.anchorY = 1, .5
		damageText.x = 68
		damageText.y = 15
	end

	function group:getDamage()
		return self.damage + self.bonus
	end

	local function updateDamage()
		group.bonus = streak:getStreak()
		damageText.text = group.damage + group.bonus
		damageText.anchorX, damageText.anchorY = 1, .5
		damageText.x = 68
		damageText.y = 15
	end

	function group:start()
		updateTimer = timer.performWithDelay(500, updateDamage, 0)
	end

	function group:stop()
		timer.cancel(updateTimer)
	end

	return group
end
