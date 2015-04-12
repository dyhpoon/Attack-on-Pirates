local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require 'widget'
local json = require 'json'
local http = require("socket.http")
local toast = require 'gameLogic.toast'
local localStorage = require 'gameLogic.localStorage'
local otherSoundEffect = require 'gameLogic.otherSoundEffect'

local soundEffect

-- initialize some information about date, month, layout position ... etc
----------------------------------------------------------------------------------------------------
local numberOfDays = {
    31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
    ["jan"] = 31,
    ["feb"] = 28,
    ["mar"] = 31,
    ["apr"] = 30,
    ["may"] = 31,
    ["jun"] = 30,
    ["jul"] = 31,
    ["aug"] = 31,
    ["sep"] = 30,
    ["oct"] = 31,
    ["nov"] = 30,
    ["dec"] = 31,
}
local month = {
    "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December",
    ["Jan"] = 1,
    ["Feb"] = 2,
    ["Mar"] = 3,
    ["Apr"] = 4,
    ["May"] = 5,
    ["Jun"] = 6,
    ["Jul"] = 7,
    ["Aug"] = 8,
    ["Sep"] = 9,
    ["Oct"] = 10,
    ["Nov"] = 11,
    ["Dec"] = 12,
}
local leapYear = {
    2012, 2016, 2020, 2024, 2028, 2032, 2036, 2040, 2044, 2048, 2052, 2056
}
local dayXPosition = {
    40, 80, 120, 160, 200, 240, 280
}
local dayYPosition = {
    137, 175, 213, 251, 289, 327
}
local localDay = tonumber(os.date("%d"))
local localMonth = tonumber(os.date("%m"))
local localYear = tonumber(os.date("%Y"))
local remoteDay, remoteMonth, remoteYear -- today's date, from remote resources
--local timeServerUrl = "http://json-time.appspot.com/time.json?tz=Hongkong" -- (this site always crashes)
--local timeServerUrl = "https://myapp-cgtesting.rhcloud.com/coffeegame/time.php" (this was the url of server that i set up, but deprecated)
local timeServerUrl = "https://api.facebook.com/method/fql.query?query=SELECT+now%28%29+FROM+link_stat+WHERE+url+%3D+%271.2%27&format=json"
local isSuccessfullyGetRemoteTime = false
local todaysAward
local isUsingRemoteTime
----------------------------------------------------------------------------------------------------

-- helper functions
----------------------------------------------------------------------------------------------------

-- check if user has claimed today's reward
local function todaysAwardIsNotYetClaimed()
    -- get record from save
    local record = localStorage.get("dailyRewardRecord")
    local tableOfToday = {remoteYear, remoteMonth, remoteDay}

    -- check if there is any record
    for i=1, #record, 1 do
        if remoteYear == record[i][1] and remoteMonth == record[i][2] and remoteDay == record[i][3] then
            return false
        end
    end

    -- otherwise, push a new record to save
    table.insert(record, tableOfToday)
    localStorage.saveWithKey("dailyRewardRecord", record)
    return true
end

-- give award to user by changing save data
local function giveAward(award)
    if award == "coins" then
        local currentCoins = localStorage.get("coins")
        localStorage.saveWithKey("coins", currentCoins + math.random(40, 60))
    elseif award == "chest" then
        local currentCoins = localStorage.get("coins")
        localStorage.saveWithKey("coins", currentCoins + math.random(50, 100))
    elseif award == "key" then
        local currenKeys = localStorage.get("keys")
        localStorage.saveWithKey("keys", currenKeys + math.random(100, 200))
    elseif award == "bluePots" then
        local currentBluePots = localStorage.get("bluePot")
        localStorage.saveWithKey("bluePot", currentBluePots + math.random(10))
    elseif award == "redPots" then
        local currentRedPots = localStorage.get("redPot1")
        localStorage.saveWithKey("redPot1", currentRedPots + math.random(5))
        local currentRedPots = localStorage.get("redPot2")
        localStorage.saveWithKey("redPot2", currentRedPots + math.random(5))
        local currentRedPots = localStorage.get("redPot3")
        localStorage.saveWithKey("redPot3", currentRedPots + math.random(5))
    elseif award == "exp" then
        local currentExpBonous = localStorage.get("expBonus")
        localStorage.saveWithKey("expBonus", currentExpBonous + 3)
    elseif award == "stamp" then
        -- to be confirmed
    elseif award == "completed" then
        -- do nothing
    end
end

local function collectButtonListener(event)
    if event.phase == "began" then
        soundEffect:play("button")
        if isUsingRemoteTime then
            if todaysAwardIsNotYetClaimed() then
                giveAward(todaysAward)
                toast.new("Congratulations! You just collected your reward", 3000)
            else
                toast.new("Sorry! You've already collected your reward", 3000)
            end
            
        else
            toast.new("Please check your connection!", 3000)
        end
    end
end

local function skipButtonListener(event)
    if event.phase == "began" then
        soundEffect:play("button")
        if localStorage.get("storyLevel") == -1 then
            storyboard.gotoScene("tutorial-scene", "fade", 800)
        else
            storyboard.gotoScene("home-scene", "fade", 800)
        end
    end
end

local function drawCalendarLayout()
    local group = display.newGroup()

    local calendarLayout = display.newImageRect("images/calendar/calendarscreen.png", display.contentWidth, display.contentHeight)
    calendarLayout.anchorX, calendarLayout.anchorY = .5, .5
    calendarLayout.x = display.contentCenterX
    calendarLayout.y = display.contentCenterY
    group:insert(calendarLayout)

    local collectButton = widget.newButton{
        defaultFile = "images/buttons/buttonCollect.png",
        overFile = "images/buttons/buttonCollectonclick.png",
        onEvent = collectButtonListener,
    }
    collectButton.width = 160
    collectButton.x = display.contentCenterX - 80
    collectButton.y = display.contentCenterY + 163
    group:insert(collectButton)

    local skipButton = widget.newButton{
        defaultFile = "images/buttons/buttonSkip.png",
        overFile = "images/buttons/buttonSkiponclick.png",
        onEvent = skipButtonListener,
    }
    skipButton.width = 160
    skipButton.x = display.contentCenterX + 80
    skipButton.y = display.contentCenterY + 163
    group:insert(skipButton)

    return group
end

local function today()
    if remoteDay then
        return remoteDay
    else
        return localDay
    end
end

local function checkIfAwardIsCompleted(y, m, d)
    local recordTable = localStorage.get("dailyRewardRecord")
    for i=1, #recordTable, 1 do
        if recordTable[i][1] == y and recordTable[i][2] == m and recordTable[i][3] == d then
            return true
        end
    end
    return false
end

local function createDaysRect(i,j,day,isCurrentMonth, award)
    local group = display.newGroup()


    local dayRect = display.newRect(i, j, 40, 38)
    dayRect.anchorX, dayRect.anchorY = 0, 0
    group:insert(dayRect)

    dayRect.alpha = 1

    local dayText = display.newText(day, 0, 0, "geneva", 7)
    dayText.anchorX, dayText.anchorY = .5, .5
    dayText.x = dayRect.x + 9
    dayText.y = dayRect.y + 5
    dayText:setTextColor(0/255, 0/255, 0/255)
    group:insert(dayText)

    if isCurrentMonth then
        if remoteYear and remoteMonth and remoteDay then
            if checkIfAwardIsCompleted(remoteYear, remoteMonth, day) then
                award = "completed"
            end
        else
            if checkIfAwardIsCompleted(localYear, localMonth, day) then
                award = "completed"
            end
        end
    end

    if isCurrentMonth and day == today() then
        dayRect:setFillColor(51/255, 102/255, 51/255, 200/255)
        --dayRect:setFillColor(math.random(255), math.random(255), math.random(255), 100)
        todaysAward = award
    elseif isCurrentMonth then
        --dayRect:setFillColor(math.random(255), math.random(255), math.random(255), 100)
        dayRect:setFillColor(235/255, 151/255, 40/255, 100/255)
    else
        --dayRect:setFillColor(math.random(255), math.random(255), math.random(255), 100)
        dayRect:setFillColor(102/255, 102/255, 102/255, 100/255)
    end

    dayRect.anchorX, dayRect.anchorY = .5, .5
    if award == "coins" then
        dayRect.award = display.newImageRect("images/calendar/calendarCoins.png", 30,23)
        dayRect.anchorX, dayRect.anchorY = .5, .5
        dayRect.award.x = dayRect.x + 1
        dayRect.award.y = dayRect.y + 3
        group:insert(dayRect.award)
    elseif award == "chest" then
        dayRect.award = display.newImageRect("images/calendar/calendarChest.png", 30,23)
        dayRect.anchorX, dayRect.anchorY = .5, .5
        dayRect.award.x = dayRect.x + 1
        dayRect.award.y = dayRect.y + 3
        group:insert(dayRect.award)
    elseif award == "key" then
        dayRect.award = display.newImageRect("images/calendar/calendarKey.png", 30,23)
        dayRect.anchorX, dayRect.anchorY = .5, .5
        dayRect.award.x = dayRect.x + 1
        dayRect.award.y = dayRect.y + 3
        group:insert(dayRect.award)
    elseif award == "bluePots" then
        dayRect.award = display.newImageRect("images/calendar/calendarMana.png", 30,23)
        dayRect.anchorX, dayRect.anchorY = .5, .5
        dayRect.award.x = dayRect.x + 1
        dayRect.award.y = dayRect.y + 3
        group:insert(dayRect.award)
    elseif award == "redPots" then
        dayRect.award = display.newImageRect("images/calendar/calendarPotion.png", 30,23)
        dayRect.anchorX, dayRect.anchorY = .5, .5
        dayRect.award.x = dayRect.x + 1
        dayRect.award.y = dayRect.y + 3
        group:insert(dayRect.award)
    elseif award == "completed" then
        dayRect.award = display.newImageRect("images/calendar/calendarComplete.png", 30,23)
        dayRect.anchorX, dayRect.anchorY = .5, .5
        dayRect.award.x = dayRect.x + 1
        dayRect.award.y = dayRect.y + 3
        group:insert(dayRect.award)
    elseif award == "exp" then
        dayRect.award = display.newImageRect("images/calendar/calendarExp.png", 30,23)
        dayRect.anchorX, dayRect.anchorY = .5, .5
        dayRect.award.x = dayRect.x + 1
        dayRect.award.y = dayRect.y + 3
        group:insert(dayRect.award)
    elseif award == "stamp" then
        dayRect.award = display.newImageRect("images/calendar/calendarStamp.png", 30,23)
        dayRect.anchorX, dayRect.anchorY = .5, .5
        dayRect.award.x = dayRect.x + 1
        dayRect.award.y = dayRect.y + 3
        group:insert(dayRect.award)
    end

    return group
end

local function numberOfDaysInLastMonth(n)
    if n == 1 then
        return numberOfDays[12]
    else
        return numberOfDays[n-1]
    end
end

local function drawCalendar(yr, mh)  -- year and month
    local group = display.newGroup()

    -- find the weekday of first day of the month(mh)
    local dayOffset = os.date("%w", os.time{year=yr, month=mh, day=1, hour=0})

    -- month
    local monthText = display.newText(month[mh], 0, 0, native.systemFont, 18)
    monthText.anchorX, monthText.anchorY = .5, .5
    monthText.x = display.contentCenterX
    monthText.y = display.contentCenterY - 175
    monthText:setTextColor(80/255, 80/255, 80/255)
    group:insert(monthText)

    -- find the last day of the month
    local lastDay
    if mh == 2 then -- in case of february in leap year
        local isLeapYear = false
        for _,v in pairs(leapYear) do
            if yr == v then
                isLeapYear = true
            end
        end
        if isLeapYear then lastDay = 29 else lastDay = 28 end
    else
        lastDay = numberOfDays[mh]
    end

    -- draw calendar
    local lastMonthDayOffset = numberOfDaysInLastMonth(mh) - dayOffset + 1

    for i = 1, dayOffset, 1 do
        local dayRect = createDaysRect(dayXPosition[i], dayYPosition[1], lastMonthDayOffset, false)
        group:insert(dayRect)
        lastMonthDayOffset = lastMonthDayOffset + 1
    end

    local day = 1
    local weekCounter = 1
    local weekday

    while day <= lastDay do
        weekday = (dayOffset + day - 1) % 7
        if weekday == 0 and day ~= 1 then 
            weekCounter = weekCounter + 1
        end
        weekday = weekday + 1
        local dayRect
        if weekday == 6 then
            dayRect = createDaysRect(dayXPosition[weekday], dayYPosition[weekCounter], day, true, "redPots")
        elseif weekday == 7 then
            dayRect = createDaysRect(dayXPosition[weekday], dayYPosition[weekCounter], day, true, "coins")
        elseif weekday == 1 then
            dayRect = createDaysRect(dayXPosition[weekday], dayYPosition[weekCounter], day, true, "chest")
        elseif weekday == 2 then
            dayRect = createDaysRect(dayXPosition[weekday], dayYPosition[weekCounter], day, true, "redPots")
        elseif weekday == 3 then
            dayRect = createDaysRect(dayXPosition[weekday], dayYPosition[weekCounter], day, true, "exp")
        elseif weekday == 4 then
            dayRect = createDaysRect(dayXPosition[weekday], dayYPosition[weekCounter], day, true, "bluePots")
        elseif weekday == 5 then
            dayRect = createDaysRect(dayXPosition[weekday], dayYPosition[weekCounter], day, true, "key")
        end

        group:insert(dayRect)
        day = day + 1
    end

    local count = 1

    while true do
        weekday = (dayOffset + day -1) % 7
        if weekday == 0 then weekCounter = weekCounter + 1 end

        if weekCounter >= 7 then break end

        local dayRect = createDaysRect(dayXPosition[weekday+1], dayYPosition[weekCounter], count, false)
        group:insert(dayRect)
        count = count + 1
        day = day + 1
    end

    return group
end

local function getRemoteTime()
    local requestUrl = timeServerUrl
    local response = http.request(requestUrl)
    if response == nil then
        return false
    else
        local dateTable = {}
        local currentTime = json.decode(response)[1]["anon"]
        remoteDay = tonumber(os.date("%d", currentTime))
        remoteMonth = tonumber(os.date("%m", currentTime))
        remoteYear = tonumber(os.date("%Y", currentTime))
    end
    return true
end

local function draw(y,m)
    local group = display.newGroup()
    local layout = drawCalendarLayout()
    local calendar = drawCalendar(y,m)
    group:insert(layout)
    group:insert(calendar)
    return group
end
----------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------
-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view
    
    soundEffect = otherSoundEffect.new()
    
    if getRemoteTime() then
        local calendar = draw(remoteYear, remoteMonth)
        isUsingRemoteTime = true
        group:insert(calendar)
    else
        local calendar = draw(localYear, localMonth)
        isUsingRemoteTime = false
        group:insert(calendar)
    end

end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
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
    for i=group.numChildren, 1, -1 do
        group[i]:removeSelf()
        group[i] = nil
    end
    group:removeSelf()
    group = nil
    self.view = nil
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