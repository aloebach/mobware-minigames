local Sprite = playdate.graphics.sprite

class('Seaweed').extends(Sprite)

-- the seaweed sprite itself is invisible and awards points when collided with
-- the visible parts of the seaweed are seaweedTop and seaweedBottom

function Seaweed:init()

	Seaweed.super.init(self)

	self.pointAwarded = false
	self.visible = false
	self:setBounds(0, 0, 26, 74)
	self:setCenter(0,0)
	self:setCollideRect(0, 0, self.width, self.height)
	self:setZIndex(10)

	-- set up the top and bottom seaweed sprites
	self.seaweedTop = Sprite.new()
	self.seaweedTop:setImage(playdate.graphics.image.new('extras/FlippyFish/Seaweed/seaweedTop'))
	self.seaweedTop:setCollideRect(0, 0, self.seaweedTop.width, self.seaweedTop.height)
	self.seaweedTop:setCenter(0,0)
	self.seaweedTop:setZIndex(10)
	self.seaweedTop:addSprite()
	self.seaweedBottom = Sprite.new()
	self.seaweedBottom:setImage(playdate.graphics.image.new('extras/FlippyFish/Seaweed/seaweedBottom'))
	self.seaweedBottom:setCollideRect(0, 0, self.seaweedBottom.width, self.seaweedBottom.height)
	self.seaweedBottom:setCenter(0,0)
	self.seaweedBottom:setZIndex(10)
	self.seaweedBottom:addSprite()
	
	self:resetPosition()
	self:addSprite()
end


function Seaweed:resetPosition()
	
	self:moveTo(playdate.display.getWidth() + 70, math.random(30, playdate.display.getHeight() - self.height - 66))
	self.seaweedTop:moveTo(self.x - 26, self.y - self.seaweedTop.height)
	self.seaweedBottom:moveTo(self.x - 26, self.y + self.height)

	self.pointAwarded = false
end


-- sprite function overrides

function Seaweed:update()

	if self.visible == true then
			
		local newX = self.x - 3
	
		self:moveTo(newX, self.y)
		self.seaweedTop:moveTo(newX - 26, self.seaweedTop.y)
		self.seaweedBottom:moveTo(newX - 26, self.seaweedBottom.y)
	end
end

function Seaweed:draw()
end