module(..., package.seeall)

chestType = {
	"coins", "sword", "curse",
}

function new(mainCharStatus, soundEffect)
	local group = display.newGroup()
	local C = {}
	local isExist = false
	local chestID = 1

	local options = {
		width = 80,
		height = 80,
		numFrames = 5,
		sheetContentWidth = 512,
		sheetContentHeight = 128
	}

	local imageSheet = graphics.newImageSheet("images/ingameChests.png", options)

	local sequenceData = {
		{name="closed", frames={1}, time=500, loopCount = 0},
		{name="glowing", frames={3}, time=400, loopCount = 0},
		{name="coins", frames={1,2}, time=400, loopCount = 1},
		{name="sword", frames={1,4}, time=400, loopCount = 1},
		{name="curse", frames={1,5}, time=400, loopCount = 1},
	}

	local function removeChest(id) -- parameter 'id'?
		return function()
		for i, chest in ipairs(C) do
			if chest.id == id then
				table.remove(C, i)
				chest:removeSelf()
				chest = nil
			end
		end
		isExist = false
		end
	end

	local function chestListener(event)
		local chest = event.target
		if event.phase == "began" and not chest.isOpened then
			soundEffect:play("chest")
			chest.isOpened = true
			chest:setSequence(chest.type)
			chest:play()
			if chest.type == "coins" then
				mainCharStatus["coins"]:increaseCoinsByN(10)
			elseif chest.type == "sword" then
				mainCharStatus["damage"]:setDamage(mainCharStatus["damage"]:getDamage() + 10)
			elseif chest.type == "curse" then
				mainCharStatus["health"]:minusHpBy(math.floor(mainCharStatus["health"]:getMaxHealth() * 0.15))
			end
			chest:removeEventListener("touch", chestListener)
			transition.to(chest, {time = 1000, alpha = 0, y = chest.y - 30, onComplete = removeChest(event.target.id)})
		end
	end


	function group:spawnChest()
		isExist = false
		local chest = display.newSprite(imageSheet, sequenceData)
		chest:setSequence("closed")
		chest:play()
		chest.type = chestType[math.random(#chestType)]
		chest.x = 400
		chest.y = 64
		chest.id = chestID
		chest.isOpened = false
		chest.hasTouchEvent = false

		group:insert(chest)
		table.insert(C, chest)

	end

	function group:updateChests(collisionRectX, shouldUpdate)
		collisionRectX = collisionRectX + 25
		if shouldUpdate then
			for i, chest in ipairs(C) do
				if chest.x < -100 then
					removeChest()
				elseif not chest.isOpened then
					chest.x = chest.x - 0.5

					if chest.x >= 150 and chest.x < 300 and not chest.hasTouchEvent then
						chest:addEventListener("touch", chestListener)
						chest.hasTouchEvent = true
						chest:setSequence("glowing")
						chest:play()
					elseif chest.x < 150 and chest.hasTouchEvent then
						chest:removeEventListener("touch", chestListener)
						chest.hasTouchEvent = false
						chest:setSequence("closed")
						chest:play()
					end
				end
			end
		end
	end

	function group:isExist()
		if #C >= 1 then return true else return false end
	end

	return group
end
