local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local otherSoundEffect = require 'gameLogic.otherSoundEffect'
local localStorage = require 'gameLogic.localStorage'
local tutorialImages = {
    "images/tutorial/tutorial1.png",
    "images/tutorial/tutorial2.png",
    "images/tutorial/tutorial3.png",
}

local soundEffect
local currentPage
local leftArrow, rightArrow

local function drawTutorial()
    local group = display.newGroup()

    local tutorialPages = display.newGroup()
    for i = 1, #tutorialImages, 1 do

        local page = display.newImageRect(tutorialImages[i], display.contentWidth, display.contentHeight)
        page.anchorX, page.anchorY = .5, .5
        if i == 1 then
            page.x = display.contentCenterX
        else
            page.x = display.contentCenterX + display.contentWidth
        end
        page.y = display.contentCenterY
        tutorialPages:insert(page)
    end
    group:insert(tutorialPages)
    
    local function exitButtonListener(event)
        if event.phase == "began" then
            soundEffect:play("button")
            if localStorage.get("storyLevel") == -1 then
                localStorage.saveWithKey("storyLevel", 0)
                storyboard.gotoScene("home-scene", "fade", 800)
            else
                storyboard.gotoScene(storyboard.getPrevious(), "slideRight", 800)
            end
        end
    end
    local exitButton = display.newImage("images/buttons/buttonExit.png")
    exitButton.xScale = 1.3
    exitButton.yScale = 1.3
    exitButton.x = 290
    exitButton.y = 30
    exitButton:addEventListener("touch", exitButtonListener)
    group:insert(exitButton)

    local function leftArrowListener(event)
        if event.phase == "began" then
            if currentPage > 1 then
                soundEffect:play("button")
                nextPage = currentPage - 1
                transition.to(tutorialPages[currentPage], {time=400, x=display.contentCenterX+display.contentWidth})
                transition.to(tutorialPages[nextPage], {time=400, x=display.contentCenterX})
                currentPage = nextPage
            end
            if currentPage == 1 then
                leftArrow.isVisible = false
            else
                leftArrow.isVisible = true
                rightArrow.isVisible = true
            end
        end
    end
    leftArrow = display.newImage("images/drawArrow.png")
    leftArrow.rotation = 180
    leftArrow.y = display.contentCenterY
    leftArrow.x = 30
    leftArrow.alpha = 0.6
    leftArrow:addEventListener("touch", leftArrowListener)
    leftArrow.isVisible = false
    group:insert(leftArrow)

    local function rightArrowListener(event)
        if event.phase == "began" then
            if currentPage < #tutorialImages then
                soundEffect:play("button")
                nextPage = currentPage + 1
                transition.to(tutorialPages[currentPage], {time=400, x=display.contentCenterX-display.contentWidth})
                transition.to(tutorialPages[nextPage], {time=400, x=display.contentCenterX})
                currentPage = nextPage
            end
            if currentPage == #tutorialImages then
                rightArrow.isVisible = false
            else
                leftArrow.isVisible = true
                rightArrow.isVisible = true
            end
        end
    end
    rightArrow = display.newImage("images/drawArrow.png")
    rightArrow.y = display.contentCenterY
    rightArrow.x = 290
    rightArrow.alpha = 0.6
    rightArrow:addEventListener("touch", rightArrowListener)
    group:insert(rightArrow)

    return group
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    soundEffect = otherSoundEffect.new()

    local tutorialGuide = drawTutorial()
    currentPage = 1
    group:insert(tutorialGuide)
end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    local group = self.view
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    local group = self.view
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