local mods = peripheral.wrap("back")
-- ensure glasses are present
local err, str = false, ""
if not mods.canvas then
	error("Shatter requires Overlay Glasses", 2)
end

function addTerm(can)
	-- ###TERMINAL API CODE###-- 

	-- colors, for reference use
	local colors = {white = 0xf0f0f000, orange = 0xf2b23300, magenta = 0xe57fd800, lightBlue = 0x99b2f200, yellow = 0xdede6c00, lime = 0x7fcc1900, pink = 0xf2b2cc00, gray = 0x4c4c4c00, lightGray = 0x99999900, cyan = 0x4c99b200, purple = 0xb266e500, blue = 0x3366cc00, brown = 0x7f664c00, green = 0x57a64e00, red = 0xcc4c4c00, black = 0x19191900}

	-- colors by number
	local cbn = {colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.gray, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black}

	-- default term scale
	local ox, oy = 6, 9

	-- default term scale
	local sx, sy = 6, 9

	-- term bg and fg colors and alpha values
	local bg, fg, bgbn, fgbn, fga, bga, fgabn, bgabn = colors.black, colors.white, 2^(#cbn-1), 2^0, 255, 255, 1, 1

	-- cursor, pos, and blink
	local csr, cx, cy, cb = nil, 1, 1, true

	-- handler activity, used to ensure cursor is activated before the term is redirected to.
	local active = false

	-- term size
	local tx, ty = can.getSize()
	tx, ty = math.floor(tx/ox), math.floor(ty/oy)

	-- Table of functions to be outputted
	local out = {}

	-- screen rendering in a table
	local screen = {}


	out.screen = screen
	-- populate that table
	local function tPop()
		local x, y = can.getSize()
		for i = 1, math.floor(x/ox) do
			screen[i] = {}
			for j = 1, math.floor(y/oy) do
				screen[i][j] = {bg = {}, fg = {}}
			end
		end
	end
	tPop()

	-- write text in grid fashion and add to table
	local function write(x, y, char, color)
		x, y = math.floor(x), math.floor(y)
		if x > 0 and y > 0 and x <= tx and y <= ty then
			if not screen[x][y].fg.getColor then
				screen[x][y].fg = can.addText({((x-1)*ox)+1, ((y-1)*oy)+1}, char, color, ox/sx)
			else
				if screen[x][y].fg.getColor() ~= color then
					screen[x][y].fg.setColor(color)
				end
				if screen[x][y].fg.getText() ~= char then
					screen[x][y].fg.setText(char)
				end
			end
		end
	end

	-- draw pixel in grid fashion and add to table
	local function draw(x, y, color)
		x, y = math.floor(x), math.floor(y)
		if x > 0 and y > 0 and x <= tx and y <= ty then
			if not screen[x][y].bg.getColor then
				screen[x][y].bg = can.addRectangle((x-1)*ox, (y-1)*oy, ox, oy, color)
			else
				if screen[x][y].bg.getColor() ~= color then
					screen[x][y].bg.setColor(color)
				end
			end
		end
	end

	-- get the data of a particular pixel
	local function getData(pixel)
		if pixel then
			return {
				bgc = bit32.band(pixel.bg.getColor(), 2^32-1), -- Credit to MC:Anavrins for bit32 ingenuity
				fgc = bit32.band(pixel.fg.getColor(), 2^32-1),
				txt = pixel.fg.getText()
			}
		end
	end

	-- set the data of a particular pixel
	local function setData(pixel, data)
		if pixel and data then
			if pixel.bg.getPosition then
				local x, y = pixel.bg.getPosition()
				draw(math.floor(x/ox)+1, math.floor(y/oy)+1, data.bgc)
				write(math.floor(x/ox)+1, math.floor(y/oy)+1, data.txt, data.fgc)
			end
		end
	end

	-- populate term with default bg and fg colors.
	local function repopulate()
		local x, y = can.getSize()
		for i = 1, math.floor(x/ox) do
			for j = 1, math.floor(y/oy) do
				draw(i, j, bg)
			end
		end
		for i = 1, math.floor(x/ox) do
			for j = 1, math.floor(y/oy) do
				write(i, j, "", fg)
			end
		end
		csr = can.addText({cx*ox, (cy*oy)+1}, "", 0xffffffff, ox/sx)
	end

	-- A simple error message I am too lazy to type twice
	local function invCol(col)
		error("invalid color (got "..col..")", 2)
	end

	-- very basic implementation of base 2 logarithm
	local function lb2(num)
		return math.log(num)/math.log(2)
	end

	-- Converts a hex value into 3 seperate r, g, and b values
	local function torgba(hex)
		-- Technically also gets a value, but it thrown out due to what this is needed for
		-- Credit to MC:valithor2 for this algorithm
		local vals = {}
		for i = 1, 4 do
			vals[i] = hex%256
			hex = (hex-vals[i])/256
		end
		return vals[4]/255, vals[3]/255, vals[2]/255
	end

	local function refreshColor(oc, nc)
		-- refreshes terminal when palette values are manipulated
		for i = 1, #screen do
			for j = 1, #screen[i] do
				local op, changed = getData(screen[i][j]), false
				if op.bgc == oc then
					op.bgc = nc
					changed = true
				end
				if op.fgc == oc then
					op.fgc = nc
					changed = true
				end
				if changed then
					setData(screen[i][j], op)
				end
			end
		end
	end

	out.write = function(str)
		-- term.write
		str = tostring(str)
		for i = 1, #str do
			write(cx+i-1, cy, str:sub(i, i), fg+fga)
			draw(cx+i-1, cy, bg+bga)
		end
		cx = cx+#str
	end

	out.blit = function(str, tfg, tbg)
		-- term.blit
		if type(str) ~= "string" then
			error("bad argument #1 (expected string, got "..type(str)..")", 2)
		elseif type(tfg) ~= "string" then
			error("bad argument #2 (expected string, got "..type(tfg)..")", 2)
		elseif type(tbg) ~= "string" then
			error("bad argument #3 (expected string, got "..type(tbg)..")", 2)
		end
		for i = 1, #str do
			nfg = cbn[tonumber(tfg:sub(i,i), 16)+1]
			nbg = cbn[tonumber(tbg:sub(i,i), 16)+1]
			draw(cx+i-1, cy, nbg+bga)
			write(cx+i-1, cy, str:sub(i,i), nfg+fga)
		end
		cx = cx+#str
	end

	out.clear = function()
		-- term.clear
		for i = 1, tx do
			for j = 1, ty do
				write(i, j, "", fg+fga)
				draw(i, j, bg+bga)
			end
		end
	end

	out.clearLine = function()
		-- term.clearLine
		if cy > 0 and cy <= ty then
			for i = 1, tx do
				draw(i, cy, bg+bga)
				write(i, cy, "", fg+fga)
			end
		end
	end

	out.getCursorPos = function()
		-- term.getCursorPos
		return cx, cy
	end

	out.setCursorPos = function(x, y)
		-- term.setCursorPos
		if type(x) ~= "number" then
			error("bad argument #1 (expected number, got "..type(x)..")", 2)
		elseif type(y) ~= "number" then
			error("bad argument #2 (expected number, got "..type(y)..")", 2)
		end
		csr.setPosition((x-1)*ox, ((y-1)*oy)+1)
		cx, cy = x, y
	end

	out.setCursorBlink = function(b)
		-- term.setCursorBlink
		if type(b) ~= "boolean" then
			error("bad argument #1 (expected boolean, got "..type(b)..")", 2)
		end
		cb = b
	end

	out.isColor = function()
		-- term.isColor
		return true, "now with more alpha!"
	end

	out.getSize = function()
		-- term.getSize
		return tx, ty
	end

	out.scroll = function(amount)
		-- term.scroll
		local tcx, tcy = out.getCursorPos()
		if type(amount) ~= "number" then
			error("bad argument #1 (expected number, got "..type(amount)..")", 2)
		end
		for i = 1, tx, amount^0 do
			if i > 0 and i <= ty and i-amount > 0 and i-amount <= ty then
				screen[i-amount] = screen[i]
			elseif not (i > 0 and i <= ty) then
				out.setCursorPos(1, i)
				out.clearLine()
			end
		end
	end

	out.setTextColor = function(col)
		-- term.setTextColor
		if type(col) ~= "number" then
			error("bad argument #1 (number expected, got "..type(col)..")", 2)
		end
		if lb2(col) > #cbn or lb2(col) ~= math.ceil(lb2(col)) then
			invCol(col)
		else
			fg = cbn[lb2(col)+1]
			fgbn = col
			csr.setColor(fg+fga)
		end
	end

	out.setBackgroundColor = function(col)
		-- term.setBackgroundColor
		if type(col) ~= "number" then
			error("bad argument #1 (expected number, got "..type(col)..")", 2)
		end
		if lb2(col) > #cbn or lb2(col) ~= math.ceil(lb2(col)) then
			invCol(col)
		else
			bg = cbn[lb2(col)+1]
			bgbn = col
		end
	end

	-- Text & BG Alpha innovated by MC:Ale32bit
	out.setTextAlpha = function(val)
		-- set the alpha value of the text
		if type(val) ~= "number" then
			error("bad argument #1 (expected number, got "..type(val)..")", 2)
		end
		if val > 1 then val = 1 elseif val < 0 then val = 0 end
		fga = math.floor(val*255)
		fgabn = val
		csr.setAlpha(fga)
	end

	out.setBackgroundAlpha = function(val)
		-- set the alpha value of the background
		if type(val) ~= "number" then
			error("bad argument #1 (expected number, got "..type(val)..")", 2)
		end
		if val > 1 then val = 1 elseif val < 0 then val = 0 end
		bga = math.floor(val*255)
		bgabn = val
	end

	out.setTextHex = function(hex)
		-- set the hex color value of the text
		if type(tonumber(hex, 16)) ~= "number" then
			error("bad argument #1 (expected number, got "..type(hex)..")", 2)
		end
		fg = hex*0x100
		fgbn = 1
		csr.setColor(fg+fga)
	end

	out.setBackgroundHex = function(hex)
		-- set the hex color value of the background
		if type(tonumber(hex, 16)) ~= "number" then
			error("bad argument #1 (expected number, got "..type(hex)..")", 2)
		end
		bg = hex*0x100
		bgbn = 1
	end

	out.getTextColor = function()
		-- term.getTextColor
		return fgbn
	end

	out.getBackgroundColor = function()
		-- term.getBackgroundColor
		return bgbn
	end

	out.getTextAlpha = function()
		-- get the alpha value of the text
		return fgabn
	end

	out.getBackgroundAlpha = function()
		-- get the alpha value of the background
		return bgabn
	end

	out.getTextHex = function()
		-- get the hex color value of the text
		return fg
	end

	out.getBackgroundHex = function()
		-- get the hex color value of the background
		return bg
	end

	out.getPaletteColor = function(col)
		-- term.getPaletteColor
		if type(col) ~= "number" then
			error("bad argument #1 (number expected, got "..type(col)..")", 2)
		end
		if lb2(col) > #cbn or lb2(col) ~= math.ceil(lb2(col)) then
			invCol(col)
		end
		return torgba(cbn[lb2(col)+1])
	end

	out.setPaletteColor = function(cnum, r, g, b)
		-- term.setPaletteColor
		local oc = cbn[lb2(cnum)+1]
		if type(cnum) ~= "number" then
			error("bad argument #1 (number expected, got "..type(cnum)..")", 2)
		end
		if type(r) ~= "number" then
			error("bad argument #2 (number expected, got "..type(r)..")", 2)
		end
		if g then
			if type(g) ~= "number" then
				error("bad argument #3 (number expected, got "..type(g)..")", 2)
			elseif type(b) ~= "number" then
				error("bad argument #4 (number expected, got "..type(b)..")", 2)
			end
			if r > 1 then r = 1 elseif r < 0 then r = 0 end
			if g > 1 then g = 1 elseif g < 0 then g = 0 end
			if b > 1 then b = 1 elseif b < 0 then b = 0 end
			cbn[lb2(cnum)+1] = (((r*255)*(16^6))+((g*255)*(16^4))+((b*255)*(16^2)))
		else
			cbn[lb2(cnum)+1] = (r*256)
		end
		if bgbn == cnum then
			out.setBackgroundColor(bgbn)
		end
		if fgbn == cnum then
			out.setTextColor(fgbn)
		end
		refreshColor(oc, cbn[lb2(cnum)+1])
	end

	out.setTextScale = function(scale)
		if type(scale) ~= "number" then
			error("bad argument #1 (number expected, got "..type(scale)..")", 2)
		end
		if 0.4 >= scale or scale > 10 then
			error("Expected number in range 0.5-10", 2)
		end
		ox, oy = math.ceil(scale*sx), math.ceil(scale*sy)
		tx, ty = can.getSize()
		tx, ty = math.floor(tx/ox), math.floor(ty/oy)
		csr.remove()
		local oldscr = screen -- replicate the screen
		screen = {} -- remove it for repopulation of table w/ new scale
		tPop() -- repopulate table
		repopulate() -- add objects
		for i = 1, #oldscr do -- rerender screen in new scale
			for j = 1, #oldscr[i] do
				if oldscr[i][j].bg.getColor ~= nil then
					if screen[i] and screen[i][j] then
						setData(screen[i][j], getData(oldscr[i][j]))
					end
					oldscr[i][j].bg.remove()
					oldscr[i][j].fg.remove()
				end
			end
		end
		os.queueEvent("shatter_resize")
	end

	-- compat for all those UK'ers
	out.isColour = out.isColor
	out.setTextColour = out.setTextColor
	out.setBackgroundColour = out.setBackgroundColor
	out.setPaletteColour = out.setPaletteColor
	out.getTextColour = out.getTextColor
	out.getBackgroundColour = out.getBackgroundColor
	out.getPaletteColour = out.getPaletteColor

	-- ###TERMINAL CREATION CODE###-- 
	repopulate()
	local coro = function()
		parallel.waitForAll(function()
			-- cursor flicker
			while true do
				if not cb then
					csr.setText(" ")
					sleep()
				else
					csr.setText("_")
					sleep(.4)
					csr.setText(" ")
					sleep(.4)
				end
			end
		end,
		function()
			-- glasses event handler conversion
			while true do
				local e = {os.pullEvent()}
				if e[1]:find("glasses") then
					local _, b = e[1]:find("glasses")
					e[1], e[3], e[4] = "mouse"..e[1]:sub(b+1, -1), math.ceil(e[3]/ox), math.ceil(e[4]/oy)
					os.queueEvent(unpack(e))
				end
			end
		end)
	end

	return out, coro
end

return addTerm
