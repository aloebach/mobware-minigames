class('Bar').extends(playdate.graphics.sprite)

function Bar:init(orientation)

	Bar.super.init(self)
	self.name = "bar"
	self.speed = 3
	-- Init orientation
	if orientation ~= "left" and orientation ~= "right" then
		orientation = "left"
	end
	self.orientation = orientation
	local x = 20
	if self.orientation == "right" then
		x = 400 - 20
	end
	-- Init sprite
	local img = self:getDrawnImage()
	self:setImage(img)
	self:moveTo(x, (240 - self.height) / 2 + 4)
	self:setCollideRect(0, 0, self.width, self.height)
	self:add()
	return self

end

function Bar:getDrawnImage()

	local barWidth = 16
	local barHeight = 48
	local borderRadius = 4
	local lineWidth = 4
	local img = playdate.graphics.image.new(barWidth, barHeight)
	playdate.graphics.pushContext(img)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(0, 0, barWidth, barHeight, borderRadius)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeInside)
		playdate.graphics.setLineWidth(lineWidth)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.drawRoundRect(0, 0, barWidth, barHeight, borderRadius)
	playdate.graphics.popContext()
	return img

end

function Bar:moveY(y)

	local actualX, actualY, collisions, length = self:moveWithCollisions(self.x, y)

end

function Bar:collisionResponse(other)

	return playdate.graphics.sprite.kCollisionTypeBounce

end
