local screenHeight = playdate.display.getHeight()

class('Ground').extends(playdate.graphics.sprite)

function Ground:init()

	Ground.super.init(self)

	self:setImage(playdate.graphics.image.new('extras/FlippyFish/Ground/ground'))

	self.xOffset = 0
	self.paused = false
	
	self:setCenter(0, 1)
	self:moveTo(0, screenHeight)
	
	self:setCollideRect(0, 0, self.width, self.height)
	self:setZIndex(500)
	self:addSprite()
	
	return self
end


-- sprite function overrides

function Ground:update()

	if self.paused == false then
	
		self.xOffset = self.xOffset + 4
		
		if ( self.xOffset > 18 ) then
			self.xOffset = 0
		end
		
-- 		self:moveTo(self.width / 2 - self.xOffset, screenHeight - self.height / 2)
		self:moveTo(-self.xOffset, screenHeight)
	end

end
