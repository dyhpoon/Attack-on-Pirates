module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'

function new(x, y)
	local group = display.newGroup()

	local diamondsText = display.newText("", x, y, native.systemFont, 9)
	diamondsText.text = localStorage.get("diamonds")
	group:insert(diamondsText)

	function group:getDiamonds()
		return localStorage.get("diamonds")
	end

	function group:refresh()
		diamondsText.text = self.getDiamonds()
	end

	return group
end
