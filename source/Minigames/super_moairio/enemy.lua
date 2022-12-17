
class('Enemy').extends(playdate.graphics.sprite)

-- local references
local Point = playdate.geometry.point
local Rect = playdate.geometry.rect
local floor = math.floor

-- constants
local LEFT, RIGHT = 0, 1
local STEP_DISTANCE = 2
local spriteHeight, spriteWidth = 16, 16

-- class variables
local stepTimer = playdate.frameTimer.new(6)
stepTimer.repeats = true


function Enemy:init(initialPosition)
	
	Enemy.super.init(self)

	self.enemyImages = playdate.graphics.imagetable.new('Minigames/super_moairio/img/enemy')
	self:setImage(self.enemyImages:getImage(1))
	self:setZIndex(900)
	self:setCenter(0, 0)	-- set center point to left bottom
	self:setCollideRect(0,8,spriteWidth,spriteHeight-8) -- make the collision rect a bit shorter than the actual sprite
	self.position = initialPosition or Rect.new(0,0,1,1)
	self:setBounds(self.position)
	
	self.direction = LEFT
	self.crushed = false
end


function Enemy:collisionResponse(other)
	if other:isa(Player) then
		return "slide"
	end
	return "bounce"
end


function Enemy:changeDirections()
	self.direction = (self.direction + 1) % 2
end


function Enemy:crush()
	self.crushed = true
	self:setImage(self.enemyImages:getImage(2))
	self:clearCollideRect()
end


function Enemy:update()	-- sprite callback

	if self.crushed then
		return
	end
	
	-- if we're not crushed, step and move
	if self.direction == LEFT then
		self.position.x = self.position.x - STEP_DISTANCE
	else
		self.position.x = self.position.x + STEP_DISTANCE
	end


	if stepTimer.frame < 3 then
		self:setImage(self.enemyImages:getImage(1))
	else
		self:setImage(self.enemyImages:getImage(1), "flipX")
	end
	
end
