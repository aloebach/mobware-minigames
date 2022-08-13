
--[[
	Author: Michael McCombie (jERKS iNC.)

	parachute_grab for Mobware Minigames

]]

-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua
local parachute_grab = {}


-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

local cloudsPositionY = 0
local cloudsPositionX = 0
local cloudsDirectionX = 'right'

local linesLeftCount = 1
local linesRightCount = 2

local playerSpeedCount = 0
local playerSpeedDirectionUp = false

local pressedButton = 1
local AbuttonIndicator_on

local parachutePosition = 0
local parachuteLeft = true


-- animation for line sprites
lines_image_table = gfx.imagetable.new("Minigames/parachute_grab/images/lines")
lines_left_sprite = gfx.sprite.new(lines_image_table)
lines_left_sprite:setZIndex(1)
lines_left_sprite:setImage(lines_image_table:getImage(1))
lines_left_sprite:moveTo(46, 120)
lines_left_sprite:add()
lines_left_sprite.frame = 1

lines_right_sprite = gfx.sprite.new(lines_image_table)
lines_right_sprite:setZIndex(1)
lines_right_sprite:setImage(lines_image_table:getImage(1))
lines_right_sprite:moveTo(354, 120)
lines_right_sprite:add()
lines_right_sprite.frame = 2

-- animation clouds
local clouds_top_screen = gfx.sprite.new()
clouds_image = gfx.image.new("Minigames/parachute_grab/images/background")
clouds_top_screen:setImage(clouds_image)
clouds_top_screen:setZIndex(0)
clouds_top_screen:moveTo(212, 265)
clouds_top_screen:addSprite()

local clouds_bottom_screen = gfx.sprite.new()
clouds_bottom_screen:setImage(clouds_image)
clouds_bottom_screen:setZIndex(0)
clouds_bottom_screen:moveTo(212, 795)
clouds_bottom_screen:addSprite()

-- parachute
local parachute_sprite = gfx.sprite.new()
parachute_image = gfx.image.new("Minigames/parachute_grab/images/parachute")
parachute_sprite:setImage(parachute_image)
parachute_sprite:setZIndex(4)
if math.random() > 0.5 then
	parachuteLeft = true
	parachute_sprite:moveTo(150, -70)
else
	parachuteLeft = false
	parachute_sprite:moveTo(270, -70)
end
parachute_sprite:addSprite()

-- animation for on-screen player sprite
player_image_table = gfx.imagetable.new("Minigames/parachute_grab/images/player")
player_sprite = gfx.sprite.new(image_table)

-- update sprite's frame so that the sprite will reflect the crank's actual position
local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
local frame_num = math.floor( crank_position / 20 + 1 )
if (frame_num == 19) then
	player_sprite:setImage(player_image_table:getImage(1, pressedButton))
else
	player_sprite:setImage(player_image_table:getImage(frame_num, pressedButton))
end
player_sprite:setZIndex(3)

player_sprite:moveTo(200, 120)
player_sprite:add()
player_sprite.frame = 1
player_sprite.crank_counter = 0
player_sprite.total_frames = 36


-- set initial gamestate
gamestate = 'play'
mobware.crankIndicator.start()


function parachute_grab.update()

	-- updates all sprites
	gfx.sprite.update()

	-- Move parachute
	parachutePosition += 1
	if (parachuteLeft == true) then
		if (parachutePosition > 10) and (parachutePosition < 40) then
			parachute_sprite:moveBy(-1, 3)
		elseif (parachutePosition < 80) then
			parachute_sprite:moveBy(0, 3)
		else
			parachute_sprite:moveBy(1, 3)
		end
	else
		if (parachutePosition > 10) and (parachutePosition < 40) then
			parachute_sprite:moveBy(1, 3)
		elseif (parachutePosition < 80) then
			parachute_sprite:moveBy(0, 3)
		else
			parachute_sprite:moveBy(-1, 3)
		end
	end
	
	if parachute_sprite.y > 260 then gamestate = "defeat" end


	-- Move player gently
	if (playerSpeedDirectionUp) then
		playerSpeedCount -= 1

		-- Move player up
		if (playerSpeedCount == 1) or (playerSpeedCount == 10) then
			player_sprite:moveBy(0,0)
		elseif (playerSpeedCount == 2) or (playerSpeedCount == 3) or (playerSpeedCount == 8) or (playerSpeedCount == 9) then
			player_sprite:moveBy(0,-1)
		elseif (playerSpeedCount == 4) or (playerSpeedCount == 5) or (playerSpeedCount == 6) or (playerSpeedCount == 7) then
			player_sprite:moveBy(0,-2)
		else
			playerSpeedDirectionUp = false
		end

	else
		playerSpeedCount += 1

		-- Move player down
		if (playerSpeedCount == 1) or (playerSpeedCount == 10) then
			player_sprite:moveBy(0,0)
		elseif (playerSpeedCount == 2) or (playerSpeedCount == 3) or (playerSpeedCount == 8) or (playerSpeedCount == 9) then
			player_sprite:moveBy(0,1)
		elseif (playerSpeedCount == 4) or (playerSpeedCount == 5) or (playerSpeedCount == 6) or (playerSpeedCount == 7) then
			player_sprite:moveBy(0,2)
		else
			playerSpeedDirectionUp = true
		end

	end

	-- lines
	linesLeftCount += 1
	lines_left_sprite:setImage(lines_image_table:getImage(linesLeftCount))
	if linesLeftCount == 14 then
		linesLeftCount = 0
	end

	linesRightCount += 1
	lines_right_sprite:setImage(lines_image_table:getImage(linesRightCount))
	if linesRightCount == 14 then
		linesRightCount = 0
	end

	-- cloudsX
	if (cloudsPositionX == -5) then
		cloudsDirectionX = 'right'
	elseif (cloudsPositionX == 4) then
		cloudsDirectionX = 'left'
	end

	if (cloudsDirectionX == 'right') then
		cloudsPositionX += 1
		clouds_top_screen:moveBy(-1,-10)
		clouds_bottom_screen:moveBy(-1,-10)
	else
		cloudsPositionX -= 1
		clouds_top_screen:moveBy(1,-10)
		clouds_bottom_screen:moveBy(1,-10)
	end

	-- cloudsY
	cloudsPositionY += 10
	local cloudTemp = cloudsPositionY / 530
	if (cloudTemp == 1) or (cloudTemp == 3) or (cloudTemp == 5) or (cloudTemp == 7) or (cloudTemp == 9) then
		clouds_top_screen:moveTo(212, 795)
	elseif (cloudTemp == 2) or (cloudTemp == 4) or (cloudTemp == 6) or (cloudTemp == 8) or (cloudTemp == 10) then
		clouds_bottom_screen:moveTo(212, 795)
	end

	-- In the first stage of the minigame, the user needs to hit the "B" button
	if gamestate == 'play' then
		if playdate.buttonJustPressed('a') then

			mobware.AbuttonIndicator.stop()
			
			-- closed hand sprite
			pressedButton = 2
			local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
			local frame_num = math.floor( crank_position / 20 + 1 )
			if (frame_num == 19) then
				player_sprite:setImage(player_image_table:getImage(1, pressedButton))
			else
				player_sprite:setImage(player_image_table:getImage(frame_num, pressedButton))
			end

			-- If player hits the "B" button while the parachute is within reach, change gamestate
			-- Needs crank position
			--print(frame_num)
			
			if (parachuteLeft == true) then
				-- Left
				if (frame_num == 16) and (parachutePosition > 30) and (parachutePosition < 40) then
					print("success! 16")
					gamestate = 'victory'
				end

				if (frame_num == 17) and (parachutePosition > 40) and (parachutePosition < 50) then
					print("success! 17")
					gamestate = 'victory'
				end

				if (frame_num == 18) and (parachutePosition > 50) and (parachutePosition < 60) then
					print("success! 18")
					gamestate = 'victory'
				end

				if (frame_num == 1) and (parachutePosition > 60) and (parachutePosition < 70) then
					print("success! 1")
					gamestate = 'victory'
				end

				if (frame_num == 2) and (parachutePosition > 70) and (parachutePosition < 80) then
					print("success! 2")
					gamestate = 'victory'
				end

				if (frame_num == 3) and (parachutePosition > 80) and (parachutePosition < 90) then
					print("success! 3")
					gamestate = 'victory'
				end

				if (frame_num == 4) and (parachutePosition > 90) and (parachutePosition < 100) then
					print("success! 4")
					gamestate = 'victory'
				end
			else
				-- Right
				if (frame_num == 13) and (parachutePosition > 30) and (parachutePosition < 40) then
					print("success! 13")
					gamestate = 'victory'
				end

				if (frame_num == 12) and (parachutePosition > 40) and (parachutePosition < 50) then
					print("success! 12")
					gamestate = 'victory'
				end

				if (frame_num == 11) and (parachutePosition > 50) and (parachutePosition < 60) then
					print("success! 11")
					gamestate = 'victory'
				end

				if (frame_num == 10) and (parachutePosition > 60) and (parachutePosition < 70) then
					print("success! 10")
					gamestate = 'victory'
				end

				if (frame_num == 9) and (parachutePosition > 70) and (parachutePosition < 80) then
					print("success! 9")
					gamestate = 'victory'
				end

				if (frame_num == 8) and (parachutePosition > 80) and (parachutePosition < 90) then
					print("success! 8")
					gamestate = 'victory'
				end

				if (frame_num == 7) and (parachutePosition > 90) and (parachutePosition < 100) then
					print("success! 7")
					gamestate = 'victory'
				end
			end




		else

			-- open hand sprite
			pressedButton = 1
			local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
			local frame_num = math.floor( crank_position / 20 + 1 )
			if (frame_num == 19) then
				player_sprite:setImage(player_image_table:getImage(1, pressedButton))
			else
				player_sprite:setImage(player_image_table:getImage(frame_num, pressedButton))
			end
		end

	elseif gamestate == 'victory' then
		-- The "victory" gamestate will simply show the victory animation and then end the minigame

		-- display image indicating the player has won
		mobware.print("good job!",140, 40)

		playdate.wait(2000)	-- Pause 2s before ending the minigame
		-- Task: Move to

		-- returning 1 will end the game and indicate the the player has won the minigame
		return 1


	elseif gamestate == 'defeat' then

		-- if player has lost, show images of playdate running out of power
		mobware.print("too late!",140, 40)

		-- wait another 2 seconds then exit
		playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- return 0 to indicate that the player has lost and exit the minigame
		return 0

	end

end



function parachute_grab.cranked(change, acceleratedChange)
	-- Once crank is turned, turn off crank indicator
	if mobware.crankIndicator then
		mobware.crankIndicator.stop()
		if AbuttonIndicator_on ~= true then
			mobware.AbuttonIndicator.start()
			AbuttonIndicator_on = true
		end
	end

	-- update sprite's frame so that the sprite will reflect the crank's actual position
	local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
	local frame_num = math.floor( crank_position / 20 + 1 )
	if (frame_num == 19) then
		player_sprite:setImage(player_image_table:getImage(1, pressedButton))
	else
		player_sprite:setImage(player_image_table:getImage(frame_num, pressedButton))
	end


end

-- Minigame package should return itself
return parachute_grab
