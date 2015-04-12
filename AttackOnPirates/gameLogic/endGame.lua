module(..., package.seeall)

local _W = display.contentWidth
local _H = display.contentHeight

local widget = require 'widget'
local storyboard = require( "storyboard" )
local customText = require 'gameLogic.customText'
local scoreDictionary = {}

function new(soundEffect)
	local group = display.newGroup()

	local function hiddenScreenTouchListener(event)
		return true
	end

	local hiddenScreen = display.newRect(0,0, _W*2, _H*2)
	hiddenScreen:setFillColor(0/255, 0/255, 0/255)
	hiddenScreen.anchorX, hiddenScreen.anchorY = .5, .5
	hiddenScreen.x = display.contentCenterX
	hiddenScreen.y = display.contentCenterY
	hiddenScreen.alpha = 0.4
	hiddenScreen:addEventListener("touch", hiddenScreenTouchListener)
	group:insert(hiddenScreen)

	local backgroundScreen = display.newRoundedRect(0, 0, _W*2, 380, 5)
	backgroundScreen.anchorX, backgroundScreen.anchorY = .5, .5
	backgroundScreen.x = display.contentCenterX
	backgroundScreen.y = display.contentCenterY + 55
	backgroundScreen:setFillColor(0/255, 0/255, 0/255)
	backgroundScreen.alpha = 0.65
	backgroundScreen:addEventListener("touch", hiddenScreenTouchListener)
	group:insert(backgroundScreen)

	group.alpha = 0

	local victoryTable = {"V", "I", "C", "T", "O", "R", "Y", "!"}
	local defeatTable = {"D", "E", "F", "E", "A", "T", "!"}
	local delay = 200

	local function moveToNextScreen(i, j)
		return function()
			soundEffect:play("endgame")
			if i == j then
				local options = {effect="fade", time=800, params={result=scoreDictionary}}
				timer.performWithDelay(4000, function() storyboard.gotoScene("result-scene", options) end)
			end
		end
	end

	local function printVictoryText()
		local isAndroid = system.getInfo("platformName") == "Android"	
		if isAndroid then
			desiredFont = "Arial-Black"
		else
			desiredFont = "Arial Rounded MT Bold"
		end
		for i = 1, #victoryTable, 1 do
			local endGameText = customText.new(victoryTable[i], 0, 0, desiredFont, 40, 255, 255, 102)
			endGameText.anchorX, endGameText.anchorY = .5, .5
			endGameText.xPosn = 35*i + 5
			endGameText.yPosn = 65
			endGameText.alpha = 0
			group:insert(endGameText)

			endGameText.xScale = 10
			endGameText.yScale = 10
			endGameText.x = display.contentCenterX
			endGameText.y = display.contentCenterY
			transition.to(endGameText, {time=delay, alpha=1, delay=(i-1)*delay, xScale=1, yScale=1, x=endGameText.xPosn, y=endGameText.yPosn, onComplete=moveToNextScreen(i, #victoryTable)})
		end
	end

	local function printDefeatText()
		local isAndroid = system.getInfo("platformName") == "Android"	
		if isAndroid then
			desiredFont = "Arial-Black"
		else
			desiredFont = "Arial Rounded MT Bold"
		end
		for i = 1, #defeatTable, 1 do
			local endGameText = customText.new(defeatTable[i], 0, 0, desiredFont, 40, 255, 255, 102)
			endGameText.anchorX, endGameText.anchorY = .5, .5
			endGameText.xPosn = 35*i + 25
			endGameText.yPosn = 65
			endGameText.alpha = 0
			group:insert(endGameText)

			endGameText.xScale = 10
			endGameText.yScale = 10
			endGameText.x = display.contentCenterX
			endGameText.y = display.contentCenterY
			transition.to(endGameText, {time=delay, alpha=1, delay=(i-1)*delay, xScale=1, yScale=1, x=endGameText.xPosn, y=endGameText.yPosn, onComplete=moveToNextScreen(i, #defeatTable)})
		end
	end

	function group:show(resultTable, result)
		local mode = resultTable["mode"]
		scoreDictionary["score"] = resultTable["score"]:getScore()
		scoreDictionary["streak"] = resultTable["streak"]:getHighestStreak()
		scoreDictionary["monsters"] = resultTable["monsters"]:getNumberOfMonstersKilled()
		scoreDictionary["keys"] = resultTable["keys"]:getKeys()
		scoreDictionary["coins"] = resultTable["coins"]:getCoins()
		scoreDictionary["mode"] = mode
		scoreDictionary["storyLevel"] = resultTable["storyLevel"]
		if mode ~= "story" then scoreDictionary["survival"] = resultTable["survival"]:getTime() end

		if result == "victory" then
			scoreDictionary["result"] = "victory"
			group.alpha = 1
			timer.performWithDelay(1000, printVictoryText)

		elseif result == "defeat" then
			scoreDictionary["result"] = "defeat"
			group.alpha = 1
			timer.performWithDelay(1000, printDefeatText)
		end
	end

	return group
end
