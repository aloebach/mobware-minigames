--[[
	MobWare Minigames
	
	Author: Andrew Loebach
	loebach@gmail.com

--This main program will reference the Minigames and run the minigames by calling their functions to run the minigame's logic

To-Do's:
-Add references to frame timers -> minigames should use frame timers so that the difficulty scales properly
-Add story-linked transition animations and polish main game interface
-Add opening sequence
-Add ending sequence

- FIX BUG THAT OCCURS WHEN CHANGING GAMESTATE DURING playdate.wait()

--> maybe call callback functions via "pcall" to avoid corner case that they're called while a game is being loaded/unloaded
]]

-- variables for use with testing/debugging:
--DEBUG_GAME = "bodega_cat" --> Set "DEBUG_GAME" variable to the name of a minigame and it'll be chosen every time!
--SET_FRAME_RATE = 40 --> as the name implies will set a framerate. Used for testing how the game runs at the max framerate of 40fps

-- Import CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer" 
import "CoreLibs/nineslice"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/easing"

-- for ART7 minigame:
--import "CoreLibs/utilities/sampler"

-- Import supporting libraries
import 'lib/AnimatedSprite' --used to generate animations from spritesheet
import 'lib/mobware_ui'
import 'lib/mobware_utilities'

-- Defining gfx as shorthand for playdate graphics API
local gfx <const> = playdate.graphics

--Define local variables to be used outside of the minigames
local GameState
local minigame
local score
local lives
--local time_scaler
local GAME_WINNING_SCORE = 20 --score that, when reached, will trigger the ending and show credits

-- generate table of minigames from directories in "Minigames" folder
minigame_list = generate_minigame_list("Minigames/")

-- seed the RNG so that calls to random are always random
local s, ms = playdate.getSecondsSinceEpoch()
math.randomseed(ms,s)

-- load main game music
local main_theme = playdate.sound.fileplayer.new('sounds/mobwaretheme')

-- initialize fonts
mobware_font_S = gfx.font.new("fonts/Mobware_S")
mobware_font_M = gfx.font.new("fonts/Mobware_M")
mobware_font_L = gfx.font.new("fonts/Mobware_L")
mobware_default_font = mobware_font_M

-- initialize spritesheets for transitions
playdate_spritesheet = gfx.imagetable.new("images/playdate_spinning")
demon_spritesheet = gfx.imagetable.new("images/demon_big")

function initialize_metagame()
	score = 0
	lives = 3

	-- if using DEBUG_GAME then jump right into the action!
	if DEBUG_GAME then
		GameState = 'initialize'
	else
		GameState = 'start'
	end

    -- the state of our game; can be any of the following:
    -- 1. 'start' (the beginning of the game, before first minigame)
    -- 2. 'transition' (the state in between minigames)
    -- 3. 'initialize' (the next minigame is chosen and initialized)
    -- 4. 'play' (minigame is being played)
    -- 5. 'credits' (the player has reached a score to get the ending which displays the game's credits)
    -- 6. 'game_over' (the game is over, display score, ready for restart)

    -- Set initial FPS to 20, which will gradually increase to a maximum of 40
	time_scaler = 0 --initial value for variable used to speed up game speed over time
	playdate.display.setRefreshRate( SET_FRAME_RATE or math.min(20 + time_scaler, 40) )

	gfx.setFont(mobware_default_font)

end


-- Call function to initialize and start game 
initialize_metagame()


function playdate.update()

	if GameState == 'start' then
		-- TO-DO: ADD OPENING CINEMATIC HERE!
		-- Run file to play opening
		
		GameState = 'menu' -- go to main game menu


	elseif GameState == 'menu' then
		-- TO-DO: FLESH OUT GAME MENU!
		
		if menu_initialized then
			
			gfx.sprite.update() 
			playdate.timer:updateTimers()
			
			mobware.print("mobware minigames")
			
			if playdate.buttonIsPressed("a") then 
				
				main_theme:stop() -- play music only once
				mobware.AbuttonIndicator.stop()
				menu_initialized = nil
				GameState = 'initialize'
				
			end
			
		else
			-- Initialize the game's main menu
			
			-- set background color to black		
			set_black_background()
			
			-- TO-DO: ONLY SHOW MENU INDICATOR IF THE PLAYER HAS UNLOCKED NEW GOODIES! 
			-- show menu indicator for ~1.2 seconds
			mobware.MenuIndicator.start()
			menu_indicator_timer = playdate.timer.new( 1200, function() mobware.MenuIndicator.stop() end ) 
			
			mobware.AbuttonIndicator.start()
			main_theme:play() -- play theme only once
			main_theme:setVolume(0.7)
			menu_initialized = 1
		end


	elseif GameState == 'bonus menu' then
		-- TO-DO: READ MEMORY TO DETERMINE WHICH BONUS GAMES HAVE BEEN UNLOCKED
			--> build this into the function that gets the bonus game list!
		
		if menu_initialized then
			-- here is where we display the menu and allow the player to choose the bonus game
			gfx.sprite.update() 
			
			--> REPLACE THIS WITH JUST AN AUTO ANIMATION THAT SHOWS CRANK TURN EVERY TIME GAME IS CHANGED?
			local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
			pd_sprite.frame_num = math.floor( crank_position / 45.1 + 1 )
			pd_sprite:setImage(playdate_image_table:getImage(pd_sprite.frame_num))
			
			-- update game selected and onscreen menu (either via crank of D-pad)
			local menu_movement =  playdate.getCrankTicks(2)
			if playdate.buttonJustPressed("up") then menu_movement = -1 end
			if playdate.buttonJustPressed("down") then menu_movement = 1 end		
			if menu_movement ~= 0 then
				bonus_game_number += menu_movement
				if bonus_game_number > #bonus_game_list then 
					bonus_game_number = 1 
				elseif bonus_game_number < 1 then
					bonus_game_number = #bonus_game_list 
				end
				
				-- display launcher card for selected bonus game
				local bonus_game_card = gfx.image.new('extras/' .. bonus_game_list[bonus_game_number] .. '/card')
				launcher_sprite:setImage(bonus_game_card)
				
			end
			
			-- if player presses "A", then load bonus game
			if playdate.buttonIsPressed("A") then
				minigame_cleanup()
				local bonus_game = bonus_game_list[bonus_game_number]
				minigame = load_minigame('extras/' .. bonus_game .. '/' .. bonus_game)
				GameState = 'play' 
			end
			
		else
			--initialize menu
			
			set_black_background()		
			
			-- To-D0: add animation to have playdate zoom out from the screen
			
			-- animation for on-screen Playdate sprite
			playdate_image_table = gfx.imagetable.new("images/playdate")
			pd_sprite = gfx.sprite.new(playdate_image_table)
			pd_sprite.frame_num = 1
			pd_sprite:setImage(playdate_image_table:getImage(pd_sprite.frame_num))
			pd_sprite:moveTo(250, 120)
			pd_sprite:add()
						
			-- generate list of bonus games
			bonus_game_list = generate_minigame_list("extras/")
			--> TO-DO: compare bonus game list to list of unlocked bonus games from memory?
			bonus_game_number = 1
			menu_initialized = 1
			
			-- add launcher card for sprite
			launcher_sprite = gfx.sprite.new(  gfx.image.new('extras/' .. bonus_game_list[bonus_game_number] .. '/card') )
			launcher_sprite:moveTo(200, 78)
			launcher_sprite:add()
			
			-- set playdate's default refresh rates so bonus games always run at a constant speed
			playdate.display.setRefreshRate(30)
			
		end


	elseif GameState == 'initialize' then 
		-- Take a random game from our list of games, or take DEBUG_GAME if defined
		local game_num = math.random(#minigame_list)
		local minigame_name = DEBUG_GAME or minigame_list[game_num]
		local minigame_path = 'Minigames/' .. minigame_name .. '/' .. minigame_name -- build minigame file path 
				
		-- Clean up graphical environment for minigame
		minigame_cleanup()
		
		-- Load minigame package:
		minigame = load_minigame(minigame_path)
		GameState = 'play' 


	elseif GameState == 'play' then
		
		-- call minigame's update function
		game_result = minigame.update()
		--> minigame update function should return 1 if the player won, and 0 if the player lost

		-- move to "transition" gamestate if the minigame is over
		if game_result == 0 or game_result == 1 or game_result == 2 then
			GameState = 'transition'
			
			--print('Minigame return value: ', game_result)
			
			if game_result == 0 then
				lives = lives - 1
				if lives == 0 then GameState = 'game_over' end
			elseif game_result == 1 then
				score = score + 1
				-- TO-DO: ADD MINIGAME_WON GAMESTATE with TRIUMPHANT SOUND EFFECT AND LOGIC FOR HAPPY ANIMATION!

				--if the player's score is sufficiently high, show credits
				if score == GAME_WINNING_SCORE then GameState = 'credits' end

				-- increase game speed after each successful minigame:
				time_scaler = time_scaler + 1
			end
			
			minigame_cleanup()
			
			-- Set up PlayDate sprite for transition animation
			demon_sprite = AnimatedSprite.new( demon_spritesheet )
			demon_sprite:addState("animate", nil, nil, {tickStep = 3}, true)
			demon_sprite:moveTo(200, 120)
			demon_sprite:setZIndex(1)

			playdate_sprite = AnimatedSprite.new( playdate_spritesheet )
			playdate_sprite:addState("animate", 1, 18, {tickStep = 1, yoyo = true, loop = 2}, true)
			playdate_sprite:moveTo(200, 120)
			playdate_sprite:setZIndex(2)

			timer = playdate.timer.new(2100)
			-- playdate.easingFunctions.outCubic(t, b, c, d) 
			-- playdate.easingFunctions.outCubic(timer.currentTime, 120, 120, d) 

		end


	elseif GameState == 'transition' then
		-- Play transition animation between minigames

		-- TO-DO: UPDATE WITH ANTAGONIST ANIMATIONS FOR VICTORY AND DEFEAT, 
		-- AND REPLACE ROTATION WITH PRERENDERED VERSION TO AVOID SLOWDOWN ON PLAYDATE HARDWARE

		-- update timer
		playdate.timer.updateTimers()

		--[[NEW CODE
		print("time:",timer.currentTime)
		local new_y
		if timer.currentTime <= 10000 then
			new_y = playdate.easingFunctions.outCubic(timer.currentTime, 120, 120, 1000) 
		else
			new_y = playdate.easingFunctions.outCubic(timer.currentTime, 240, -120, 1000) 
		end
		playdate_sprite:moveTo(200, new_y)
		--END NEW CODE]]
		
		gfx.sprite.update() -- updates all sprites
		
		-- display UI for transition
		--gfx.setFont(mobware_font_M)
		--mobware.print("Mobware Minigames!", 15, 15)
		
		-- moved from "rendering" section of code
		gfx.setFont(mobware_font_S)
		mobware.print("score: " .. score, 15, 20)
		mobware.print("lives: " .. lives, 15, 65)
		gfx.setFont(mobware_default_font) -- reset font to default
		
		if timer.currentTime >= 2100 then GameState = 'initialize' end



	elseif GameState == 'game_over' then
		-- TO-DO: UPDATE WITH GAME OVER SEQUENCE

  		-- Display game over screen
		gfx.clear(gfx.kColorBlack)
		gfx.setFont(mobware_font_M)
		mobware.print("GAME OVER!")  
        playdate.wait(4000)

		--reload game from the beginning
		initialize_metagame()  


	elseif GameState == 'credits' then
		-- Play credits sequence
		
		-- load "credits" as minigame
		minigame_cleanup()
		minigame = load_minigame('credits') 		
		GameState = 'play' 		

	end


end


-- Callback functions for Playdate inputs:

-- Callback functions for crank
function playdate.cranked(change, acceleratedChange) if minigame and minigame.cranked then minigame.cranked(change, acceleratedChange) end end
function playdate.crankDocked() if minigame and minigame.crankDocked then minigame.crankDocked() end end
function playdate.crankUndocked() if minigame and minigame.crankDocked then minigame.crankUndocked() end end

-- Callback functions for button presses:
function playdate.AButtonDown() if minigame and minigame.AButtonDown then minigame.AButtonDown() end end
function playdate.AButtonHeld() if minigame and minigame.AButtonHeld then minigame.AButtonHeld() end end
function playdate.AButtonUp() if minigame and minigame.AButtonUp then minigame.AButtonUp() end end
function playdate.BButtonDown() if minigame and minigame.BButtonDown then minigame.BButtonDown() end end
function playdate.BButtonHeld() if minigame and minigame.BButtonHeld then minigame.BButtonHeld() end end
function playdate.BButtonUp() if minigame and minigame.BButtonUp then minigame.BButtonUp() end end
function playdate.downButtonDown() if minigame and minigame.downButtonDown then minigame.downButtonDown() end end
function playdate.downButtonUp() if minigame and minigame.downButtonUp then minigame.downButtonUp() end end
function playdate.leftButtonDown() if minigame and minigame.leftButtonDown then minigame.leftButtonDown() end end
function playdate.leftButtonUp() if minigame and minigame.leftButtonUp then minigame.leftButtonUp() end end
function playdate.rightButtonDown() if minigame and minigame.rightButtonDown then minigame.rightButtonDown() end end
function playdate.rightButtonUp() if minigame and minigame.rightButtonUp then minigame.rightButtonUp() end end
function playdate.upButtonDown() if minigame and minigame.upButtonDown then minigame.upButtonDown() end end
function playdate.upButtonUp() if minigame and minigame.upButtonUp then minigame.upButtonUp() end end


-- Add menu option to return to main menu
playdate.getSystemMenu():addMenuItem(
    'Main Game',
    function()
		if GameState ~= "menu" then
			minigame_cleanup()
			menu_initialized = nil
        	GameState = "menu"
		end
    end
)

-- Add menu option to view bonus content
playdate.getSystemMenu():addMenuItem(
	'bonus games',
	function()
		minigame_cleanup()
		menu_initialized = nil
		GameState = "bonus menu"
	end
)

-- Add menu option to view credits
playdate.getSystemMenu():addMenuItem(
	'Game Credits',
	function()
		minigame_cleanup()
		GameState = "credits"
	end
)


-- For debugging
function  playdate.keyPressed(key)
	if GameState == 'play' then pcall(minigame.keyPressed, minigame, key) end 
	
	--Debugging code for memory management
	print("Memory used: " .. math.floor(collectgarbage("count")))

	if key == "c" then print('Sprite count: ', gfx.sprite.spriteCount() ) end
	
	-- mute sounds if "m" is pressed
	if key == "m" then 
		sounds = playdate.sound.playingSources()
		for _i, sound in ipairs(sounds) do
			print('muting', sound)
			sound:stop() 
		end
	end
end
