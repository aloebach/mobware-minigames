
--[[
	Author: Drew Loebach

	a_sketchy_etcher minigame made for Mobware Minigames
	-- Based on A-Sketchy-Etcher Pulp game by Shaun Inman
]]

-- Define name for minigame package
a_sketchy_etcher = {}

local gfx <const> = playdate.graphics

-- Load A Sketchy Etcher drawn image
local etcher_screen = gfx.sprite.new()
etcher_image = gfx.image.new("Minigames/a_sketchy_etcher/images/shake_pic")
etcher_screen:setImage(etcher_image)
etcher_screen:moveTo(200, 120)
etcher_screen:addSprite()

-- Load A Sketchy Etcher background image
local background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/a_sketchy_etcher/images/etcher"))
background:moveTo(200, 120)
background:addSprite()

-- display input prompt for Accelerometer
mobware.AccelerometerIndicator.start("up", "down")

--> Initialize sound effects
local shake_noise = playdate.sound.sampleplayer.new('Minigames/a_sketchy_etcher/sounds/etcher_shake')

-- Start accelerometer while we'll read later to determine the player has sufficiently shook a sketchy etcher
playdate.startAccelerometer()
local x,y,z = playdate.readAccelerometer()

-- set gamestate variable
local gamestate = 'play'

-- initialize variables
local shake_counter = 0
local previous_x = 0
local previous_y = 1
local previous_z = 0
local SHAKE_THRESHOLD = 0.2
local WINNING_SCORE = 80
local MAX_GAME_TIME = 8 -- maxiumum time (in seconds) minigame should run

-- start timer	 
game_timer = playdate.frameTimer.new(MAX_GAME_TIME * 20, function() gamestate = "defeat" end) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate


function a_sketchy_etcher.update()

	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()

	if gamestate == "play" then
		-- read values from accelerometer
		local x,y,z = playdate.readAccelerometer()
		--print(x,y,z) -- for testing/debugging

		-- if device has been sufficiently shaken, then call "shake" function
		if math.abs(x - previous_x) > SHAKE_THRESHOLD then shake() end
		if math.abs(y - previous_y) > SHAKE_THRESHOLD then shake() end
		if math.abs(z - previous_z) > SHAKE_THRESHOLD then shake() end
		previous_x = x
		previous_y = y
		previous_z = z

	elseif gamestate == "victory" then
		-- once victory animation is completed return 1 to end the minigame
		if animation_finished then
			return 1
		end

	elseif gamestate == "defeat" then
		-- you lost the minigame :-(
		return 0

	end

end

function shake()
	-- turn off accelerometer indicator once player has shaken device
	if shake_counter == 4 then mobware.AccelerometerIndicator.stop() end 

	-- play sound effect
	if shake_counter >= 4 and not shake_noise:isPlaying() then
		-- play "shake" noise if it's not already playing
		shake_noise:play(1) -- play static noise
	end

	shake_counter += 1
	--print('Shake counter:', shake_counter)
	
	-- Re-draw a faded version of our etcher screen
	local canvas = gfx.image.new(400, 240)
	gfx.lockFocus(canvas)
		etcher_image:drawFaded(0, 0, 1 - shake_counter/WINNING_SCORE, gfx.image.kDitherTypeBayer2x2)
	gfx.unlockFocus()
	etcher_screen:setImage(canvas)

	-- win condition: player shakes enough to erase the image
	if shake_counter >= WINNING_SCORE then
		-- load game-winning animation
		thumbs_up_gif = gfx.imagetable.new("Minigames/a_sketchy_etcher/images/thumbs_up")
		thumbs_up = AnimatedSprite.new( thumbs_up_gif )
		thumbs_up:addState("animate", nil, nil, {tickStep = 1, loop = false, onAnimationEndEvent = function() animation_finished = true end}, true)
			--> In the animated sprite above I included a function that will set animation_finished = true once the animation completes
		thumbs_up:moveTo(200, 120)
		playdate.stopAccelerometer()

		game_timer:remove()
		gamestate = "victory" 
	end

end

-- Minigame package should return itself
return a_sketchy_etcher
