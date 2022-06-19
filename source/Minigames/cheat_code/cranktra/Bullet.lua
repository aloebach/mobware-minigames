--[[
	Cranktra
	bullet class

	for managing the bullets flying around the screen
]]

local gfx = playdate.graphics

Bullet = {}
Bullet.__index = Bullet

-- pre-render bullet image
local bullet_image = gfx.image.new(6, 6)

gfx.lockFocus(bullet_image)
	-- black outline
	gfx.setColor(gfx.kColorBlack)
	gfx.fillCircleAtPoint(3, 3, 3)
	-- white bullet
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(1, 1, 3, 3)
gfx.unlockFocus()


function Bullet:new()
	local self = playdate.graphics.sprite:new(bullet_image)
	
	self:setSize(6, 6)
	self:setCollideRect(1, 1, 3, 3) 	-- hitbox is only the white center of the bullet
	
	function self:setVelocity(dx, dy)
		self.dx = dx
		self.dy = dy
	end
	
	function self:update()
		--self:moveWithCollisions(self.x + self.dx, self.y + self.dy)
		self:moveTo(self.x + self.dx, self.y + self.dy)
		if self.x < 0 then self:remove() end
		if self.x > 400 then self:remove() end
		if self.y < 0 then self:remove() end
		if self.y > 240 then self:remove() end
	end
		
	return self

end

