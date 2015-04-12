module(..., package.seeall)

local levelSetting = require 'gameLogic.levelSetting'

function new(resultTable, mode, soundEffect)
	local timers = {}
	local screen = display.newGroup()
	local _W = display.contentWidth 
	local _H = display.contentHeight
	local spawnTimerHandler, eventsUpdateHandler

	---------------------- INITIALIZE -------------------------
	local streakBonus = resultTable["streak"]

	local healthBar = require 'gameLogic.healthBar'
	local healthBar = healthBar.new(streakBonus)
	healthBar:setHealth(healthBar:getMaxHealth(),healthBar:getMaxHealth())

	local manaBar = require 'gameLogic.manaBar'
	local manaBar = manaBar.new()
	manaBar:setMana(100,100)

	local potions = require 'gameLogic.potions'
	local potions = potions.new(healthBar, manaBar, soundEffect)

	local endGame = require 'gameLogic.endGame'
	local endGameScreen = endGame.new(soundEffect)

	local damage = require 'gameLogic.damage'
	local damage = damage.new(streakBonus)

	local coins = require 'gameLogic.coins'
	local coins = coins.new()

	local keys = require 'gameLogic.keys'
	local keys = keys.new()

	local monsters = require 'gameLogic.monsters'
	local monstersTable = monsters.new(healthBar, soundEffect)
	local monsters = monstersTable["screen"]
	local monstersTimers = monstersTable["timers"]

	pirateStatus = {
		["health"] = healthBar,
		["mana"] = manaBar,
		["keys"] = keys,
		["damage"] = damage,
		["coins"] = coins
	}
	local chests = require 'gameLogic.chests'
	local chests = chests.new(pirateStatus, soundEffect)

	local hostage = require 'gameLogic.hostage'
	local hostage = hostage.new(pirateStatus)

	local minimap = require 'gameLogic.minimap'
	local boss, gameTimer
	local stageInformation
	if mode == "story" then
		stageInformation = levelSetting.get(resultTable["storyLevel"])
	else
		boss      = {}
		gameTimer = 40
	end
	local minimapInit = minimap.new(5,140,_W-10,15, monsters, chests, hostage, stageInformation)
	local minimap = minimapInit["screen"]
	local minimapTimers = minimapInit["timers"]

	local background = require 'gameLogic.background'
	local gameBackground = background.new()

	local mainCharacter = require 'gameLogic.mainCharacter'
	local pirate = mainCharacter.new(damage, monsters, minimap, healthBar, soundEffect)
	local collisionRect = pirate:getCollisionRect()

	local ultimate = require 'gameLogic.ultimate'
	local ultimate = ultimate.new(manaBar, monsters, pirate, minimap)

	local topStatusBar = display.newImageRect("images/mainTopbar.png", display.contentWidth, 30)
	topStatusBar.anchorX, topStatusBar.anchorY = 0, 0
	topStatusBar.x = 0
	topStatusBar.y = 0

	local botBlackScreen = display.newRect( 0, 130, _W * 2, 47)
	botBlackScreen:setFillColor( 0/255, 0/255, 0/255 ) -- black, to hide the bottom part
	-----------------------------------------------------------

	----------------------SURVIVAL MODE------------------------
	-- add a timer for survival mode
	local survivalModeTimer
	if mode ~= "story" then
		minimap.alpha = 0
		local survivalTimer = require 'gameLogic.survivalTimer'
		survivalModeTimer = survivalTimer.new()
	end
	-----------------------------------------------------------

	----------------ARRANGE DISPLAY ORDERS---------------------
	screen:insert(topStatusBar)
	screen:insert(gameBackground)
	screen:insert(hostage)
	screen:insert(chests)
	screen:insert(ultimate)
	screen:insert(monsters)
	screen:insert(botBlackScreen)
	screen:insert(pirate)
	screen:insert(healthBar)
	screen:insert(manaBar)
	screen:insert(damage)
	screen:insert(keys)
	screen:insert(minimap)
	if mode ~= "story" then screen:insert(survivalModeTimer) end
	screen:insert(coins)
	screen:insert(resultTable["score"])
	screen:insert(resultTable["streak"])
	screen:insert(potions)
	screen:insert(endGameScreen)
	-----------------------------------------------------------

	-----------------COMBINE RESULT OBJECT---------------------
	resultTable["monsters"] = monsters
	resultTable["keys"] = keys
	resultTable["coins"] = coins
	if mode ~= "story" then resultTable["survival"] = survivalModeTimer end
	resultTable["mode"] = mode
	-----------------------------------------------------------

	---------------PERFORM UPDATES PER FRAME-------------------
	local pirateIsMoving = true
	local function update( event )
		
		ultimate:update()
		local isInBattle = monsters:updateMonsters(collisionRect.x, healthBar)
		local isRescuingHostage = hostage:updateHostage(collisionRect.x, pirateIsMoving)
		pirateIsMoving = pirate:update(isInBattle, isRescuingHostage)
		local shouldUpdateMovement = not isInBattle and not isRescuingHostage and pirateIsMoving
		updateMinimap(shouldUpdateMovement)
		chests:updateChests(collisionRect.x, shouldUpdateMovement)
		gameBackground:update(shouldUpdateMovement)

		if minimap:isGameOver() then
			screen:stop()
			endGameScreen:show(resultTable, "victory")
		elseif healthBar:isDead() then
			screen:stop()
			timer.performWithDelay(1500, function() endGameScreen:show(resultTable, "defeat") end)
		end
	end

	local monsterSpawnFreq = 5
	local hostageSpawnFreq = 40
	local chestSpawnFreq = 13
	local counter = 0
	local hp = 5
	local atkDmg = 6

	function updateSpawns()
		counter = counter + 1
		
		-- story mode updates
		if mode == "story" then
			-- do nothing

		-- survival mode updates
		else
			if (counter % 15) == 0 then 
				hp = math.min(hp + 5, 210)
			end

			if (counter % 15) == 0 then
				atkDmg = math.min(atkDmg + 2, 22)
			end

			if (counter % 120) == 0 then
				if monsterSpawnFreq ~= 2 then
					monsterSpawnFreq = math.min(monsterSpawnFreq-1, 2)
					hp = hp * 0.7
					atkDmg = atkDmg * 0.7
				end
			end

			if (counter % monsterSpawnFreq) == 0 then
				monsters:spawnMonster(0, hp, atkDmg, false, 380)
			end

			if (counter % hostageSpawnFreq) == 0 and not hostage:isExist() and math.random(0, 1) then
				hostage:spawnHostage()
			elseif (counter % chestSpawnFreq) == 0 and not chests:isExist() and math.random(0, 1) then
				chests:spawnChest()
			end
		end
	end

	function updateMinimap(shouldUpdate)
		if mode == "story" then
			if shouldUpdate then
				minimap:resume()
				minimap:update()
			else
				minimap:pause()
			end
		end
	end
	-----------------------------------------------------------

	--------------------START/STOP UPDATE----------------------
	function screen:start()
		if mode == "story" then
			minimap:start()
			ultimate:start()
			spawnTimerHandler = timer.performWithDelay(1000, updateSpawns, 0)
			eventsUpdateHandler = timer.performWithDelay(3, update, 0)
			damage:start()
		else
			survivalModeTimer:start()
			ultimate:start()
			spawnTimerHandler = timer.performWithDelay(1000, updateSpawns, 0)
			eventsUpdateHandler = timer.performWithDelay(3, update, 0)
			damage:start()
		end
		
	end

	function screen:stop()
		if mode == "story" then
			minimap:stop()
			ultimate:stop()
			timer.cancel(spawnTimerHandler)
			timer.cancel(eventsUpdateHandler)
			damage:stop()
		else
			survivalModeTimer:stop()
			ultimate:stop()
			timer.cancel(spawnTimerHandler)
			timer.cancel(eventsUpdateHandler)
			damage:stop()
		end
	end
	-----------------------------------------------------------
	table.insert(timers, nil)
	table.insert(timers, spawnTimerHandler)
	table.insert(timers, eventsUpdateHandler)
	table.insert(timers, monstersTimers[1])
	table.insert(timers, minimapTimers[1])
	table.insert(timers, minimapTimers[2])

	return {["timers"] = timers,
			["screen"] = screen}
end
