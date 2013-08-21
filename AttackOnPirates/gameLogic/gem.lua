module(..., package.seeall)

local tableNumberOfColumns = 8
local tableNumberOfRows = 8

local gemYPosition = 138 -- 115

function newGem (i,j)
	local newGem
	
	local R = math.random(1, 13)
	
	if 		(R == 1 or R == 2 or R == 3) then 
		newGem = display.newImageRect("images/sword.png", 40, 40)
		newGem.gemType = "red"
		
	elseif 	(R == 4 or R == 5 or R == 6) then 
	
		newGem = display.newImageRect("images/potion.png", 40, 40)
		newGem.gemType = "green"
	
	elseif 	(R == 7 or R == 8 or R == 9) then 
	
		newGem = display.newImageRect("images/glass.png", 40, 40)
		newGem.gemType = "blue"
	
	elseif 	(R == 10 or R == 11 or R == 12) then 
	
		newGem = display.newImageRect("images/key.png", 40, 40)
		newGem.gemType = "yellow"

	elseif 	(R == 13) then 
	
		newGem = display.newImageRect("images/rainbow.png", 40, 40)
		newGem.gemType = "rainbow"
	
	end

	newGem.x = i*40-20
	newGem.y = -50
	newGem.i = i
	newGem.j = j
	newGem.isMarkedToDestroy = false
	newGem.isMarked = false
	newGem.class = "gem"
	newGem.destination_y = j*40+gemYPosition

	return newGem
end


function newBomb(i,j,type)
	local newBomb

	if type == "area" then
		newBomb = display.newImageRect("images/bombBlue.png", 40, 40)
	elseif type == "horizontal" or type == "vertical" then
		newBomb = display.newImageRect("images/bombGreen.png", 40, 40)
	elseif type == "cross" then
		newBomb = display.newImageRect("images/bombRed.png", 40, 40)
	end
	
	newBomb.x = i*40-20
	newBomb.y = j*40+gemYPosition

	newBomb.i = i
	newBomb.j = j
	newBomb.isMarked = false
	newBomb.isMarkedToDestroy = false
	newBomb.class = "bomb"
	newBomb.type = type
	newBomb.alpha = 0
	newBomb.bombType = type
	newBomb.xScale = 2
	newBomb.yScale = 2

	newBomb.destination_y = j*40+ gemYPosition

	return newBomb
end


