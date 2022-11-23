
--[[
	Author: Drew Loebach
	
	rock_paper_scissors for Mobware Minigames
	
	I'm using Use the following convention for RPS state:
		rock = 1
		paper = 2
		scissors = 3
	
	--> Afterwards make into a 2-player game "Vs. Rock-Paper-Siccsors" for bonus content!
]]

rock_paper_scissors = {}

local gfx <const> = playdate.graphics

-- initialize images / image tables 
rps_image_table = gfx.imagetable.new("Minigames/rock_paper_scissors/images/rock_paper_scissors")
rock_icon = gfx.image.new("Minigames/rock_paper_scissors/images/rock_icon") 
paper_icon = gfx.image.new("Minigames/rock_paper_scissors/images/paper_icon") 
scissors_icon = gfx.image.new("Minigames/rock_paper_scissors/images/scissors_icon") 
pointer_image = gfx.image.new("Minigames/rock_paper_scissors/images/pointer") 
local text_box = gfx.nineSlice.new("images/text-bubble", 16, 16, 32, 32)

total_animation_frames = rps_image_table:getLength()

-- static background image
local background = gfx.sprite.new()
background:setImage( gfx.image.new("Minigames/rock_paper_scissors/images/rps_static_background") )
background:moveTo(200, 120)
background:add()

-- animated part of background
local background_spritesheet = gfx.imagetable.new("Minigames/rock_paper_scissors/images/rps_animated_background")
animated_background = AnimatedSprite.new(background_spritesheet)
animated_background:addState("animate", nil, nil, {tickStep = 2}, true)
animated_background:setZIndex(1)
animated_background:moveTo(75, 87)

-- draw menu on right-hand side of screen
local menu_window = gfx.sprite.new()
local window_width = 92
local window_height = 240
local canvas = gfx.image.new(window_width, window_height)
-- draw menu on canvas, then transform into a sprite
gfx.lockFocus(canvas)
	gfx.fillRect(0, 0, window_width, window_height ) 
	text_box:drawInRect(window_width / 4 - 16, 40 - 32, 64, 64)
	rock_icon:draw(window_width / 4 , 40 - 16) 
	text_box:drawInRect(window_width / 4 - 16, 120 - 32, 64, 64)
	paper_icon:draw(window_width / 4 , 120 - 16) 
	text_box:drawInRect(window_width / 4 - 16, 200 - 32, 64, 64)
	scissors_icon:draw(window_width / 4 , 200 - 16) 
gfx.unlockFocus()
menu_window:setImage(canvas)
menu_window:moveTo(400 - window_width / 2 ,120)
menu_window:add()

-- add pointer sprite to indicate which RPS the player is pointing to
pointer = gfx.sprite.new(pointer_image)
pointer:moveTo(380,120)
pointer:add()
pointer:setZIndex(10)

-- initialize player-controlled hand
player_hand = gfx.sprite.new()
player_hand:setImage(rps_image_table:getImage(1), playdate.graphics.kImageFlippedX)
player_hand:moveTo(248,120)
player_hand:add()

-- initialize computer hand
CPU_hand = gfx.sprite.new()
local CPU_hand_rps = math.random(1,3) -- determines if CPU is rock, paper, or scissors
-- set CPU-hand to rock for intro, then update when switching to 'play' state!
CPU_hand:setImage(rps_image_table:getImage(1)) 
CPU_hand:moveTo(60,120)
CPU_hand:setZIndex(3)
CPU_hand:add()

-- update player_hand sprite's frame so that the sprite will reflect the crank's position
function update_rps_sprite()
	local crank_position = playdate.getCrankPosition()
	if crank_position > 180 then crank_position = 360 - crank_position end
	local frame_num = math.floor( total_animation_frames * crank_position / 181 + 1 )
	player_hand:setImage(rps_image_table:getImage(frame_num), playdate.graphics.kImageFlippedX)

	-- move pointer indicator	
	pointer:moveTo(380, 30 + crank_position )

	-- set rps value based on crank position:
	if crank_position < 60 then
		player_hand_rps = 1 -- "rock"
	elseif crank_position < 120 then
		player_hand_rps = 2 -- "paper"
	else
		player_hand_rps = 3 -- "scissors"
	end

end 


--> Initialize music / sound effects
local background_noise = playdate.sound.sampleplayer.new('Minigames/rock_paper_scissors/sounds/crowd_neutral')
local cheering_noise = playdate.sound.sampleplayer.new('Minigames/rock_paper_scissors/sounds/crowd_cheering')
local booing_noise = playdate.sound.sampleplayer.new('Minigames/rock_paper_scissors/sounds/crowd_booing')
--> play background noise
background_noise:play(0)
background_noise:setVolume(0.5)

-- start timer, which will move to "compare" gamestate after a set amount of time
MAX_GAME_TIME = 4.5 -- define the time at (20 fps) that the game will run before setting the "compare" gamestate
game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "compare" end ) 
-- for bouncing hands, use this function to determine hand y-values during introduction before moving to `play` state:
hand_position_timer = playdate.frameTimer.new ( 20, 0, 1.5 )

-- set initial gamestate and start prompt for player to use the crank
gamestate = 'intro'
mobware.crankIndicator.start()

function rock_paper_scissors.update()

	-- updates all sprites
	gfx.sprite.update() 
	
	-- update frame timer
	playdate.frameTimer.updateTimers()

	if gamestate == 'intro' then
		mobware.print("choose wisely!", 55, 30)

		-- for bouncing hands up and down in intro: use this function to determine hand y-values during introduction before moving to `play` state:
		local t = hand_position_timer.value
		hand_y = -20 * math.abs( math.sin(2 * math.pi * t) ) + 120 
		CPU_hand:moveTo(60, hand_y)
		player_hand:moveTo(248, hand_y)
		
		if t >= 1.5 then 
			-- after intro is done, have CPU change to it's random RPS-state
			CPU_hand:setImage(rps_image_table:getImage(CPU_hand_rps)) 
			gamestate = 'play'
		end
		
		
	-- In the play state, all we need to do is update the sprite with the crank angle and wait until the timer has expired, which will automatically move us to the "compare" state
	elseif gamestate == 'play' then
		update_rps_sprite()		


	-- In the "compare" state, we compare the two players to see who has one rock-paper-scissors
	elseif gamestate == 'compare' then
		-- check if player 2 has defeated player 1
		
		background_noise:stop()
		-- if player defeats CPU, then move to "victory" state
		if player_hand_rps - CPU_hand_rps == 1 or player_hand_rps - CPU_hand_rps == -2 then
			print('player wins!')
			cheering_noise:play(1)
			cheering_noise:setVolume(0.5)
			gamestate = 'victory'
		-- if P2 defeated P2, then move to "defeat" state
		elseif player_hand_rps == CPU_hand_rps then
			print('tie!')
			booing_noise:play(1)
			booing_noise:setVolume(0.5)
			gamestate = 'defeat'
		-- if CPU defeated player, then move to "victory" state
		else
			print('CPU wins!')
			booing_noise:play(1)
			booing_noise:setVolume(0.5)
			gamestate = 'defeat'
		end

	elseif gamestate == 'victory' then
		-- The "victory" gamestate will simply show the victory animation and then end the minigame
		
		-- display image indicating the player has won
		mobware.print("you win!",100, 40)
		playdate.wait(2000)	-- Pause 2s before ending the minigame
		cheering_noise:stop()
		
		return 1	-- returning 1 will end the game and indicate the the player has won the minigame
		
	
	elseif gamestate == 'defeat' then

		mobware.print("BITTER DEFEAT!",50, 40)
		playdate.wait(2000)	-- Pause 2s before ending the minigame
		booing_noise:stop()
		
		return 0	-- return 0 to indicate that the player has lost and exit the minigame 
	
	end

end


function rock_paper_scissors.cranked(change, acceleratedChange)
	-- Once crank is turned, turn off crank indicator
	if mobware.crankIndicator then mobware.crankIndicator:stop() end
end

-- Minigame package should return itself
return rock_paper_scissors
