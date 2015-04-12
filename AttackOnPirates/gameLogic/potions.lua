module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'

function new(health, mana, soundEffect)
	local group = display.newGroup()
	local imageGroup = display.newGroup()
	local textGroup = display.newGroup()
	local menuIsOpened = false

	local potionsBox = display.newImageRect("images/mainStackbar.png", 60, 30)
	potionsBox.anchorX, potionsBox.anchorY = 0, 0
	potionsBox.x = display.contentWidth - 70
	potionsBox.y = 1
	group:insert(potionsBox)
	imageGroup:insert(potionsBox)

	local selectItemImage
	local currentSelectedItem
	local lastSelectedItem
	local imageSize = 60
	local potionsMenu = display.newGroup()
	local potionsTable = {
		{"images/buttons/buttonMana.png", 190, 30, 100, "mana"},
		{"images/buttons/buttonPotion.png", 250, 30, 50, "health1"},
		{"images/buttons/buttonSpotion.png", 190, 90, 100, "health2"},
		{"images/buttons/buttonEpotion.png", 250, 90, 200, "health3"},
		{"images/buttons/buttonUpotion.png", 250, 150, 100, "health4"},
	}

	local function getNumbersOfPotions()
		local redPot1, redPot2, redPot3, redPot4, bluePot
		redPot1 = localStorage.get("redPot1")
		redPot2 = localStorage.get("redPot2")
		redPot3 = localStorage.get("redPot3")
		redPot4 = localStorage.get("redPot4")
		bluePot = localStorage.get("bluePot")
		return {bluePot, redPot1, redPot2, redPot3, redPot4}
	end

	local function drawPotionsTable()
		for i = 1, #potionsTable, 1 do
			local potionImage = display.newImageRect(potionsTable[i][1], imageSize, imageSize)
			potionImage.anchorX, potionImage.anchorY = 0, 0
			potionImage.x = potionsTable[i][2]
			potionImage.y = potionsTable[i][3]
			imageGroup:insert(potionImage)
			potionImage.isVisible = false
		end
	end

	local function drawNumberTextOnPotionsTable(t)
		for i=1, #potionsTable, 1 do
			local numberOfPotions = display.newText(t[i], potionsTable[i][2]+44, potionsTable[i][3]+36, "Impact", 10)
			textGroup:insert(numberOfPotions)
		end
		textGroup.isVisible = false
	end

	local function checkTouchPosition(x,y)
		if selectItemImage and textGroup and imageGroup then
			for i=1, #potionsTable, 1 do
				if x >= potionsTable[i][2] and x < potionsTable[i][2]+imageSize and y >= potionsTable[i][3] and y < potionsTable[i][3]+imageSize then
					selectItemImage.isVisible = true
					selectItemImage.x = potionsTable[i][2]
					selectItemImage.y = potionsTable[i][3]
					currentSelectedItem = i

					if lastSelectedItem == nil or (currentSelectedItem ~= lastSelectedItem) then
						lastSelectedItem = currentSelectedItem
						soundEffect:play("choose")
					end

					break
				end
			end
		end
	end

	local function showPotionsTable()
		for i=1, imageGroup.numChildren, 1 do
			imageGroup[i].isVisible = true
			menuIsOpened = true

			if selectItemImage then
				selectItemImage:removeSelf()
				selectItemImage = nil
			end
			selectItemImage = display.newImageRect("images/mainSelectitem.png", 60, 60)
			selectItemImage.anchorX, selectItemImage.anchorY = 0, 0
			selectItemImage.isVisible = false
		end
		textGroup.isVisible = true
	end

	local function hidePotionsTable()
		for i=2, imageGroup.numChildren, 1 do
			imageGroup[i].isVisible = false
			menuIsOpened = false

			if selectItemImage then
				selectItemImage:removeSelf()
				selectItemImage = nil
			end
			currentSelectedItem = nil
			lastSelectedItem = nil
		end
		textGroup.isVisible = false
	end

	local hidePotionsTableTimer

	local function refreshTimer()
		if hidePotionsTableTimer then
			timer.cancel(hidePotionsTableTimer)
		end
		hidePotionsTableTimer = timer.performWithDelay(1000, function() hidePotionsTable() end)
	end

	local function restore(i)
		local restoreType, restoreAmount

		if i and not health:isDead() then
			restoreType = potionsTable[i][5]
			restoreAmount = potionsTable[i][4]

			if restoreType == "mana" then
				local currentBluePot = localStorage.get("bluePot") - 1
				if currentBluePot >= 0 then
					mana:addMpBy(restoreAmount)
					localStorage.saveWithKey("bluePot", currentBluePot)
					textGroup[1].text = currentBluePot
					soundEffect:play("useitem")
				end

			elseif restoreType == "health1" then
				local currentRedPot1 = localStorage.get("redPot1") - 1
				if currentRedPot1 >= 0 then
					health:addHpBy(restoreAmount, restoreType)
					localStorage.saveWithKey("redPot1", currentRedPot1)
					textGroup[2].text = currentRedPot1
					soundEffect:play("useitem")
				end

			elseif restoreType == "health2" then
				local currentRedPot2 = localStorage.get("redPot2") - 1
				if currentRedPot2 >= 0 then
					health:addHpBy(restoreAmount, restoreType)
					localStorage.saveWithKey("redPot2", currentRedPot2)
					textGroup[3].text = currentRedPot2
					soundEffect:play("useitem")
				end

			elseif restoreType == "health3" then
				local currentRedPot3 = localStorage.get("redPot3") - 1
				if currentRedPot3 >= 0 then
					health:addHpBy(restoreAmount, restoreType)
					localStorage.saveWithKey("redPot3", currentRedPot3)
					textGroup[4].text = currentRedPot3
					soundEffect:play("useitem")
				end

			elseif restoreType == "health4" then
				local currentRedPot4 = localStorage.get("redPot4") - 1
				if currentRedPot4 >= 0 then
					health:addHpBy(health:getMaxHealth(), restoreType)
					localStorage.saveWithKey("redpot4", currentRedPot4)
					textGroup[5].text = currentRedPot4
					soundEffect:play("useitem")
				end
			end
		end
	end

	local function selectPotionsListener(event)
		checkTouchPosition(event.x, event.y)
		if event.phase == "began" then
			showPotionsTable()
			refreshTimer()
		elseif event.phase == "moved" then
			refreshTimer()
		elseif event.phase == "cancelled" then
			hidePotionsTable()
		elseif event.phase == "ended" and menuIsOpened then
			restore(currentSelectedItem)
			hidePotionsTable()
		end
	end

	local inBagPotionsNumber = getNumbersOfPotions()
	drawPotionsTable()
	drawNumberTextOnPotionsTable(inBagPotionsNumber)
	imageGroup:addEventListener("touch", selectPotionsListener)
	group:insert(imageGroup)
	group:insert(textGroup)

	return group
end
