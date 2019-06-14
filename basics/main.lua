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

	-- options when paused
	pauseOpts = {
		continue = {
			text = "Continue",
			x = 30,
			y = 200,
			show = function()
				return "Continue", 30, 200
			end
		},
		newGame = {
			text = "New Game",
			x = 30,
			y = 240,
			show = function()
				return "New Game", 30, 240
			end
		},
		options = {
			text = "Options",
			x = 30,
			y = 280,
			show = function()
				return "Options", 30, 280
			end
		},
		quitMain = {
			text = "Quit to Main Menu",
			x = 30,
			y = 320,
			show = function()
				return "Quit to Main Menu", 30, 320
			end,
		},
		quitDesktop = {
			text = "Quit to Desktop",
			x = 30,
			y = 360,
			show = function()
				return "Quit to Desktop", 30, 360
			end
		}
	}

	-- entities
	player:init(100, 100, 150, 'assets/person.png', playerSize)

	crosshair.img = love.graphics.newImage('assets/ch_w.png')
	crosshair.scale = crosshairDim / crosshair.img:getWidth()

	enemy.img = love.graphics.newImage('assets/enemy.png')
	enemy.scale = enemyDim / enemy.img:getWidth()

	-- window icon
	local ico = love.image.newImageData('assets/logo.png')
	love.window.setIcon(ico)

	-- fonts
	defaultFont = love.graphics.getFont()
	pauseFont = love.graphics.newFont('fonts/back-to-1982.regular.ttf', 30)

	-- miscellaneous
	love.graphics.setDefaultFilter('nearest', 'nearest')

	handCursor = love.mouse.getSystemCursor('hand')
	defCursor = love.mouse.getSystemCursor('arrow')

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

-- does actions relating to pausing the game
function doPause()
	paused = not paused
	if not paused then love.mouse.setVisible(false) end
end

-- checks input on hover
function checkOptionHover()
	love.mouse.setCursor(defCursor)

	local ctText, ctX, ctY = pauseOpts.continue.show()
	if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, ctX, ctY,
			defaultFont:getWidth(ctText), defaultFont:getHeight(ctText)) then
		love.mouse.setCursor(handCursor)
	end

	local ngText, ngX, ngY = pauseOpts.newGame.show()
	if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, ngX, ngY,
			defaultFont:getWidth(ngText), defaultFont:getHeight(ngText)) then
		love.mouse.setCursor(handCursor)
	end

	local optText, optX, optY = pauseOpts.options.show()
	if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, optX, optY,
			defaultFont:getWidth(optText), defaultFont:getHeight(optText)) then
		love.mouse.setCursor(handCursor)
	end

	local qmText, qmX, qmY = pauseOpts.quitMain.show()
	if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, qmX, qmY,
			defaultFont:getWidth(qmText), defaultFont:getHeight(qmText)) then
		love.mouse.setCursor(handCursor)
	end

	local qdText, qdX, qdY = pauseOpts.quitDesktop.show()
	if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, qdX, qdY,
			defaultFont:getWidth(qdText), defaultFont:getHeight(qdText)) then
		love.mouse.setCursor(handCursor)
	end
end

-- check for mouse click on one of the options buttons
function checkOptionClick()
	if love.mouse.isDown('1') then
		local ctText, ctX, ctY = pauseOpts.continue.show()
		if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, ctX, ctY,
				defaultFont:getWidth(ctText), defaultFont:getHeight(ctText)) then
			doPause()
			canShoot = false
			return
		end

		local ngText, ngX, ngY = pauseOpts.newGame.show()
		if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, ngX, ngY,
				defaultFont:getWidth(ngText), defaultFont:getHeight(ngText)) then
			print("Pressed New Game")
			return
		end

		local optText, optX, optY = pauseOpts.options.show()
		if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, optX, optY,
				defaultFont:getWidth(optText), defaultFont:getHeight(optText)) then
			print("Pressed Options")
			return
		end

		local qmText, qmX, qmY = pauseOpts.quitMain.show()
		if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, qmX, qmY,
				defaultFont:getWidth(qmText), defaultFont:getHeight(qmText)) then
			print("Pressed Quit to Main Menu")
			return
		end

		local qdText, qdX, qdY = pauseOpts.quitDesktop.show()
		if checkCollision(love.mouse.getX(), love.mouse.getY(), 10, 10, qdX, qdY,
				defaultFont:getWidth(qdText), defaultFont:getHeight(qdText)) then
			love.event.push('quit')
		end
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
		doPause()
	end
end

-- update entities with respect to delta-time (dt)
function love.update(dt)
	if paused then
		checkOptionHover()
		checkOptionClick()
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

	-- draw paused background
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", 30, 35, 360, 65)

	-- draw paused text
	love.graphics.setColor(124 / 255, 174 / 255, 255 / 255)
	love.graphics.setFont(pauseFont)
	love.graphics.print("PAUSED", 120, 50)

	-- draw options
	love.graphics.setFont(defaultFont)
	love.graphics.print(pauseOpts.continue.show())
	love.graphics.print(pauseOpts.newGame.show())
	love.graphics.print(pauseOpts.options.show())
	love.graphics.print(pauseOpts.quitMain.show())
	love.graphics.print(pauseOpts.quitDesktop.show())

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
