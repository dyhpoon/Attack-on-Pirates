module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'

function new()
	local group = display.newGroup()

	local diamondsText = display.newText("", 275, 9, native.systemFont, 9)
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
