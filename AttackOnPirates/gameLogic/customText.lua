module(..., package.seeall)

function new(text, x, y, fontname, size, r, g, b)
	local group = display.newGroup()

	local offset = size / 10
	local label = display.newText(text, x, y, (fontname), size)
	local shadow = display.newText(text, x+offset, y+offset, (fontname), size)
	label:setTextColor(r/255, g/255, b/255)
	shadow:setTextColor( 0/255, 0/255, 0/255, 255/255 )
	group:insert(shadow)
	group:insert(label)

	function group:setText(text)
		label.text = text
		shadow.text = text
	end

	return group
end
