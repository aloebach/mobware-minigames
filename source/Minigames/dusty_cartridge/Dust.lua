--[[
	Dust class

	Author: Andrew Loebach

	for managing the dust specks in "Dusty Cartridge" Minigame for Mobware Minigames		
]]

local gfx = playdate.graphics

Dust = {}
Dust.__index = Dust

dust_sprite = gfx.image.new("Minigames/dusty_cartridge/images/dust_speck")

function Dust:new(x, y)
	local self = playdate.graphics.sprite:new(dust_sprite)
	self:moveTo(x, y)
	self:setZIndex(1)
	self:addSprite()

	-- set velocity
	self.dx = math.random(-10,10)
	self.dy = -10 -- make dy constant so the dust always goes away from the player
	
	function self:update()

		-- move if threshold his high enough
		if mic_input > BLOW_THRESHOLD then
			self:moveTo(self.x + self.dx, self.y + self.dy)
		end

		-- remove dust sprite if it's blown off the screen
		if self.x < 0 then self:remove() end
		if self.x > 400 then self:remove() end
		if self.y < 0 then self:remove() end
		if self.y > 240 then self:remove() end
	end

	return self
end
