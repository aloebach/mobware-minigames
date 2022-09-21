-- Define minigame package
local FlippyFish = {}

import "extras/FlippyFish/Fish/fish"
import "extras/FlippyFish/Ground/ground"
import "extras/FlippyFish/Seaweed/seaweed"
import "extras/FlippyFish/Score/score"

local gfx = playdate.graphics
local spritelib = gfx.sprite
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

-- reset the screen to white
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 0, screenWidth, screenHeight)


-- ! game states

local kGameInitialState, kGameGetReadyState, kGamePlayingState, kGamePausedState, kGameOverState, kShowScoreState = 0, 1, 2, 3, 4, 5
local gameState = kGameGetReadyState


-- ! set up sprites

local score = Score()
score:setZIndex(900)
score:addSprite()

local titleSprite = spritelib.new()
titleSprite:setImage(gfx.image.new('extras/FlippyFish/images/getReady'))
titleSprite:moveTo(screenWidth / 2, screenHeight / 2.5)
titleSprite:setZIndex(950)
titleSprite:addSprite()

local background = spritelib.new()
background:setImage(gfx.image.new('extras/FlippyFish/images/bg'))
background:moveTo(200, 163)
background:addSprite()

local ground = Ground()
local seaweeds = {Seaweed(), Seaweed(), Seaweed(), Seaweed()}
local flippy = Fish()

local ticks = 0
local buttonDown = false

-- initialize sounds
local pling_sound = playdate.sound.sampleplayer.new('extras/FlippyFish/sounds/pling')
local death_sound = playdate.sound.sampleplayer.new('extras/FlippyFish/sounds/dead_fish')

-- start button indicator
mobware.AbuttonIndicator.start()

-- set games's progressive difficulty curve
local MAX_FRAME_RATE = 40
local MIN_FRAME_RATE = 20
local SPEED_INCREASE_INTERVAL = 2 --> sets how many points the user collects before the game speeds up
local frame_rate = MIN_FRAME_RATE
playdate.display.setRefreshRate(frame_rate)

-- reading high score from memory
local hi_score = 0
local new_hi_score
local hi_score_font = gfx.font.new('extras/FlippyFish/Score/FlappyFont')

local _status, data_read = pcall(playdate.datastore.read, "flippyfish_data")
if data_read then 
	hi_score = data_read["hi_score"]
end

local function gameOver()

	death_sound:play(1)
	gameState = kGameOverState

	titleSprite:setImage(gfx.image.new('extras/FlippyFish/images/gameOver'))
	titleSprite:setVisible(true)
	
	if score.score > hi_score then
		print("new hi score!")
		hi_score = score.score
		new_hi_score = true
		pling_sound:play(4, 1.5)
		
		-- save hi score to disc
		local hi_score_table = {hi_score = hi_score}
		playdate.datastore.write(hi_score_table, "flippyfish_data")
	else
		new_hi_score = nil
	end
	
	ticks = 0
end


local function startGame()
	
	gameState = kGameGetReadyState
	ticks = 0
	score:setScore(0)
	
	frame_rate = MIN_FRAME_RATE
	playdate.display.setRefreshRate(frame_rate)

	titleSprite:setImage(gfx.image.new('extras/FlippyFish/images/getReady'))
	titleSprite:setVisible(true)

	flippy:reset()
	for _, seaweed in ipairs(seaweeds) do
		seaweed:resetPosition()
		seaweed.visible = false
	end	
	

end



function FlippyFish.update()
	
	ticks = ticks + 1

	if gameState == kGameInitialState then

		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, screenWidth, screenHeight)
		local playButton = gfx.image.new('extras/FlippyFish/images/playButton')
		local y = screenHeight/2 - playButton.height/2
		if buttonDown == false then
			y -= 3
		end
		playButton:draw(screenWidth/2 - playButton.width/2, y)

	elseif gameState == kGameGetReadyState then
		
		spritelib.update()
				
		if ticks > 30 then
			seaweeds[1].visible = true
			ground.paused = false
			flippy.fishState = flippy.kFishNormalState
			gameState = kGamePlayingState
			
			titleSprite:setVisible(false)
		end

	elseif gameState == kGamePlayingState then
		
		spritelib.update()	
	
		-- check the position of the rightmost seaweed to see if we need to maybe create a new one
		local rightmostSeaweedX = 0
		local potentialSeaweed = nil
		for _, seaweed in ipairs(seaweeds) do
		
			if seaweed.x < -60 then
				seaweed.visible = false
			end
			
			if seaweed.visible == false then
				potentialSeaweed = seaweed
			
			elseif seaweed.visible == true then			
				rightmostSeaweedX = math.max(rightmostSeaweedX, seaweed.x)
			end	
		end
		
		-- if there has been too long since a seaweed has appeared make a new one, otherwise make it a bit random
		if (potentialSeaweed ~= nil) and ((rightmostSeaweedX < 250) or (rightmostSeaweedX < 350 and math.random(1, 20) == 10)) then
			potentialSeaweed:resetPosition()
			potentialSeaweed.visible = true
		end
		
	elseif gameState == kGameOverState then
		
		if ticks < 5 then
			playdate.display.setInverted(ticks % 2)
		else
			gameState = kShowScoreState
		end
		
	elseif gameState == kShowScoreState then
		spritelib.update()	--DELETE THIS LATER!??
		--- Triggers after GameOverState to show score and high score
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineWidth(3)
		gfx.fillRoundRect(72, 130, 256, 48, 5)
		gfx.setColor(gfx.kColorBlack)
		gfx.drawRoundRect(72, 130, 256, 48, 5)
		gfx.setFont(hi_score_font)
		gfx.drawTextAligned("HIGH SCORE " .. hi_score, 200, 146, kTextAlignment.center)
		
		-- proudly display "NEW" if the player just made a new high score
		if new_hi_score then
			if ticks % 20 <= 12 then 
				gfx.setColor(gfx.kColorBlack)
				gfx.fillRoundRect(5, 130, 63, 48, 5)
				gfx.drawTextAligned("NEW", 36, 146, kTextAlignment.center)
			end
		end
		
	end

end



function flippy:collisionResponse(other)
	if gameState ~= kGamePlayingState then
		return gfx.sprite.kCollisionTypeOverlap
	end
	
	if other == ground and flippy:alphaCollision(ground) then
		-- collided with the ground
		gameOver()
	else
		for _, seaweed in ipairs(seaweeds) do

			if other == seaweed and seaweed.pointAwarded == false then
				
				score:addOne()
				seaweed.pointAwarded = true
				pling_sound:play(1)
				
				-- gradually speed up the game as the player progresses
				if score.score % SPEED_INCREASE_INTERVAL == 0 then
					frame_rate = math.min( frame_rate + 1, MAX_FRAME_RATE )
					playdate.display.setRefreshRate(frame_rate)
				end
								
			elseif (other == seaweed.seaweedTop and flippy:alphaCollision(seaweed.seaweedTop)) or (other == seaweed.seaweedBottom and flippy:alphaCollision(seaweed.seaweedBottom)) then
				
				-- collided with a seaweed
				gameOver()
			end
		end
	end
	
	return gfx.sprite.kCollisionTypeOverlap
end



-- ! Button Functions

function FlippyFish.leftButtonDown()
	if gameState == kGamePlayingState then
		flippy:left()
	end
end

function FlippyFish.rightButtonDown()
	if gameState == kGamePlayingState then
		flippy:right()
	end
end

function FlippyFish.upButtonDown()
	if gameState == kGamePlayingState then
		flippy:up()
	end
end

function FlippyFish.AButtonDown()
	
	mobware.AbuttonIndicator.stop()

	if gameState == kGameInitialState then
		buttonDown = true
	elseif gameState == kShowScoreState and ticks > 40  then	-- the ticks thing is just so the player doesn't accidentally restart immediately
		startGame()
	elseif gameState == kGamePlayingState then
		flippy:up()		
	end
end

function FlippyFish.BButtonDown()
	if gameState == kGameInitialState then
		buttonDown = true
	elseif gameState == kShowScoreState and ticks > 40 then
		startGame()
	elseif gameState == kGamePlayingState then
		flippy:up()
	end
end

function FlippyFish.AButtonUp()

	if gameState == kGameInitialState then
		buttonDown = false
		startGame()
	end
end

function FlippyFish.BButtonUp()
	if gameState == kGameInitialState then
		buttonDown = false
		startGame()
	end
end

-- Return minigame package
return FlippyFish