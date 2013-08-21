module(..., package.seeall)

local localStorage = require 'gameLogic.localStorage'

function new()
	local group = display.newGroup()

	local numOfKeys = localStorage.get("keys")

	local keysText = display.newText("", 153, 151, native.systemFont, 9)
	keysText.text = numOfKeys
	group:insert(keysText)

	function group:refresh()
		keysText.text = localStorage.get("keys")
	end

	return group
end