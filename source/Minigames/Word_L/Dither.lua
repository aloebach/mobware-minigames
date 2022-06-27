--[[
	Dither class

	Author: Andrew Loebach

	Dither for letters guessed incorrectly in Word L
]]

local gfx = playdate.graphics

Dither = {}
Dither.__index = Dither

local thick_dither = gfx.image.new("Minigames/Word_L/images/thick_dither_32x34")
local thin_dither = gfx.image.new("Minigames/Word_L/images/thin_dither_32x34")

function Dither:new(x, y, ditherType)

	local self
	
	if ditherType == "thick" then
		self = gfx.sprite:new( thick_dither )
	else
		self = gfx.sprite:new( thin_dither )
	end
	
	self:moveTo(x, y)
	self:add()

	return self
end
