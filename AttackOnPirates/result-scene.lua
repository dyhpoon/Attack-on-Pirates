--[[

The end game result

--]]


------------------------------FORWARD REF------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local resultSoundEffect = require 'gameLogic.resultSoundEffect'
local localStorage = require 'gameLogic.localStorage'
local experience = require 'gameLogic.experience'
local energy = require 'gameLogic.energy'
local gameCoins = require 'gameLogic.gameCoins'
local gameDiamonds = require 'gameLogic.gameDiamonds'
local widget = require 'widget'

local _W = display.contentWidth
local _H = display.contentHeight
local coinsNumText, monstersNumText, keysNumText, scoreNumText
local scoreTimer
local sequence
local table
local scoreTable
local experienceBar
local nextButton
local energyTable
local endGameText
local highScoreText
local soundEffect

local monsterTextX = 215
local monsterTextY = 161
local coinsTextX   = 215
local coinsTextY   = 190
local keysTextX    = 215
local keysTextY    = 218
local scoreTextX   = 215
local scoreTextY   = 254
---------------------------------------------------------------------------------

-------------------------------HELPER FUNCTIONS----------------------------------

-- draw UI
local function showNextButton() 
    transition.to(nextButton, {time=1000, alpha=1})
    transition.to(highScoreText, {time=1000, alpha=1, xScale=2, yScale=2})
    transition.to(highScoreText, {time=1000, delay=1000, alpha=1, xScale=1.3, yScale=1.3})
    soundEffect:play("rollingscore")

    if scoreTable["result"] == "victory" then
        soundEffect:play("stageclear")
    else
        soundEffect:play("stagefail")
    end
    transition.to(endGameText, {time = 300, xScale=1.3, yScale=1.3, alpha=1})
    transition.to(endGameText, {time = 300, delay=300, xScale=1, yScale=1})
end

local function increasePiratesExp()
    if scoreTable["mode"] == "story" and scoreTable["result"] == "victory" then
        local currentLevel = localStorage.get("storyLevel")
        local experienceGot = experience.expGainFromLevel(currentLevel)
        experienceBar:increaseExpBy(experienceGot)
    end
end

local function scoreAnimation(id)
    return function()
        if id == "monsters" then
            monstersNumText.text = table[id]
            monstersNumText:setReferencePoint(display.CenterRightReferencePoint)
            monstersNumText.x = monsterTextX
            monstersNumText.y = monsterTextY
            if table[id] >= scoreTable[id] then
                timer.cancel(scoreTimer)
                scoreTimer = timer.performWithDelay(1, scoreAnimation(sequence[2]), 0)
                soundEffect:play("rollingscore")
                transition.to(coinsNumText, {time=130, y=coinsNumText.y-10, alpha=1})
                transition.to(coinsNumText, {time=130, delay=130, y=coinsNumText.y, alpha=1})
            end
            table[id] = table[id] + math.max(1, math.min(scoreTable[id]-table[id], math.floor(scoreTable[id]/61)))

        elseif id == "coins" then
            coinsNumText.text = table[id]
            coinsNumText:setReferencePoint(display.CenterRightReferencePoint)
            coinsNumText.x = coinsTextX
            coinsNumText.y = coinsTextY
            if table[id] >= scoreTable[id] then
                timer.cancel(scoreTimer)
                scoreTimer = timer.performWithDelay(1, scoreAnimation(sequence[3]), 0)
                soundEffect:play("rollingscore")
                transition.to(keysNumText, {time=130, y=keysNumText.y-10, alpha=1})
                transition.to(keysNumText, {time=130, delay=130, y=keysNumText.y, alpha=1})
            end
            table[id] = table[id] + math.max(1, math.min(scoreTable[id]-table[id], math.floor(scoreTable[id]/61)))

        elseif id == "keys" then
            keysNumText.text = table[id]
            keysNumText:setReferencePoint(display.CenterRightReferencePoint)
            keysNumText.x = keysTextX
            keysNumText.y = keysTextY
            if table[id] >= scoreTable[id] then
                timer.cancel(scoreTimer)
                scoreTimer = timer.performWithDelay(1, scoreAnimation(sequence[4]), 0)
                soundEffect:play("rollingscore")
                transition.to(scoreNumText, {time=130, y=scoreNumText.y-10, alpha=1})
                transition.to(scoreNumText, {time=130, delay=130, y=scoreNumText.y, alpha=1})
            end
            table[id] = table[id] + math.max(1, math.min(scoreTable[id]-table[id], math.floor(scoreTable[id]/61)))

        elseif id == "score" then
            scoreNumText.text = table[id]
            scoreNumText:setReferencePoint(display.CenterRightReferencePoint)
            scoreNumText.x = scoreTextX
            scoreNumText.y = scoreTextY
            if table[id] >= scoreTable[id] then
                timer.cancel(scoreTimer)
            end

            if table[id] >= scoreTable[id] then
                increasePiratesExp()
                timer.performWithDelay(2000, showNextButton)
            end
            table[id] = table[id] + math.max(1, math.min(scoreTable[id]-table[id], math.floor(scoreTable[id]/61)))

        end
    end
end

local function startAnimateScore()
    scoreTimer = timer.performWithDelay(1, scoreAnimation(sequence[1]), 0)
    transition.to(monstersNumText, {time=130, y=monstersNumText.y-10, alpha=1})
    transition.to(monstersNumText, {time=130, delay=130, y=monstersNumText.y, alpha=1})
    soundEffect:play("rollingscore")
end


local function drawLayout(scoreTable)
    local group = display.newGroup()

    local background = display.newImageRect("images/result/resultMenu.png", display.contentWidth, display.contentHeight)
    background:setReferencePoint(display.CenterReferencePoint)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    group:insert(background)

    local scoreBoard = display.newImage("images/result/resultScoreboard.png")
    scoreBoard:setReferencePoint(display.CenterReferencePoint)
    scoreBoard.x = display.contentCenterX - 10
    scoreBoard.y = 190
    group:insert(scoreBoard)

    local highScoreBoard = display.newImageRect("images/result/resultHighscore.png", 224, 101)
    highScoreBoard:setReferencePoint(display.CenterReferencePoint)
    highScoreBoard.x = display.contentCenterX
    highScoreBoard.y = 355
    group:insert(highScoreBoard)

    experienceBar = experience.new(soundEffect)
    experienceBar:setReferencePoint(display.TopLeftReferencePoint)
    group:insert(experienceBar)

    local energy = energyTable["screen"]
    group:insert(energy)

    local gameCoins = gameCoins.new()
    group:insert(gameCoins)

    local gameDiamonds = gameDiamonds.new()
    group:insert(gameDiamonds)

    if scoreTable["result"] == "victory" then
        endGameText = display.newImage("images/result/resultStageclear.png")
    else
        endGameText = display.newImage("images/result/resultStagefail.png")
    end
    endGameText:setReferencePoint(display.CenterReferencePoint)
    endGameText.x = display.contentCenterX
    endGameText.y = 80
    endGameText.alpha = 0
    endGameText.xScale = 0.1
    endGameText.yScale = 0.1
    group:insert(endGameText)

    
    coinsNumText = display.newText("0", 0, 0, "comic sans ms", 14)
    coinsNumText:setReferencePoint(display.CenterRightReferencePoint)
    coinsNumText.x = coinsTextX
    coinsNumText.y = coinsTextY
    group:insert(coinsNumText)

    monstersNumText = display.newText("0", 0, 0, "comic sans ms", 14)
    monstersNumText:setReferencePoint(display.CenterRightReferencePoint)
    monstersNumText.x = monsterTextX
    monstersNumText.y = monsterTextY
    group:insert(monstersNumText)

    scoreNumText = display.newText("0", 0, 0, "comic sans ms", 14)
    scoreNumText:setReferencePoint(display.CenterRightReferencePoint)
    scoreNumText.x = scoreTextX
    scoreNumText.y = scoreTextY
    group:insert(scoreNumText)

    keysNumText = display.newText("0", 0, 0, "comic sans ms", 14)
    keysNumText:setReferencePoint(display.CenterRightReferencePoint)
    keysNumText.x = keysTextX
    keysNumText.y = keysTextY
    group:insert(keysNumText)

    local function nextButtonListener(event)
        if event.phase == "ended" then
            soundEffect:play("button")
            storyboard.gotoScene("home-scene", "fade", 800)
        end
    end
    nextButton = widget.newButton{
        defaultFile = "images/buttons/buttonNext.png",
        overFile = "images/buttons/buttonNextonclick.png",
        onEvent = nextButtonListener
    }
    nextButton.xScale = 0.9
    nextButton.yScale = 0.9
    nextButton.x = display.contentCenterX
    nextButton.y = display.contentCenterY + 200
    group:insert(nextButton)
    nextButton.alpha = 0

    return group
end

local function updateStoryModeSave()
    local currentLevel = localStorage.get("storyLevel")
    local thisStageLevel = scoreTable["storyLevel"]

    -- update story level
    if currentLevel < thisStageLevel then
        localStorage.saveWithKey("storyLevel", thisStageLevel)
    end

    -- update number of keys
    local currentNoOfKeys = localStorage.get("keys")
    currentNoOfKeys = currentNoOfKeys + scoreTable["keys"]
    localStorage.saveWithKey("keys", currentNoOfKeys)

    -- update number of coins
    local currentNoOfCoins = localStorage.get("coins")
    currentNoOfCoins = currentNoOfCoins + scoreTable["coins"]
    localStorage.saveWithKey("coins", currentNoOfCoins)
end

local function updateSurvivalModeSave()
    local currentTimeRecord = localStorage.get("survivalRecord")
    local thisGameRecord = scoreTable["survival"]
    if thisGameRecord > currentTimeRecord then
        localStorage.saveWithKey("survivalRecord", thisGameRecord)
    end
end

local function updateHighScore()
    if scoreTable["mode"] == "story" then
        local storyLevel = scoreTable["storyLevel"]
        local highScoreTable = localStorage.get("highScore")
        if highScoreTable[storyLevel] == nil then
            highScoreTable[storyLevel] = 0
            localStorage.saveWithKey("highScore", highScoreTable)
        end
        if scoreTable["score"] > highScoreTable[storyLevel] then
            highScoreTable[storyLevel] = scoreTable["score"]
            localStorage.saveWithKey("highScore", highScoreTable)
        end
    else
        local survivalScore = localStorage.get("survivalHighScore")
        if scoreTable["score"] > survivalScore then
            localStorage.saveWithKey("survivalHighScore", scoreTable["score"])
        end
    end
end
---------------------------------------------------------------------------------


---------------------------------------------------------------------------------
-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    soundEffect = resultSoundEffect.new()

    energyTable = energy.new()
    sequence = {"monsters", "coins", "keys", "score"}
    table = {["coins"]=0, ["monsters"]=0, ["score"]=0, ["keys"]=0}
    --scoreTable = {["coins"] = 110,["monsters"] = 124, ["score"] = 128, ["keys"] = 428, ["result"] = "victory"}
    --scoreTable = {["coins"] = 110,["monsters"] = 124, ["score"] = 128, ["keys"] = 428, ["result"] = "victory", ["mode"] = "story", ["storyLevel"] = 1}

    scoreTable = event.params.result
    if scoreTable["mode"] == "story" and scoreTable["result"] == "victory" then 
        updateStoryModeSave()
    elseif scoreTable["mode"] == "survival" then
        updateSurvivalModeSave()
    end
    
    updateHighScore()

    local layout = drawLayout(scoreTable)
    group:insert(layout)

    highScoreText = display.newText("", 210, 343, "Impact", 20)
    group:insert(highScoreText)
    if scoreTable["mode"] == "story" then
        highScoreText.text = localStorage.get("highScore")[scoreTable["storyLevel"]]
    else
        highScoreText.text = localStorage.get("survivalHighScore")
    end
    highScoreText.alpha = 0
end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    print("result scene")
    local group = self.view
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    local BGM = require 'gameLogic.backgroundMusic'
    BGM.play("main")
    startAnimateScore()
    
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    timer.cancel(scoreTimer)
    timer.cancel(energyTable["timer"])
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
    soundEffect:dispose()
    soundEffect = nil
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    local group = self.view

    if highScoreText then
        highScoreText:removeSelf()
        highScoreText = nil
    end

    group:removeSelf()
    group = nil
    energyTable = nil
    self.view = nil
    table = nil
    scoreTable = nil
    sequence = nil
end


-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
end


-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local group = self.view
    local overlay_name = event.sceneName  -- name of the overlay scene
end



---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )
-- "willEnterScene" event is dispatched before scene transition begins
scene:addEventListener( "willEnterScene", scene )
-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )
-- "exitScene" event is dispatched before next scene's transition begins
scene:addEventListener( "exitScene", scene )
-- "didExitScene" event is dispatched after scene has finished transitioning out
scene:addEventListener( "didExitScene", scene )
-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )
-- "overlayBegan" event is dispatched when an overlay scene is shown
scene:addEventListener( "overlayBegan", scene )
-- "overlayEnded" event is dispatched when an overlay scene is hidden/removed
scene:addEventListener( "overlayEnded", scene )
---------------------------------------------------------------------------------

return scene