local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local widget = require 'widget'
store = require("store")
local otherSoundEffect = require 'gameLogic.otherSoundEffect'
local localStorage = require 'gameLogic.localStorage'
local soundEffect
local processingMask

local variables = {}
variables["processing"] = false
local products = 
{
    "aop.normalpack",
    "aop.bigpack",
    "aop.overloaded"
}

local function iapPurchase(productIndex)

    if (store.canMakePurchases) and variables["processing"] == false then
        store.purchase({products[productIndex]});
    end
end

local function onInitStore(event)
    local transactionInfo;

    if event.transaction.state == "purchased" then
        transactionInfo = "Transaction Success!";

        if event.transaction.productIdentifier == products[1] then

            local currentDiamonds = localStorage.get("diamonds")
            localStorage.saveWithKey("diamonds", currentDiamonds + 1)
        elseif event.transaction.productIdentifier == products[2] then

            local currentDiamonds = localStorage.get("diamonds")
            localStorage.saveWithKey("diamonds", currentDiamonds + 6)
        elseif event.transaction.productIdentifier == products[3] then

            local currentDiamonds = localStorage.get("diamonds")
            localStorage.saveWithKey("diamonds", currentDiamonds + 20)
        end

        native.showAlert("Transaction", "Completed Successfully", {"OK"});

    elseif event.transaction.state == "restored" then
        native.showAlert("Restored purchases", {"OK"});
    elseif event.transaction.state == "cancelled" then
        transactionInfo = "Transaction cancelled by user.";
    elseif event.transaction.state == "failed" then
        transactionInfo = "Transaction failed " .. event.transaction.errorType .. " " .. event.transaction.errorString;
    else
        transactionInfo = "Unknown Event!";
    end

    processingMask.isVisible = false;
    variables["processing"] = false;

    -- native.showAlert("testing", transactionInfo, {"OK"});


    -- Finish transaction with the store
    store.finishTransaction(event.transaction);
end

-- Called when the scene's view does not exist:
function scene:createScene( event )
    local group = self.view

    processingMask = display.newImageRect("images/processing.png", display.contentWidth, display.contentHeight);
    processingMask.anchorX, processingMask.anchorY = .5, .5
    processingMask.x = display.contentCenterX
    processingMask.y = display.contentCenterY
    processingMask.isVisible = false;
    
    group:insert(processingMask)
    soundEffect = otherSoundEffect.new()

    local IAPImage = display.newImageRect("images/iapscreen.png", display.contentWidth, display.contentHeight)
    IAPImage.anchorX, IAPImage.anchorY = .5, .5
    IAPImage.x = display.contentCenterX
    IAPImage.y = display.contentCenterY
    group:insert(IAPImage)

    local buyButton1 = widget.newButton{
        defaultFile = "images/buttons/buttonBuy.png",
        overFile = "images/buttons/buttonBuyonclick.png",
    }
    buyButton1.x = display.contentCenterX
    buyButton1.y = 162
    group:insert(buyButton1)

    local buyButton2 = widget.newButton{
        defaultFile = "images/buttons/buttonBuy.png",
        overFile = "images/buttons/buttonBuyonclick.png",
    }
    buyButton2.x = display.contentCenterX
    buyButton2.y = 226
    group:insert(buyButton2)

    local buyButton3 = widget.newButton{
        defaultFile = "images/buttons/buttonBuy.png",
        overFile = "images/buttons/buttonBuyonclick.png",
    }
    buyButton3.x = display.contentCenterX
    buyButton3.y = 290
    group:insert(buyButton3)

    local function backbuttonListener(event)
        if event.phase == "began" then
            storyboard.gotoScene(storyboard.getPrevious(), "fade", 800)
        end
    end
    local backButton = widget.newButton{
        defaultFile = "images/buttons/buttonBack.png",
        overFile = "images/buttons/buttonBackonclick.png",
        onEvent = backbuttonListener
    }
    backButton.x = display.contentCenterX
    backButton.y = display.contentHeight - 60
    group:insert(backButton)

    local function buy(event)
        local product = event.target.id
        if event.phase == "ended" and variables["processing"] == false then
            soundEffect:play("button")
            iapPurchase(product)
            processingMask.isVisible = true
            variables["processing"] = true
        end
        return true
    end

    buyButton1:addEventListener("touch", buy)
    buyButton2:addEventListener("touch", buy)
    buyButton3:addEventListener("touch", buy)
end

variables["processing"] = false;
store.init(onInitStore);

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