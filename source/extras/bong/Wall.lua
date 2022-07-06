class('Wall').extends(playdate.graphics.sprite)

function Wall:init(y)

	Wall.super.init(self)
	self.name = "wall"
	local img = self:getDrawnImage()
	self:setImage(img)
	self:setCenter(0, 0)
	self:moveTo(0, y)
	self:setCollideRect(0, 0, self.width, self.height)
	self:add()
	return self

end

function Wall:getDrawnImage()

	local img = playdate.graphics.image.new(400, 4)
	playdate.graphics.pushContext(img)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.fillRect(0, 0, 400, 4)
	playdate.graphics.popContext()
	return img

end

function Wall:collisionResponse(other)

	-- commented out by Drew
	--return playdate.graphics.sprite.kCollisionTypeBounce

end