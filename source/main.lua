--[[
	MobWare Minigames
	
	Author: Andrew Loebach
	loebach@gmail.com

	This main program will reference the Minigames and run the minigames by calling their functions to execute the minigame's logic
]]

-- variables for use with testing/debugging:
--DEBUG_GAME = "asheteroids" --> Set "DEBUG_GAME" variable to the name of a minigame and it'll be chosen every time!
--SET_FRAME_RATE = 40 --> as the name implies will set a framerate. Used for testing minigames at various framerates
UNLOCK_ALL_EXTRAS = true -- set this to true to have all extras unlocked!

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
import "CoreLibs/keyboard"

-- Import supporting libraries
import 'lib/AnimatedSprite' --used to generate animations from spritesheet
import 'lib/mobware_ui'
import 'lib/mobware_utilities'
import 'lib/Playdate'
import 'lib/Coin'

-- Defining gfx as shorthand for playdate graphics API
local gfx <const> = playdate.graphics

--Define local variables to be used outside of the minigames
local GameState
local minigame
local unlockable_game
local is_in_bonus_game_list
local score
local money
local GAME_WINNING_SCORE = 20 --score that, when reached, will trigger the ending and show credits
local threshold_for_unlocking_bonus_game = 10  -- minimum score player has to have before being offered unlockables
local chance_of_unlocking_bonus_game = 25 -- percentage chance player will be offered an unlockable after completing minigame

-- generate table of minigames and bonus games
minigame_list = generate_minigame_list("Minigames/")
local bonus_game_list, unlocked_bonus_games = generate_bonusgame_list("extras/")

-- seed the RNG so that calls to random are always random
local s, ms = playdate.getSecondsSinceEpoch()
math.randomseed(ms,s)

-- initialize fonts
mobware_font_S = gfx.font.new("fonts/Mobware_S")
mobware_font_M = gfx.font.new("fonts/Mobware_M")
mobware_font_L = gfx.font.new("fonts/Mobware_L")
mobware_default_font = mobware_font_M

-- initialize sprite sheets for transitions
local playdate_spritesheet = gfx.imagetable.new("images/playdate_spinning")
local demon_spritesheet = gfx.imagetable.new("images/demon_big")

-- initialize music
local main_theme = playdate.sound.fileplayer.new('sounds/mobwaretheme')
local victory_music = playdate.sound.fileplayer.new('sounds/victory_v2')
local defeat_music = playdate.sound.fileplayer.new('sounds/defeat')


function initialize_metagame()
	score = 0
	money = 30
	display_money = money

	-- if DEBUG_GAME is set then jump right into the action!
	if DEBUG_GAME then
		GameState = 'initialize'
	else
		GameState = 'start'
	end

    -- Set initial FPS to 20, which will gradually increase to a maximum of 40
	time_scaler = 0 --initial value for variable used to speed up game speed over time
	playdate.display.setRefreshRate( SET_FRAME_RATE or math.min(20 + time_scaler, 40) )

	gfx.setFont(mobware_default_font)

end


-- Call function to initialize and start game 
initialize_metagame()

-- Main game loop called every frame
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
			
			-- TO-DO: ONLY SHOW MENU INDICATOR IF THE PLAYER HAS UNLOCKED NEW GOODIES?
			-- add menu indicator, then remove after ~1.2 seconds
			mobware.MenuIndicator.start()
			menu_indicator_timer = playdate.timer.new( 1200, function() mobware.MenuIndicator.stop() end ) 
			
			mobware.AbuttonIndicator.start()
			main_theme:play() -- play theme only once
			main_theme:setVolume(0.7)
			menu_initialized = 1
		end


	elseif GameState == 'bonus menu' then
		
		if menu_initialized then
			-- here is where we display the menu and allow the player to choose the bonus game
			
			-- only display the launch card once the onscreen playdate's animation has finished
			if pd_sprite.currentState == "idle" then
				launcher_sprite:setVisible(true)
			else
				launcher_sprite:setVisible(false)
			end
			
			gfx.sprite.update() 
			
			-- update game selected and onscreen menu (either via crank of D-pad)
			local menu_movement =  playdate.getCrankTicks(1)
			if playdate.buttonJustPressed("up") then menu_movement = -1 end
			if playdate.buttonJustPressed("down") then menu_movement = 1 end		
			if menu_movement ~= 0 then
				bonus_game_number += menu_movement
				if bonus_game_number > #unlocked_bonus_games_list then 
					bonus_game_number = 1 
				elseif bonus_game_number < 1 then
					bonus_game_number = #unlocked_bonus_games_list 
				end
				
				-- animate on-screen Playdate sprite's crank
				if menu_movement > 0 then 
					pd_sprite:changeState("crank")
				else
					pd_sprite:changeState("reverse_crank")
				end
				
				-- display launcher card for selected bonus game
				-- TO-DO: replace static card with card.gif like I do in the credits?
				local bonus_game_card = gfx.image.new('extras/' .. unlocked_bonus_games_list[bonus_game_number] .. '/card')
				launcher_sprite:setImage(bonus_game_card)
			end
			
			-- if player presses "A", then load bonus game
			if playdate.buttonJustPressed("A") then
				pd_sprite:changeState("transition_out")
			end
			
			-- once transition animation has finished and switched to "loading" state, open bonus game
			if pd_sprite.currentState == "loading" then
				pcall(minigame_cleanup)
				local bonus_game = unlocked_bonus_games_list[bonus_game_number]
				minigame = load_minigame('extras/' .. bonus_game .. '/' .. bonus_game)
				GameState = 'play'
			end 
			
		else
			--initialize menu
			
			set_black_background()		
						
			-- animation for on-screen Playdate sprite
			playdate_image_table = gfx.imagetable.new("images/playdate")
			pd_sprite = AnimatedSprite.new( playdate_image_table )
			pd_sprite:addState("transition_in", 1, 5, {tickStep = 2, nextAnimation = "idle"}, true)
			pd_sprite:addState("transition_out", 1, 5, {tickStep = 2, nextAnimation = "loading", reverse = true})
			pd_sprite:addState("loading", 1, 1)
			pd_sprite:addState("crank", 7, 13, {tickStep = 1, nextAnimation = "idle"})
			pd_sprite:addState("reverse_crank", 7, 13, {tickStep = 1, reverse = true, nextAnimation = "idle"})
			pd_sprite:addState("idle", 6, 6, {tickStep = 3})	
			pd_sprite:moveTo(250, 120)
						
			bonus_game_number = 1
			menu_initialized = 1
			
			-- generate table containing bonus games which have been unlocked 
			print("Generating table of unlocked bonus games:")
			unlocked_bonus_games_list = {}
			for _bonus_game, _status in pairs(unlocked_bonus_games) do
				print("adding", _bonus_game)
				table.insert( unlocked_bonus_games_list, _bonus_game )
			end

			-- add launcher card for sprite
			launcher_sprite = gfx.sprite.new(  gfx.image.new('extras/' .. unlocked_bonus_games_list[bonus_game_number] .. '/card') )
			launcher_sprite:moveTo(200, 78)
			launcher_sprite:add()
			
			-- set playdate's default refresh rates so bonus games always run at a constant speed
			playdate.display.setRefreshRate(30)

		end


	elseif GameState == 'initialize' then 
		-- Take a random game from our list of games, or take DEBUG_GAME if defined
		local game_num = math.random(#minigame_list)
		minigame_name = DEBUG_GAME or minigame_list[game_num]
		local minigame_path = 'Minigames/' .. minigame_name .. '/' .. minigame_name -- build minigame file path 
				
		-- Clean up graphical environment for minigame
		pcall(minigame_cleanup)
		
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
			
			-- unload & clean-up minigame
			minigame = nil
			_minigame_env = nil	
			pcall(minigame_cleanup)
						
			if game_result == 0 then 
				money = money - 10 -- update our score
				if money <= 0 then GameState = 'game_over' end

			elseif game_result == 1 then
				score = score + 1
				
				-- logic for randomly offering for the player to buy bonus content if they complete a minigame above a certain difficulty level:
				if score >= threshold_for_unlocking_bonus_game then
					local random_num = math.random(100)
					if random_num <= chance_of_unlocking_bonus_game then
						print('congratulations! You have been offered unlockable content!')
						unlockable_game = minigame_name
						GameState = 'offer_unlockable'
					end
				end
				
				--if the player's score is sufficiently high, show credits
				if score == GAME_WINNING_SCORE then GameState = 'credits' end

				-- increase game speed after each successful minigame:
				time_scaler = time_scaler + 1
			end
						
			-- Set up demon sprite for transition animation
			set_black_background()
			demon_sprite = AnimatedSprite.new( demon_spritesheet )
			demon_sprite:addState("animate", nil, nil, {tickStep = 3, frames = {2,4}}, true)
			demon_sprite:addState("laughing", nil, nil, {tickStep = 2, frames = {2,4}, loop = 5, nextAnimation = "throwing"})
			demon_sprite:addState("angry", nil, nil, {tickStep = 2, frames = {5,6}, reverse = true, loop = 3, nextAnimation = "throwing"})
			demon_sprite:addState("throwing", 1, 4, {tickStep = 3, loop = 3, nextAnimation = "finish"})
			demon_sprite:addState("finish", nil, nil, {tickStep = 2, frames = {7,7}, nextAnimation = "animate"})
			demon_sprite:moveTo(200, 120)
			demon_sprite:setZIndex(1)
			
			-- demon throws playdates in "throwing" state
			demon_sprite.states.throwing.onFrameChangedEvent = function (self)
				if self._currentFrame == 1 then
					local playdate_sprite = Playdate:new(270,130,12)
				elseif self._currentFrame == 3 then
					local playdate_sprite = Playdate:new(130,130,-12)
				end
			end -- remove sprite once animation completes

			-- once throwing state is completed throw one last playdate at the player and begin minigame
			demon_sprite.states.throwing.onAnimationEndEvent = function () 
				local playdate_sprite = AnimatedSprite.new( playdate_spritesheet )
				playdate_sprite:addState("animate", 1, 18, {tickStep = 1, reverse = true, loop = false, onAnimationEndEvent = function () GameState = 'initialize' end }, true)
				playdate_sprite:moveTo(200, 120)
				playdate_sprite:setZIndex(200)
			end -- remove sprite once animation completes
			
			
			-- animate demon laughing or crying depending on if the player won the minigame
			if game_result == 0 then 
				local music_rate = math.min(1 + time_scaler / 20, 2)
				--defeat_music:setRate(music_rate)
				defeat_music:play(1)
				demon_sprite:changeState("laughing")
				coin1 = Coin:new(140, 100)
				coin2 = Coin:new(260, 100)
			elseif game_result == 1 then
				victory_music:play(1) -- play victory theme 
				demon_sprite:changeState("angry")
			else
				victory_music:play(1) -- play victory theme 
				demon_sprite:changeState("throwing")				
			end

		end


	elseif GameState == 'transition' then
		-- Play transition animation between minigames

		-- update timer
		playdate.frameTimer.updateTimers()
		
		-- updates sprites
		gfx.sprite.update() 
		
		-- updating player's score
		if display_money > money then
			display_money -= 1
			if display_money <= money then display_money = money end
			--if display_money <= 0 then GameState = 'game_over' end
		end

		-- display UI for transition		
		gfx.setFont(mobware_font_S)
		mobware.print("score: " .. score, 15, 20)
		mobware.print("money: $" .. display_money, 15, 65)
		gfx.setFont(mobware_default_font) -- reset font to default
		
		
	elseif GameState == 'offer_unlockable' then
		-- here the player is given the option to purchase unlockable content with their in-game currency
		
		-- TO-DO: instead of doing this iterate over unlocked_bonus_games list?
		-- generating easily referencable dictionary of unlocked games
		-- TO-DO: move this to utilities? 
		if is_in_bonus_game_list then
			print('is_in_bonus_game_list already generated')
		else
			-- create a set so that we can easily 
			print('is_in_bonus_game_list not found. Creating...')
			is_in_bonus_game_list = {}
			for _, i in ipairs(bonus_game_list) do
				is_in_bonus_game_list[i] = true
			end
		end
		
		-- check if there is an unlockable game corresponding to the minigame that was just completed
		if is_in_bonus_game_list[unlockable_game] then
			if unlocked_bonus_games[unlockable_game] then
				print("what a shame, you've already unlocked the extra for",  unlockable_game)
				GameState = 'transition' 
			else
				-- offer player to purchase bonus game
				print("you're in luck, unlockable content for", unlockable_game, "is available!")
				-- TO-DO: ADD CUTSCENE HERE WHERE PLAYER HAS OPTION TO PURCHASE BONUS CONTENT
				print(unlockable_game, "unlocked")
				
				-- Save updated list of unlockable games to file
				unlocked_bonus_games[unlockable_game] = "unlocked" -- add bonus game to list of unlocked content
				playdate.datastore.write(unlocked_bonus_games, "mobware_unlockables")
				
				GameState = 'transition' 
			end
			
		else
			print("no bonus game found for", unlockable_game)
			-- return to transition gamestate to continue game
			GameState = 'transition' 
		end


	elseif GameState == 'game_over' then
		-- TO-DO: UPDATE WITH GAME OVER SEQUENCE

		-- Display game over screen
		pcall(minigame_cleanup)
		gfx.clear(gfx.kColorBlack)
		gfx.setFont(mobware_font_M)
		mobware.print("GAME OVER!")  
        playdate.wait(4000)

		--reload game from the beginning
		initialize_metagame()  


	elseif GameState == 'credits' then
		-- Play credits sequence
		
		-- load "credits" as minigame
		pcall(minigame_cleanup)
		minigame = load_minigame('credits') 		
		GameState = 'play' 		

	end
	
	-- Added for debugging
	--playdate.drawFPS()

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

sysMenu = playdate.getSystemMenu()
-- Add menu option to return to main menu
sysMenu:addMenuItem(
    'Main Game',
    function()
		if GameState ~= "menu" then
			minigame = nil
			_minigame_env = nil	
			pcall(minigame_cleanup)
			menu_initialized = nil
        	GameState = "menu"
		end
    end
)

-- Add menu option to view bonus content
sysMenu:addMenuItem(
	'bonus games',
	function()
		minigame = nil
		_minigame_env = nil	
		pcall(minigame_cleanup)
		menu_initialized = nil
		GameState = "bonus menu"
	end
)

-- Add menu option to view credits
sysMenu:addMenuItem(
	'Game Credits',
	function()
		pcall(minigame_cleanup)
		GameState = "credits"
	end
)
--[[ OPTIONAL DEBUGGING MENU OPTION TO CHOOSE MINIGAME:
sysMenu:addOptionsMenuItem("game:", minigame_list, 
	function(selected_minigame)
		DEBUG_GAME = selected_minigame
	end
)
]]

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
