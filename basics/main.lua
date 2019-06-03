-- main.lua
--
-- @about Describes the game logic.

-- Load all items needed
function love.load(arg)
	-- create new world with no gravity
	world = love.physics.newWorld(0, 0, true)

	playerDim = 50	-- dimensions for the player img
	enemyDim = 30
	crosshairDim = 35

	bulletWidth = 8
	bulletHeight = 8

	paused = false
	bulletSpeed = 200

	canShoot = true -- if player can shoot
	shotWait = 0.3
	shotTick = 0

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

	-- enemy table
	enemy = {
		x = 500,
		y = 500,
		img = nil,
		scale = 1
	}

	bullets = {}

	player.img = love.graphics.newImage('assets/person.png')
	player.scale = playerDim / player.img:getWidth()

	crosshair.img = love.graphics.newImage('assets/ch_w.png')
	crosshair.scale = crosshairDim / crosshair.img:getWidth()

	enemy.img = love.graphics.newImage('assets/enemy.png')
	enemy.scale = enemyDim / enemy.img:getWidth()

	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.mouse.setVisible(false)
end

-- adds a bullet into the bullet table
function shoot(x, y)
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
end

-- checks for collision of 2 entities
function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return	x1 < x2 + w2 and
			x2 < x1 + w1 and
			y1 < y2 + h2 and
			y2 < y1 + h1
end

-- checks for keystrokes
function checkInput(dt)
	-- check for quitting
	if love.keyboard.isDown('escape') then
		love.event.quit()
	end

	-- check for up, down, left and right (or w, s, a and d)
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

-- check for mouse presses
function checkShooting(dt)
	-- gets mouse position and shoots in direction
	mx, my = love.mouse.getPosition()
	if love.mouse.isDown('1') then
		if canShoot then
			shoot(mx, my)
			canShoot = false
		end
	end

	-- checks if player can shoot
	if not canShoot then
		shotTick = shotTick + dt
		if shotTick > shotWait then
			canShoot = true
			shotTick = 0
		end
	end
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

	checkInput(dt)
	checkShooting(dt)

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
	local enemySize = enemy.scale * enemy.img:getWidth()

	love.graphics.setBackgroundColor(96 / 255, 125 / 255, 139 / 255, 1.0)
	love.graphics.draw(player.img, player.x, player.y, 0, player.scale, player.scale)
	love.graphics.draw(enemy.img, enemy.x, enemy.y, 0, enemy.scale, enemy.scale)

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
		if checkCollision(v.x, v.y, bulletWidth, bulletHeight,
				enemy.x, enemy.y, enemySize, enemySize) then
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
