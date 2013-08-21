--[[

Showing game title

--]]

---------------------------FASTFORWARD REF-------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require 'widget'
local _W = display.contentWidth
local _H = display.contentHeight
local otherSoundEffect = require 'gameLogic.otherSoundEffect'
local soundEffect
---------------------------------------------------------------------------------


-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    soundEffect = otherSoundEffect.new()

    local backgroundImage = display.newImageRect("images/mainscreen.png", display.contentWidth, display.contentHeight)
    backgroundImage.x = display.contentCenterX
    backgroundImage.y = display.contentCenterY
    group:insert(backgroundImage)

    local function startButtonListener(event)
        if event.phase == "ended" then
            soundEffect:play("button")
            storyboard.gotoScene("login-scene", "fade", 800)
        end
    end
    local startButton = widget.newButton{
        defaultFile = "images/buttons/buttonStart.png",
        overFile = "images/buttons/buttonStartonclick.png",
        onEvent = startButtonListener,
    }
    startButton:setReferencePoint(display.CenterReferencePoint)
    startButton.x = display.contentCenterX
    startButton.y = 405
    group:insert(startButton)

end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    print("title-scene")
    local group = self.view

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    
    local BGM = require 'gameLogic.backgroundMusic'
    BGM.play("main")

end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view

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
    group:removeSelf()
    group = nil
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