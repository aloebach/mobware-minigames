
import 'extras/asheteroids/vectorsprite'

Asteroid = {}
Asteroid.__index = Asteroid

asteroidCount = 0

local geom = playdate.geometry

local explosion_noise = playdate.sound.sampleplayer.new('extras/asheteroids/sounds/explosion')

function Asteroid:new()
	local self = VectorSprite:new({5,0, 0,5, -5,0, 0,-5, 5,0})
	self.type = "asteroid"
	self.wraps = true

	asteroidCount += 1

	function self:setLevel(s)
		self.size = s
		self:setScale(s)
	end
	
	self:setLevel(3)
	
	function self.collision(other)
		if other == player then
			player:hit(self)
		end
	end
	
	function self:boom()
		
		-- play explosion noise
		explosion_noise:play(1)
		
		-- increment score
		score += 1
		
		if self.size > 1 then
			-- break into three pieces
			local dx = self.dx
			local dy = self.dy
			
			-- push away from the ship
			local d = hypot(self.x - player.x, self.y - player.y)
			--dx += 2 * (self.x - player.x) / d
			--dy += 2 * (self.y - player.y) / d
			dx += 1 * (self.x - player.x) / d
			dy += 1 * (self.y - player.y) / d			
			self:setLevel(self.size-1)
			self:setVelocity(dx, dy, self.da + math.random(100) / 200.0 - 0.25)

			local a = Asteroid:new()
			a.angle = self.angle
			a:setVelocity(dx + 2 * math.random() - 1, dy + 2 * math.random() - 1, self.da + math.random(100) / 200.0 - 0.25)
			a:moveTo(self.x, self.y)
			a:setLevel(self.size)
			a:addSprite()

			a = Asteroid:new()
			a.angle = self.angle
			a:setVelocity(dx + 2 * math.random() - 1, dy + 2 * math.random() - 1, self.da + math.random(100) / 200.0 - 0.25)
			a:moveTo(self.x, self.y)
			a:setLevel(self.size)
			a:addSprite()

		else
			self:remove()
			asteroidCount -= 1

			if asteroidCount == 0 then
				levelCleared()
			end
		end
	end

	return self
end
