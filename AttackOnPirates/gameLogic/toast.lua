module(..., package.seeall)


local trueDestroy;

-------------------------------
-- private functions
-------------------------------
function trueDestroy(toast)
    toast:removeSelf();
    toast = nil;
end

-------------------------------
-- public functions
-------------------------------
function new(pText, pTime)
    local text = pText or "nil";
    local pTime = pTime;
    local toast = display.newGroup();

    toast.text                      = display.newText(toast, pText, 14, 12, "comic sans ms", 11);
    --toast.background                = display.newRoundedRect( toast, 0, 0, toast.text.width + 24, toast.text.height + 24, 16 );
    toast.background                = display.newRect( toast, 0, 0, toast.text.width + 24, toast.text.height + 24 );
    toast.background.x = toast.text.x
    toast.background.y = toast.text.y
    toast.background.strokeWidth    = 4
    toast.background:setFillColor(0/255, 0/255, 0/255)
    toast.background:setStrokeColor(96/255, 88/255, 96/255)

    toast.text:toFront();

    toast.anchorX, toast.anchorY = .5, .5

    toast.alpha = 0;
    toast.transition = transition.to(toast, {time=250, alpha = 1});

    if pTime ~= nil then
        timer.performWithDelay(pTime, function() destroy(toast) end);
    end

    toast.x = display.contentWidth * .5
    toast.y = display.contentHeight * .8

    return toast;
end

function destroy(toast)
    toast.transition = transition.to(toast, {time=250, alpha = 0, onComplete = function() trueDestroy(toast) end});
end