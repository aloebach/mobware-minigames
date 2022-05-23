--[[
	Paperclip class

	Author: Andrew Loebach

	for managing the Paperclip objects in "Dusty Cartridge" Minigame for Mobware Minigames		
]]

local gfx = playdate.graphics

Paperclip = {}
Paperclip.__index = Paperclip

Paperclip_sprite = gfx.image.new("Minigames/dusty_cartridge/images/paperclip")

function Paperclip:new(x, y, dx, dy)
	local self = playdate.graphics.sprite:new(Paperclip_sprite)
	self:moveTo(x, y)
	self:setZIndex(1)
	self:addSprite()
	local rotation = math.random(0,360)
	self:setRotation(rotation)
	self.dx = dx
	self.dy = dy

	function self:update()

		-- move if threshold his high enough
		if mic_input > BLOW_THRESHOLD then
			self:moveTo(self.x + self.dx, self.y + self.dy)
		end

		-- remove Paperclip sprite if it's blown off the screen
		if self.x < 0 then self:remove() end
		if self.x > 400 then self:remove() end
		if self.y < 0 then self:remove() end
		if self.y > 240 then self:remove() end
	end

	return self
end
