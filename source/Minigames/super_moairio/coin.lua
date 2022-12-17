
class('Coin').extends(playdate.graphics.sprite)

-- local references
local floor = math.floor

-- class variables
local coinTimer = playdate.frameTimer.new(7)	-- Timer to control coin animations
coinTimer.repeats = true

local coinImagesTable = playdate.graphics.imagetable.new('Minigames/super_moairio/img/coin')
local coinImages = {}
for i = 1,#coinImagesTable do
	coinImages[i] = coinImagesTable[i]
end

function Coin:init(initialPosition)
	Coin.super.init(self)

	self:setImage(coinImages[1])
	self:setZIndex(800)
	self:setCenter(0, 0)
	self:setCollideRect(0,0,12,16)	-- coins are a bit more narrow than a regular tile
	self:moveTo(initialPosition)
end


local setImage = playdate.graphics.sprite.setImage
local getImage = playdate.graphics.imagetable.getImage

function Coin:update()
	local frame = floor(coinTimer.frame / 2) + 1
	setImage(self, coinImages[frame])
end
