module(..., package.seeall)

local _H = display.contentHeight
local _W = display.contentWidth

function new(mode, storyLevel, soundEffect)
	local upperGameLayer = display.newGroup()			-- holds upper part of the game (runner game)
	local lowerGameLayer = display.newGroup()			-- holds lower part of the game (puzzle game)

	local lowerGameFrontLayer = display.newGroup() 		-- holds display objects at the front (flashing tiles)
	local lowerGameBackLayer = display.newGroup()		-- holds display objects at the back (normal tiles, explosion)

	local groupGameLayer = display.newGroup()			-- holds both upper and lower game layer

	------------ start implementation --------------
	local gemsTable = {}								-- where we store gems as a table
	local numberOfMarkedToDestroy = 0					-- also the number of selected tiles
	local gemToBeDestroyed  							-- used as a placeholder
	local isGemTouchEnabled = false 					-- used for freezing touch event
				
	local bomb 											-- holds information of bomb
				
	local currentSelectedGem							-- current selected gem information
	local currentColor									-- color that user is currently selected

	local timers = {}

	-- pre-declaration of functions
	local onGemTouch
	local shuffle
	local destroyGems
	local cleanUpGems
	local enableGemTouch
	local destroyBomb

	-- import a library with helper functions for the puzzle game
	local puzzleLogic = require 'gameLogic.puzzleLogic'

	-------------------- FLASHING TILES -----------------------
	local flashingTiles = require 'gameLogic.flashingTiles'
	local flashingTilesTable = flashingTiles.new()
	local flashingTiles = flashingTilesTable["screen"]
	local flashingTilesTimers = flashingTilesTable["timers"]
	-----------------------------------------------------------

	------------------- STREAK FUNCTIONS ----------------------
	local streak = require 'gameLogic.streak'
	local streakTable = streak.new()
	local streak = streakTable["screen"]
	local streakTimers = streakTable["timers"]
	-----------------------------------------------------------

	------------------- SCORE FUNCTIONS -----------------------
	local score = require 'gameLogic.score'
	local score = score.new()
	-----------------------------------------------------------

	------------------- BOMB ANIMATION ------------------------
	local bombAnimation = require 'gameLogic.bombAnimation'
	local bombAnimation = bombAnimation.new()
	-----------------------------------------------------------

	------------------- EXPLOSION EFFECT ----------------------
	local explosionEffect = require 'gameLogic.explosionEffect'
	local explosionEffect = explosionEffect.new()
	-----------------------------------------------------------

	--------------------BACKGROUND IMAGE-----------------------
	local gameBoardImage = display.newImage("images/gameboard.png")
	gameBoardImage.anchorX, gameBoardImage.anchorY = .5, 1
	gameBoardImage.x = display.contentCenterX
	gameBoardImage.y = display.contentHeight - 2
	lowerGameBackLayer:insert(gameBoardImage)
	-----------------------------------------------------------

	------------------ GEMS INITIALIZATION --------------------
	local gem = require 'gameLogic.gem'
	local function newGemCreate(i,j)
		local newGem = gem.newGem(i,j)
		transition.to( newGem, { time=100, y= newGem.destination_y} )
		newGem.touch = onGemTouch
		newGem:addEventListener( "touch", newGem )
		lowerGameBackLayer:insert(newGem)
		return newGem
	end

	local function newBombCreate(i,j,type)
		local newBomb = gem.newBomb(i,j,type)
		transition.to( newBomb, { time=300, alpha=1, xScale=1, yScale=1} )
		lowerGameBackLayer:insert(newBomb)
		return newBomb
	end
	-----------------------------------------------------------

	--------------- UPPER PART ( RUNNER GAME) -----------------
	local runner = require 'gameLogic.runner'
	local runnerGameTable = runner.new({["score"]=score, ["streak"]=streak, ["storyLevel"]=storyLevel}, mode, soundEffect)
	local runnerGame = runnerGameTable["screen"]
	local runnerGameTimers = runnerGameTable["timers"]
	local pirate_hp = runnerGame[9]
	local pirate_mp = runnerGame[10]
	local pirate_dmg = runnerGame[11]
	local pirate_keys = runnerGame[12]
	
	-----------------------------------------------------------

	-----------------------------------------------------------
	upperGameLayer:insert(runnerGame)
	lowerGameFrontLayer:insert(flashingTiles)
	lowerGameFrontLayer:insert(bombAnimation)
	lowerGameFrontLayer:insert(explosionEffect)
	-----------------------------------------------------------

	------------------- MAIN FUNCTIONS ------------------------
	local function shiftGems(bombType)
		for i = 1, 8, 1 do
			-- create a new gem and destroy old gem
			if gemsTable[i][1].isMarkedToDestroy then
				gemToBeDestroyed = gemsTable[i][1]
				gemsTable[i][1] = newGemCreate(i,1)
				gemToBeDestroyed:removeSelf()
				gemToBeDestroyed = nil
			end
		end

		for j = 2, 8, 1 do
		for i = 1, 8, 1 do
			if gemsTable[i][j].isMarkedToDestroy then
				gemToBeDestroyed = gemsTable[i][j]
				-- shiftin whole column down, starting from bottom
				for k = j, 2, -1 do
					-- gem on top is shifted downward by one
					gemsTable[i][k] = gemsTable[i][k-1]
					gemsTable[i][k].destination_y = gemsTable[i][k].destination_y +40
					transition.to( gemsTable[i][k], { time=100, y= gemsTable[i][k].destination_y} )
					gemsTable[i][k].j = gemsTable[i][k].j + 1
				end
				gemsTable[i][1] = newGemCreate(i,1)
				gemToBeDestroyed:removeSelf()
				gemToBeDestroyed = nil
			end
		end
		end

		if bombType == "cross" or bombType == "vertical" or bombType == "horizontal" or bombType == "area" then
			timer.performWithDelay(1000, destroyBomb)
		else
			if not puzzleLogic.findMatchedTiles(gemsTable) then
				shuffle()
			end
			enableGemTouch()
		end
	end

	destroyBomb = function()
		local function unlockDestroyBomb(i, j)
			return function()
			if i == j then
				shiftGems("none")
				numberOfMarkedToDestroy = 0
				bomb = nil
			end
			end
		end
		
		-- find explosion information
		local i = bomb.i
		local j = bomb.j
		local bombType = bomb.bombType
		local bombSet = {}
		local explosionInformation = puzzleLogic.findExplodedTiles(i, j, bombType, {["bombSet"] = bombSet,
																					["gemsTable"] = gemsTable})
		bombSet = explosionInformation["bombSet"]
		gemsTable = explosionInformation["gemsTable"]

		-- use explosion information to update relevant components(streaks, markings ...etc)
		numberOfMarkedToDestroy = #bombSet
		streak:updateStreak(numberOfMarkedToDestroy)
		puzzleLogic.updatePirateStatus(pirate_hp, pirate_mp, pirate_dmg, pirate_keys, bombSet)	

		-- explosion animation
		timer.performWithDelay(50, bombAnimation:play(gemsTable[bomb.i][bomb.j].x, gemsTable[bomb.i][bomb.j].y))
		local explosionImages = explosionEffect:explosionAnimation(bomb.i, bomb.j, bombType)
		lowerGameFrontLayer:insert(explosionImages)
		explosionImages:toBack()

		for k = 1, #bombSet, 1 do
			transition.to( bombSet[k], { time=200, alpha=0.2, xScale=2, yScale = 2, onComplete=unlockDestroyBomb(k, #bombSet) } )
		end
		soundEffect:play("bomb")
		score:addScore((#bombSet * 10))	
		bombSet = nil
	end

	destroyGems = function()
		local function unlockDestroyGems(i, boomType)
			return function()
			if (i+1) == numberOfMarkedToDestroy then
				shiftGems(boomType)
				numberOfMarkedToDestroy = 0
			end
			end
		end

		local function setupBomb(type)
			local i = currentSelectedGem.i
			local j = currentSelectedGem.j
			gemToBeDestroyed = gemsTable[i][j]
			-- create a new one
			gemsTable[i][j] = newBombCreate(i, j, type)
			gemsTable[i][j].isMarkedToDestroy = false
			numberOfMarkedToDestroy = numberOfMarkedToDestroy - 1
			bombType = type
			bomb = gemsTable[i][j]
			-- destroy old gem
			gemToBeDestroyed:removeSelf()
			gemToBeDestroyed = nil
		end

		if numberOfMarkedToDestroy >= 3 then
			soundEffect:play("explosion")
			streak:updateStreak()
			isGemTouchEnabled = false
			bombType = "none"

			if numberOfMarkedToDestroy >= 7 then
				setupBomb("cross")
			elseif numberOfMarkedToDestroy >= 6 then
				local R = math.random(1,2)
				if R == 1 then
					setupBomb("horizontal")
				else
					setupBomb("vertical")
				end
			elseif numberOfMarkedToDestroy >= 5 then
				setupBomb("area")
			end

			local colorsCount = {["red"] = 0,["green"] = 0,["blue"] = 0,["yellow"] = 0}
			-- delete selected tiles
			local countDestroyed = 0
			for i = 1, 8, 1 do
			for j = 1, 8, 1 do
				if gemsTable[i][j].isMarkedToDestroy then
					countDestroyed = countDestroyed + 1
					transition.to( gemsTable[i][j], { time=200, alpha=0.2, xScale=2, yScale = 2, onComplete=unlockDestroyGems(countDestroyed, bombType) } )

					-- update score
					score:addScore(10)

					-- update other stats
					if currentColor == "blue" then
						colorsCount["blue"] = colorsCount["blue"] + 1
					elseif currentColor == "green" then
						colorsCount["green"] = colorsCount["green"] + 1
					elseif currentColor == "red" then
						colorsCount["red"] = colorsCount["red"] + 1
					elseif currentColor == "yellow" then
						colorsCount["yellow"] = colorsCount["yellow"] + 1
					end
				end
			end
			end
			puzzleLogic.updatePirateStatusWithCalculatedTable(pirate_hp, pirate_mp, pirate_dmg, pirate_keys, colorsCount)	
		end

		-- stop flashing
		flashingTiles:deleteAll()
	end
	-----------------------------------------------------------

	------------------- HELPER FUNCTIONS ----------------------
	enableGemTouch = function()
		isGemTouchEnabled = true
	end

	cleanUpGems = function()
		numberOfMarkedToDestroy = 0
		flashingTiles:deleteAll()
		for i = 1, 8, 1 do
			for j = 1, 8, 1 do
				gemsTable[i][j].isMarkedToDestroy = false
			end
		end
	end

	shuffle = function()
		local gemsTableToBeDestroyed = {}

		local function removeGemsTable()
			for i = 1, 8, 1 do
				for j = 1, 8, 1 do
					gemToBeDestroyed = gemsTableToBeDestroyed[i][j]
					gemToBeDestroyed:removeSelf()
					gemToBeDestroyed = nil
				end
			end
		end

		local function 	unlockShuffle(i,j)
			return function()
			if i == 8 and j == 1 then
				isGemTouchEnabled = true
				removeGemsTable()
			end
			end
		end

		isGemTouchEnabled = false
		local newGemsTable = {}
		for i = 1, 8, 1 do
			newGemsTable[i] = {}
			for j = 1, 8, 1 do
				newGemsTable[i][j] = newGemCreate(i,j)
			end
		end
		for i = 1, 8, 1 do
			gemsTableToBeDestroyed[i] = {}
			for j = 8, 1, -1 do
				transition.to ( gemsTable[i][j], {time = 800, y = _H + 2000})
				gemsTableToBeDestroyed[i][j] = gemsTable[i][j]
			end
		end
		for i = 1, 8, 1 do
			for j = 8, 1, -1 do
				gemsTable[i][j] = newGemsTable[i][j]
				gemsTable[i][j].y = -1500
				transition.to( gemsTable[i][j], { time=825, y= gemsTable[i][j].destination_y, onComplete=unlockShuffle(i,j)} )
			end
		end
	end
	-----------------------------------------------------------

	------------------- EVENT LISTENERS -----------------------
	local function actionsToSelectedTiles()
		if numberOfMarkedToDestroy >= 3 then
			destroyGems()
		else
			cleanUpGems()
		end
	end

	function onEdgeTouch( event )
		if isGemTouchEnabled then
			if event.phase == "ended" or event.phase == "cancelled" then
				actionsToSelectedTiles()
			end
		end
		return true
	end

	function onGemTouch( self, event )	-- was pre-declared
		local function changePuzzleSelectionState()
			self.isMarkedToDestroy = true
			flashingTiles:createTile(event.target.i, event.target.j)
			numberOfMarkedToDestroy = numberOfMarkedToDestroy + 1
			soundEffect:play("swaptiles")
			currentSelectedGem = self
		end
		
		if isGemTouchEnabled then

			if event.phase == "began" then
				cleanUpGems()
				currentColor = self.gemType
				changePuzzleSelectionState()

			elseif event.phase == "moved" then
				if currentSelectedGem == nil and (self.class == "gem" or self.class == "bomb") then
					cleanUpGems()
					currentColor = self.gemType
					changePuzzleSelectionState()
				elseif self ~= currentSelectedGem and currentColor == "rainbow" and not self.isMarkedToDestroy and puzzleLogic.isAdjacent(self, currentSelectedGem) then
					currentColor = self.gemType
					changePuzzleSelectionState()
				elseif self ~= currentSelectedGem then
					if (self.gemType == currentColor or self.gemType == "rainbow") and not self.isMarkedToDestroy and puzzleLogic.isAdjacent(self, currentSelectedGem) then
						changePuzzleSelectionState()
					else
						actionsToSelectedTiles()
					end
				end

			elseif event.phase == "ended" or event.phase == "cancelled" then
				actionsToSelectedTiles()
			end
		end
		return true
	end

	-----------------------------------------------------------

    -- initialize gems
    for i = 1, 8, 1 do
    	gemsTable[i] = {}
		for j = 1, 8, 1 do
			gemsTable[i][j] = newGemCreate(i,j)
 		end
 	end

	lowerGameLayer:insert(lowerGameBackLayer)
	lowerGameLayer:insert(lowerGameFrontLayer)
	groupGameLayer:insert(lowerGameLayer)
	groupGameLayer:insert(upperGameLayer)

	table.insert(timers, runnerGameTimers[1])
	table.insert(timers, runnerGameTimers[2])
	table.insert(timers, runnerGameTimers[3])
	table.insert(timers, runnerGameTimers[4])
	table.insert(timers, runnerGameTimers[5])
	table.insert(timers, flashingTilesTimers[1])
	table.insert(timers, streakTimers[1])

	function groupGameLayer:start()
		isGemTouchEnabled = true
		Runtime:addEventListener("touch", onEdgeTouch)
		runnerGame:start()
	end

	function groupGameLayer:stop()
		isGemTouchEnabled = false
		Runtime:removeEventListener("touch", onEdgeTouch)
		runnerGame:stop()
	end

	-------------------- end -----------------------

	return {["timers"] = timers,
			["screen"] = groupGameLayer} 

end
