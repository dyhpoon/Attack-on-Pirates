module(..., package.seeall)

function new(soundEffect)
	local group = display.newGroup()

	 local function facebookButtonListener(event)
        if event.phase == "began" then
            soundEffect:play("button")

            -- do something here

        end 
    end	

	local facebookButton = display.newImage("images/buttons/buttonFacebook.png")
    facebookButton.x = 280
    facebookButton.y = 60
    facebookButton:addEventListener("touch", facebookButtonListener)
    group:insert(facebookButton)


	return group
end