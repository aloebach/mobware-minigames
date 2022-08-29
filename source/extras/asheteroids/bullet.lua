
local gfx = playdate.graphics

Bullet = {}
Bullet.__index = Bullet

function Bullet:new()
	local self = playdate.graphics.sprite:new()
	
	self:setSize(3, 3)
	self:setCollideRect(0, 0, 3, 3)
	
	function self:setVelocity(dx, dy, da)
		self.dx = dx
		self.dy = dy
	end
	
	function self:update()
		local x,y,c,n = self:moveWithCollisions(self.x + self.dx, self.y + self.dy)
		
		for i=1,n do
			local other = c[i].other
			if other.type == "asteroid" then
				other:boom()
				self:remove()
			end
		end
		
		if self.x < 0 or self.x > 400 or self.y < 0 or self.y > 240 or self.removeme then
			self:remove()
		end
	end

	function self:draw()
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, 3, 3)
	end
	
	function self:collisionResponse(other)
		return "overlap"
	end

	return self
end
