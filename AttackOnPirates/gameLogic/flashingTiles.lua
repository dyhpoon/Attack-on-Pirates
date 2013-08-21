module(..., package.seeall)

function new()
	local timers = {}
	local group = display.newGroup()
	local threshold = 1
	local gemYPosition = 138

	function group:createTile(i, j)
		local rect = display.newRect(i*40-40, j*40+gemYPosition - 20, 40, 40)
		rect:setFillColor(255, 255, 255)
		rect.isFlashing = true
		rect.alpha = 0
		self:insert(rect)
	end

	function group:deleteAll()
		for i=group.numChildren,1,-1 do
			local temp = self[i]
			temp:removeSelf()
			temp = nil
		end
	end

	local function updateThreshold()
		threshold = (threshold + 1) % 2
		if threshold == 0 then
			for i=1,group.numChildren,1 do
				group[i].alpha = 0.5
			end
		elseif threshold == 1 then 
			for i=1,group.numChildren,1 do
				group[i].alpha = 0.8
			end
		end
	end

	local updateHandler = timer.performWithDelay(30, updateThreshold, 0)
	table.insert(timers, updateHandler)

	return {["timers"] = timers,
			["screen"] = group}
end
