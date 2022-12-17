
class('Player').extends(playdate.graphics.sprite)


-- local references
local Point = playdate.geometry.point
local Rect = playdate.geometry.rect
local vector2D = playdate.geometry.vector2D
local affineTransform = playdate.geometry.affineTransform
local min, max, abs, floor = math.min, math.max, math.abs, math.floor

-- constants
local dt = 0.05					-- time between frames at 20fps

local MAX_VELOCITY = 600
local GRAVITY_CONSTANT = 1680
local GRAVITY_STEP = vector2D.new(0, GRAVITY_CONSTANT * dt)
local JUMP_VELOCITY = 240
--local SUPERJUMP_VELOCITY = 380
local SUPERJUMP_VELOCITY = 340

local MAX_JUMP_VELOCITY = 420
local MAX_FALL_VELOCITY = 280

local GROUND_FRICTION = 0.8			-- could be increased for different types of terrain
local SKID_FRICTION = 1			-- stop more quickly if the player is trying to change directions
local RUN_VELOCITY = 10 			-- velocity change for running
local AIR_RUN_VELOCITY = 10 			-- velocity change for moving in the air
local SPEED_OF_RUNNING = 50			-- thea velocity at which we decide the player is running rather than walking

local LEFT, RIGHT = 1, 2
local STAND, RUN1, RUN2, RUN3, TURN, JUMP, CROUCH = 1, 2, 3, 4, 5, 6, 7

-- timer used for player jumps
local jumpTimer = playdate.frameTimer.new(5, 45, 45, playdate.easingFunctions.outQuad)
jumpTimer:pause()
jumpTimer.discardOnCompletion = false


-- local variables - these are "class local" but since we only have one player this isn't a problem
local minXPosition = 8
local maxXPosition = 0 -- real value set in level.lua importTilemapsFromTiledJSON()
playerStates = {}
local spriteHeight = 32
local onGround = true		-- true if player's feet are on the ground
local skidding = false		-- true if player is moving one way but the player is trying to move the opposite direction
local crouch = false
local facing = RIGHT
local MAX_RUN_VELOCITY = 240
local runImageIndex = 1


function Player:init()
	
	Player.super.init(self)

	self.playerImages = playdate.graphics.imagetable.new('Minigames/super_moairio/img/player')
	self:setImage(self.playerImages:getImage(1))
	self:setZIndex(1000)
	self:setCenter(0.5, 1)	-- set center point to center bottom middle
	--self:moveTo(102, 210)
	self:moveTo(2112, 204)
	self:setCollideRect(4,0,16,48)
	
	self.position = Point.new(102, 210)
	self.velocity = vector2D.new(0,0)
	self.alive = true
end


function Player:reset()
	self.position = Point.new(102, 108)
	self.velocity = vector2D.new(0,0)
end



function Player:collisionResponse(other)
	if other:isa(Coin) or (other:isa(Enemy) and other.crushed == true) then
		return "overlap"
	end
	
	return "slide"
end


-- called every frame, handles new input and does simple physics simulation
function Player:move()

	if playdate.buttonIsPressed("down") and onGround then
		
		self:setCrouching(true)
	else
		
		if onGround then
			self:setCrouching(false)
		end
		
		if playdate.buttonIsPressed("left") then
			if onGround then
				self:runLeft()
			else
				self:airRunLeft()	-- can still move left and right in the air, but not as quickly
			end
			
			if playdate.buttonJustPressed("left") then
				if self.velocity.x > SPEED_OF_RUNNING then	-- skid if Player moving fast enough and now is trying to go the other way
					skidding = true
				else
					skidding = false
				end
			end
			
		elseif playdate.buttonIsPressed("right") then
			if onGround then
				self:runRight()
			else
				self:airRunRight()
			end
			
			if playdate.buttonJustPressed("right") then
				if self.velocity.x < -SPEED_OF_RUNNING then
					skidding = true
				else
					skidding = false
				end
			end
		end
	end
	

	if onGround and (skidding == true or crouch == true or (playdate.buttonIsPressed("left") == false and playdate.buttonIsPressed("right") == false)) then
		
		if skidding == true then
			self.velocity.x = self.velocity.x * SKID_FRICTION
		else
			self.velocity.x = self.velocity.x * GROUND_FRICTION
		end
	end

	
	-- no longer skidding if we've slowed down this much
	if abs(self.velocity.x) < 10 then
		skidding = false
	end
	
	if playdate.buttonJustPressed("A") then
		self:jump()
	elseif playdate.buttonIsPressed("A") then
		self:continueJump()
	end
	
	-- set the maximum velocity based on if the O button is down or not
	if playdate.buttonIsPressed("B") then
		MAX_RUN_VELOCITY = 240
	else
		MAX_RUN_VELOCITY = 120
	end
		

	-- gravity
	self.velocity = self.velocity + GRAVITY_STEP

	-- don't accellerate past max velocity
	if self.velocity.x > MAX_RUN_VELOCITY then self.velocity.x = MAX_RUN_VELOCITY
	elseif self.velocity.x < -MAX_RUN_VELOCITY then self.velocity.x = -MAX_RUN_VELOCITY
	end

	if self.velocity.y > MAX_FALL_VELOCITY then self.velocity.y = MAX_FALL_VELOCITY 
	elseif self.velocity.y < -MAX_JUMP_VELOCITY then self.velocity.y = -MAX_JUMP_VELOCITY
	end
	
	-- update the index used to control which frame of the run animation Player is in. Switch frames faster when running quickly.
	if abs(self.velocity.x) < 10 then
		self.velocity.x = 0
		runImageIndex = 1
	elseif abs(self.velocity.x) < 140 then
		runImageIndex = runImageIndex + 0.5
	else
		runImageIndex = runImageIndex + 1
	end
	
	if runImageIndex > 3.5 then runImageIndex = 1 end
		
	
	-- update Player position based on current velocity
	local velocityStep = self.velocity * dt
	self.position = self.position + velocityStep
	
	-- don't move outside the walls of the game
	if self.position.x < minXPosition then
		self.velocity.x = 0
		self.position.x = minXPosition
	elseif self.position.x > maxXPosition then
		self.velocity.x = 0
		self.position.x = maxXPosition
	end
	
	self:updateImage()

end


-- sets the appropriate sprite image for Player based on the current conditions
function Player:updateImage()

	if crouch then
		
		if facing == LEFT then
			self:setImage(self.playerImages:getImage(CROUCH), "flipX")
		else
			self:setImage(self.playerImages:getImage(CROUCH))
		end
		
	elseif onGround then
		if facing == LEFT then
			if skidding then
				self:setImage(self.playerImages:getImage(TURN), "flipX")
			elseif self.velocity.x == 0 then
				self:setImage(self.playerImages:getImage(STAND), "flipX")
			else
				self:setImage(self.playerImages:getImage(floor(runImageIndex+1)), "flipX")
			end
		else
			if skidding then
				self:setImage(self.playerImages:getImage(TURN))
			elseif self.velocity.x == 0 then
				self:setImage(self.playerImages:getImage(STAND))
			else
				self:setImage(self.playerImages:getImage(floor(runImageIndex+1)))
			end
		end
	else
		if facing == LEFT then
			self:setImage(self.playerImages:getImage(JUMP), "flipX")
		else
			self:setImage(self.playerImages:getImage(JUMP))
		end
	end

end


function Player:setMaxX(x)
	maxXPosition = x
end


function Player:setOnGround(flag)
	onGround = flag
end


function Player:setCrouching(flag)
	crouch = flag
	
	if crouch then
		spriteHeight = 40
	else
		spriteHeight = 48
	end
end


function Player:isCrouching()
	return crouch
end


function Player:runLeft()
	facing = LEFT
	self.velocity.x = max(self.velocity.x - RUN_VELOCITY, -MAX_VELOCITY)
end


function Player:runRight()
	facing = RIGHT
	self.velocity.x = min(self.velocity.x + RUN_VELOCITY, MAX_VELOCITY)
	
end


function Player:airRunLeft()
	facing = LEFT
	self.velocity.x = self.velocity.x - AIR_RUN_VELOCITY
	if self.velocity.y < -MAX_VELOCITY then self.velocity.x = -MAX_VELOCITY end
end


function Player:airRunRight()
	facing = RIGHT
	self.velocity.x = self.velocity.x + AIR_RUN_VELOCITY
	if self.velocity.x > MAX_VELOCITY then self.velocity.x = MAX_VELOCITY end
end


function Player:jump()
	
	-- if feet on ground
	if onGround then
		
		if playdate.buttonIsPressed("A") and abs(self.velocity.x) > SPEED_OF_RUNNING then -- super jump
			self.velocity.y = -SUPERJUMP_VELOCITY
		else -- regular jump
			self.velocity.y = -JUMP_VELOCITY
		end
		
		jumpTimer:reset()
		jumpTimer:start()		
		
		skidding = false
		
		SoundManager:playSound(SoundManager.kSoundJump)
	end
	
end


function Player:continueJump()
	self.velocity.y = self.velocity.y - jumpTimer.value
end


function Player:die()
	
	-- play sound effect
	SoundManager:playSound("moai_hurt")
	
	-- creating easing function for death animation
	self.player_death_y = playdate.frameTimer.new(30, self.y, 600, playdate.easingFunctions.inBack)	

	gGameState = "player_dead"
	self.alive = nil
	
end				

