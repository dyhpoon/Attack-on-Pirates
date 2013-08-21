module(..., package.seeall)

function new()
	local group = display.newGroup()


local function drawExplosion(i, j, explosionType)
	local xPosition = i*40-20
	local yPosition = j*40+138
	
	local explosionImage
	if explosionType == "verticalTopEnd" then
		explosionImage = display.newImageRect("images/explodeEnd.png", 40, 40)

	elseif explosionType == "verticalSegment" then
		explosionImage = display.newImageRect("images/explodeSegment.png", 40, 40)

	elseif explosionType == "verticalBottomEnd" then
		explosionImage = display.newImageRect("images/explodeEnd.png", 40, 40)
		explosionImage.rotation = 180
		explosionImage.xScale = -1

	elseif explosionType == "horizontalLeftEnd" then
		explosionImage = display.newImageRect("images/explodeEnd.png", 40, 40)
		explosionImage.rotation = -90

	elseif explosionType == "horizontalSegment" then
		explosionImage = display.newImageRect("images/explodeSegment.png", 40, 40)
		explosionImage.rotation = -90

	elseif explosionType == "horizontalRightEnd" then
		explosionImage = display.newImageRect("images/explodeEnd.png", 40, 40)
		explosionImage.rotation = 90
		explosionImage.xScale = -1

	end

	explosionImage.x = xPosition
	explosionImage.y = yPosition

	return explosionImage
end

local function drawVerticalExplosion(i)
	local imageGroup = display.newGroup()
	imageGroup:insert(drawExplosion(i,1, "verticalTopEnd"))

	for j=2,7,1 do
		imageGroup:insert(drawExplosion(i,j, "verticalSegment"))
	end
	imageGroup:insert(drawExplosion(i,8, "verticalBottomEnd"))

	return imageGroup 
end

local function drawHorizontalExplosion(j)
	local imageGroup = display.newGroup()
	imageGroup:insert(drawExplosion(1,j, "horizontalLeftEnd"))
	for i=2,7,1 do
		imageGroup:insert(drawExplosion(i,j, "horizontalSegment"))
	end
	imageGroup:insert(drawExplosion(8,j, "horizontalRightEnd"))

	return imageGroup
end

local function drawCrossExplosioin(i,j)
	imageGroup = display.newGroup()
	
	local verticalImages = drawVerticalExplosion(i)
	imageGroup:insert(verticalImages)

	local horizontalImages = drawHorizontalExplosion(j)
	imageGroup:insert(horizontalImages)

	local centerImage = display.newImageRect("images/explodeCenter.png", 40, 40)
	centerImage.x = i * 40 - 17.5
	centerImage.y = j * 40 + 120
	imageGroup:insert(centerImage)

	return imageGroup	
end

local function removeAllExplosionImages(images)
	return function()
	if images then
		for i=images.numChildren, 1, -1 do
			images[i]:removeSelf()
			images[i] = nil
		end
	end
	end
end

local function animateExplosion(images)
	for i=1,images.numChildren-1,1 do
		transition.to(images[i], {time=100, xScale=0.5})
		transition.to(images[i], {time=100, delay=100, xScale=1})

		transition.to(images[i], {time=100, delay=200, xScale=0.5})
		transition.to(images[i], {time=100, delay=300, xScale=1})

		transition.to(images[i], {time=100, delay=400, xScale=0.5})
		transition.to(images[i], {time=100, delay=500, xScale=1})
	end
	transition.to(images[images.numChildren], {time=100, xScale=-0.5})
	transition.to(images[images.numChildren], {time=100, delay=100, xScale=-1})

	transition.to(images[images.numChildren], {time=100, delay=200, xScale=-0.5})
	transition.to(images[images.numChildren], {time=100, delay=300, xScale=-1})

	transition.to(images[images.numChildren], {time=100, delay=400, xScale=-0.5})
	transition.to(images[images.numChildren], {time=100, delay=500, xScale=-1, onComplete=removeAllExplosionImages(images)})
end

--local temp = drawHorizontalExplosion(5)
--local temp1 = drawVerticalExplosion(5)
--animateExplosion(temp)
--animateExplosion(temp1)

function group:explosionAnimation(i,j,type)
	local imageGroup = display.newGroup()
	if type == "vertical" then
		local images = drawVerticalExplosion(i)
		imageGroup:insert(images)

	elseif type == "horizontal" then
		local images = drawHorizontalExplosion(j)
		imageGroup:insert(images)

	elseif type == "cross" then
		local verticalImages = drawVerticalExplosion(i)
		imageGroup:insert(verticalImages)

		local horizontalImages = drawHorizontalExplosion(j)
		imageGroup:insert(horizontalImages)

	elseif type == "area" then
		-- do something
		print("area")
		local function destroy(target)
			return function()
			if target then
				target:removeSelf()
				target = nil
			end
			end
		end
		local xPosition = i*40-20
		local yPosition = j*40+138
		local areaImages = display.newImage("images/explosion2.png")
		areaImages.x = xPosition
		areaImages.y = yPosition
		transition.to(areaImages, {time=500, xScale=4, yScale=4, onComplete=destroy(areaImages)})
		imageGroup:insert(areaImages)
		return imageGroup
	end

	for i=1, imageGroup.numChildren, 1 do
		animateExplosion(imageGroup[i])
	end

	return imageGroup
end

	return group
end
