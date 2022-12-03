
--[[
	Author: seansamu
	
	(bonus game adaptation by Drew-Lo)
	
	quick_draw bonus game for Mobware Minigames

]]

-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local quick_draw = {}

-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

playdate.display.setRefreshRate( 40 )

-- uninitialized variables
local flagTimer = nil
local enemyShootTimer = nil

-- initialized variables
local player1_score = 0
local player2_score = 0

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

local function any_button_pressed()
	-- returns 1 if any button is pressed
	if playdate.buttonIsPressed('a') then return 1 end
	if playdate.buttonIsPressed('b') then return 1 end
	if playdate.buttonIsPressed('up') then return 1 end
	if playdate.buttonIsPressed('down') then return 1 end
	if playdate.buttonIsPressed('left') then return 1 end
	if playdate.buttonIsPressed('right') then return 1 end

	-- if no button is pressed, return nil
	return nil
end

local function dpad_pressed()
	-- returns 1 if any button on the d-pad is pressed
	if playdate.buttonIsPressed('up') then return 1 end
	if playdate.buttonIsPressed('down') then return 1 end
	if playdate.buttonIsPressed('left') then return 1 end
	if playdate.buttonIsPressed('right') then return 1 end

	-- if no button is pressed, return nil
	return nil
end

local text_width, text_height = gfx.getTextSize("X")
-- returns an image of the score
local function draw_score(score)
	local canvas = gfx.image.new(text_width, text_height)
	gfx.lockFocus(canvas)
		gfx.drawTextAligned(score, 0, 0)
	gfx.unlockFocus()
	return canvas
end



-- Sample Sounds from https://www.fesliyanstudios.com/royalty-free-sound-effects-download
local gunfireSound = playdate.sound.sampleplayer.new('extras/quick_draw/sounds/gunfire.wav') -- Gauge Pump Action Shotgun Close Gunshot A Sound Effect
local flagWaveSound = playdate.sound.sampleplayer.new('extras/quick_draw/sounds/wind-swoosh.wav') -- Wind Shoowsh Fast Sound Effect

-- Wind sound from https://mixkit.co/free-sound-effects/wind/
local windSound = playdate.sound.sampleplayer.new('extras/quick_draw/sounds/light-wind.wav')

-- load and play soundtrack
local soundtrack = playdate.sound.fileplayer.new('extras/quick_draw/sounds/Gunslingers')
local victory_song = playdate.sound.fileplayer.new('extras/quick_draw/sounds/Gunslingers_victory')

soundtrack:play(0)

-- Images
local P1_ImageTable = gfx.imagetable.new('extras/quick_draw/images/cowboy-table-39-76.png')
assert(P1_ImageTable)

local P2_ImageTable = gfx.imagetable.new('extras/quick_draw/images/enemy-cowboy-table-39-76.png')
assert(P2_ImageTable)

local backgroundImage = gfx.image.new('extras/quick_draw/images/background.png')
assert(backgroundImage)

local cactusImageTable = gfx.imagetable.new('extras/quick_draw/images/cactus-table-74-107.png')
assert(cactusImageTable)

local sign_image = gfx.image.new('extras/quick_draw/images/sign')
assert(sign_image)

-- Sprites

P1_score_sign = gfx.sprite.new(sign_image)
P1_score_sign:moveTo(32, 32)

local P1_score_sprite = gfx.sprite.new(32,32)
P1_score_sprite:setImage(draw_score(0))
P1_score_sprite:moveTo(32, 26)
P1_score_sprite:setRotation(45)

local P2_score_sign = gfx.sprite.new(sign_image)
P2_score_sign:moveTo(368, 32)
P2_score_sign:setImageFlip(gfx.kImageFlippedX)

local P2_score_sprite = gfx.sprite.new(32,32)
P2_score_sprite:setImage(draw_score(0))
P2_score_sprite:moveTo(368, 26)
P2_score_sprite:setRotation(-45)

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
		tickStep = 3,
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

local player1sprite = AnimatedSprite.new( P1_ImageTable )
player1sprite:setStates(cowboyStates)
player1sprite:changeState('cowboy_idle')
player1sprite:moveTo(50, 150)
player1sprite:setZIndex(2)
player1sprite:add()

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
		tickStep = 3,
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

local player2sprite = AnimatedSprite.new( P2_ImageTable )
player2sprite:setStates( enemyStates )
player2sprite:changeState('enemy_idle')
player2sprite:moveTo(350, 150)
player2sprite:setZIndex(2)
player2sprite:add()

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


-- call this to reset the dual and start over
local function reset_duel()
	gamestate = 'beginning' -- gamestate values: 'beginning', 'waiting', 'flag-waved', 'win', 'defeat'
	buttonPromptShowing = false
	openingAnimationDone = true
	cactusPlayed = false
	shootingAnimationFinished = false
	buttonValueMap = { }
	
	flagTimer = nil
	enemyShootTimer = nil
	
	player1sprite:changeState('cowboy_idle')
	player1sprite:setRotation(0)
	player1sprite:moveTo(50, 150)
	
	player2sprite:changeState('enemy_idle')
	player2sprite:setRotation(0)
	player2sprite:moveTo(350, 150)
	
	cactusSprite:changeState('cactus_idle')
	
	P1_score_sign:remove()
	P1_score_sprite:remove()
	P2_score_sign:remove()
	P2_score_sprite:remove()

end


function quick_draw.update()

	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()

	-- show game start animation
	if gamestate == 'beginning' then
		windSound:play()

		if (openingAnimationDone and not flagTimer) then
			local randomNumber = math.random(30 * 1, 30 * 8) -- between 3s and 6s at 20fps 
			flagTimer = playdate.frameTimer.new(randomNumber, randomNumber, 0)
			flagTimer:start()
			gamestate = 'waiting'
		end
		
	-- start flagTimer, play cactus animation once flagTimer is 0
	elseif gamestate == 'waiting' then
		
		-- if the player hits the button before the flag is waved, don't allow them to register another button press for ~1 second
		if playdate.buttonJustPressed(playdate.kButtonA) then
			print("OOPS! player 2 was too quick on the draw!")
			P2penaltyTimer = playdate.frameTimer.new(2 * 20, function(P2penaltyTimer) P2penaltyTimer:remove() end) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
		end

		-- if the player hits the button before the flag is waved, don't allow them to register another button press for ~1 second
		if dpad_pressed() then
			print("OOPS! player 1 was too quick on the draw!")
			P1penaltyTimer = playdate.frameTimer.new(2 * 20, function(P1penaltyTimer) P1penaltyTimer:remove() end) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
		end
	
		if (flagTimer.value == 0 and not cactusPlayed) then
			flagWaveSound:play()
			cactusSprite:changeState('cactus_play')
			cactusPlayed = true
		end

		if (cactusSprite.currentState == 'cactus_done') then
			gamestate = 'flag-waved'
			local randomNumber = math.random(10, 40) -- between 0.5s and 2s at 20fps 
			enemyShootTimer = playdate.frameTimer.new(randomNumber, randomNumber, 0)
			enemyShootTimer:start()
		end
		
	elseif gamestate == 'flag-waved' then
		-- show button prompt sprite
		if (buttonPromptShowing == false) then
			mobware.AbuttonIndicator.start()
			mobware.DpadIndicator.start()
			buttonPromptShowing = true
		end
		

		-- if A is pressed, have Player 2 shoot 
		if playdate.buttonIsPressed(playdate.kButtonA) then
			
			-- if the player hit the button too early, don't allow 
			if P2penaltyTimer and (P2penaltyTimer.frame < P2penaltyTimer.duration)  then
				print("you can't shoot since you're in the penalty box!")
			
			else
				-- stop the prompt move to next gamestate
				mobware.AbuttonIndicator:stop()
				mobware.DpadIndicator:stop()
								
				gunfireSound:play()
				player2sprite:changeState('enemy_play')
				player1sprite:changeState('cowboy_dead')
				-- knock over enemy sprite:
				player1sprite:setRotation(-90)
				local _width, sprite_height = player1sprite:getSize()
				player1sprite:moveTo(player1sprite.x, player1sprite.y+sprite_height/2)
				gamestate = 'player2_wins'
				player2_score += 1
				P2_score_sprite:setImage(draw_score(player2_score))
				P1_score_sign:add()
				P1_score_sprite:add()
				P2_score_sign:add()
				P2_score_sprite:add()
			end
		end
		
		-- if d-pad is pressed, have Player 1 shoot 
		if dpad_pressed() then
			
			-- if the player hit the button too early, don't allow 
			if P1penaltyTimer and (P1penaltyTimer.frame < P1penaltyTimer.duration)  then
				print("you can't shoot since you're in the penalty box!")
			
			else
				-- stop the prompt move to next gamestate
				mobware.AbuttonIndicator:stop()
				mobware.DpadIndicator:stop()
				gunfireSound:play()
				player1sprite:changeState('cowboy_play')
				player2sprite:changeState('enemy_dead')
				-- knock over enemy sprite:
				player2sprite:setRotation(90)
				local _width, sprite_height = player2sprite:getSize()
				player2sprite:moveTo(player2sprite.x, player2sprite.y+sprite_height/2)
				if gamestate == 'player2_wins' then
					-- here we have draw since both players fired on the same frame, so we subtract the point back from player 2 and go to "draw" state
					gamestate = 'draw'
					player2_score -= 1
					P2_score_sprite:setImage(draw_score(player2_score))
				else
					gamestate = 'player1_wins'
					player1_score += 1
				end
				P1_score_sprite:setImage(draw_score(player1_score))
				P1_score_sign:add()
				P1_score_sprite:add()
				P2_score_sign:add()
				P2_score_sprite:add()
			end
		end

	elseif gamestate == 'draw' then
		mobware.print("draw!")
		if (shootingAnimationFinished) then
			if any_button_pressed() then
				reset_duel()
			end
		end


	elseif gamestate == 'player1_wins' then

		if player1_score >= 5 then 
			soundtrack:stop()
			victory_song:play(1)
			mobware.print("player 1 is the champ!", 45, 70)
		else
			mobware.print("player 1 wins!", 90, 70)
		end

		if (shootingAnimationFinished) then
			if any_button_pressed() then
				if player1_score >= 5 then 
					player1_score = 0
					player2_score = 0
					P1_score_sprite:setImage(draw_score(player1_score))
					P2_score_sprite:setImage(draw_score(player2_score))
				end
				victory_song:stop()
				soundtrack:play(0)
				reset_duel()
			end
		end

	elseif gamestate == 'player2_wins' then

		if player2_score >= 5 then 
			soundtrack:stop()
			victory_song:play(1)
			mobware.print("player 2 is the champ!", 45, 70)
		else
			mobware.print("player 2 wins!", 90, 70)
		end
		-- wait until animation finishes then exit
		if (shootingAnimationFinished) then
			if any_button_pressed() then
				if player2_score >= 5 then 
					player1_score = 0
					player2_score = 0
					P1_score_sprite:setImage(draw_score(player1_score))
					P2_score_sprite:setImage(draw_score(player2_score))
				end
				victory_song:stop()
				soundtrack:play(0)
				reset_duel()
			end
		end

	end

end


-- Minigame package should return itself
return quick_draw
