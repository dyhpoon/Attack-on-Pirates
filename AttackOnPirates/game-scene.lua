--[[

game scene

--]]

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-----------------------------------------------------------
local puzzleTable
local puzzleGame
local soundEffect
---------------------- SCENES -----------------------------
-- Called when the scene's view does not exist:
function scene:createScene( event )
	print("create scene")
    local screenGroup = self.view

    -------------------- SOUND EFFECTS ------------------------
    local gameSoundEffect = require 'gameLogic.gameSoundEffect'
    soundEffect = gameSoundEffect.new()
    -----------------------------------------------------------

    ------------------------ GAME -----------------------------
    local puzzle = require 'gameLogic.puzzle'
	puzzleTable = puzzle.new(event.params.mode, event.params.storyLevel, soundEffect)
    --puzzleTable = puzzle.new("story", 1)
	puzzleGame = puzzleTable["screen"]
	screenGroup:insert(puzzleGame)
    -----------------------------------------------------------
end
 
-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
	print("will enter scene")
	print("game scene")
    local screenGroup = self.view

end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	print("enter scene")
    local screenGroup = self.view

    local BGM = require 'gameLogic.backgroundMusic'
    BGM.play("game")
    
    puzzleGame:start()
end
 
 
-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	print("exit scene")
    local screenGroup = self.view
    puzzleGame:stop()
	local puzzleTimers = puzzleTable["timers"]
	for i = #puzzleTimers, 1, -1 do
		timer.cancel(puzzleTimers[i])
		puzzleTimers[i] = nil
	end
	puzzleTimers = nil
end
 
-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
	print("did exit scene")
    local screenGroup = self.view
    soundEffect:dispose()
    soundEffect = nil
end

-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	print("destroy scene")
    local screenGroup = self.view

    screenGroup:removeSelf()
    screenGroup = nil
    puzzleGame = nil
    puzzleTable = nil
    self.view = nil
end

-- Called if/when overlay scene is displayed via storyboard.showOverlay()
function scene:overlayBegan( event )
    local screenGroup = self.view
    local overlay_scene = event.sceneName  -- overlay scene name      
end

-- Called if/when overlay scene is hidden/removed via storyboard.hideOverlay()
function scene:overlayEnded( event )
    local screenGroup = self.view
    local overlay_scene = event.sceneName  -- overlay scene name
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "createScene", scene )
scene:addEventListener( "willEnterScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "didExitScene", scene )
scene:addEventListener( "destroyScene", scene )
scene:addEventListener( "overlayBegan", scene )
scene:addEventListener( "overlayEnded", scene )
---------------------------------------------------------------------------------
 
return scene