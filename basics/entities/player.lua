-- entities/self.lua
--
-- @about Describes the player entity.

local defPlayerImg = 'assets/person.png'

-- player table
local player = {
	x = nil,
	y = nil,
	speed = nil,
	img = nil,
	size = nil,
	scale = 1
}

-- initializes a new player
function player:init(x, y, speed, path, size)
	self.x = x or 100
	self.y = y or 100
	self.speed = speed or 150

	if path then
		self.img = love.graphics.newImage(path)
	else
		self.img = love.graphics.newImage(defPlayerImg)
	end

	self.size = size or 50
	self.scale = self.size / self.img:getWidth()
end

-- updates player position
function player:update(dt)
	if love.keyboard.isDown('up', 'w') then
		if self.y > 0 then
			self.y = self.y - (self.speed * dt)
		end
	end
	if love.keyboard.isDown('down', 's') then
		if self.y < (love.graphics.getHeight() - self.size) then
			self.y = self.y + (self.speed * dt)
		end
	end
	if love.keyboard.isDown('left', 'a') then
		if self.x > 0 then
			self.x = self.x - (self.speed * dt)
		end
	end
	if love.keyboard.isDown('right', 'd') then
		if self.x < (love.graphics.getWidth() - self.size) then
			self.x = self.x + (self.speed * dt)
		end
	end
end

-- draws player
function player:draw()
	love.graphics.draw(self.img, self.x, self.y, 0, self.scale, self.scale)
end

return player
