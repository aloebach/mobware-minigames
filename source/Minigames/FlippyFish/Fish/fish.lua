
-- because math.floor is slow
local floor = function(n)
  return (n - n % 1)
end


class('Fish').extends(playdate.graphics.sprite)

function Fish:init()

	Fish.super.init(self)

	-- image table is 7 wide by 3 tall, each cell is 48x48 pixels
	-- self.swimImages = playdate.graphics.imagetable.new('Fish/fish')
	self.swimImages = playdate.graphics.imagetable.new('Minigames/FlippyFish/Fish/fish')

	self:setCollideRect(0, 0, 48, 48)
	self:setZIndex(800)

	self.kFishNormalState = 1
	self.kFishHoverState = 2

	self:reset()
	self:addSprite()
end


function Fish:reset()
	self.xd = 0
	self.yd = 0
	self.v = 0
	self.justSwam = 0	-- this is just a janky way to handle a two-frame angle animation change when a swim occurs

	self.frame = 0
	self:updateFrame()

	self:moveTo(playdate.display.getWidth() / 4, playdate.display.getHeight() / 4)

	-- state stuff for the hover state
	self.fishState = self.kFishHoverState
	self.hoverTime = 0
	self.hoverY = self.y
	self.wasHovering = true		-- messy and hacky
end



function Fish:up()

	self.wasHovering = false

	if self.fishState == self.kFishNormalState then
		if self.v > 160 then
			self.justSwam = 2
		elseif self.v > 100 then
			self.justSwam = 1
		end

		self.v = -160
	end
end


function Fish:left()
	if self.fishState == self.kFishNormalState then
		self.xd = -8
	end
end


function Fish:right()
	if self.fishState == self.kFishNormalState then
		self.xd = 8
	end
end


function Fish:updateFrame()

	-- figure out what angle we should be using based on our verical velocity
	-- fishAngle goes from 1 to 7, with 3 being completely horizontal
	-- self.frame itself ranges from 0 to 7, while actualFrame oscillates between 0 and 2

	local fishAngle = 3

	if self.fishState == self.kFishNormalState then

		if self.justSwam == 2 then
			fishAngle = 5
			self.justSwam = 1
		elseif self.justSwam == 1 then
			fishAngle = 3
			self.justSwam = 0
		else

			if self.v < 60 and self.wasHovering == false then
				fishAngle = 1
			elseif self.v < 90 and self.wasHovering == false then
				fishAngle = 2
			elseif self.v > 280 then
				fishAngle = 7
			elseif self.v > 240 then
				fishAngle = 6
			elseif self.v > 200 then
				fishAngle = 5
			elseif self.v > 150 then
				fishAngle = 4

			if self.v > 90 then
				self.wasHovering = false
			end

			end
		end
	end

	self.frame = (self.frame + 1) % 8
	local actualFrame = floor(self.frame / 2)
	if actualFrame == 3 then
		actualFrame = 1
	end

	-- stop swimming if we're nose-diving
	if self.v > 240 then
		actualFrame = 1
	end

	local tableWidth = 7
	self:setImage(self.swimImages[fishAngle + tableWidth * actualFrame])

end


function Fish:update()

	if self.fishState == self.kFishHoverState then
		self:updateHover()
	else
		self:updateNormal()
	end
end


function Fish:updateNormal()

	local a = 440 -- pixels per second^2
	local dt = 1.0/20

	self:updateFrame()

	self.v = self.v + a * dt
	if self.v > 400 then	-- terminal fish velocity
		self.v = 400
	end

	local distance = self.v * dt

	-- collision response logic for the fish instance (flippy) is handled in main.lua in `function flippy:collisionResponse(other)`
	self:moveWithCollisions(self.x + self.xd, self.y + distance)

	-- decelerate any x movement
	if (self.xd > 0.5 or self.xd < -0.5) then
		self.xd = self.xd * 0.8
	else
		self.xd = 0.0
	end
end


function Fish:updateHover()
	self:updateFrame()

	local dt = 1/20
	self.hoverTime = self.hoverTime + dt
	local occilationsPerSecond = 2.6
	local amplitude = 3.5
	local y = math.sin(math.pi * self.hoverTime * occilationsPerSecond) * amplitude
	self:moveTo(self.x, self.hoverY + y)
end
