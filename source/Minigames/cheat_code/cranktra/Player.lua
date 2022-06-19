--[[
	Player class for Cranktra
]]

class('Player').extends(AnimatedSprite)

-- initialize game variables
local gfx = playdate.graphics
local player_spritesheet = gfx.imagetable.new("Minigames/cheat_code/cranktra/images/bill_wiser")
local PLAYER_SPEED = 3
local FALL_SPEED = 0.08
local JUMP_VELOCITY = 6
local fall_counter = 0

local bulletspeed = 10
local bullet_rate = 3 -- lower number means faster shot
local bullet_counter = 0 


function Player:new(spawn_x, spawn_y)

	-- import animation states from json
	local animation_states = AnimatedSprite.loadStates("Minigames/cheat_code/cranktra/player_animations.json")

	-- initialize player animation
	self = Player.super.new(player_spritesheet, animation_states)
	self:setStates(animation_states)
    self:changeState("jump_right")
	self:playAnimation()
	self:setCollideRect( 10, 12, 16, 16 ) -- collision rectangle when jumping
    self:moveTo(spawn_x, spawn_y)
    --self:moveWithCollisions(spawn_x, spawn_y)

	self.dx = 0
	self.dy = 0 
	self.jumping = true
	self.crouching = false 
	self.orientation = "right"
	self.idle = false

	self.lives = 3

	function self:update()

		if self.currentState ~= "dead" then
			
			-- Player Controls:

			self.dx = 0

			-- Pressing up on the d-pad makes player jump
			if playdate.buttonJustPressed('up') then
				self:jump()
			end

			if playdate.buttonIsPressed('down') then
				-- crouch
				if self.jumping == false then 
					self.crouching = true
					-- set low collision rectangle
					self:setCollideRect( 0, 29, 30, 13 ) -- includes body, and legs
					
					if self.orientation == "right" then
						self:changeState("crouch") 
						bullet_angle = 0
					else
						self:changeState("crouch_left") 
						bullet_angle = math.rad(180)						
					end
				end
				
			elseif playdate.buttonIsPressed('left') then
				self.dx = -PLAYER_SPEED
				
			elseif playdate.buttonIsPressed('right') then
				self.dx = PLAYER_SPEED
				
			end
			--new_x = math.max( math.min(self.x + self.dx, level.player_max_X ), level.player_min_X)
			new_x = self.x + self.dx
			
			-- have crouching player stand up when down is no longer pressed
			if self.crouching == true and playdate.buttonIsPressed('down') == false then
				self.crouching = false
				print('stand back up!')
				self:calculate_bullet_angle()
				self:update_animation_state()
				self:setCollideRect( 10, 10, 12, 32 ) -- includes body, and legs
			end

			-- if player is above the i'm, player falls downward
			if self.y < level_floor(self.x,self.y) then
				self.dy = self.dy + FALL_SPEED * fall_counter
				fall_counter+=1

				-- if player hits the ground, land on ground exactly and set dy to zero
				if self.y + self.dy >= level_floor(self.x,self.y) then
					self:moveTo(new_x, level_floor(self.x,self.y))
					self.jumping = false
					self.dy = 0
					fall_counter = 0
					self:update_animation_state()
				end
			end
			new_y = math.min(self.y + self.dy, level_floor(self.x, self.y))

			self:moveWithCollisions(new_x, new_y)
			--self:moveTo(new_x, new_y)

			-- If crank position has changed, then update animation state
			crank_change, _acceleratedChange = playdate.getCrankChange()
			if crank_change ~= 0 then

				-- update animation state based on new crank angle
				self:update_animation_state()

				-- calculate new bullet angle
				self:calculate_bullet_angle()

			end


			-- pause animation if player isn't moving
			if self.dx ==0 and self.dy == 0 and self.jumping == false then
				--if self.idle == false then
					self.idle = true
					self:stopAnimation()
				--end
			else
				if self.idle == true then
					self.idle = false
					self:update_animation_state()
					self:playAnimation()
				end
			end
			
			-- Generate bullets if crank is undocked
			if bullet_counter == 1 and playdate.isCrankDocked() == false then
				local b = Bullet:new()
		        bullet_x_offset = 18 * math.cos(bullet_angle)
		        bullet_y_offset = 18 * math.sin(bullet_angle)
		        if playdate.buttonIsPressed('down') then
			        -- move y offset down if player is crouching
		        	bullet_y_offset += 17
		        end

		        b:moveTo(self.x + bullet_x_offset, self.y + bullet_y_offset)
		        b:setVelocity( bulletspeed * math.cos(bullet_angle), bulletspeed * math.sin(bullet_angle) )
				b:addSprite()
			end

		    bullet_counter += 1
		    if bullet_counter > bullet_rate then bullet_counter = 0 end

		    self:updateAnimation()

		end
	end


	function self:jump()
		
		-- If the player is on the ground
		if self.dy == 0 then

			self.jumping = true
			self:update_animation_state()
			self.dy = -JUMP_VELOCITY

		end
		
	end


	function self:update_animation_state()

		-- Control aim trajectory with crank
		local angle = playdate.getCrankPosition()

	    -- define collision rectangle for standing player
	    self:setCollideRect( 10, 10, 12, 32 ) -- includes body, and legs

	    -- jumping animation
		if self.jumping == true then
			
			if angle < 180 then
				self:changeState("jump_right")
			else
				self:changeState("jump_left")
			end

		    -- smaller collision rectangle when jumping
		    self:setCollideRect( 10, 12, 16, 16 ) -- includes just body, not legs
    

		-- if crank is docked, default to player facing right
		elseif playdate.isCrankDocked() == true then
			self:changeState("right")


		-- distinguish between 8 firing angles:
		-- up (~0 degrees)
		elseif angle > 338 then
			self:changeState("up(L)")

		elseif angle < 23 then
			self:changeState("up(R)")

		-- up_right (~45 degrees)
		elseif angle < 68 then
			self:changeState("up_right")

		-- right (~90 degrees)
		elseif angle < 113 then
			self:changeState("right")

		-- down_right (~135 degrees)
		--elseif angle < 158 then
		elseif angle < 180 then
			self:changeState("down_right")

		-- down (~180 degrees) 
		--> you can't shoot straight down standing, so no animation here

		-- down_left (~225)
		elseif angle < 248 then
			self:changeState("down_left")

		-- left (~270 degrees)
		elseif angle < 293 then
			self:changeState("left")

		-- up_left (~315 degrees)
		--elseif angle < 338 then
		else
			self:changeState("up_left")
		end


		-- if crank direction is the opposite as player direction set reverse = true
			--> This will get rid of the "moonwalking" animation phenomenon
		if (self.dx < 0  and angle < 180) or (self.dx > 0  and angle >= 180) then
			self.states.default.reverse = true
			-- alternate code: self.globalFlip = playdate.geometry.kFlippedX
		else
			self.states.default.reverse = nil
		end


	end


	function self:calculate_bullet_angle()
		-- calculate new bullet angle
		local crank_angle = playdate.getCrankPosition()
		-- to get that true "cranktra" feel, limit trajectory to 45 degree angles
		bullet_angle = math.floor((crank_angle - 90 + 22.5) / 45) * 45

		-- stop player from firing straight down if they're not jumping:
		if bullet_angle == 90 then
			if crank_angle < 180 then
				bullet_angle = 45
			else
				bullet_angle = 135
			end
		end

		-- convert bullet angle to radians
		bullet_angle = math.rad(bullet_angle)

		-- update player's orientation state
		if crank_angle < 180 then 
			self.orientation = "right"
		else
			self.orientation = "left"
		end

	end


	-- call function to calculate bullet angle when initializing player 
	self:calculate_bullet_angle()


end



function level_floor(x,y)
	-- left side of stage
	if x < 30 then
		return 240
	elseif x >= 30 and y <= 105 then 
		return 105
	else
		return 105
	end

end

