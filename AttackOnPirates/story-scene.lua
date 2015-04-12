local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local energy = require 'gameLogic.energy'
local localStorage = require 'gameLogic.localStorage'
local toast = require 'gameLogic.toast'
local widget = require 'widget'
local otherSoundEffect = require 'gameLogic.otherSoundEffect'

local soundEffect
local energyTable
local energyBar
local beginY, endY, fastForwardBeginY, fastForwardEndY
local background, lowerBound, upperBound
local buttonGroup
local route
local backgroundTransition, lowerboundTransition, upperboundTransition, buttongroupTransiiton, routeTransition
local startTime, endTime
local bounds
local boundsTransition = {}
local mapPopup

local upperBoundY = -4632
local lowerBoundY = 480
local mapTable = {
    {"images/map/map1.png", 480},
    {"images/map/map2.png", -88},
    {"images/map/map3.png", -656},
    {"images/map/map4.png", -1224},
    {"images/map/map5.png", -1792},
    {"images/map/map6.png", -2360},
    {"images/map/map7.png", -2928},
    {"images/map/map8.png", -3496},
    {"images/map/map9.png", -4064},
}
local buttonsTable = {
    --{button_id, button's x coordinate, button's y coordinate}
    {1, 140, 400},{2, 200, 330},{3, 90, 250},{4, 40, 100},{5, 20, -60},
    {6, 110, -165},{7, 250, -280},{8, 200, -460},{9, 20, -500},{10, 70, -700},
    {11, 30, -900},{12, 250, -990},{13, 240, -1130},{14, 40, -1200},{15, 85, -1280},
    {16, 15, -1400},{17, 170, -1470},{18, 60, -1570},{19, 230, -1660},{20, 210, -1770},
    {21, 220, -1880},{22, 140, -1970},{23, 220, -2060},{24, 80, -2180},{25, 180, -2240},
    {26, 250, -2380},{27, 50, -2430},{28, 150, -2540},{29, 20, -2620},{30, 140, -2760},
    {31, 20, -2800},{32, 250, -2900},{33, 110, -3000},{34, 240, -3080},{35, 170, -3160},
    {36, 50, -3280},{37, 140, -3380},{38, 220, -3500},{39, 70, -3560},{40, 250, -3610},
    {41, 260, -3750},{42, 160, -3810},{43, 60, -3870},{44, 50, -4000},{45, 220, -4050},
    {46, 30, -4140},{47, 60, -4260},{48, 190, -4340},{49, 250, -4480},{50, 170, -4580},
}

local function cancelAllTransitions()
    if backgroundTransition then
        transition.cancel(backgroundTransition)
    end
    if lowerboundTransition then
        transition.cancel(lowerboundTransition)
    end
    if upperboundTransition then
        transition.cancel(upperboundTransition)
    end
    if buttongroupTransiiton then
        transition.cancel(buttongroupTransiiton)
    end
    if routeTransition then
        transition.cancel(routeTransition)
    end
    for i=1, bounds.numChildren, 1 do
        if boundsTransition[i] then
            transition.cancel(boundsTransition[i])
        end
    end
end

local function renderMap(id)
    local mapIsAlreadyRendered = false
    for i=background.numChildren, 1, -1 do
        if background[i].mapID == id then
            mapIsAlreadyRendered = true
            break
        end
    end

    if not mapIsAlreadyRendered then
        local temp = display.newImageRect(mapTable[id][1], display.contentWidth, 568)
        temp.anchorX, temp.anchorY = .5, 1
        temp.x = display.contentCenterX
        temp.y = mapTable[id][2]
        temp.mapID = id
        background:insert(temp)
    end
end

local function removeMap(id)
    for i=background.numChildren, 1, -1 do
        if background[i].mapID == id then
            background[i]:removeSelf()
            background[i] = nil
        end
    end
end
local function showAndHideBackgrounds()
    for i=2, bounds.numChildren, 1 do
        if (bounds[i-1].y > 0 and bounds[i-1].y < 480) or (bounds[i].y > 0 and bounds[i].y < 480) then
            --renderMap(i-1)
            background[i-1].isVisible = true
        elseif bounds[i-1].y >= 480 and bounds[i].y <= 0 then
            --renderMap(i-1)
            background[i-1].isVisible = true
        else
            --removeMap(i-1)
            background[i-1].isVisible = false
        end
    end
end

local function drawMapBounds()
    local group = display.newGroup()

    lowerBound = display.newRect(0, 0, display.contentWidth, 5)
    lowerBound.anchorX, lowerBound.anchorY = .5, 0
    lowerBound.x = display.contentCenterX
    lowerBound.y = lowerBoundY
    lowerBound:setFillColor(255/255, 255/255, 255/255)
    lowerBound.alpha = 0

    local b = display.newRect(0, 0, display.contentWidth, 1)
    b.anchorX, b.anchorY = .5, .5
    b.x = display.contentCenterX
    b.y = lowerBoundY
    bounds:insert(b)

    for i=1, #mapTable, 1 do
        local temp = display.newImageRect(mapTable[i][1], display.contentWidth, 568)
        temp.anchorX, temp.anchorY = .5, 1
        temp.x = display.contentCenterX
        temp.y = mapTable[i][2]
        temp.mapID = i
        group:insert(temp)

        local b = display.newRect(0, 0, display.contentWidth, 1)
        b.anchorX, b.anchorY = .5, .5
        b.x = display.contentCenterX
        b.y = mapTable[i][2] - 568
        bounds:insert(b)
    end

    upperBound = display.newRect(0, 0, display.contentWidth, 5)
    upperBound.anchorX, upperBound.anchorY = .5, 1
    upperBound.x = display.contentCenterX
    upperBound.y = upperBoundY
    upperBound:setFillColor(255/255, 255/255, 255/255)
    upperBound.alpha = 0
    bounds.alpha = 0

    return group
end

local function drawRoute()
    local offsetx = -20
    local offsety = 20
    local route = display.newLine(buttonsTable[1][2]-offsetx,buttonsTable[1][3]+offsety,buttonsTable[2][2]-offsetx,buttonsTable[2][3]+offsety)

    for i=1, #buttonsTable, 1 do
        route:append(buttonsTable[i][2]-offsetx,buttonsTable[i][3]+offsety)
    end
    route:setColor(255/255, 255/255, 255/255)

    route.width = 5

    return route
end

local function swipeScreen(isFastForward)
    local yDistance =  endY - beginY
    if isFastForward then
        --yDistance = yDistance * 300
        yDistance = (fastForwardEndY - fastForwardBeginY) * 5
        if yDistance+lowerBound.y < display.contentHeight then
            yDistance = display.contentHeight-lowerBound.y
        elseif yDistance+upperBound.y > 0 then
            yDistance = -1 * upperBound.y
        end
        backgroundTransition = transition.to(background, {time=3000, y=background.y+yDistance, transition=easing.outExpo})
        lowerboundTransition = transition.to(lowerBound, {time=3000, y=lowerBound.y+yDistance, transition=easing.outExpo})
        upperboundTransition = transition.to(upperBound, {time=3000, y=upperBound.y+yDistance, transition=easing.outExpo})
        buttongroupTransiiton = transition.to(buttonGroup, {time=3000, y=buttonGroup.y+yDistance, transition=easing.outExpo})
        routeTransition = transition.to(route, {time=3000, y=route.y+yDistance, transition=easing.outExpo})

        for i=1, bounds.numChildren, 1 do
            boundsTransition[i] = transition.to(bounds[i], {time=3000,y=bounds[i].y+yDistance, transition=easing.outExpo})
        end

    else

        if yDistance+lowerBound.y < display.contentHeight then
            yDistance = display.contentHeight-lowerBound.y
        elseif yDistance+upperBound.y > 0 then
            yDistance = -1 * upperBound.y
        end
        background:translate(0,yDistance)
        lowerBound:translate(0,yDistance)
        upperBound:translate(0,yDistance)
        buttonGroup:translate(0,yDistance)
        route:translate(0,yDistance)
        for i=1, bounds.numChildren, 1 do
            bounds[i]:translate(0, yDistance)
        end
    end
    
end

local function moveScreenToButton(id)
    if id < 1 then id = 1 end
    if id > 50 then id = 50 end
    local deltaY = buttonsTable[id][3]*-1 + 240
    if deltaY > 5112 - display.contentHeight then
        deltaY = 5112 - display.contentHeight
    elseif deltaY < 0 then
        deltaY = 0
    end

    backgroundTransition = transition.to(background, {time=2000, y = background.y+deltaY, transition=easing.outExpo})
    lowerboundTransition = transition.to(lowerBound, {time=2000, y = lowerBound.y+deltaY, transition=easing.outExpo})
    upperboundTransition = transition.to(upperBound, {time=2000, y = upperBound.y+deltaY, transition=easing.outExpo})
    buttongroupTransiiton = transition.to(buttonGroup, {time=2000, y = buttonGroup.y+deltaY, transition=easing.outExpo})
    routeTransition = transition.to(route, {time=2000, y = route.y+deltaY, transition=easing.outExpo})

    for i=1, bounds.numChildren, 1 do
        boundsTransition[i] = transition.to(bounds[i], {time=2000, y = bounds[i].y+deltaY, transition=easing.outExpo})
    end
end

local function swipe(event)
    if event.phase == "began" then
        cancelAllTransitions()
        startTime = event.time
        beginY = event.y
        fastForwardBeginY = event.y
    elseif event.phase == "moved" and startTime ~= nil then
        endY = event.y
        if pcall(swipeScreen) then
        else
        end
        beginY = endY
    elseif (event.phase == "ended" or event.phase == "cancelled") and startTime ~= nil then
        endTime = event.time
        endY = event.y
        fastForwardEndY = event.y
        local timeUsed = endTime - startTime
        if timeUsed < 200 then
            cancelAllTransitions()
            swipeScreen(true)
        else
            if pcall(swipeScreen) then
            else
            end
        end 
    end
end

local function closePopupListener(event)
    if event.phase == "began" then
        soundEffect:play("back")
        if mapPopup then
            mapPopup:removeSelf()
            mapPopup = nil
        end
    end
end

local function showPopUp(level)
    if mapPopup then
        mapPopup:removeSelf()
        mapPopup = nil
    end
    mapPopup = display.newGroup()

    local function popupListener(event)
        return true
    end
    local popUp = display.newImageRect("images/map/popup.png", display.contentWidth, display.contentHeight)
    popUp.anchorX, popUp.anchorY = .5, .5
    popUp.x = display.contentCenterX
    popUp.y = display.contentCenterY
    mapPopup:insert(popUp)
    popUp:addEventListener("touch", popupListener)

    local closeButton = display.newImageRect("images/buttons/buttonExit.png", 30, 30)
    closeButton.x = 275
    closeButton.y = 45
    closeButton.xScale = 1.3
    closeButton.yScale = 1.3
    closeButton:addEventListener("touch", closePopupListener)
    mapPopup:insert(closeButton)
    
    mapPopup:insert(display.newText(level, 180, 95, "Impact", 30))

    local highScore = localStorage.get("highScore")[level]
    local highScoreText = display.newText("", 253, 175, "impact", 26)
    if highScore then
        highScoreText.text = highScore
    else
        highScoreText.text = 0
    end
    mapPopup:insert(highScoreText)

    local function playButtonListener(event)
        if event.phase == "ended" then
            soundEffect:play("button")
            if energyBar:deductEnergyBy(1) then
                --energyBar:restoreEnergy()
                local options = {
                    effect = "fade",
                    time = 1000,
                    params = {
                        mode="story",
                        storyLevel=event.target.level
                    }
                }
                storyboard.gotoScene( "game-scene", options )

                if mapPopup then
                    mapPopup:removeSelf()
                    mapPopup = nil
                end
            else
                toast.new("Out of Energy.", 3000)
            end
        end
    end
    local playButton = widget.newButton{
        defaultFile = "images/buttons/buttonPlay.png",
        overFile = "images/buttons/buttonPlayonclick.png",
        onEvent = playButtonListener
    }
    playButton.xScale = 1.3
    playButton.yScale = 1.3
    playButton.x = display.contentCenterX
    playButton.y = 440
    playButton.level = level
    mapPopup:insert(playButton)


    mapPopup.alpha = 0
    transition.to(mapPopup, {time=400, alpha=0.8})

end

local function createButton(x,y,id,buttonType)
    local function ButtonListener(event)
        if event.phase == "ended" then
            soundEffect:play("button")
            showPopUp(id)
        end
    end
    local myButton
    if buttonType == "locked" then
        myButton = widget.newButton
        {
            left = x,
            top = y,
            width = 40,
            height = 40,
            defaultFile = "images/map/bigmapDefaulticon.png",
            id = id,
            --label = id,
        }

    elseif buttonType == "next" then
        myButton = widget.newButton
        {
            left = x-12,
            top = y-18,
            width = 60,
            height = 60,
            defaultFile = "images/map/bigmapUnlockicon.png",
            id = id,
            --label = id,
            onEvent = ButtonListener,
        }
    elseif buttonType == "current" then
        myButton = widget.newButton
        {
            left = x,
            top = y,
            width = 40,
            height = 40,
            defaultFile = "images/map/bigmapOnstageicon.png",
            id = id,
            --label = id,
            onEvent = ButtonListener,
        }
    elseif buttonType == "completed" then
        myButton = widget.newButton
        {
            left = x,
            top = y,
            width = 40,
            height = 40,
            defaultFile = "images/map/bigmapFinishicon.png",
            id = id,
            --label = id,
            onEvent = ButtonListener,
        }
    end
    return myButton
end



-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    soundEffect = otherSoundEffect.new() 

    bounds = display.newGroup()
    background = drawMapBounds()
    group:insert(background)
    group:insert(lowerBound)
    group:insert(upperBound)
    group:insert(bounds)

    route = drawRoute()
    group:insert(route)

    local storyLevel = localStorage.get("storyLevel")

    buttonGroup = display.newGroup()
    for i=1, #buttonsTable, 1 do
        local newButton
        if i < storyLevel then 
            newButton = createButton(buttonsTable[i][2], buttonsTable[i][3], buttonsTable[i][1], "completed")
        elseif i == storyLevel then
            newButton = createButton(buttonsTable[i][2], buttonsTable[i][3], buttonsTable[i][1], "current")
        elseif i == storyLevel + 1 then            
            newButton = createButton(buttonsTable[i][2], buttonsTable[i][3], buttonsTable[i][1], "next")
        elseif i > storyLevel + 1 then
            newButton = createButton(buttonsTable[i][2], buttonsTable[i][3], buttonsTable[i][1], "locked")
        end
        buttonGroup:insert(newButton)
    end
    group:insert(buttonGroup)

    energyTable = energy.new()
    energyBar = energyTable["screen"]
    group:insert(energyBar)    
    energyBar.isVisible = false

    local function backButtonListener(event)
        if event.phase == "began" then
            soundEffect:play("back")
            storyboard.gotoScene("home-scene", "fade", 800)
        end
    end

    local backButton = widget.newButton{
        defaultFile = "images/buttons/buttonBack.png",
        overFile = "images/buttons/buttonBackonclick.png",
        onEvent = backButtonListener
    }
    backButton.width = 100
    backButton.height = 30
    backButton.x = display.contentCenterX
    backButton.y = display.contentHeight - 20
    group:insert(backButton)


    local function tutorialButtonListener(event)
        if event.phase == "began" then
            soundEffect:play("button")
            storyboard.gotoScene("tutorial-scene", "slideLeft", 800)
        end
    end
    local tutorialButton = widget.newButton{
        defaultFile = "images/buttons/buttonTutorial.png",
        onEvent = tutorialButtonListener
    }
    tutorialButton.anchorX, tutorialButton.anchorY = .5, 1
    tutorialButton.y = 480
    group:insert(tutorialButton)
end

-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local storyLevel = localStorage.get("storyLevel")
    moveScreenToButton(storyLevel)
    local group = self.view
    --Runtime:addEventListener("enterFrame", showAndHideBackgrounds)
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view
    background:addEventListener("touch", swipe)

    local BGM = require 'gameLogic.backgroundMusic'
    BGM.play("map")
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    if energyTable["timer"] then
        timer.cancel(energyTable["timer"])
    end
    cancelAllTransitions()
    --Runtime:removeEventListener("enterFrame", showAndHideBackgrounds)
    backgroundTimer = nil
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

    cancelAllTransitions()
    backgroundTransition = nil
    lowerboundTransition = nil
    upperboundTransition = nil
    buttongroupTransiiton = nil
    routeTransition = nil

    background:removeSelf()
    background = nil

    buttonGroup:removeSelf()
    buttonGroup = nil

    lowerBound:removeSelf()
    lowerBound = nil
    upperBound:removeSelf()
    upperBound = nil

    route:removeSelf()
    route = nil
    energyTable["timer"] = nil
    energyBar:removeSelf()
    energyBar = nil
    
    group:removeSelf()
    group = nil

    energyTable = nil
    beginY = nil
    endY = nil
    fastForwardBeginY = nil
    fastForwardEndY = nil
    startTime = nil
    endTime = nil

    self.view = nil

    if mapPopup then
        mapPopup:removeSelf()
        mapPopup = nil
    end
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