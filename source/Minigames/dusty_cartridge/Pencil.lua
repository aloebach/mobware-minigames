--[[
	Pencil class

	Author: Andrew Loebach

	for managing the Pencil objects in "Dusty Cartridge" Minigame for Mobware Minigames		
]]

local gfx = playdate.graphics

Pencil = {}
Pencil.__index = Pencil

Pencil_sprite = gfx.image.new("Minigames/dusty_cartridge/images/pencil")

function Pencil:new(x, y, dx, dy)
	local self = playdate.graphics.sprite:new(Pencil_sprite)
	self:moveTo(x, y)
	self:setZIndex(1)
	self:addSprite()
	self:setRotation(15)
	self.dx = dx
	self.dy = dy

	function self:update()

		-- move if threshold his high enough
		if mic_input > BLOW_THRESHOLD then
			self:moveTo(self.x + self.dx, self.y + self.dy)
		end

		-- remove Pencil sprite if it's blown off the screen
		if self.x < 0 then self:remove() end
		if self.x > 400 then self:remove() end
		if self.y < 0 then self:remove() end
		if self.y > 240 then self:remove() end
	end

	return self
end
