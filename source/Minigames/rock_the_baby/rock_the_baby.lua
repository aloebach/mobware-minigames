
--[[
	Author: Drew Loebach

	rock_the_baby minigame made for Mobware Minigames
	
	-- music by Kate Kody
	under the creative commons license:
	https://creativecommons.org/licenses/by/4.0/legalcode
	
]]

-- Define name for minigame package
local rock_the_baby = {}

local gfx <const> = playdate.graphics

-- Load image of baby in a crib
local baby = gfx.image.new("Minigames/rock_the_baby/images/baby_crib")

-- Load background image
local background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/rock_the_baby/images/bedroom"))
background:moveTo(200, 120)
background:addSprite()

-- display input prompt for Accelerometer
mobware.AccelerometerIndicator.start("left", "right")
mobware.AccelerometerIndicator_sprite.states.custom.tickStep = 5

--> Initialize music and sound effects
local music_box = playdate.sound.sampleplayer.new('Minigames/rock_the_baby/sounds/Music_Box')
local victory_lullaby = playdate.sound.sampleplayer.new('Minigames/rock_the_baby/sounds/victory_lullaby')
local whining_baby = playdate.sound.sampleplayer.new('Minigames/rock_the_baby/sounds/baby_whine')
local crying_baby = playdate.sound.sampleplayer.new('Minigames/rock_the_baby/sounds/baby_crying')
local whining_baby = playdate.sound.sampleplayer.new('Minigames/rock_the_baby/sounds/baby_whine')

music_box:play(0)

-- Start accelerometer while we'll read later to determine the player has sufficiently shook a sketchy etcher
playdate.startAccelerometer()
local x,y,z = playdate.readAccelerometer()

-- set gamestate variable
local gamestate = 'intro'

-- initialize variables
local shake_counter = 0
local rock_counter = 0
local cry_counter = 0
local ROCK_THRESHOLD = 0.25 -- threshold at which we disturb the baby
local CRYING_THRESHOLD = 2 -- number of times we can rock too hard before the baby starts crying uncontrollably
local WINNING_SCORE = 8
local MAX_GAME_TIME = 10 -- maximum time (in seconds) minigame should run (at 20fps)
local minigame_finished = nil

-- initialize "previous" accelerometer values 
local previous_ax, previous_ay, previous_az = playdate.readAccelerometer()

-- math stuffs for rotating crib
local imageTransform = playdate.geometry.affineTransform.new()

local function end_minigame()	minigame_finished = true	end

-- start timer that will trigger the defeat animation if the player doesn't win before time runs out
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
local game_timer = playdate.frameTimer.new(MAX_GAME_TIME * 20, function() 
	
	baby:load("Minigames/rock_the_baby/images/crying_baby") 	-- change image to crying baby
	crying_baby:play(0) 	-- play baby crying sound effect
	crying_baby:setLoopCallback(end_minigame)	-- end minigame after crying sound is finished
	gamestate = "defeat"
	
	-- animated tears
	local tears_spritesheet = gfx.imagetable.new("Minigames/rock_the_baby/images/tears")
	tears = AnimatedSprite.new( tears_spritesheet )
	tears:addState("animate", nil, nil, {tickStep = 4}, true)
	tears:moveTo(190,30)

end)

function rock_the_baby.update()

	-- read values from accelerometer (we're only interested in the x axis for the "rocking" motion though)
	local ax,ay,az = playdate.readAccelerometer()

	-- transform logic for rotating crib image
	local angle = ax * 45
	imageTransform:reset()
	imageTransform:rotate( angle, 0,120 )

	-- updates all sprites
	gfx.sprite.update() 
	
	--	draw baby in crib
	baby:drawWithTransform( imageTransform, 200 , 120 )

	-- update timer
	playdate.frameTimer.updateTimers()

	if gamestate == "intro" then
		
		-- updates all sprites (to put accelerometer indicator in front)
		gfx.sprite.update() 
				
		mobware.print("rock the baby to sleep")
		
		-- after showing directions for 20 frames, move to play state		
		if game_timer.frame > 30 then
			mobware.AccelerometerIndicator.stop()
			gamestate = "play" 
		end


	elseif gamestate == "play" then
		
		-- if you rocked the baby too much go to the defeat gamestate where the baby starts crying
		if math.abs(ax) > ROCK_THRESHOLD and math.abs(previous_ax) < ROCK_THRESHOLD then
			cry_counter += 1
			whining_baby:play(1)
			if cry_counter >= CRYING_THRESHOLD then
				game_timer:remove()
				baby:load("Minigames/rock_the_baby/images/crying_baby") 	-- change image to crying baby
				crying_baby:play(0) 	-- play baby crying sound effect
				crying_baby:setLoopCallback(end_minigame)	-- end minigame after crying sound is finished
				gamestate = "defeat"
				
				-- animated tears
				local tears_spritesheet = gfx.imagetable.new("Minigames/rock_the_baby/images/tears")
				tears = AnimatedSprite.new( tears_spritesheet )
				tears:addState("animate", nil, nil, {tickStep = 4}, true)
				tears:moveTo(190,30)
			end
		end
		
		-- if the transform crosses the zero-axis we consider it a successful rock
		if ax * previous_ax < 0 then
			rock_counter += 1
			if rock_counter > WINNING_SCORE then
				game_timer:remove()
				music_box:stop()
				victory_lullaby:play(0)
				victory_lullaby:setLoopCallback(end_minigame)
				gamestate = "victory"
				
				-- animated ZZZs
				local ZZZ_spritesheet = gfx.imagetable.new("Minigames/rock_the_baby/images/zzz")
				ZZZs = AnimatedSprite.new( ZZZ_spritesheet )
				ZZZs:addState("animate", nil, nil, {tickStep = 4}, true)
				ZZZs:moveTo(180,30)
				
			end
		end
		
		previous_ax = ax	-- store current ax as previous_ax for next comparison


	elseif gamestate == "victory" then
		
		-- animate ZZZs
		ZZZs:moveTo(190 + ax * 70,30)
		
		-- once victory music is finished return 1 to end the minigame
		if minigame_finished then
			playdate.stopAccelerometer()
			return 1
		end


	elseif gamestate == "defeat" then
		
		if cry_counter >= CRYING_THRESHOLD then
			mobware.print("don't shake the baby!")
		end
		
		-- animate tears
		tears:moveTo(180 + ax * 70,30)
		
		-- once crying sound effect is finished return 1 to end the minigame
		if minigame_finished then
			playdate.stopAccelerometer()
			return 0
		end

	end

end



-- Minigame package should return itself
return rock_the_baby
