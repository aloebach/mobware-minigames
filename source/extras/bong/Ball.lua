class('Ball').extends(playdate.graphics.sprite)

--TO-DO: randomize direction ball goes in when spawned
local directionX = -1
local directionY = -1
local initial_ball_speed = 8 

function Ball:init()

	Ball.super.init(self)
	self.speed = initial_ball_speed
	local img = self:getDrawnImage()
	self:setImage(img)
	self:moveTo(200, math.floor(math.random(40, 200)))
	--self:moveTo(200, math.floor(math.random(60, 140)))
	self:setCollideRect(0, 0, self.width, self.height)
	self:add()
	return self

end


function Ball:reset()
	self.speed = initial_ball_speed
	directionX *= -1
	self:moveTo(200, math.floor(math.random(40, 200)))
end


function Ball:getDrawnImage()
	local img = playdate.graphics.image.new(16, 16)
	playdate.graphics.pushContext(img)
		playdate.graphics.setColor(playdate.graphics.kColorBlack)
		playdate.graphics.fillRoundRect(0, 0, 16, 16, 8)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeInside)
		playdate.graphics.setLineWidth(4)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.drawRoundRect(0, 0, 16, 16, 8)
	playdate.graphics.popContext()
	return img
end

function Ball:move()

	local newX = self.x + (self.speed * directionX)
	local newY = self.y + (self.speed * directionY)
	local actualX, actualY, collisions, length = self:moveWithCollisions(newX, newY)
	if length > 0 then
		for key, collision in ipairs(collisions) do
			if collision.other.name == "bar" then
				local bar = collision.other
				if bar.orientation == "left" and actualX > bar.x then
					directionX = directionX * -1
				elseif bar.orientation == "right" and actualX < bar.x then
					directionX = directionX * -1
				end
			elseif collision.other.name == "wall" then
				directionY = directionY * -1
			end
		end
	end

end

function Ball:collisionResponse(other)

	bounce_sound:play(1)
	
	--TEST CODE:
	-- speed up ball slightly every time it hits a surface
	self.speed *= 1.05

	return playdate.graphics.sprite.kCollisionTypeBounce

end