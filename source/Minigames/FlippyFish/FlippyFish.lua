-- Define minigame package
local FlippyFish = {}

import "Minigames/FlippyFish/Fish/fish"
import "Minigames/FlippyFish/Ground/ground"
import "Minigames/FlippyFish/Seaweed/seaweed"
import "Minigames/FlippyFish/Score/score"

local gfx = playdate.graphics
local spritelib = gfx.sprite
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()

-- reset the screen to white
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 0, screenWidth, screenHeight)


-- ! game states

local kGameState = {initial, ready, playing, paused, over}
local currentState = kGameState.initial

local kGameInitialState, kGameGetReadyState, kGamePlayingState, kGamePausedState, kGameOverState, kVictoryState = 0, 1, 2, 3, 4, 5
local gameState = kGameGetReadyState


-- ! set up sprites

local score = Score()
score:setZIndex(900)
score:addSprite()

local titleSprite = spritelib.new()
titleSprite:setImage(gfx.image.new('Minigames/FlippyFish/images/getReady'))
titleSprite:moveTo(screenWidth / 2, screenHeight / 2.5)
titleSprite:setZIndex(950)
titleSprite:addSprite()

local background = spritelib.new()
background:setImage(gfx.image.new('Minigames/FlippyFish/images/bg'))
background:moveTo(200, 163)
background:addSprite()

local ground = Ground()
local seaweeds = {Seaweed(), Seaweed(), Seaweed(), Seaweed()}
local flippy = Fish()

local ticks = 0
local buttonDown = false
local GAME_WINNING_SCORE = 2

-- initialize sounds
local pling_sound = playdate.sound.sampleplayer.new('Minigames/FlippyFish/sounds/pling')
local death_sound = playdate.sound.sampleplayer.new('Minigames/FlippyFish/sounds/dead_fish')

-- start button indicator
mobware.AbuttonIndicator.start()


local function gameOver()

	death_sound:play(1)
	gameState = kGameOverState

	titleSprite:setImage(gfx.image.new('Minigames/FlippyFish/images/gameOver'))
	titleSprite:setVisible(true)
	
	ticks = 0
end


local function startGame()
	
	gameState = kGameGetReadyState
	ticks = 0
	score:setScore(0)

	titleSprite:setImage(gfx.image.new('Minigames/FlippyFish/images/getReady'))
	titleSprite:setVisible(true)

	flippy:reset()
	for _, seaweed in ipairs(seaweeds) do
		seaweed:resetPosition()
		seaweed.visible = false
	end	
	

end



function FlippyFish.update()
	
	ticks = ticks + 1
	
	-- update frame timer
	playdate.frameTimer.updateTimers()

	if gameState == kGameInitialState then

		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, screenWidth, screenHeight)
		local playButton = gfx.image.new('Minigames/FlippyFish/images/playButton')
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
		end
		
		playdate.wait(1000)
		return 0
		
	elseif gameState == kVictoryState then
		return 1

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
				-- check if we've hit the winning score, and if so, go to victory state after ~1s
				if score.score > GAME_WINNING_SCORE then
					game_timer = playdate.frameTimer.new( 20, function() gameState = kVictoryState end )
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
	elseif gameState == kGameOverState and ticks > 5  then	-- the ticks thing is just so the player doesn't accidentally restart immediately
		startGame()
	elseif gameState == kGamePlayingState then
		flippy:up()		
	end
end

function FlippyFish.BButtonDown()
	if gameState == kGameInitialState then
		buttonDown = true
	elseif gameState == kGameOverState and ticks > 5 then
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