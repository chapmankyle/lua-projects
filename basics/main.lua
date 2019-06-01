-- main.lua
--
-- @about Describes the game logic.

-- Load all items needed
function love.load(arg)
	playerDim = 50	-- dimensions for the player img
	crosshairDim = 35

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

	player.img = love.graphics.newImage('assets/person.png')
	player.scale = playerDim / player.img:getWidth()

	crosshair.img = love.graphics.newImage('assets/ch_w.png')
	crosshair.scale = crosshairDim / crosshair.img:getWidth()

	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.mouse.setVisible(false)
end

-- Update with respect to delta-time (dt)
function love.update(dt)
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
end

-- Draw updates with respect to delta-time (dt)
function love.draw(dt)
	local x, y = love.mouse.getPosition()
	local FPS = love.timer.getFPS()

	love.graphics.setBackgroundColor(96 / 255, 125 / 255, 139 / 255, 1.0)
	love.graphics.draw(player.img, player.x, player.y, 0, player.scale, player.scale)
	love.graphics.draw(crosshair.img, x, y, 0, crosshair.scale, crosshair.scale)
	love.graphics.print("FPS: " .. tostring(FPS), 10, 10)
end
