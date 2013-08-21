-- Project: Attack on Pirate
-- SDK:		CoronaSDK
-- 
-- Author: Darren Poon
-- email : dyhpoon@gmail.com
-- Copyright 2013 Coffee Games. All rights reserved.
---------------------------------------------------------------------------------
display.setStatusBar( display.HiddenStatusBar )

local storyboard = require "storyboard"
storyboard.purgeOnSceneChange = true

-------------------CUSTOM FONT CONFIG-------------------------
local onSimulator = system.getInfo( "environment" ) == "simulator"
local platformVersion = system.getInfo( "platformVersion" )
local olderVersion = tonumber(string.sub( platformVersion, 1, 1 )) < 4
 
local fontName = "Impact"
local fontSize = 10
 
-- if on older device (and not on simulator) ...
if not onSimulator and olderVersion then
    if string.sub( platformVersion, 1, 3 ) ~= "3.2" then
        fontName = "Impact"
        fontSize = 10
    end
end

storyboard.state = {}
storyboard.state.font = fontName
-------------------------------------------------------------


-------------------FIX MARGIN BACKGROUND---------------------
local marginY = math.abs(display.screenOriginY)
if marginY > 0 then
	local topMarginYImage = display.newImageRect("images/marginImageY.png", display.contentWidth, marginY)
	topMarginYImage:setReferencePoint(display.BottomCenterReferencePoint)
	topMarginYImage.x = display.contentCenterX
	topMarginYImage.y = 0

	local bottomMarginYImage = display.newImageRect("images/marginImageY.png", display.contentWidth, marginY)
	bottomMarginYImage:setReferencePoint(display.TopCenterReferencePoint)
	bottomMarginYImage.x = display.contentCenterX
	bottomMarginYImage.y = display.contentHeight
end

local marginX = math.abs(display.screenOriginX)
if marginX > 0 then
	local leftMarginXImage = display.newImageRect("images/marginImageX.png", marginX, display.contentHeight)
	leftMarginXImage:setReferencePoint(display.CenterRightReferencePoint)
	leftMarginXImage.x = 0
	leftMarginXImage.y = display.contentCenterY

	local rightMarginXImage = display.newImageRect("images/marginImageX.png", marginX, display.contentHeight)
	rightMarginXImage:setReferencePoint(display.CenterLeftReferencePoint)
	rightMarginXImage.x = display.contentWidth
	rightMarginXImage.y = display.contentCenterY
end

-------------------------------------------------------------

--storyboard.isDebug = true
--Runtime:addEventListener( "enterFrame", storyboard.printMemUsage )

-- load first screen
storyboard.gotoScene( "opening-scene", "fade", 800 )
--storyboard.gotoScene("game-scene")
--storyboard.gotoScene("result-scene")
--storyboard.gotoScene("leaderboard-scene")
--storyboard.gotoScene("login-scene")
--storyboard.gotoScene("home-scene")
--storyboard.gotoScene("shop-scene")
--storyboard.gotoScene("story-scene")
--storyboard.gotoScene("title-scene")
--storyboard.gotoScene("IAP-scene")
--storyboard.gotoScene("tutorial-scene")
---------------------------------------------------------------------------------
