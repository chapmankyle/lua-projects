-- entities/camera.lua
--
-- @about Describes everything related to the camera

camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

camera.layers = {}

-- sets up the camera
function camera:set()
	love.graphics.push()
	love.graphics.rotate(-self.rotation)
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate(-self.x, -self.y)
end

-- destroys camera
function camera:unset()
	love.graphics.pop()
end

-- sets position of camera
function camera:setPosition(x, y)
	self.x = x or self.x
	self.y = y or self.y
end

-- sets zoom level of camera
function camera:setScale(sx, sy)
	self.scaleX = sx or self.scaleX
	self.scaleY = sy or self.scaleY
end

-- moves camera in a direction
function camera:move(dx, dy)
	self.x = self.x + (dx or 0)
	self.y = self.y + (dy or 0)
end

-- rotates camera
function camera:rotate(dir)
	self.rotation = self.rotation + dir
end

-- scales camera
function camera:scale(sx, sy)
	sx = sx or 1
	self.scaleX = self.scaleX * sx
	self.scaleY = self.scaleY * (sy or sx)
end

-- draws layers for parallax
function camera:draw()
	local bx, by = self.x, self.y

	for _, v in ipairs(self.layers) do
		self.x = bx * v.scale
		self.y = by * v.scale

		camera:set()
		v.draw()
		camera:unset()
	end
end

-- gets position of mouse inside game world
function camera:mousePosition()
	return  love.mouse.getX() * self.scaleX + self.x,
			love.mouse.getY() * self.scaleY + self.y
end

-- creates a new layer used for parallax scrolling
function camera:newLayer(scale, func)
	table.insert(self.layers, { draw = func, scale = scale })
	table.sort(self.layers, function(a, b) return a.scale < b.scale end)
end
