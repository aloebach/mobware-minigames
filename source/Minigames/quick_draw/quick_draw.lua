
--[[
	Author: seansamu

	quick_draw for Mobware Minigames

]]

-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local quick_draw = {}


-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

-- uninitialized variables
local flagTimer = nil
local enemyShootTimer = nil

-- initialized variables
local gamestate = 'beginning' -- gamestate values: 'beginning', 'waiting', 'flag-waved', 'win', 'defeat'
local buttonPromptShowing = false
local openingAnimationDone = true
local cactusPlayed = false
local shootingAnimationFinished = false
local buttonValueMap = { }
table.insert(buttonValueMap, 'a')
table.insert(buttonValueMap, 'b')

local buttonMap = {
	a = mobware.AbuttonIndicator,
	b = mobware.BbuttonIndicator,
}

local buttonValue = math.random(1,#buttonValueMap)
local wrongButtonValue = (buttonValue % #buttonValueMap ) + 1
local buttonToPressIndicator = buttonMap[buttonValueMap[buttonValue]]

-- functions
local function onShootingFinished ()
	shootingAnimationFinished = true
end

-- Sample Sounds from https://www.fesliyanstudios.com/royalty-free-sound-effects-download
local gunfireSound = playdate.sound.sampleplayer.new('Minigames/quick_draw/sounds/gunfire.wav') -- Gauge Pump Action Shotgun Close Gunshot A Sound Effect
local flagWaveSound = playdate.sound.sampleplayer.new('Minigames/quick_draw/sounds/wind-swoosh.wav') -- Wind Shoowsh Fast Sound Effect

-- Wind sound from https://mixkit.co/free-sound-effects/wind/
local windSound = playdate.sound.sampleplayer.new('Minigames/quick_draw/sounds/light-wind.wav')

-- Images
local cowboyImageTable = gfx.imagetable.new('Minigames/quick_draw/images/cowboy-table-39-76.png')
assert(cowboyImageTable)

local enemyImageTable = gfx.imagetable.new('Minigames/quick_draw/images/enemy-cowboy-table-39-76.png')
assert(enemyImageTable)

local backgroundImage = gfx.image.new('Minigames/quick_draw/images/background.png')
assert(backgroundImage)

local cactusImageTable = gfx.imagetable.new('Minigames/quick_draw/images/cactus-table-74-107.png')
assert(cactusImageTable)

local quickImage = gfx.image.new('Minigames/quick_draw/images/quick.png')
assert(quickImage)

local drawImage = gfx.image.new('Minigames/quick_draw/images/draw.png')
assert(drawImage)

-- Sprites

local cowboyStates = {
	{
		name = 'cowboy_idle',
		firstFrameIndex = 1,
		framesCount = 1,
		tickStep = 1,
		loop = false,
		xScale = 2, 
		yScale = 2
	},
	{
		name = 'cowboy_play',
		firstFrameIndex = 1,
		framesCount = 8,
		tickStep = 1,
		loop = false,
		nextAnimation = 'cowboy_gunsmoke',
		xScale = 2, 
		yScale = 2,
	},
	{
		name = 'cowboy_gunsmoke',
		firstFrameIndex = 5,
		framesCount = 4,
		tickStep = 1,
		loop = 3,
		nextAnimation = 'cowboy_idle',
		xScale = 2, 
		yScale = 2,
		onAnimationEndEvent = onShootingFinished
	},
	{
		name = 'cowboy_dead',
		firstFrameIndex = 9,
		framesCount = 1,
		tickStep = 1,
		loop = false,
		xScale = 2, 
		yScale = 2,
	},
}

local cowboySprite = AnimatedSprite.new( cowboyImageTable )
cowboySprite:setStates(cowboyStates)
cowboySprite:changeState('cowboy_idle')
cowboySprite:moveTo(50, 150)
cowboySprite:setZIndex(2)
cowboySprite:add()

local enemyStates = {
	{
		name = 'enemy_idle',
		firstFrameIndex = 1,
		framesCount = 1,
		tickStep = 1,
		loop = false,
		xScale = 2, 
		yScale = 2,
	},
	{
		name = 'enemy_play',
		firstFrameIndex = 1,
		framesCount = 8,
		tickStep = 1,
		loop = false,
		nextAnimation = 'enemy_gunsmoke',
		xScale = 2, 
		yScale = 2,
	},
	{
		name = 'enemy_gunsmoke',
		firstFrameIndex = 5,
		framesCount = 4,
		tickStep = 1,
		loop = 3,
		nextAnimation = 'enemy_idle',
		xScale = 2, 
		yScale = 2,
		onAnimationEndEvent = onShootingFinished
	},
	{
		name = 'enemy_dead',
		firstFrameIndex = 9,
		framesCount = 1,
		tickStep = 1,
		loop = false,
		xScale = 2, 
		yScale = 2,
	},
}

local enemySprite = AnimatedSprite.new( enemyImageTable )
enemySprite:setStates( enemyStates )
enemySprite:changeState('enemy_idle')
enemySprite:moveTo(350, 150)
enemySprite:setZIndex(2)
enemySprite:add()

local backgroundSprite = gfx.sprite.new(backgroundImage)
backgroundSprite:moveTo(0, 0)
backgroundSprite:setCenter(0, 0)
backgroundSprite:setZIndex(1)
backgroundSprite:add()

local cactusStates = {
	{
		name = 'cactus_idle',
		firstFrameIndex = 1,
		framesCount = 1,
		tickStep = 1,
		loop = false
	},
	{
		name = 'cactus_play',
		firstFrameIndex = 1,
		framesCount = 4,
		tickStep = 1,
		loop = false,
		nextAnimation = 'cactus_done',
	},
	{
		name = 'cactus_done',
		firstFrameIndex = 4,
		framesCount = 1,
		tickStep = 1,
		loop = false,
	}
}

local cactusSprite = AnimatedSprite.new( cactusImageTable )
cactusSprite:setStates(cactusStates)
cactusSprite:changeState('cactus_idle')
cactusSprite:moveTo(215, 134)
cactusSprite:setZIndex(1)

function quick_draw.update()

	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()

	-- show game start animation
	if gamestate == 'beginning' then
		windSound:play()

		if (openingAnimationDone and not flagTimer) then
			local randomNumber = math.random(20 * 3, 20 * 6) -- between 3s and 6s at 20fps 
			flagTimer = playdate.frameTimer.new(randomNumber, randomNumber, 0)
			flagTimer:start()
			gamestate = 'waiting'
		end
	-- start flagTimer, play cactus animation once flagTimer is 0
	elseif gamestate == 'waiting' then
	
		if (flagTimer.value == 0 and not cactusPlayed) then
			flagWaveSound:play()
			cactusSprite:changeState('cactus_play')
			cactusPlayed = true
		end

		if (cactusSprite.currentState == 'cactus_done') then
			gamestate = 'flag-waved'
			local randomNumber = math.random(20, 60) -- between 1s and 3s at 20fps 
			enemyShootTimer = playdate.frameTimer.new(randomNumber, randomNumber, 0)
			enemyShootTimer:start()
		end
	elseif gamestate == 'flag-waved' then
		-- show button prompt sprite
		if (buttonPromptShowing == false) then
			buttonToPressIndicator:start(buttonValueMap[buttonValue])
			buttonPromptShowing = true
		end
		
		-- if wrong button is pressed, play animation and move to defeat gamestate
		if playdate.buttonIsPressed(buttonValueMap[wrongButtonValue]) then
			if (buttonPromptShowing) then
				buttonPromptShowing = false
				buttonToPressIndicator:stop()
			end
			gunfireSound:play()
			enemySprite:changeState('enemy_play')
			cowboySprite:changeState('cowboy_dead')
		
			gamestate = 'defeat'
		end

		-- if correct button is pressed, shoot enemy cowboy
		if (playdate.buttonIsPressed(buttonValueMap[buttonValue])) then
			-- stop the prompt move to next gamestate
			buttonToPressIndicator:stop()
			gunfireSound:play()
			cowboySprite:changeState('cowboy_play')
			enemySprite:changeState('enemy_dead')
			gamestate = 'victory'
		end

		-- if enemy shoot timer gets to 0, play animation and move to defeat gamestate
		if (not playdate.buttonIsPressed(buttonValueMap[buttonValue]) and enemyShootTimer.value == 0) then
			if (buttonPromptShowing) then
				buttonPromptShowing = false
				buttonToPressIndicator:stop()
			end
			gunfireSound:play()
			enemySprite:changeState('enemy_play')
			cowboySprite:changeState('cowboy_dead')

			gamestate = 'defeat'
		end


	elseif gamestate == 'victory' then
		if (buttonPromptShowing) then
			buttonPromptShowing = false
			buttonToPressIndicator:stop()
		end

		mobware.print("Yee haw!", 90, 70)

		if (shootingAnimationFinished) then
			-- returning 1 will end the game and indicate the the player has won the minigame
			windSound:stop()
			return 1
		end

	elseif gamestate == 'defeat' then

		mobware.print("What in tarnation", 90, 70)

		-- wait until animation finishes then exit
		if (shootingAnimationFinished) then
			windSound:stop()
			-- return 0 to indicate that the player has lost and exit the minigame 
			return 0
		end

	end

end


-- Minigame package should return itself
return quick_draw
