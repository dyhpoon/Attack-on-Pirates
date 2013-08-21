module(..., package.seeall)

local toast = require 'gameLogic.toast'
local localStorage = require 'gameLogic.localStorage'

function new(keysHaveText, keysNeededText, itemStat, soundEffect)
	local group = display.newGroup()
    local threeArrows, threeChests
    local hasDrawn = false

    -- tier 1-3 awards
    local award1Table = {
        ["coins1"]  = {{"images/luckyDraw/draw10coins.png",  "coins",   10},  {"images/luckyDraw/draw20coins.png",  "coins",   20}, },
        ["redPot1"] = {{"images/luckyDraw/draw1potion.png",  "redPot1", 1 },  {"images/luckyDraw/draw2potion.png",  "redPot1", 2},  },
        ["bluePot"] = {{"images/luckyDraw/draw1mana.png",    "bluePot", 1 },                                                        },
    }
    local award2Table = {
        ["coins1"]  = {{"images/luckyDraw/draw20coins.png",  "coins",   20},                                                        },
        ["coins2"]  = {{"images/luckyDraw/draw50coins.png",  "coins",   50},                                                        },
        ["redPot1"] = {{"images/luckyDraw/draw1potion.png",  "redPot1", 1},   {"images/luckyDraw/draw2potion.png",  "redPot1", 2},  },
        ["redPot2"] = {{"images/luckyDraw/draw1spotion.png", "redPot2", 1},   {"images/luckyDraw/draw2spotion.png", "redPot2", 2},  },
        ["bluePot"] = {{"images/luckyDraw/draw1mana.png",    "bluePot", 1},   {"images/luckyDraw/draw2mana.png",    "bluePot", 2},  },
    }
    local award3Table = {
        ["coins2"]  = {{"images/luckyDraw/draw50coins.png",  "coins",   50},  {"images/luckyDraw/draw100coins.png", "coins",   100}, },
        ["redPot2"] = {{"images/luckyDraw/draw2spotion.png", "redPot2", 2},                                                         },
        ["redPot3"] = {{"images/luckyDraw/draw1epotion.png", "redPot3", 1},   {"images/luckyDraw/draw2epotion.png", "redPot3", 2},  },
        ["bluePot"] = {{"images/luckyDraw/draw2mana.png",    "bluePot", 2},                                                         },
    }

    -- tier 1-3 chests
    local chest1Type = {"coins1", "redPot1", "bluePot",}

    local chest2Type = {"coins1", "coins2", "redPot1", "redPot2", "bluePot",}

    local chest3Type = {"coins2", "redPot2", "redPot3", "bluePot",}

    local chestSequence = { "coins1", "coins2", "redPot1", "redPot2", "redPot3", "bluePot",
        ["coins1"] = {"openedCoins1", "closedCoins1"},
        ["coins2"] = {"openedCoins2", "closedCoins2"},
        ["redPot1"] = {"openedRedPot1", "closedRedPot1"},
        ["redPot2"] = {"openedRedPot2", "closedRedPot2"},
        ["redPot3"] = {"openedRedPot3", "closedRedPot3"},
        ["bluePot"] = {"openedBluePot", "closedBluePot"},
    }

    local function updateAwards(awardType, n)
        if awardType == "coins" then
            soundEffect:play("coinpickup")
            local currentCoins = localStorage.get("coins") + n
            localStorage.saveWithKey("coins", currentCoins)
            itemStat["coins"]:refresh()

        elseif awardType == "redPot1" then
            soundEffect:play("itemcollect")
            local currentRedPot1 = localStorage.get("redPot1") + n
            localStorage.saveWithKey("redPot1", currentRedPot1)
            itemStat["redPot1"].text = currentRedPot1

        elseif awardType == "redPot2" then
            soundEffect:play("itemcollect")
            local currentRedPot2 = localStorage.get("redPot2") + n
            localStorage.saveWithKey("redPot2", currentRedPot2)
            itemStat["redPot2"].text = currentRedPot2

        elseif awardType == "redPot3" then
            soundEffect:play("itemcollect")
            local currentRedPot3 = localStorage.get("redPot3") + n
            localStorage.saveWithKey("redPot3", currentRedPot3)
            itemStat["redPot3"].text = currentRedPot3

        elseif awardType == "bluePot" then
            soundEffect:play("itemcollect")
            local currentBluePot = localStorage.get("bluePot") + n
            localStorage.saveWithKey("bluePot", currentBluePot)
            itemStat["bluePot"].text = currentBluePot
        end

    end

    local function randomGenerator(table, range)
        while(true) do
            local r = math.random(range)
            local inTable = false
            for i = 1, #table, 1 do
                if table[i] == r then
                    inTable = true
                    break
                end
            end
            if not inTable then
                return r
            end
        end
    end

    local function assignChestAwards(displayGroup, chestType)
        local chestTier
        local awardTier
        
        if chestType == "t1" then
            chestTier = chest1Type
            awardTier = award1Table
        elseif chestType == "t2" then
            chestTier = chest2Type
            awardTier = award2Table
        elseif chestType == "t3" then
            chestTier = chest3Type
            awardTier = award3Table
        end

        local temp = {}
        for i = 1, displayGroup.numChildren, 1 do
            local r1 = randomGenerator(temp, #chestTier)
            table.insert(temp, r1)
            displayGroup[i].type = chestTier[r1]
            local awardChoices = awardTier[displayGroup[i].type]
            local r2 = math.random(#awardChoices)
            displayGroup[i].awardImage = awardChoices[r2][1]
            displayGroup[i].awardType = awardChoices[r2][2]
            displayGroup[i].awardSize = awardChoices[r2][3]
        end
    end

    -- chest listener
    local function chestListener(event)
        local currentNumberOfKeys = localStorage.get("keys")
        local numberOfKeysNeeded = tonumber(keysNeededText.text)
        if currentNumberOfKeys < numberOfKeysNeeded then
            toast.new("Not enough keys to draw!", 3000)
        elseif not hasDrawn and event.phase == "ended" and currentNumberOfKeys >= numberOfKeysNeeded then
            soundEffect:play("openchest")
            hasDrawn = true

            if numberOfKeysNeeded == 10 then
                assignChestAwards(threeChests, "t1")
            elseif numberOfKeysNeeded == 20 then
                assignChestAwards(threeChests, "t2")
            elseif numberOfKeysNeeded == 30 then
                assignChestAwards(threeChests, "t3")
            end

            -- remove arrow
            if threeArrows then
                threeArrows:removeSelf()
                threeArrows = nil
            end

            -- update keys
            localStorage.saveWithKey("keys", currentNumberOfKeys - numberOfKeysNeeded)
            keysHaveText:refresh()

            -- update chest
            event.target:setSequence(chestSequence[event.target.type][1])
            event.target:play()

            -- udpate number of potions/coins
            updateAwards(event.target.awardType, event.target.awardSize)

            local awardPopup = display.newImage(event.target.awardImage)
            awardPopup:setReferencePoint(display.CenterReferencePoint)
            awardPopup.x = event.target.x
            awardPopup.y = event.target.y + 20
            group:insert(awardPopup)

            local function removeAwardImage()
                if awardPopup then
                    awardPopup:removeSelf()
                    awardPopup = nil
                end
            end
            transition.to(awardPopup, {time=600, y=awardPopup.y-60})
            transition.to(awardPopup, {time=800, delay=600, alpha=0, onComplete=removeAwardImage})

            for i=1, threeChests.numChildren, 1 do
                if i ~= event.target.id then
                    threeChests[i]:setSequence(chestSequence[threeChests[i].type][2])
                    threeChests[i]:play()
                end
            end
            --transition.to(event.target, {time=500, y=event.target.y - 30})
            event.target.y = event.target.y - 14
        end
    end

    -- arrow transition (move down and up)
    local function arrowMoveUpAndDown(target)
        transition.to(target, {time=500, y=target.y+10})
        transition.to(target, {time=500, delay=500, y=target.y, onComplete=function() arrowMoveUpAndDown(target) end})
    end


    -- function to draw chest
    local function drawChest(id)
        local sheetData1 = {width=82, height=71, numFrames=7, sheetContentWidth=256, sheetContentHeight=256}
        local sheet1 = graphics.newImageSheet("images/drawChestopen.png", sheetData1)
        local sheetData2 = {width=56, height=44, numFrames=8, sheetContentWidth=256, sheetContentHeight=128}
        local sheet2 = graphics.newImageSheet("images/drawChestclose.png", sheetData2)
        local sequenceData = {
            {name="openedCoins1", sheet=sheet1, frames={5}, time=500},
            {name="openedCoins2", sheet=sheet1, frames={1}, time=500},
            {name="openedRedPot1", sheet=sheet1, frames={6}, time=500},
            {name="openedRedPot2", sheet=sheet1, frames={7}, time=500},
            {name="openedRedPot3", sheet=sheet1, frames={2}, time=500},
            {name="openedBluePot", sheet=sheet1, frames={4}, time=500},
            --{name="openedAttack", sheet=sheet1, frames={3}, time=500},

            {name="closed", sheet=sheet2, frames={1}, time=500},
            {name="closedRedPot1", sheet=sheet2, frames={7}, time=500},
            {name="closedRedPot2", sheet=sheet2, frames={8}, time=500},
            {name="closedRedPot3", sheet=sheet2, frames={3}, time=500},
            {name="closedBluePot", sheet=sheet2, frames={5}, time=500},
            --{name="closedAttack", sheet=sheet2, frames={4}, time=500},
            {name="closedCoins1", sheet=sheet2, frames={6}, time=500},
            {name="closedCoins2", sheet=sheet2, frames={2}, time=500},
        }

        local chest = display.newSprite(sheet2, sequenceData)
        chest:setSequence("closed")
        chest:play()
        --chest.type = chestType[math.random(#chestType)]
        chest.id = id
        chest:addEventListener("touch", chestListener)
        return chest
    end

    local function drawArrow(x, y)
        local arrow = display.newImageRect("images/drawArrowdown.png", 34, 26)
        arrow:setReferencePoint(display.CenterReferencePoint)
        arrow.x = x
        arrow.y = y - 30
        arrowMoveUpAndDown(arrow)

        return arrow
    end

    local function drawThreeChests()
        local group = display.newGroup()

        local firstChest = drawChest(1)
        firstChest:setReferencePoint(display.CenterReferencePoint)
        firstChest.x = 90
        firstChest.y = 350
        group:insert(firstChest)

        local secondChest = drawChest(2)
        secondChest:setReferencePoint(display.CenterReferencePoint)
        secondChest.x = 162
        secondChest.y = 350
        group:insert(secondChest)

        local thirdChest = drawChest(3)
        thirdChest:setReferencePoint(display.CenterReferencePoint)
        thirdChest.x = 235
        thirdChest.y = 350
        group:insert(thirdChest)

        return group
    end

    local function drawThreeArrows()
        local group = display.newGroup()
        group:insert(drawArrow(90, 345))
        group:insert(drawArrow(162, 345))
        group:insert(drawArrow(235, 345))
        return group
    end

    threeChests = drawThreeChests()
    threeArrows = drawThreeArrows()
    group:insert(threeChests)
    group:insert(threeArrows)

    function group:reset()
        if threeChests then
            threeChests:removeSelf()
            threeChests = nil
        end
        if threeArrows then
            threeArrows:removeSelf()
            threeArrows = nil
        end

        threeChests = drawThreeChests()
        threeArrows = drawThreeArrows()
        group:insert(threeChests)
        group:insert(threeArrows)
        hasDrawn = false
    end

	return group
end
