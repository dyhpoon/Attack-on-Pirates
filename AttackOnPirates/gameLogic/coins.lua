module(..., package.seeall)

function new()
	local group = display.newGroup()
	group.coins = 0

	local coinText = display.newText( "0" , 0, 0, "impact", 13 )
	coinText:setReferencePoint(display.CenterRightReferencePoint)
	coinText.x = 218
	coinText.y = 15
	coinText.text = group.coins
	group:insert(coinText)

	function group:setCoins(coins)
		self.coins = coins
		coinText.text = self.coins
		coinText:setReferencePoint(display.CenterRightReferencePoint)
		coinText.x = 218
		coinText.y = 15
	end

	function group:increaseCoinsByN(n)
		self.coins = self.coins + n
		coinText.text = self.coins
		coinText:setReferencePoint(display.CenterRightReferencePoint)
		coinText.x = 218
		coinText.y = 15
	end

	function group:getCoins()
		return self.coins
	end

	return group
end
