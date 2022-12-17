
class('Exit').extends(playdate.graphics.sprite)

function Exit:init(initialPosition)
	Exit.super.init(self)

	self:setCenter(0, 0)
	self:setCollideRect(4,14,8,2)	-- exits are a bit smaller than a regular tile
	
	self:moveTo(initialPosition)
end
