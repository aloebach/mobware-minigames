
import 'extras/asheteroids/bullet'
import 'extras/asheteroids/vectorsprite'

Player = {}
Player.__index = Player

local bulletspeed = 10
local maxspeed = 8
local turnspeed = 7
local thrustspeed = 0.3

--> Initialize sound effects
local laser_noise = playdate.sound.sampleplayer.new('extras/asheteroids/sounds/laserShoot')
laser_noise:setVolume(0.5)
local explosion_noise = playdate.sound.sampleplayer.new('extras/asheteroids/sounds/explosion')
local thruster_noise = playdate.sound.sampleplayer.new('extras/asheteroids/sounds/thruster')

function Player:new()
	local self = VectorSprite:new({4,0, -4,3, -2,0, -4,-3, 4,0})
	
	self.thrust = { VectorSprite:new({-4, 3, -6,0, -4,-3}),
					VectorSprite:new({-4, 3, -9,0, -4,-3}) }

	self.thrust[1]:addSprite()
	self.thrust[2]:addSprite()

	self.thrust[1]:setVisible(false)
	self.thrust[2]:setVisible(false)
	self.thrustframe = 1

	self.da = 0
	self.dx = 0
	self.dy = 0
	self.angle = 0
	self.thrusting = 0
	self.wraps = true
	self.invincibility = 0
	
	function self:collide(s)
		print(s)
	end
	
	function self:turn(d)
		self.da = turnspeed * d
	end

	function self:hit(asteroid)
		if self.invincibility <= 0 then 
			thruster_noise:stop()
			explosion_noise:play(4, 2)
			gamestate = "player_hit"
		end
	end

	function self.collision(other)
		if other.type == "asteroid" then
			self:hit(other)
		end
	end

	function self:shoot()
		laser_noise:play(1)
		local b = Bullet:new()
		b:moveTo(self.x-1, self.y-1)
		b:setVelocity(self.dx + bulletspeed * math.cos(math.rad(self.angle)), self.dy + bulletspeed * math.sin(math.rad(self.angle)))
		b:addSprite()
	end
	
	function self:update()
		self:updatePosition()
		
		if self.invincibility > 0 then
			self.invincibility -= 1
			if self.invincibility % 2 == 1 then 
				self:setVisible(false)
			else
				self:setVisible(true)
			end
		end

		if self.thrusting == 1 
		then
			self.thrust[self.thrustframe]:setVisible(false)
			self.thrustframe = 3 - self.thrustframe

			local t = self.thrust[self.thrustframe]

			t:setVisible(true)
			t.angle = self.angle
			t:setScale(self.xscale, self.yscale)
			t:moveTo(self.x, self.y)
			t:updatePosition()

			local dx = self.dx + thrustspeed * math.cos(math.rad(self.angle))
			local dy = self.dy + thrustspeed * math.sin(math.rad(self.angle))
			local m = hypot(dx, dy)
			
			if m > maxspeed then
				dx *= maxspeed / m
				dy *= maxspeed / m
			end
			
			self:setVelocity(dx, dy)
		end
	end
	
	function self:startThrust()
		self.thrust[self.thrustframe]:setVisible(true)
		self.thrusting = 1
		thruster_noise:play(1)
	end

	function self:stopThrust()
		self.thrust[self.thrustframe]:setVisible(false)
		self.thrusting = 0
		thruster_noise:stop()
	end

	return self
end
