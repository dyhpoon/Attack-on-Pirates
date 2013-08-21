--[[

Shop

--]]

-------------------------------FORWARD REF-------------------------------------
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local localStorage = require 'gameLogic.localStorage'
local gameCoins = require 'gameLogic.gameCoins'
local gameDiamonds = require 'gameLogic.gameDiamonds'
local energy = require 'gameLogic.energy'
local experience = require 'gameLogic.experience'
local widget = require 'widget'
local toast = require 'gameLogic.toast'
local otherSoundEffect = require 'gameLogic.otherSoundEffect'

local coinCostText
local diamondCostText
local selectedItem
local coins
local energyTable
local diamonds
local descriptionImage
local selectionImage
local shopView
local currentCurrency
local soundEffect

local itemsTable = {
    --table
    --{id, award, cost(coins), image, cost(diamonds)}
    {"butRestoreEnergy", "images/shop/shopEnergytxt.png", 300, "images/shop/shopEnergy.png", 5},
    {"buyNormalPot", "images/shop/shopPotiontxt.png", 10, "images/shop/shopPotion.png", 1},
    {"buySuperPot", "images/shop/shopSuperpotiontxt.png", 30, "images/shop/shopSuperpotion.png", 2},
    {"buyElitePot", "images/shop/shopElitepotiontxt.png", 50, "images/shop/shopElitepotion.png", 3},
    {"buyUltimatePot", "images/shop/shopUltimatepotiontxt.png", 70, "images/shop/shopUltimatepotion.png", 4},
    {"buyBluePot", "images/shop/shopManatxt.png", 10, "images/shop/shopMana.png", 1},

    --dictionary
    ["butRestoreEnergy"]  = {"butRestoreEnergy", "images/shop/shopEnergytxt.png", 500, "images/shop/shopEnergy.png", 5},
    ["buyNormalPot"]      = {"buyNormalPot", "images/shop/shopPotiontxt.png", 10, "images/shop/shopPotion.png", 1},
    ["buySuperPot"]       = {"buySuperPot", "images/shop/shopSuperpotiontxt.png", 30, "images/shop/shopSuperpotion.png", 2},
    ["buyElitePot"]       = {"buyElitePot", "images/shop/shopElitepotiontxt.png", 50, "images/shop/shopElitepotion.png", 3},
    ["buyUltimatePot"]    = {"buyUltimatePot", "images/shop/shopUltimatepotiontxt.png", 70, "images/shop/shopUltimatepotion.png", 4},
    ["buyBluePot"]        = {"buyBluePot", "images/shop/shopManatxt.png", 10, "images/shop/shopMana.png", 1},

}
---------------------------------------------------------------------------------

------------------BUTTONS LISTENER ------------------------
local function selectButtonListener(event)
    if event.phase == "began" then
        soundEffect:play("choose")
        if descriptionImage then
            descriptionImage:removeSelf()
            descriptionImage = nil
        end
        descriptionImage = display.newImage(event.target.description)
        descriptionImage:setReferencePoint(display.CenterReferencePoint)
        descriptionImage.x = display.contentCenterX
        descriptionImage.y = 360
        shopView:insert(descriptionImage)

        if selectionImage then
            selectionImage:removeSelf()
            selectionImage = nil
        end
        selectionImage = display.newImage("images/shop/shopSelectitem.png")
        selectionImage:setReferencePoint(display.CenterReferencePoint)
        selectionImage.x = event.target.x
        selectionImage.y = event.target.y
        shopView:insert(selectionImage)

        coinCostText.text = event.target.cost
        diamondCostText.text = event.target.diamondCost

        selectedItem = event.target.name
    end
end

local function buyButtonListener(event)
    currentCurrency = event.target.currency

    if event.phase == "ended" then
        soundEffect:play("button")

        if selectedItem == nil then
            toast.new("Please select an item.", 3000)
        else
            local numOfTokensHave, numOfTokensNeeded
            if currentCurrency == "coin" then
                numOfTokensNeeded = itemsTable[selectedItem][3]
                numOfTokensHave = coins:getCoins()
            elseif currentCurrency == "diamond" then
                numOfTokensNeeded = itemsTable[selectedItem][5]
                numOfTokensHave = diamonds:getDiamonds()
            end

            if numOfTokensHave >= numOfTokensNeeded then
                local havePurchased = false
                if itemsTable[selectedItem][1] == "butRestoreEnergy" then
                    local currentEnergyBottle = localStorage.get("energyBottle")
                    localStorage.saveWithKey("energyBottle", currentEnergyBottle + 1)
                    havePurchased = true

                elseif itemsTable[selectedItem][1] == "buyNormalPot" then
                    local currentRedPot1 = localStorage.get("redPot1")
                    localStorage.saveWithKey("redPot1", currentRedPot1 + 1)
                    havePurchased = true

                elseif itemsTable[selectedItem][1] == "buySuperPot" then
                    local currentRedPot2 = localStorage.get("redPot2")
                    localStorage.saveWithKey("redPot2", currentRedPot2 + 1)
                    havePurchased = true

                elseif itemsTable[selectedItem][1] == "buyElitePot" then
                    local currentRedPot3 = localStorage.get("redPot3")
                    localStorage.saveWithKey("redPot3", currentRedPot3 + 1)
                    havePurchased = true

                elseif itemsTable[selectedItem][1] == "buyUltimatePot" then
                    local currentRedPot4 = localStorage.get("redPot4")
                    localStorage.saveWithKey("redPot4", currentRedPot4 + 1)
                    havePurchased = true

                elseif itemsTable[selectedItem][1] == "buyBluePot" then
                    local currentBluePot = localStorage.get("bluePot")
                    localStorage.saveWithKey("bluePot", currentBluePot + 1)
                    havePurchased = true

                end

                if havePurchased then
                    soundEffect:play("coin")
                    if currentCurrency == "coin" then
                        localStorage.saveWithKey("coins", localStorage.get("coins")-numOfTokensNeeded)
                        coins:refresh()
                        toast.new("You have successfully purchased your item.", 3000)
                    elseif currentCurrency == "diamond" then
                        localStorage.saveWithKey("diamonds", localStorage.get("diamonds")-numOfTokensNeeded)
                        diamonds:refresh()
                        toast.new("You have successfully purchased your item.", 3000)
                    end
                end

            else
                if currentCurrency == "coin" then
                    toast.new("Sorry, you do not have enough coins.", 3000)
                elseif currentCurrency == "diamond" then
                    toast.new("Sorry, you do not have enough diamonds.", 3000)
                end
            end
        end
    end
end

local function backButtonListener(event)
    if event.phase == "began" then
        soundEffect:play("back")
        storyboard.gotoScene("home-scene", "fade", 800)
    end
end

local function IAPButtonListener( event )
    if event.phase == "began" then
        soundEffect:play("button")
        storyboard.gotoScene("IAP-scene", "fade", 800)
    end 
end
-----------------------------------------------------------

local function drawButtons()
    local group = display.newGroup()

    local rowPositionX = 160
    local rowPositionY = 130
    local marginX = 100
    local marginY = 80
    local numberOfColumns = 3
    local j = 0
    for i = 1, #itemsTable, 1 do
        local button = display.newImage(itemsTable[i][4])
        button.name = itemsTable[i][1]
        button.description = itemsTable[i][2]
        button.cost = itemsTable[i][3]
        button.diamondCost = itemsTable[i][5]
        button:setReferencePoint(display.CenterReferencePoint)
        button.x = (j-1) * marginX + rowPositionX
        button.y = rowPositionY
        group:insert(button)
        j = (j+1) % numberOfColumns
        if j == 0 then
            rowPositionY = rowPositionY + marginY
        end
        button:addEventListener("touch", selectButtonListener)
    end

    local coinBuyButton = display.newImage("images/shop/shopCoinbuy.png")
    coinBuyButton.x = 100
    coinBuyButton.y = 280
    coinBuyButton.currency = "coin"
    group:insert(coinBuyButton)
    coinBuyButton:addEventListener("touch", buyButtonListener)

    local diamondBuyButton = display.newImage("images/shop/shopDiamondbuy.png")
    diamondBuyButton.x = 227
    diamondBuyButton.y = 280
    diamondBuyButton.currency = "diamond"
    group:insert(diamondBuyButton)
    diamondBuyButton:addEventListener("touch", buyButtonListener)

    coinCostText = display.newText("", 0, 0, "impact", 16)
    coinCostText.text = 0
    coinCostText.x = 110
    coinCostText.y = 279
    group:insert(coinCostText)

    diamondCostText = display.newText("", 0, 0, "impact", 16)
    diamondCostText.text = 0
    diamondCostText.x = 237
    diamondCostText.y = 279
    group:insert(diamondCostText)
    
    local backButton = widget.newButton{
        defaultFile = "images/buttons/buttonBack.png",
        overFile = "images/buttons/buttonBackonclick.png",
        onEvent = backButtonListener,
    }
    backButton:setReferencePoint(display.CenterReferencePoint)
    backButton.x = 85
    backButton.y = 450
    group:insert(backButton)

    local IAPButton = widget.newButton{
        defaultFile = "images/buttons/buttonBuyiap.png",
        onEvent = IAPButtonListener
    }
    IAPButton.x = 235
    IAPButton.y = 450
    group:insert(IAPButton)

    return group
end


local function drawDescriptionFrame()
    local group = display.newGroup()

    local descriptionFrame = display.newImage("images/shop/shopDescriptionframe.png")
    descriptionFrame:setReferencePoint(display.CenterReferencePoint)
    descriptionFrame.x = display.contentCenterX
    descriptionFrame.y = 360
    group:insert(descriptionFrame)

    return group
end

local function drawLayout()
    local group = display.newGroup()

    local energy = energyTable["screen"]
    group:insert(energy)

    local experienceBar = experience.new()
    group:insert(experienceBar)

    coins = gameCoins.new()
    coins.y = coins.y - 4
    group:insert(coins)

    diamonds = gameDiamonds.new()
    diamonds.y = diamonds.y - 4
    group:insert(diamonds)

    local function IAPButtonListener( event )
        if event.phase == "began" and not buttonIsPressed then
            buttonIsPressed = true
            unfreezeButtonTimer = timer.performWithDelay(buttonPressTimeDelay, unfreezeButton)
            storyboard.gotoScene("IAP-scene", "fade", 800)
        end 
    end
    local iapButton = display.newImage("images/buttons/buttonIapmainmenu.png")
    iapButton:setReferencePoint(display.CenterReferencePoint)
    iapButton.x = 304
    iapButton.y = 12
    iapButton:addEventListener("touch", IAPButtonListener)
    group:insert(iapButton)

    local descriptionText = drawDescriptionFrame()
    group:insert(descriptionText)

    local buttons = drawButtons()
    group:insert(buttons)

    return group
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    soundEffect = otherSoundEffect.new()

    shopView = display.newGroup()

    local menuImage = display.newImageRect("images/shop/shopMenu.png", display.contentWidth, display.contentHeight)
    menuImage:setReferencePoint(display.CenterReferencePoint)
    menuImage.x = display.contentCenterX
    menuImage.y = display.contentCenterY
    group:insert(menuImage)

    energyTable = energy.new()


    local layout = drawLayout()
    group:insert(layout)

    group:insert(shopView)
end


-- Called BEFORE scene has moved onscreen:
function scene:willEnterScene( event )
    local group = self.view
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
    local group = self.view

    local BGM = require 'gameLogic.backgroundMusic'
    BGM.play("shop")
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
    local group = self.view
    if energyTable["timer"] then
        timer.cancel(energyTable["timer"])
    end
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

    currentCurrency = nil
    coinCostText:removeSelf()
    coinCostText = nil
    diamondCostText:removeSelf()
    diamondCostText = nil
    coins:removeSelf()
    coins = nil
    diamonds:removeSelf()
    diamonds = nil
    if descriptionImage then
        descriptionImage:removeSelf()
        descriptionImage = nil
    end
    
    if selectionImage then
        selectionImage:removeSelf()
        selectionImage = nil
    end
    shopView:removeSelf()
    shopView = nil

    energyTable["screen"]:removeSelf()
    energyTable["screen"] = nil
    energyTable["timer"] = nil
    energyTable = nil

    group:removeSelf()
    group = nil
    
    selectedItem = nil
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