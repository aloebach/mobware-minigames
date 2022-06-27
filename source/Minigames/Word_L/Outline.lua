--[[
	Outline class

	Author: Andrew Loebach

	Outline for letters guessed correctly in Word L		
]]

local gfx = playdate.graphics

Outline = {}
Outline.__index = Outline

local outline_image = gfx.image.new("Minigames/Word_L/images/correct_letter_indicator")

function Outline:new(x, y)
	local self = playdate.graphics.sprite:new(outline_image)
	self:moveTo(x, y)
	--self:setZIndex(1)
	self:add()

	return self
end
