module(..., package.seeall)

local monsterHealthBar = require 'gameLogic.monsterHealthBar'

monstersInfo = {
	-- {imagesPath, sheetWidth, sheetHeight, #frames, width, height, runStart, runCount, atkStart, atkCount, yOffset, xOffset, HPyOffset, r, g, b}
	{"images/enemies/enemyChest.png", 		256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},		--1
	{"images/enemies/enemyEnergyball.png", 	256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},		--2
	{"images/enemies/enemyFrog.png", 		256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},				--3
	{"images/enemies/enemyFrog2.png", 		256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--4
	{"images/enemies/enemyFrog3.png", 		256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--5
	{"images/enemies/enemyFrog4.png", 		256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--6
	{"images/enemies/enemyFrog5.png", 		256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--7
	{"images/enemies/enemyFrog6.png", 		256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--8
	{"images/enemies/enemyFrog7.png", 		256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--9
	{"images/enemies/enemyFrog8.png", 		256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--10
	{"images/enemies/enemyKingFrog.png", 	512, 512, 8, 160, 160, 5, 4, 1, 4, 40, 10, 50, 255, 255, 255,},		--11
	{"images/enemies/enemyKingoctopus.png", 1024, 512, 12, 160, 160, 9, 4, 1, 8, 42, 0, 80, 255, 255, 255,},--12
	{"images/enemies/enemyOctopus.png", 	256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--13
	{"images/enemies/enemyOctopus2.png", 	256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--14
	{"images/enemies/enemyOctopus3.png", 	256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--15
	{"images/enemies/enemyOctopus4.png", 	256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--16
	{"images/enemies/enemySkeleton.png", 	256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 255, 255, 255,},			--17
	{"images/enemies/enemyWerewolf.png", 	512, 512, 8, 160, 160, 5, 4, 1, 4, 38, 15, 40, 255, 255, 255,},		--18
	{"images/enemies/enemyWerewolf2.png", 	512, 512, 8, 160, 160, 5, 4, 1, 4, 38, 15, 50, 255, 255, 255,},	--19
	{"images/enemies/enemyZombie.png", 		512, 128, 6, 80, 80, 4, 3, 1, 3, 0, 0, 0, 255, 255, 255,},			--20

	{"images/enemies/enemyChest.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--21
	{"images/enemies/enemyEnergyball.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},		--22
	{"images/enemies/enemyFrog.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},				--23
	{"images/enemies/enemyFrog2.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--24
	{"images/enemies/enemyFrog3.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--25
	{"images/enemies/enemyFrog4.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--26
	{"images/enemies/enemyFrog5.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--27
	{"images/enemies/enemyFrog6.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--28
	{"images/enemies/enemyFrog7.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--29
	{"images/enemies/enemyFrog8.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--30
	{"images/enemies/enemyKingFrog.png", 512, 512, 8, 160, 160, 5, 4, 1, 4, 40, 10, 50, 80, 80, 80,},		--31
	{"images/enemies/enemyKingoctopus.png", 1024, 512, 12, 160, 160, 9, 4, 1, 8, 42, 0, 80, 80, 80, 80,},--32
	{"images/enemies/enemyOctopus.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--33
	{"images/enemies/enemyOctopus2.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--34
	{"images/enemies/enemyOctopus3.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--35
	{"images/enemies/enemyOctopus4.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--36
	{"images/enemies/enemySkeleton.png", 256, 256, 8, 80, 80, 5, 4, 1, 4, 0, 0, 0, 80, 80, 80,},			--37
	{"images/enemies/enemyWerewolf.png", 512, 512, 8, 160, 160, 5, 4, 1, 4, 38, 15, 40, 80, 80, 80,},		--38
	{"images/enemies/enemyWerewolf2.png", 512, 512, 8, 160, 160, 5, 4, 1, 4, 38, 15, 50, 80, 80, 80,},	--39
	{"images/enemies/enemyZombie.png", 512, 128, 6, 80, 80, 4, 3, 1, 3, 0, 0, 0, 80, 80, 80,},			--40
}

function new(pirateHealth, soundEffect)
	local timers = {}
	local group = display.newGroup()
	local monsterId = 1
	local M = {}
	local threshold = 1
	local numberOfMonsterKilled = 0

	function group:getNumberOfMonstersKilled()
		return numberOfMonsterKilled
	end

	-- create a monster
	local function monsterSpriteListener(event)
		local targetMonster = event.target
		if targetMonster.sequence == "attacking" and targetMonster.frame == 3 then
			soundEffect:play("enemyattack")
			local currentHealth = pirateHealth:getHealth()
			pirateHealth:minusHpBy(event.target.damage)
		end
		if targetMonster.sequence == "attacking" and event.phase == "ended" then
			targetMonster:setSequence("attacking")
			targetMonster:play()
		end
	end

	function group:spawnMonster(id,health,damage,isBoss,xPosn)
		-- initialize the monster's sprite sheet
		if id == 0 then
			id = math.random(1, #monstersInfo)
		end
		local imagePath = monstersInfo[id][1]

		local options = {
			width = monstersInfo[id][5],
			height = monstersInfo[id][6],
			numFrames = monstersInfo[id][4],
			sheetContentWidth = monstersInfo[id][2],
			sheetContentHeight = monstersInfo[id][3]
		}
		local sequenceData = {
			{name="running", start=monstersInfo[id][7], count=monstersInfo[id][8], time=500, loopCount=0},
			{name="attacking", start=monstersInfo[id][9], count=monstersInfo[id][10], time=2000, loopCount=1},		
		}
		local imageSheet = graphics.newImageSheet(imagePath, options)

		-- configure monster's status/look
		local monster = display.newSprite(imageSheet, sequenceData)
		monster:setSequence("running")
		monster:play()
		monster.x = xPosn
		monster.y = 65 - monstersInfo[id][11]
		monster.xScale = 0.5
		monster.yScale = 0.5
		monster.alpha = 1
		monster.id = monsterId
		monster.isAttacking = false
		monster.maxHealth = health
		monster.currentHealth = health
		monster.damage = damage
		monster.atkFrame = monstersInfo[id][10]
		monster.boss = isBoss
		monster.xOffset = monstersInfo[id][12]
		monster.health = monsterHealthBar.new(monster.x - 390,monster.y - 50)
		monster.anchorX =.5
		monster.health.x = monster.x
		monster.anchorY = 0
		monster.health.y = monster.y - 25 + monstersInfo[id][13]
		monster.isInBattle = false
		monster.id = id
		monster:addEventListener("sprite", monsterSpriteListener)
		monster:setFillColor(monstersInfo[id][14]/255, monstersInfo[id][15]/255, monstersInfo[id][16]/255)

		group:insert(monster)
		group:insert(monster.health)
		monsterId = monsterId + 1
		table.insert(M, monster)
	end

	-- update is called on every frame update (to keep track of monsters' status ex. hp, damage dealt to main character ... etc)
	function group:updateMonsters(collisionRectX)
		collisionRectX = collisionRectX + 15
		local isInBattle = false
		for i,monster in ipairs(M) do
			if monster.x < -40 then
				--monster.x = 380
				-- should be deleted
			elseif (monster.x - monster.xOffset) <= collisionRectX and not monster.isAttacking then
				isInBattle = true
				monster.isAttacking = true
				monster.isInBattle = true
				monster:setSequence("attacking")
				monster:play()
			elseif (monster.x - monster.xOffset) <= collisionRectX then
				isInBattle = true
			elseif collisionRectX < (monster.x - monster.xOffset) then
				monster.x = monster.x - 1
				monster.health.x = monster.health.x - 1
			end
		end


		return isInBattle
	end

	-- this is called when main character dealt damage to monsters
	function group:killMonster(damage, usingUltimate, minimap)

		-- event handler when monster is dead (memory clearing)
		local function deleteMonster(monster)
			return function()
			--monster.health:removeSelf()
			display.remove(monster.health)
			monster.health = nil
			--monster:removeSelf()
			display.remove(monster)
			monster = nil
			numberOfMonsterKilled = numberOfMonsterKilled + 1
			end
		end

		-- start checking if monsters are still alive (deduct hit points), or dead (handle dead monsters)
		local deadMonster = {}
		local numberOfDeads = 0
		for i, monster in ipairs(M) do
			if monster.isInBattle then
				monster.currentHealth = monster.currentHealth - damage
				monster.health:setHealth(monster.currentHealth, monster.maxHealth)
				if monster.currentHealth <= 0 then
					numberOfDeads = numberOfDeads + 1
					monster.health.alpha = 0
					if monster.id > 0 then
						table.insert(deadMonster, monster)
					end
				end
			end
		end

		-- if monsters are dead, animate some dead effect (ex. flashing, spinning)
		for j = 1, numberOfDeads, 1 do
			for i, monster in ipairs(M) do
				if monster.currentHealth <= 0 then
					if usingUltimate then
						transition.to(monster, {time = 500, xScale = 1.0, yScale = 1, rotation = math.random(500), alpha = 0.01, x = monster.x+math.random(20, 70), y = monster.y - 50, onComplete = deleteMonster(monster)})
					else
						transition.to(monster, {time = 500, xScale = 1.0, yScale = 1, rotation = math.random(500), alpha = 0.01, x = monster.x+math.random(20, 70), y = monster.y - 50, onComplete = deleteMonster(monster)})
					end
					table.remove(M, i)
					break
				end
			end
		end
		
		for i=1, #deadMonster, 1 do
			if deadMonster[i].boss then
				minimap:deleteADot()
			end
		end

	end

	table.insert(timers, updateHandler)
	
	return {["timers"] = timers,
			["screen"] = group}
end
