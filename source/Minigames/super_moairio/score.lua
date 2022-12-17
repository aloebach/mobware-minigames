
class('Score').extends(playdate.graphics.sprite)

local gfx = playdate.graphics

-- load assets to be used to display score
local font = gfx.font.new('Minigames/super_moairio/img/SMB')
local coinImagesTable = gfx.imagetable.new('Minigames/super_moairio/img/coin')
local coin_image = coinImagesTable:getImage(1)

function Score:init()
	
	Score.super.init(self)

	self.font = playdate.graphics.font.new('Minigames/super_moairio/img/SMB')
	self.score = 0
	
	self:setZIndex(900)
	self:setIgnoresDrawOffset(true)
	self:setCenter(0, 0)
	self:setSize(48, 20)
	self:moveTo(10, 10)
end

function Score:addOne()
	self.score += 1
	self:markDirty()
end

function Score:draw()
	coin_image:draw(0,0)
	gfx.setFont(self.font)
	gfx.drawText(tostring(self.score), 16, 1)
end
