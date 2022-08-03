local screenWidth = playdate.display.getWidth()
local gfx = playdate.graphics

class('Score').extends(playdate.graphics.sprite)

function Score:init()

	Score.super.init(self)
	self.scoreFont = gfx.font.new('Minigames/FlippyFish/Score/Roobert-24-Medium-Numerals');
	self:setCenter(1,0)
	self:setScore(0)
	self:add()
end


function Score:addOne()
	self:setScore(self.score + 1)
end


function Score:setScore(newNumber)
	self.score = newNumber
	
	gfx.setFont(self.scoreFont)
	local width = gfx.getTextSize(self.score)
	self:setSize(width, 36)
	self:moveTo(screenWidth - 6, 6)
	self:markDirty()
end


-- draw callback from the sprite library
function Score:draw(x, y, width, height)
	
	gfx.setFont(self.scoreFont)
	gfx.drawText(self.score, 0, 0);
		
end
