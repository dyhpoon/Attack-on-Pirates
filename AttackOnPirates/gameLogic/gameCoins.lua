module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'

function new()
	local group = display.newGroup()

	local coinsText = display.newText("", 275, 32, native.systemFont, 9)
	coinsText.text = localStorage.get("coins")
	group:insert(coinsText)

	function group:getCoins()
		return localStorage.get("coins")
	end

	function group:refresh()
		coinsText.text = self.getCoins()
	end

	return group
end
