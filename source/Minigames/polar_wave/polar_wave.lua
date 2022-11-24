
--[[
	Author: timhei

	Title: Polar Wave

	Description: Based on the Warioware microgame "The Wave". The player (polar bear) has to follow the motion of the eskimo's wave by positioning the crank up or down.
]]

-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local polar_wave = {}

-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

--> Initialize music / sound effects
local correct_noise = playdate.sound.sampleplayer.new('Minigames/polar_wave/sounds/correct')
local grunt_noise = playdate.sound.sampleplayer.new('Minigames/polar_wave/sounds/grunt')
local boing_noise = playdate.sound.sampleplayer.new('Minigames/polar_wave/sounds/boing')
local lose_noise = playdate.sound.sampleplayer.new('Minigames/polar_wave/sounds/lose')
local music = playdate.sound.sampleplayer.new('Minigames/polar_wave/sounds/music')

local bearSprite = nil
local eskimos = {}

local bearPos = 5
local currentEskimoDownWave1 = 1
local currentEskimoUpWave1 = 1
local currentEskimoUpWave2 = 1
local upWave1 = nil
local downWave1 = nil
local upWave2 = nil
local victoryAnim = nil
local defeatAnim = nil

local crankPromptShowing = false

local bearImageTable = gfx.imagetable.new('Minigames/polar_wave/images/polarbear')
local eskimoImageTable = gfx.imagetable.new('Minigames/polar_wave/images/eskimo')
local bearCurrentImage = 1
local backgroundImage = gfx.image.new('Minigames/polar_wave/images/background')

class('Eskimo').extends(gfx.sprite)

function Eskimo:init(x, y, offset)
    Eskimo.super.init(self) -- this is critical
	self.offset = offset
	self.currentImage = 1
	self.animationTimer = playdate.frameTimer.new(20, 1, #eskimoImageTable, playdate.easingFunctions.inOutSine)
	self.animationTimer:pause()
	self.animationTimer.discardOnCompletion = false
	self:setCenter(0.5, 1.0)
    self:setImage(eskimoImageTable:getImage(self.currentImage))
    self:moveTo(x, y)
	self:add()
end

function Eskimo:waveUp()
	self.animationTimer.startValue = 1
	self.animationTimer.endValue = #eskimoImageTable
	self.animationTimer:reset()
	self.animationTimer:start()
end

function Eskimo:waveDown()
	self.animationTimer.startValue = #eskimoImageTable
	self.animationTimer.endValue = 1
	self.animationTimer:reset()
	self.animationTimer:start()
end

local function defeatAnimation()
	lose_noise:play()
	gamestate = 'defeat_anim'
	local bearInitialY = bearSprite.y
	defeatAnim = playdate.frameTimer.new(30, 0, 500, playdate.easingFunctions.linear)
	defeatAnim.updateCallback = function(timer)
			bearSprite:setImage(bearImageTable:getImage(#bearImageTable))
			bearSprite:moveTo(bearSprite.x, bearInitialY - timer.value)
		end
	defeatAnim.timerEndedCallback = function()
		gamestate = 'defeat'
	end
end

local function checkBearPosition(pos)
	if pos == 'up' then
		if bearCurrentImage > 25 then
			return true
		else
			if gamestate ~= 'defeat_anim' then
				defeatAnimation()
				return nil
			end
		end
	end
	if pos == 'down' then
		if bearCurrentImage < 25 then
			return true
		else
			if gamestate ~= 'defeat_anim' then
				defeatAnimation()
				return nil
			end
		end
	end
end

local function checkVictory()
	if gamestate ~= 'defeat' and gamestate ~= 'defeat_anim' then
		boing_noise:play()
		local bearInitialY = bearSprite.y
		local eskimoInitialY = eskimos[1].y
		victoryAnim = playdate.frameTimer.new(5, 0, 30, playdate.easingFunctions.outSine)
		victoryAnim.reverseEasingFunction = playdate.easingFunctions.inSine
		victoryAnim.updateCallback = function(timer)
				bearSprite:moveTo(bearSprite.x, bearInitialY - timer.value)
				for index, eskimo in ipairs(eskimos) do
					if index ~= bearPos then
						eskimo:moveTo(eskimo.x, eskimoInitialY - timer.value)
					end
				end
			end
		victoryAnim.timerEndedCallback = function()
			if victoryAnim.timerEndedArgs == nil then victoryAnim.timerEndedArgs = {count = 0} end
			victoryAnim.timerEndedArgs.count += 1
			boing_noise:play()
			if victoryAnim.timerEndedArgs.count >= 5 then
				gamestate = 'victory'
			end
		end
		victoryAnim.reverses = true
		victoryAnim.repeats = true
	end
end

local function loadGame()
	--playdate.display.setRefreshRate(30)
	music:setRate(1.0 + (playdate.display.getRefreshRate() - 20.0) / 20.0)
	music:setVolume(0.7)
	music:play(0)
	math.randomseed(playdate.getSecondsSinceEpoch()) -- seed for math.random

	gfx.sprite.setBackgroundDrawingCallback(
        function( x, y, width, height )
            gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
            backgroundImage:draw( 0, 0 )
            gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
        end
    )

	bearPos = math.random(5, 6)

	bearSprite = gfx.sprite.new(bearImageTable:getImage(bearCurrentImage))
	bearSprite:setImage(bearImageTable:getImage(bearCurrentImage))
	bearSprite:setCenter(0.5, 1.0)
	bearSprite:moveTo((bearPos * 50) - 25, 224)
	bearSprite:add()

	for i = 1, 8 do
		if i ~= bearPos then
			eskimos[i] = Eskimo((i * 50) - 25, 220, 50)
		else
			eskimos[i] = gfx.sprite.new()
		end
	end

	upWave1 = playdate.frameTimer.new(8, function(timer)
		if currentEskimoUpWave1 > 8 then
			grunt_noise:play()
			timer:remove()
			return
		end
		
		if currentEskimoUpWave1 == bearPos then
			grunt_noise:play()
			currentEskimoUpWave1 += 1
			timer:reset()
			return
		end

		if currentEskimoUpWave1 + 1 == bearPos then
			--checkBearPosition('down')
		elseif currentEskimoUpWave1 - 2 == bearPos then
			if checkBearPosition('up') then correct_noise:play() end
		elseif currentEskimoUpWave1 ~= 1 then grunt_noise:play() end
		
		eskimos[currentEskimoUpWave1]:waveUp()
		currentEskimoUpWave1 += 1
		timer:reset()
	end)

	upWave1.discardOnCompletion = false

	downWave1 = playdate.frameTimer.new(8, function(timer)
		if currentEskimoDownWave1 > 8 then
			timer:remove()
			return
		end
		
		if currentEskimoDownWave1 == bearPos then
			currentEskimoDownWave1 += 1
			timer:reset()
			return
		end

		if currentEskimoDownWave1 + 1 == bearPos then
			checkBearPosition('up')
		elseif currentEskimoDownWave1 - 2 == bearPos then
			if checkBearPosition('down') then correct_noise:play() end
		end
		
		eskimos[currentEskimoDownWave1]:waveDown()
		currentEskimoDownWave1 += 1
		timer:reset()
	end)

	downWave1:pause()
	downWave1.discardOnCompletion = false

	local secondWaveOffset = 40 + math.random(0, 20)
	playdate.frameTimer.new(secondWaveOffset, function(timer)
		downWave1:start()
	end)

	upWave2 = playdate.frameTimer.new(8, function(timer)
		if currentEskimoUpWave2 > 8 then
			checkVictory()
			grunt_noise:play()
			timer:remove()
			return
		end
		
		if currentEskimoUpWave2 == bearPos then
			grunt_noise:play()
			currentEskimoUpWave2 += 1
			timer:reset()
			return
		end

		if currentEskimoUpWave2 + 1 == bearPos then
			checkBearPosition('down')
		elseif currentEskimoUpWave2 - 2 == bearPos then
			if checkBearPosition('up') then correct_noise:play() end
		elseif currentEskimoUpWave2 ~= 1 then grunt_noise:play() end
		
		eskimos[currentEskimoUpWave2]:waveUp()
		currentEskimoUpWave2 += 1
		timer:reset()
	end)

	upWave2:pause()
	upWave2.discardOnCompletion = false

	playdate.frameTimer.new(secondWaveOffset + 40 + math.random(0, 20), function(timer)
		upWave2:start()
	end)
	
	mobware.crankIndicator.start()
	crankPromptShowing = true
end

local function updateGame()
	local adjustedCrankValue = playdate.getCrankPosition()

	if adjustedCrankValue > 180 then adjustedCrankValue = 360 - adjustedCrankValue end
	bearCurrentImage = math.floor(((1 - (adjustedCrankValue / 180)) * (#bearImageTable - 1)) + 1)
	if bearCurrentImage < 1 then bearCurrentImage = 1 end
	if bearCurrentImage > #bearImageTable then bearCurrentImage = #bearImageTable end
	if gamestate ~= 'defeat_anim' then bearSprite:setImage(bearImageTable:getImage(bearCurrentImage)) end

	for index, eskimo in ipairs(eskimos) do
		if index ~= bearPos then
			eskimo:setImage(eskimoImageTable:getImage(math.floor(eskimo.animationTimer.value)))
		end
	end
	--print(currentImage)
end

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- start timer	 
--MAX_GAME_TIME = 10 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
--game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "defeat" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame

loadGame()

local function cleanup()
	music:stop()
	upWave1:remove()
	downWave1:remove()
	upWave2:remove()
	if victoryAnim ~= nil then
		victoryAnim:remove()
		victoryAnim = nil
	end
	if defeatAnim ~= nil then
		defeatAnim:remove()
		defeatAnim = nil
	end

	for index, eskimo in ipairs(eskimos) do
		if index ~= bearPos then
			eskimo.animationTimer:remove()
		end
		eskimo:remove()
	end
	bearSprite:remove()

	correct_noise = nil
	grunt_noise = nil
	boing_noise = nil
	lose_noise = nil
	music = nil
	bearImageTable = nil
	eskimoImageTable = nil
	backgroundImage = nil
end

--[[
	function <minigame name>.update()

	This function is what will be called every frame to run the minigame. 
	NOTE: The main game will initially set the framerate to call this at 20 FPS to start, and will gradually speed up to 40 FPS
]]
function polar_wave.update()

	updateGame()

	-- updates all sprites
	gfx.sprite.update()

	-- update timer
	playdate.frameTimer.updateTimers()
	--print('Time:', game_timer.frame)

	if gamestate == 'victory' then
		-- The "victory" gamestate will simply show the victory animation and then end the minigame

		-- display image indicating the player has won

		--playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- returning 1 will end the game and indicate the the player has won the minigame
		cleanup()
		return 1
	end

	if gamestate == 'defeat' then
		-- wait another 2 seconds then exit
		--playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- return 0 to indicate that the player has lost and exit the minigame
		cleanup()
		return 0

	end
	--playdate.drawFPS(0,0)
end


--[[
	You can use the playdate's callback functions! Simply replace "playdate" with the name of the minigame. 
	The minigame-version of playdate.cranked looks like this:
]]
function polar_wave.cranked(change, acceleratedChange)
	if crankPromptShowing then
		crankPromptShowing = false
		mobware.crankIndicator.stop()
	end
end

-- make sure to add put your name in "credits.json" and add "credits.gif" to the minigame's root folder. 
	--> These will be used to credit your game during the overarching game's credits sequence!

--> Finally, go to main.lua and search for "DEBUG_GAME". You'll want to set this to the name of your minigame so that your minigame gets loaded every turn!

-- Minigame package should return itself
return polar_wave
