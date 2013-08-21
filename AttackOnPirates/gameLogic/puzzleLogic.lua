module(..., package.seeall)

function findMatchedTiles(gemsTable)
	local numberOfMarked = 0
	
	-- set all tiles to false
	for i = 1, 8, 1 do
		for j = 1, 8, 1 do
			gemsTable[i][j].isMarked = false
		end
	end

	-- helper function to find matched tiles, set to true for all searched tiles
	local function checkMatchedTiles(self)
		self.isMarked = true
		numberOfMarked = numberOfMarked + 1
		-- check on the left
		if self.i>1 then
			if (gemsTable[self.i-1][self.j]).isMarked == false then
				if (gemsTable[self.i-1][self.j]).gemType == self.gemType or (gemsTable[self.i-1][self.j]).gemType == "rainbow" then
					checkMatchedTiles( gemsTable[self.i-1][self.j] )
				end	 
			end
		end
		-- check on the right
		if self.i<8 then
			if (gemsTable[self.i+1][self.j]).isMarked == false then
				if (gemsTable[self.i+1][self.j]).gemType == self.gemType or (gemsTable[self.i+1][self.j]).gemType == "rainbow" then
					checkMatchedTiles( gemsTable[self.i+1][self.j] )
				end	 
			end
		end
		-- check above
		if self.j>1 then
			if (gemsTable[self.i][self.j-1]).isMarked == false then
				if (gemsTable[self.i][self.j-1]).gemType == self.gemType or (gemsTable[self.i][self.j-1]).gemType == "rainbow" then
					checkMatchedTiles( gemsTable[self.i][self.j-1] )
				end	 
			end
		end
		-- check below
		if self.j<8 then
			if (gemsTable[self.i][self.j+1]).isMarked == false then
				if (gemsTable[self.i][self.j+1]).gemType == self.gemType or (gemsTable[self.i][self.j+1]).gemType == "rainbow" then
					checkMatchedTiles( gemsTable[self.i][self.j+1] )
				end	 
			end
		end
	end

	for i = 1, 8, 1 do
		for j = 1, 8, 1 do
			numberOfMarked = 0
			if gemsTable[i][j].class == "bomb" then
				return true
			end
			checkMatchedTiles(gemsTable[i][j])
			if numberOfMarked >=3 then
				return true
			end
		end
	end
	return false
end

function findExplodedTiles(i, j, bombType, information)
	local bombSet = information["bombSet"]
	local gemsTable = information["gemsTable"]

	-- area
	if bombType == "area" then
		gemsTable[i][j].isMarkedToDestroy = true
		table.insert(bombSet, gemsTable[i][j])
		if i == 1 or i == 8 or j == 1 or j == 8 then
			if i == 1 and j == 1 then
				gemsTable[i+1][j].isMarkedToDestroy = true
				gemsTable[i+2][j].isMarkedToDestroy = true
				gemsTable[i][j+1].isMarkedToDestroy = true
				gemsTable[i+1][j+1].isMarkedToDestroy = true
				gemsTable[i+2][j+1].isMarkedToDestroy = true
				gemsTable[i][j+2].isMarkedToDestroy = true
				gemsTable[i+1][j+2].isMarkedToDestroy = true
				gemsTable[i+2][j+2].isMarkedToDestroy = true
				table.insert(bombSet, gemsTable[i+1][j])
				table.insert(bombSet, gemsTable[i+2][j])
				table.insert(bombSet, gemsTable[i][j+1])
				table.insert(bombSet, gemsTable[i+1][j+1])
				table.insert(bombSet, gemsTable[i+2][j+1])
				table.insert(bombSet, gemsTable[i][j+2])
				table.insert(bombSet, gemsTable[i+1][j+2])
				table.insert(bombSet, gemsTable[i+2][j+2])
			elseif i == 1 and j == 8 then
				gemsTable[i+1][j].isMarkedToDestroy = true
				gemsTable[i+2][j].isMarkedToDestroy = true
				gemsTable[i][j-1].isMarkedToDestroy = true
				gemsTable[i+1][j-1].isMarkedToDestroy = true
				gemsTable[i+2][j-1].isMarkedToDestroy = true
				gemsTable[i][j-2].isMarkedToDestroy = true
				gemsTable[i+1][j-2].isMarkedToDestroy = true
				gemsTable[i+2][j-2].isMarkedToDestroy = true
				table.insert(bombSet, gemsTable[i+1][j])
				table.insert(bombSet, gemsTable[i+2][j])
				table.insert(bombSet, gemsTable[i][j-1])
				table.insert(bombSet, gemsTable[i+1][j-1])
				table.insert(bombSet, gemsTable[i+2][j-1])
				table.insert(bombSet, gemsTable[i][j-2])
				table.insert(bombSet, gemsTable[i+1][j-2])
				table.insert(bombSet, gemsTable[i+2][j-2])
			elseif i == 8 and j == 1 then
				gemsTable[i-1][j].isMarkedToDestroy = true
				gemsTable[i-2][j].isMarkedToDestroy = true
				gemsTable[i][j+1].isMarkedToDestroy = true
				gemsTable[i-1][j+1].isMarkedToDestroy = true
				gemsTable[i-2][j+1].isMarkedToDestroy = true
				gemsTable[i][j+2].isMarkedToDestroy = true
				gemsTable[i-1][j+2].isMarkedToDestroy = true
				gemsTable[i-2][j+2].isMarkedToDestroy = true
				table.insert(bombSet, gemsTable[i-1][j])
				table.insert(bombSet, gemsTable[i-2][j])
				table.insert(bombSet, gemsTable[i][j-1])
				table.insert(bombSet, gemsTable[i-1][j-1])
				table.insert(bombSet, gemsTable[i-2][j-1])
				table.insert(bombSet, gemsTable[i][j-2])
				table.insert(bombSet, gemsTable[i-1][j-2])
				table.insert(bombSet, gemsTable[i-2][j-2])
			elseif i == 8 and j == 8 then
				gemsTable[i-1][j].isMarkedToDestroy = true
				gemsTable[i-2][j].isMarkedToDestroy = true
				gemsTable[i][j-1].isMarkedToDestroy = true
				gemsTable[i-1][j-1].isMarkedToDestroy = true
				gemsTable[i-2][j-1].isMarkedToDestroy = true
				gemsTable[i][j-2].isMarkedToDestroy = true
				gemsTable[i-1][j-2].isMarkedToDestroy = true
				gemsTable[i-2][j-2].isMarkedToDestroy = true
				table.insert(bombSet, gemsTable[i-1][j])
				table.insert(bombSet, gemsTable[i-2][j])
				table.insert(bombSet, gemsTable[i][j-1])
				table.insert(bombSet, gemsTable[i-1][j-1])
				table.insert(bombSet, gemsTable[i-2][j-1])
				table.insert(bombSet, gemsTable[i][j-2])
				table.insert(bombSet, gemsTable[i-1][j-2])
				table.insert(bombSet, gemsTable[i-2][j-2])
			else
				if i == 1 then
					gemsTable[i][j-1].isMarkedToDestroy = true
					gemsTable[i][j+1].isMarkedToDestroy = true
					gemsTable[i+1][j].isMarkedToDestroy = true
					gemsTable[i+1][j-1].isMarkedToDestroy = true
					gemsTable[i+1][j+1].isMarkedToDestroy = true
					table.insert(bombSet, gemsTable[i][j-1])
					table.insert(bombSet, gemsTable[i][j+1])
					table.insert(bombSet, gemsTable[i+1][j])
					table.insert(bombSet, gemsTable[i+1][j-1])
					table.insert(bombSet, gemsTable[i+1][j+1])
				elseif i == 8 then
					gemsTable[i][j-1].isMarkedToDestroy = true
					gemsTable[i][j+1].isMarkedToDestroy = true
					gemsTable[i-1][j].isMarkedToDestroy = true
					gemsTable[i-1][j-1].isMarkedToDestroy = true
					gemsTable[i-1][j+1].isMarkedToDestroy = true
					table.insert(bombSet, gemsTable[i][j-1])
					table.insert(bombSet, gemsTable[i][j+1])
					table.insert(bombSet, gemsTable[i-1][j])
					table.insert(bombSet, gemsTable[i-1][j-1])
					table.insert(bombSet, gemsTable[i-1][j+1])
				elseif j == 1 then
					gemsTable[i+1][j].isMarkedToDestroy = true
					gemsTable[i-1][j].isMarkedToDestroy = true
					gemsTable[i][j+1].isMarkedToDestroy = true
					gemsTable[i+1][j+1].isMarkedToDestroy = true
					gemsTable[i-1][j+1].isMarkedToDestroy = true
					table.insert(bombSet, gemsTable[i+1][j])
					table.insert(bombSet, gemsTable[i-1][j])
					table.insert(bombSet, gemsTable[i][j+1])
					table.insert(bombSet, gemsTable[i+1][j+1])
					table.insert(bombSet, gemsTable[i-1][j+1])
				elseif j == 8 then
					gemsTable[i+1][j].isMarkedToDestroy = true
					gemsTable[i-1][j].isMarkedToDestroy = true
					gemsTable[i][j-1].isMarkedToDestroy = true
					gemsTable[i+1][j-1].isMarkedToDestroy = true
					gemsTable[i-1][j-1].isMarkedToDestroy = true
					table.insert(bombSet, gemsTable[i+1][j])
					table.insert(bombSet, gemsTable[i-1][j])
					table.insert(bombSet, gemsTable[i][j-1])
					table.insert(bombSet, gemsTable[i+1][j-1])
					table.insert(bombSet, gemsTable[i-1][j-1])
				end
			end
		elseif 2 <= i and i <= 7 and 2 <= j and j <= 7 then
			gemsTable[i+1][j].isMarkedToDestroy = true
			gemsTable[i-1][j].isMarkedToDestroy = true
			gemsTable[i][j+1].isMarkedToDestroy = true
			gemsTable[i][j-1].isMarkedToDestroy = true
			gemsTable[i+1][j+1].isMarkedToDestroy = true
			gemsTable[i-1][j-1].isMarkedToDestroy = true
			gemsTable[i+1][j-1].isMarkedToDestroy = true
			gemsTable[i-1][j+1].isMarkedToDestroy = true
			table.insert(bombSet, gemsTable[i+1][j])
			table.insert(bombSet, gemsTable[i-1][j])
			table.insert(bombSet, gemsTable[i][j+1])
			table.insert(bombSet, gemsTable[i][j-1])
			table.insert(bombSet, gemsTable[i+1][j+1])
			table.insert(bombSet, gemsTable[i-1][j-1])
			table.insert(bombSet, gemsTable[i+1][j-1])
			table.insert(bombSet, gemsTable[i-1][j+1])
		end

	-- cross explosion
	elseif bombType == "cross" then
		for k = 1, 8, 1 do
			if k == j then
				-- do nothing
			else
				gemsTable[i][k].isMarkedToDestroy = true
				table.insert(bombSet, gemsTable[i][k])
			end
			gemsTable[k][j].isMarkedToDestroy = true
			table.insert(bombSet, gemsTable[k][j])
		end

	-- vertical explosion
	elseif bombType == "vertical" then
		for k = 1, 8, 1 do
			gemsTable[i][k].isMarkedToDestroy = true
			table.insert(bombSet, gemsTable[i][k])
		end

	-- horizontal explosion
	elseif bombType == "horizontal" then
		for k = 1, 8, 1 do
			gemsTable[k][j].isMarkedToDestroy = true
			table.insert(bombSet, gemsTable[k][j])
		end
	end

	information["bombSet"] = bombSet
	information["gemsTable"] = gemsTable

	return information
end

function isAdjacent(gem1, gem2)
	if (math.abs(gem1.i - gem2.i) + math.abs(gem1.j - gem2.j)) == 1 then
		return true
	else
		return false
	end
end

function updatePirateStatus(hp, mp, dmg, keys, table)
	-- initialize on the fly
	local colorsCount = {
		["red"] = 0,
		["green"] = 0,
		["blue"] = 0,
		["yellow"] = 0
	}

	-- start counting
	for i = 1, #table, 1 do
		if table[i].gemType == "red" then
			colorsCount["red"] = colorsCount["red"] + 1
		elseif table[i].gemType == "green" then
			colorsCount["green"] = colorsCount["green"] + 1
		elseif table[i].gemType == "blue" then
			colorsCount["blue"] = colorsCount["blue"] + 1
		elseif table[i].gemType == "yellow" then
			colorsCount["yellow"] = colorsCount["yellow"] + 1
		end
	end

	-- update
	local currentHealth = hp:getHealth()
	local currentMana = mp:getMana()
	hp:addHpBy(colorsCount["green"], "percent")
	--mp:setMana(currentMana + colorsCount["blue"], 100)
	mp:addMpBy(colorsCount["blue"])
	dmg:increaseDamageByN(colorsCount["red"])
	keys:increaseKeysByN(colorsCount["yellow"])
end

function updatePirateStatusWithCalculatedTable(hp, mp, dmg, keys, table)
	hp:addHpBy(table["green"], "percent")
	--mp:setMana(mp:getMana() + table["blue"], 100)
	mp:addMpBy(table["blue"])
	dmg:increaseDamageByN(table["red"])
	keys:increaseKeysByN(table["yellow"])
end
