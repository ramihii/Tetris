-- Tetris for TI-nspire CX CAS


shapes = {-- typ 1 = same in every rotation, typ 2 = has 2 roation states, typ 4 = has 4 rotation states
	-- square
	{color = 1, typ = 1, {
		0,0,0,0,
		0,0,0,0,
		1,1,0,0,
		1,1,0,0}
	},
	-- line
	{color = 2, typ = 2, {
		1,0,0,0,
		1,0,0,0,
		1,0,0,0,
		1,0,0,0},
		{
		0,0,0,0,
		0,0,0,0,
		0,0,0,0,
		1,1,1,1}
	},
	-- Z-shape
	{color = 3, typ = 2, {
		0,0,0,0,
		0,1,0,0,
		1,1,0,0,
		1,0,0,0},
		{
		0,0,0,0,
		0,0,0,0,
		1,1,0,0,
		0,1,1,0}
	},
	-- mirrored Z-shape
	{color = 4, typ = 2, {
		0,0,0,0,
		1,0,0,0,
		1,1,0,0,
		0,1,0,0},
		{
		0,0,0,0,
		0,0,0,0,
		0,1,1,0,
		1,1,0,0}
	},
	-- T-shape
	{color = 5, typ = 4, {
		0,0,0,0,
		0,0,0,0,
		0,1,0,0,
		1,1,1,0},
		{
		0,0,0,0,
		1,0,0,0,
		1,1,0,0,
		1,0,0,0},
		{
		0,0,0,0,
		0,0,0,0,
		1,1,1,0,
		0,1,0,0},
		{
		0,0,0,0,
		0,1,0,0,
		1,1,0,0,
		0,1,0,0}
	},
	-- L-shape
	{color = 6, typ = 4, {
		0,0,0,0,
		1,0,0,0,
		1,0,0,0,
		1,1,0,0},
		{
		0,0,0,0,
		0,0,0,0,
		1,1,1,0,
		1,0,0,0},
		{
		0,0,0,0,
		1,1,0,0,
		0,1,0,0,
		0,1,0,0},
		{
		0,0,0,0,
		0,0,0,0,
		0,0,1,0,
		1,1,1,0}
	},
	-- mirrored L-shape
	{color = 7, typ = 4, {
		0,0,0,0,
		0,1,0,0,
		0,1,0,0,
		1,1,0,0},
		{
		0,0,0,0,
		0,0,0,0,
		1,0,0,0,
		1,1,1,0},
		{
		0,0,0,0,
		1,1,0,0,
		1,0,0,0,
		1,0,0,0},
		{
		0,0,0,0,
		0,0,0,0,
		1,1,1,0,
		0,0,1,0}
	}
}

colors = {
	{id = 1, red = 255, green = 255, blue = 0},   -- yellow  / square shape
	{id = 2, red = 0,   green = 255, blue = 255}, -- cyan    / line shape
	{id = 3, red = 255, green = 0,   blue = 0},   -- red     / Z-shape
	{id = 4, red = 0,   green = 255, blue = 0},   -- green   / mirrored Z-shape
	{id = 5, red = 255, green = 0,   blue = 255}, -- magenta / T-shape
	{id = 6, red = 255, green = 127, blue = 0},   -- orange  / L-shape
	{id = 7, red = 0,   green = 0,   blue = 255}  -- blue    / mirrored L-shape
}

screen = platform.window
scrWidth = screen:width()
scrHeight = screen:height()

-- constants
shapeCount = 7
tileSize = 13
areaWidth = 10
areaHeight = 16

-- state data
blockArea = {} -- 10x16
gcColor = 0

--current
currentTile = nil  -- unrotated shape
currentShape = nil -- rotated shape
currentRot = 1
currentColor = 1

--next
nextTile = nil
nextShape = nil
nextRot = 1
nextColor = 1

gameover = false
fallingX = 2
fallingY = 1
score = 0
scoreStr = "Score: "

function reset()
	for x=1, areaWidth do
		blockArea[x] = {}
		for y=1, areaHeight do
			blockArea[x][y] = 0
		end
	end
	
	currentColor = {}
	nextColor = {}
	randomizeShape()
	gameover = false
	fallingX = 2
	fallingY = 1
	score = 0
	scoreStr = "Score: "
end

function randomizeShape()
	fallingX = 2
	fallingY = 4
	
	local i = math.random(shapeCount)
	local buf = shapes[i]
	if nextShape == nil then
		-- init
		currentRot = math.random(buf.typ)
		currentTile = buf
		currentShape = currentTile[currentRot]
		currentColor = colors[currentTile.color]
	else
		-- normal
		currentRot = nextRot
		currentTile = nextTile
		currentShape = nextShape
		currentColor = nextColor
	end
	
	-- setup for next shape
	i = math.random(shapeCount)
	buf = shapes[i]
	
	nextRot = math.random(buf.typ)
	nextTile = buf
	nextShape = nextTile[nextRot]
	nextColor = colors[nextTile.color]
	
	--print("selected " .. i .. ":" .. rot)
end

function on.construction()
	reset()
end

function falldown()
	if fallingY == areaHeight then
		weld()
		randomizeShape()
		screen:invalidate()
	else
		for x=0, 3 do
			for y=3, 0, -1 do
				if currentShape[y * 4 + x] == 1 then
					if blockArea[fallingX + x][fallingY + 3 - y + 1] ~= 0 then
						print("whaa")
						weld()
						randomizeShape()
						screen:invalidate()
						return
					end
				end
				
			end
		end
		
		fallingY = fallingY + 1
	end
end

function weld()
	for x=3, 0, -1 do
		for y=3, 0, -1 do
			if currentShape[y * 4 + x] == 1 then
				setBlock(fallingX + x, fallingY - 3 + y, currentColor.id)
			end
		end
	end
end

function setBlock(x, y, id)
	if x > 0 and x <= areaWidth then
		if y > 0 and y <= areaHeight then
			blockArea[x][y] = id
		end
	end
end

function rotate()
	currentRot = currentRot + 1
	if currentRot > currentTile.typ then
		currentRot = 1
	end
	
	currentShape = currentTile[currentRot]
	screen:invalidate()
end

function movex(dir) -- broken
	if dir then
		local width = 4
		for y=3, 0, -1 do
			for x=3, 0, -1 do
				if currentShape[y * 4 + x + 1] == 1 then
					if fallingX + x + 1 > areaWidth then
						return
					end
					if blockArea[fallingX + x + 1][fallingY - y] ~= 0 then
						return
					end
				end
			end
		end
		
		fallingX = fallingX + 1
		
		if fallingX + width > areaWidth then
			fallingX = areaWidth - width
		end
	else
		fallingX = fallingX - 1
		
		if fallingX < 0 then
			fallingX = 0
		end
	end
	screen:invalidate()
	--print(fallingX .. " " .. fallingY)
end

function on.paint(gc)
	--print(scrWidth .. " " .. scrHeight)
	gc:setColorRGB(100, 100, 100)
	gcColor = 0
	gc:fillRect(0,0, areaWidth * tileSize, areaHeight * tileSize)
	
	drawArea(gc)
	
	drawFalling(gc)
end

function drawArea(gc)
	for x=1, areaWidth do
		for y=1, areaHeight do
			if blockArea[x][y] > 0 then
				setColor(blockArea[x][y], gc)
				gc:fillRect((x - 1) * tileSize, (y - 1) * tileSize, tileSize, tileSize)
			end
		end
	end
end

function drawFalling(gc)
	setColor(currentColor.id, gc)
	for i=0, 15 do
		if currentShape[i + 1] == 1 then
			--print("a")
			gc:fillRect((fallingX + (i % 4)) * tileSize, (fallingY - 4 + math.floor(i / 4)) * tileSize, tileSize, tileSize)
			--print((i % areaWidth) .. " " .. math.floor(i / areaWidth))
		end
		
	end

end

function setColor(id, gc)
	if id ~= gcColor then
		gcColor = id
		--print(id)
		gc:setColorRGB(colors[id].red, colors[id].green, colors[id].blue)
	end
end

function on.enterKey()
	rotate()
end

function on.arrowKey(key)
	if key == "left" then
		movex(false)
	elseif key == "right" then
		movex(true)
	elseif key == "down" then
		falldown()
	end
end
