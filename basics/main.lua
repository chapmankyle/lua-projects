-- main.lua
--
-- @about Describes the game logic.

-- Load all items needed
function love.load(arg)
	-- create new world with no gravity
	world = love.physics.newWorld(0, 0, true)

	playerDim = 50	-- dimensions for the player img
	crosshairDim = 35

	bulletWidth = 8
	bulletHeight = 8

	paused = false
	bulletSpeed = 200

	-- player table
	player = {
		x = 100,
		y = 100,
		speed = 150,
		img = nil,
		scale = 1
	}

	-- crosshair table
	crosshair = {
		img = nil,
		scale = 1
	}

	bullets = {}

	player.img = love.graphics.newImage('assets/person.png')
	player.scale = playerDim / player.img:getWidth()

	crosshair.img = love.graphics.newImage('assets/ch_w.png')
	crosshair.scale = crosshairDim / crosshair.img:getWidth()

	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.mouse.setVisible(false)
end

-- Called when a mouse button is pressed
function love.mousepressed(x, y, button)
	if button == 1 then
		local playerSize = player.scale * player.img:getWidth()
		local mouseSize = crosshair.scale * crosshair.img:getWidth()

		local startX = player.x + (playerSize / 2)
		local startY = player.y + (playerSize / 2)
		local mouseX = x + (mouseSize / 2)
		local mouseY = y + (mouseSize / 2)

		local angle = math.atan2((mouseY - startY), (mouseX - startX))

		local bulletDx = bulletSpeed * math.cos(angle)
		local bulletDy = bulletSpeed * math.sin(angle)

		-- insert bullets into table
		table.insert(bullets, {
			x = startX,
			y = startY,
			dx = bulletDx,
			dy = bulletDy
		})
	elseif button == 2 then
		print('Aim')
	elseif button == 3 then
		print('Middle Mouse')
	end
end

-- checks for collision of 2 entities
function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return	x1 < x2 + w2 and
			x2 < x1 + w1 and
			y1 < y2 + h2 and
			y2 < y1 + h1
end

-- Pauses game on focus lost
function love.focus(f)
	paused = not f
end

-- Checks for key presses
function love.keypressed(key)
	if key == 'p' then
		paused = not paused
	end
end

-- Update with respect to delta-time (dt)
function love.update(dt)
	if paused then
		return
	end

	world:update(dt)

	-- quiting the game
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end

	if love.keyboard.isDown('up', 'w') then
		if player.y > 0 then
			player.y = player.y - (player.speed * dt)
		end
	end
	if love.keyboard.isDown('down', 's') then
		if player.y < (love.graphics.getHeight() - playerDim) then
			player.y = player.y + (player.speed * dt)
		end
	end
	if love.keyboard.isDown('left', 'a') then
		if player.x > 0 then
			player.x = player.x - (player.speed * dt)
		end
	end
	if love.keyboard.isDown('right', 'd') then
		if player.x < (love.graphics.getWidth() - playerDim) then
			player.x = player.x + (player.speed * dt)
		end
	end

	-- update bullet positions
	for k, v in ipairs(bullets) do
		v.x = v.x + (v.dx * dt)
		v.y = v.y + (v.dy * dt)
	end
end

-- Draw updates with respect to delta-time (dt)
function love.draw(dt)
	local x, y = love.mouse.getPosition()
	local FPS = love.timer.getFPS()

	love.graphics.setBackgroundColor(96 / 255, 125 / 255, 139 / 255, 1.0)
	love.graphics.draw(player.img, player.x, player.y, 0, player.scale, player.scale)
	love.graphics.rectangle("line", 500, 500, 30, 30)

	love.graphics.push("all")
	love.graphics.setColor(255 / 255, 87 / 255, 34 / 255)
	for k, v in ipairs(bullets) do
		if v.x > love.graphics.getWidth() or v.x < 0 then
			table.remove(bullets, k)
		elseif v.y > love.graphics.getHeight() or v.y < 0 then
			table.remove(bullets, k)
		else
			love.graphics.rectangle("fill", v.x, v.y, bulletWidth, bulletHeight)
		end

		-- collision detection
		if checkCollision(v.x, v.y, bulletWidth, bulletHeight, 500, 500, 30, 30) then
			-- do collision detection
		end
	end
	love.graphics.pop()

	love.graphics.draw(crosshair.img, x, y, 0, crosshair.scale, crosshair.scale)

	if paused then
		love.graphics.print("PAUSED", 300, 20)
	end

	love.graphics.print("FPS: " .. tostring(FPS), 10, 10)
end
