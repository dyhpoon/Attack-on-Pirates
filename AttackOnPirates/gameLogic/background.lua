module(..., package.seeall)

local _W = display.contentWidth 
local _H = display.contentHeight
local runnerGameHeight = 78 -- 108
local yPosition = 108 - runnerGameHeight

local dayBackground = {
	"images/ingameBg1.png",
	"images/ingameBg2.png",
	"images/ingameBg3.png",
}
local nightBackground = {
	"images/ingameBg4.png",
	"images/ingameBg5.png",
}


function new()
	local blocks = display.newGroup()
	local speed = 0.5

	for a = 1, 5, 1 do
		local newBackground = display.newImageRect("images/ingameBg3.png", 140, runnerGameHeight)
		newBackground.anchorX, newBackground.anchorY = 0, 0

		newBackground.x = (a * 138) - (138 * 2)
		newBackground.y = yPosition
		blocks:insert(newBackground)
	end

	function blocks:update(shouldUpdateMovement)
		if shouldUpdateMovement then

			for a = blocks.numChildren, 1, -1 do
				blocks[a]:translate(speed * -1 , 0)

				if blocks[a].x < - 200 then
					display.remove(blocks[a])
					--blocks[a]:removeSelf()
					blocks[a] = nil

					local r = math.random(1, 5)
					local imagePath
					if r == 1 then
						imagePath = dayBackground[1]
					elseif r == 2 then
						imagePath = dayBackground[2]
					elseif r == 3 or r == 4 or r == 5 then
						imagePath = dayBackground[3]
					end

					local newBackground = display.newImageRect(imagePath, 140, runnerGameHeight)
					newBackground.anchorX, newBackground.anchorY = 0, 0

					newBackground.x = blocks[blocks.numChildren].x + 138
					newBackground.y = yPosition
					blocks:insert(newBackground)
				end
			end
		end
	end


	return blocks
end
