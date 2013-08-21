module(..., package.seeall)

function new(x,y)
	local group = display.newGroup()

	local redBar = display.newRect(x, y, 35, 4)
	group:insert(redBar)
	redBar:setFillColor(255, 0, 0)
 
	local greenBar = display.newRect(x, y, 35, 4)
	greenBar:setReferencePoint(display.TopLeftReferencePoint)
	group:insert(greenBar)
	greenBar:setFillColor(0, 255, 0)
 
	function group:setHealth(current, max)
		local percent = current / max
		if percent <= 0 then 
			percent = 0.0001
			greenBar.alpha = 0
		else
			greenBar.alpha = 1
		end
		greenBar.xScale = percent
		--greenBar.x = redBar.x + greenBar.xReference
	end
 
	return group

end
