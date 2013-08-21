--[[

The leaderboard of the game

--]]

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require 'widget'
local otherSoundEffect = require 'gameLogic.otherSoundEffect'

-- local forward references
local currentPage 
local currentRank
local lastScore
local numberOfPages
local rankTable
local beginX, endX
local font = storyboard.state.font
local userRank, userFacebookID
local soundEffect

-------------------- HELPER FUNCTIONS -----------------------

-- check whether the user swipes left/right, and change the leaderboard score correspondingly
-- if user swipes right, it shows the next page of scores (vice versa)
local function flipPages()
    local xDistance =  math.abs(endX - beginX)
    
    if xDistance > 50 then
        if beginX > endX then
            --swipe left, turn to previous page
            if currentPage < numberOfPages then
                soundEffect:play("swipe")
                for i = 1, rankTable[currentPage].numChildren, 1 do
                    transition.to(rankTable[currentPage][i][1], {time=300, x = -450 - 20})
                    transition.to(rankTable[currentPage][i][2], {time=300, x = -450 - 80})
                    transition.to(rankTable[currentPage][i][3], {time=300, x = -450 - 250})
                end
                for i = 1, rankTable[currentPage+1].numChildren, 1 do
                    transition.to(rankTable[currentPage+1][i][1], {time=300, x=rankTable[currentPage+1][i][1].xPosition})
                    transition.to(rankTable[currentPage+1][i][2], {time=300, x=rankTable[currentPage+1][i][2].xPosition})
                    transition.to(rankTable[currentPage+1][i][3], {time=300, x=rankTable[currentPage+1][i][3].xPosition})
                end
                currentPage = currentPage + 1
            end
        else 
            -- swipe right, turn to next page
            if currentPage > 1 then
                soundEffect:play("swipe")
                for i = 1, rankTable[currentPage].numChildren, 1 do
                    transition.to(rankTable[currentPage][i][1], {time=300, x = 450 + 20})
                    transition.to(rankTable[currentPage][i][2], {time=300, x = 450 + 80})
                    transition.to(rankTable[currentPage][i][3], {time=300, x = 450 + 250})
                end
                for i = 1, rankTable[currentPage-1].numChildren, 1 do
                    transition.to(rankTable[currentPage-1][i][1], {time=300, x = rankTable[currentPage-1][i][1].xPosition})
                    transition.to(rankTable[currentPage-1][i][2], {time=300, x = rankTable[currentPage-1][i][2].xPosition})
                    transition.to(rankTable[currentPage-1][i][3], {time=300, x = rankTable[currentPage-1][i][3].xPosition})
                end
                currentPage = currentPage - 1
            end
        end
    end
end

-- swipe listener (TOUCH EVENT)
local function swipe(event)
    if event.phase == "began" then
        beginX = event.x
    end
    if event.phase == "ended" and beginX then
        endX = event.x
        if pcall(flipPages) then
            -- do nothing
        else
            print("arithmetic error in swipe")
        end
    end
end

-- trims a long name into a less characters name.
-- For example, if a name "Sharon Amfbfihebidc Liangberg" => "Sharon A. L."
local function trimName(name)
    -- split name into parts
    local nameTable = {}
    for i in string.gmatch(name, "%a+") do
        table.insert(nameTable, i)
    end

    -- case if: user name has first_name, middle_name, and last_name
    if #nameTable == 3 then
        local first_name = nameTable[1]
        local middle_name = nameTable[2]
        local last_name = nameTable[3]

        if string.len(first_name) > 13 then
            first_name = first_name:sub(0, 13) .. "."
        end
        middle_name = middle_name:sub(0, 1) .. "."
        last_name = last_name:sub(0,1) .. "."
        return (first_name .. " " .. middle_name .. " " .. last_name)

    -- case if: user has first_name, and last_name
    elseif #nameTable == 2 then
        local first_name = nameTable[1]
        local last_name = nameTable[2]

        if string.len(first_name) > 13 then
            first_name = first_name:sub(0, 13) .. "."
        end
        last_name = last_name:sub(0,1) .. "."
        return (first_name .. " " .. last_name)
    
    -- case if: user has first_name only
    elseif #nameTable == 1 then
        local first_name = nameTable[1]

        if string.len(first_name) > 13 then
            first_name = first_name:sub(0, 13) .. "."
        end
        return (first_name)
    end
end

-- show the header name of each columns(rank, name, score)
local function displayHeader()
    local group = display.newGroup()

    local rankText = display.newText("Rank#", 5, 13, font, 17)
    group:insert(rankText)
    local nameText = display.newText("Name", 80, 13, font, 17)
    group:insert(nameText)
    local scoreText = display.newText("Score", 240, 13, font, 17)
    group:insert(scoreText)

    return group
end

-- shows one user's leaderboard score in one row
local function displayFriendsScore(i, name, score, fbid)
    local group = display.newGroup()

    -- if user's rank
    if score < lastScore then
        lastScore = score
        currentRank = currentRank + 1
    end
    rank = currentRank

    if fbid == userFacebookID then
        userRank = rank
    end

    -- rank text
    local rankNumberText = display.newText(rank, 450, 28*i+47, font, 14)
    rankNumberText:setReferencePoint(display.TopLeftReferencePoint)
    rankNumberText.xPosition = 30
    rankNumberText.yPosition = 28*i+47
    group:insert(rankNumberText)

    -- user's friends' name text
    local playerName = trimName(name)
    local nameText = display.newText(playerName, 450, 28*i+47, font, 14)
    nameText:setReferencePoint(display.TopLeftReferencePoint)
    nameText.xPosition = 84
    nameText.yPosition = 28*i+47
    group:insert(nameText)

    -- score text
    local scoreText = display.newText(score, 450, 28*i+47, font, 14)
    scoreText:setReferencePoint(display.TopLeftReferencePoint)
    scoreText.xPosition = 265
    scoreText.yPosition = 28*i+47
    group:insert(scoreText)

    return group
end

-- display 10 users's leaderboard score
local function displayTenFriendsScore(pageNum, data)
    local group = display.newGroup()

    local firstIndexPosition = (pageNum)*10 + 1
    if firstIndexPosition <= #data then
        local min = math.min(10, #data - (pageNum*10))
        for i=1, min, 1 do
            local index = i+(pageNum)*10
            local name = data[index][1]
            local score = data[index][3]
            local facebookID = data[index][2]
            local rankEntry = displayFriendsScore(i, name, score, facebookID)
            group:insert(rankEntry)
        end
    end

    return group
end

-- shows information at the bottom (just your score)
local function displayFooter()
    local group = display.newGroup()

    local yourScoreText = display.newText("Your Score", 230, 360, font, 18)
    group:insert(yourScoreText)

    return group
end

-- shows your score
local function displayUserScore(name, score, rank)
    local group = display.newGroup()

    local rankText = display.newText(rank, 29, 385, font, 18)
    group:insert(rankText)
    local username = trimName(name)
    local nameText = display.newText(username, 84, 385, font, 18)
    group:insert(nameText)
    local scoreText = display.newText(score, 263, 385, font, 18)
    scoreText:setReferencePoint(display.CenterReferencePoint)
    group:insert(scoreText)
    
    return group
end

-----------------------------------------------------------

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    soundEffect = otherSoundEffect.new()

    print("friendsScoreScene createScene")
    local background = display.newImageRect("images/leaderboardMenu.png", display.contentWidth, display.contentHeight)
    background:setReferencePoint(display.CenterReferencePoint)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    group:insert(background)

    userFacebookID = event.params.myScoreInformation[1][2]
    currentPage = 1
    currentRank = 1
    
    local data = event.params.friendsInformation
    lastScore = data[1][3]

    numberOfPages = math.floor(#data/10)
    if #data%10 ~= 0 then
        numberOfPages = numberOfPages + 1
    end

    rankTable = display.newGroup()
    for i = 0, numberOfPages, 1 do
        local rankPage = displayTenFriendsScore(i, data)
        rankTable:insert(rankPage)
    end
    for i = 1, rankTable[1].numChildren, 1 do
        rankTable[1][i][1].x = rankTable[1][i][1].xPosition
        rankTable[1][i][2].x = rankTable[1][i][2].xPosition
        rankTable[1][i][3].x = rankTable[1][i][3].xPosition
    end
    group:insert(rankTable)

    local myInformation = event.params.myScoreInformation
    local myScore = myInformation[1][3]
    local myName = myInformation[1][1]

    local footer = displayFooter()
    group:insert(footer)

    local userScore = displayUserScore(myName, myScore, userRank)
    group:insert(userScore)

    local function backButtonListener(event)
        if event.phase == "ended" then
            soundEffect:play("back")
            storyboard.gotoScene("home-scene", "fade", 800)
        end
    end
    local backButton = widget.newButton{
        defaultFile = "images/buttons/buttonBack.png",
        overFile = "images/buttons/buttonBackonclick.png",
        onEvent = backButtonListener
    }
    backButton.x = display.contentCenterX
    backButton.y = 447
    group:insert(backButton)

end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    print("friendsScoreScene willEnterScene")
    local group = self.view
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    print("friendsScoreScene enterScene")
    local group = self.view
    Runtime:addEventListener("touch", swipe)

    local BGM = require 'gameLogic.backgroundMusic'
    BGM.play("main")
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    print("friendsScoreScene exitScene")
    local group = self.view
    Runtime:removeEventListener("touch", swipe)
end


-- Called AFTER scene has finished moving offscreen:
function scene:didExitScene( event )
    print("friendsScoreScene didExitScene")
    local group = self.view

    soundEffect:dispose()
    soundEffect = nil

end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
    print("friendsScoreScene destroyScene")
    local group = self.view

    currentPage = nil
    currentRank = nil
    lastScore = nil
    numberOfPages = nil
    userRank = nil
    userFacebookID = nil
    rankTable:removeSelf()
    rankTable = nil
    beginX = nil
    endX = nil

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