
--[[
	Author: <your name here>

	minigame_template for Mobware Minigames

	feel free to search and replace "minigame_template" in this code with your minigame's name,
	rename the file <your_minigame>.lua, and rename the folder to the same name to get started on your own minigame!
]]


--[[ NOTE: The following libraries are already imported in main.lua, so there's no need to define them in the minigame
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer" 
import "CoreLibs/nineslice"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/easing"
]]

-- Import any supporting libraries from minigame's folder
	--> Note that all supporting files should be located under 'Minigames/minigame_template/''
--import 'Minigames/minigame_template/lib/AnimatedSprite' 


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
minigame_template = {}


-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

-- animation for on-screen Playdate sprite
playdate_image_table = gfx.imagetable.new("Minigames/minigame_template/images/playdate")
low_battery_image_table = gfx.imagetable.new("Minigames/minigame_template/images/playdate_low_battery")
pd_sprite = gfx.sprite.new(image_table)

-- update sprite's frame so that the sprite will reflect the crank's actual position
local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
local frame_num = math.floor( crank_position / 45 + 1 )
pd_sprite:setImage(playdate_image_table:getImage(frame_num))


pd_sprite:moveTo(200, 120)
pd_sprite:add()
pd_sprite.frame = 1 
pd_sprite.crank_counter = 0
pd_sprite.total_frames = 16


--> Initialize music / sound effects
local click_noise = playdate.sound.sampleplayer.new('Minigames/minigame_template/sounds/click')

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- start timer	 
MAX_GAME_TIME = 6 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "defeat" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame


-- set initial gamestate and start prompt for player to hit the B button
gamestate = 'hitB'
mobware.BbuttonIndicator.start()



--[[
	function <minigame name>:update()

	This function is what will be called every frame to run the minigame. 
	NOTE: The main game will initially set the framerate to call this at 20 FPS to start, and will gradually speed up to 40 FPS
]]
function minigame_template.update()

	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()
	--print('Time:', game_timer.frame)

	-- In the first stage of the minigame, the user needs to hit the "B" button
	if gamestate == 'hitB' then
		if playdate.buttonIsPressed('b') then
			-- If player hits the "B" button during this gamestate, remove B button prompt and move to next gamestate
			mobware.BbuttonIndicator.stop()
			mobware.AbuttonIndicator.start()
			gamestate = 'hitA'
		end

	-- In the second stage of the minigame, the user needs to hit the "A" button
	elseif gamestate == 'hitA' then
		
		if playdate.buttonIsPressed('a') then
			-- If player hits the "A" button during this gamestate then stop the prompt move to next gamestate
			mobware.AbuttonIndicator.stop()
			mobware.DpadIndicator.start()
			gamestate = 'hitDpad'
		end

	-- In the next stage of the minigame, the user needs to hit the D-pad
	elseif gamestate == 'hitDpad' then
		if playdate.buttonIsPressed( playdate.kButtonUp ) or playdate.buttonIsPressed( playdate.kButtonDown ) or playdate.buttonIsPressed( playdate.kButtonLeft ) or playdate.buttonIsPressed( playdate.kButtonRight )  then
			-- If player hits the D-pad during this gamestate then move to next gamestate
			mobware.DpadIndicator.stop()
			mobware.crankIndicator.start()
			gamestate = 'turnCrank'
		end

	-- In the final stage of the minigame the user needs to turn the crank
	elseif gamestate == 'turnCrank' then
		if playdate.getCrankTicks(1) >= 1 then
			mobware.crankIndicator.stop()
			gamestate = 'victory'
		end


	elseif gamestate == 'victory' then
		-- The "victory" gamestate will simply show the victory animation and then end the minigame

		-- display image indicating the player has won
		mobware.print("good job!",90, 70)

		playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- returning 1 will end the game and indicate the the player has won the minigame
		return 1


	elseif gamestate == 'defeat' then

		-- if player has lost, show images of playdate running out of power 
		local playdate_low_battery_image = gfx.image.new("Minigames/minigame_template/images/playdate_low_battery")
		local low_battery = gfx.sprite.new(playdate_low_battery_image)
		low_battery:moveTo(150, 75)
		low_battery:addSprite()
		gfx.sprite.update() 

		-- wait another 2 seconds then exit
		playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- return 0 to indicate that the player has lost and exit the minigame 
		return 0

	end

end


--[[
	You can use the playdate's callback functions! Simply replace "playdate" with the name of the minigame. 
	The minigame-version of playdate.cranked looks like this:
]]
function minigame_template.cranked(change, acceleratedChange)
	-- When crank is turned, play clicking noise
	click_noise:play(1)

	-- update sprite's frame so that the sprite will reflect the crank's actual position
	local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
	local frame_num = math.floor( crank_position / 45 + 1 )
	pd_sprite:setImage(playdate_image_table:getImage(frame_num))

end


-- Minigame package should return itself
return minigame_template
