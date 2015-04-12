module(..., package.seeall)

function new()
	local group = display.newGroup()
	group.keys = 0

	local keyText = display.newText( "0" , 0, 0, "impact", 13 )
	keyText.anchorX, keyText.anchorY = 1, .5
	keyText.x = 145
	keyText.y = 15
	keyText.text = group.keys
	group:insert(keyText)

	function group:setKeys(keys)
		self.keys = keys
		keyText.text = self.keys
		keyText.anchorX, keyText.anchorY = 1, .5
		keyText.x = 145
		keyText.y = 15
	end

	function group:increaseKeysByN(n)
		self.keys = self.keys + n
		keyText.text = self.keys
		keyText.anchorX, keyText.anchorY = 1, .5
		keyText.x = 145
		keyText.y = 15
	end

	function group:getKeys()
		return self.keys
	end

	return group
end
