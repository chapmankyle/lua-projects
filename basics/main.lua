-- main.lua
--
-- @about Describes the game logic.

-- load all entities
function love.load()
	player = require('entities/player')

	playerSize = 50
	enemyDim = 30
	crosshairDim = 35

	bulletWidth = 8
	bulletHeight = 8

	paused = false
	bulletSpeed = 200

	canShoot = true -- if player can shoot
	rateOfFire = 0.3
	shotTick = 0

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
	enemies = {}

	-- creats new player
	player:init(100, 100, 150, 'assets/person.png', playerSize)

	crosshair.img = love.graphics.newImage('assets/ch_w.png')
	crosshair.scale = crosshairDim / crosshair.img:getWidth()

	enemy.img = love.graphics.newImage('assets/enemy.png')
	enemy.scale = enemyDim / enemy.img:getWidth()

	local ico = love.image.newImageData('assets/logo.png')
	love.window.setIcon(ico)

	pauseFont = love.graphics.newFont('fonts/back-to-1982.regular.ttf', 30)

	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.mouse.setVisible(false)
end

-- adds a bullet into the bullet table
function shoot(x, y)
	local startX = player.x + (playerSize / 2)
	local startY = player.y + (playerSize / 2)
	local mouseX = x + (crosshairDim / 2)
	local mouseY = y + (crosshairDim / 2)

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
		if shotTick > rateOfFire then
			canShoot = true
			shotTick = 0
		end
	end
end

-- updates bullet positions
function updateBullets(dt)
	for k, v in ipairs(bullets) do
		v.x = v.x + (v.dx * dt)
		v.y = v.y + (v.dy * dt)
	end
end

-- pauses game on focus lost
function love.focus(f)
	paused = not f
end

-- checks for key presses
function love.keypressed(key)
	-- checks for quitting
	if key == 'escape' then
		love.event.push('quit')
	end

	-- checks for pause
	if key == 'p' then
		paused = not paused
		if not paused then love.mouse.setVisible(false) end
	end
end

-- update entities with respect to delta-time (dt)
function love.update(dt)
	if paused then
		return
	end

	player:update(dt)
	checkShooting(dt)
	updateBullets(dt)
end

-- draws bullets onto the screen
function drawBullets()
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
		--[[
		if checkCollision(v.x, v.y, bulletWidth, bulletHeight,
				enemy.x, enemy.y, enemySize, enemySize) then
			-- do collision detection
		end
		--]]
	end
	love.graphics.pop()
end

-- draw pause screen
function drawPause()
	love.graphics.push("all")
	love.mouse.setVisible(true)

	-- draw dim screen
	love.graphics.setColor(0, 0, 0, 0.3)
	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 30, 35, 360, 65)

	love.graphics.setColor(124 / 255, 174 / 255, 255 / 255)
	love.graphics.setFont(pauseFont)
	love.graphics.print("PAUSED", 120, 50)

	love.graphics.pop()
end

-- draw all updates on screen
function love.draw()
	love.graphics.setBackgroundColor(96 / 255, 125 / 255, 139 / 255, 1.0)

	-- draws player
	player:draw()
	love.graphics.draw(enemy.img, enemy.x, enemy.y, 0, enemy.scale, enemy.scale)

	drawBullets()

	if paused then
		drawPause()
	else
		love.graphics.draw(crosshair.img, love.mouse.getX(), love.mouse.getY(),
			0, crosshair.scale, crosshair.scale)
	end

	love.graphics.print("FPS: " .. love.timer.getFPS(), 5, 5)
end
