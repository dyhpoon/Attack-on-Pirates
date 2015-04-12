module(..., package.seeall)

function new(x,y,w,h,monsters,chests,hostages,stageInformation)
	local group = display.newGroup()
	local timers = {}
	local gameTime

	if stageInformation then
		gameTime = stageInformation["time"]
	else
		gameTime = 40
	end

	group.timer = gameTime 					-- game length
	local pause = false						-- holder of whether the minimap is being paused
	local inBossFight = false				-- holder of whether the main character is in a boss fight
	local deadIdCount = 1 					-- keep track of dead bosses
	local timerRef, minimapRef 				-- placeholders (time and transition)
	local gameIsOver = false
	local boss

	-- grey bar (background)
	local greyBar = display.newRoundedRect(x, y, w, h, 4)
	greyBar.anchorX, greyBar.anchorY = 0, 0
	group:insert(greyBar)
	greyBar:setFillColor(102/255, 102/255, 102/255)

	-- initializing
	local function initMinimap()

		if stageInformation then
			local bossInfo = stageInformation["boss"]

			if bossInfo and #bossInfo == 4 then
				xPosition = ((w - w/30)/gameTime * bossInfo[4]) + w/30
				--boss = display.newCircle(xPosition, greyBar.y, 5)
				boss = display.newImage("images/mainBossicon.png")
				boss.anchorX, boss.anchorY = 0, 0
				boss.x = xPosition + 12
				boss.y = greyBar.y
				boss.health = bossInfo[2]
				boss.damage = bossInfo[3]
				boss.id = bossInfo[1]
				boss.isSpawned = false
				boss:setFillColor(255/255,255/255,0/255)
				group:insert(boss)
			end
		end
	end
	initMinimap()


	-- main character icon
	local mainCharacter = display.newImage("images/mainCharicon.png")
	mainCharacter.anchorX, mainCharacter.anchorY = 0, 0
	mainCharacter.x = w/30
	mainCharacter.y = greyBar.y
	group:insert(mainCharacter)

	-- collision rectangle (for detecting bosses)
	local collisionRect = display.newRect(mainCharacter.x+15, mainCharacter.y-3, 3, 8)
	collisionRect.alpha = 0
	group:insert(collisionRect)
	local function updateCollisionRect(event)
		collisionRect.x = mainCharacter.x + 5
	end
	local collisionRectUpdateHandler = timer.performWithDelay(1, updateCollisionRect, 0)

	-- update monsters spawn
	local enemiesSpawn, chestsSpawn, hostagesSpawn
	if stageInformation then
		enemiesSpawn = stageInformation["monsters"]
		chestsSpawn = stageInformation["chests"]
		hostagesSpawn = stageInformation["hostages"]
	end
	local function timerListener(event)
		group.timer = group.timer - 1
		local counter = gameTime - group.timer

		for i=1, #enemiesSpawn, 1 do
			if enemiesSpawn[i][4] == counter then
				monsters:spawnMonster(enemiesSpawn[i][1], enemiesSpawn[i][2], enemiesSpawn[i][3], false, enemiesSpawn[i][5])
			end
		end

		for i=1, #chestsSpawn, 1 do
			if chestsSpawn[i] == counter then
				chests:spawnChest()
			end
		end

		for i=1, #hostagesSpawn, 1 do
			if hostagesSpawn[i] == counter and not hostages:isExist() then
				hostages:spawnHostage()
			end
		end

		if group.timer < 0 then
			gameIsOver = true
		end
	end
	
--------------------  helper methods -------------------------------
	function group:isPause()
		return pause
	end

	function group:isGameOver()
		return gameIsOver
	end

	function group:start()
		timerRef = timer.performWithDelay(1000, timerListener, 0)
		minimapRef = transition.to(mainCharacter, {time=group.timer*1000, x=w})
	end

	function group:stop()
		timer.cancel(timerRef)
		transition.cancel(minimapRef)
	end

	-- pause the minimap when main character is busy (fighting monsters, rescuing hostages, opening chest .. etc)
	function group:pause()
		if inBossFight and not pause then
			pause = true
			timer.pause(timerRef)
			transition.cancel(minimapRef)
		end
		
		if not pause then
			pause = true
			timer.pause(timerRef)
			transition.cancel(minimapRef)
		end
	end

	-- resume if minimap is paused
	function group:resume()
		if inBossFight then return end
		if pause then
			pause = false
			timer.resume(timerRef)
			minimapRef = transition.to(mainCharacter, {time=group.timer*1000, x=w})
		end
	end

	-- delete a dot (boss) if it is eliminated
	function group:deleteADot()
		inBossFight = false
		boss:removeSelf()
		boss = nil
	end

	-- update is called on every frame update
	function group:update()
		if boss then
			if boss.x <= collisionRect.x + 5 then
				--group:pause()
				inBossFight = true
				group:pause()
				if not boss.isSpawned then
					boss.isSpawned = true
					monsters:spawnMonster(boss.id, boss.health, boss.damage, true, 380)
				end
			end
		end
	end

	table.insert(timers, collisionRectUpdateHandler)
	table.insert(timers, timerRef)

	return {["timers"] = timers,
			["screen"] = group}
			
end
