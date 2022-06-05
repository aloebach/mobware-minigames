
--[[
	Author: Andrew Loebach

	"Hello World" Minigame demo for Mobware Minigames
]]

-- Define name for minigame package
local hello_world = {}

local gfx <const> = playdate.graphics
	
-- Crank indicator prompt
mobware.crankIndicator.start()

-- Initialize animation for on-screen Playdate sprite
local playdate_helloWorld_table = gfx.imagetable.new("Minigames/hello_world/images/hello_world")

local pd_sprite = gfx.sprite.new(image_table)
pd_sprite:setImage(playdate_helloWorld_table:getImage(1))
pd_sprite:moveTo(200, 120)
pd_sprite:add()
pd_sprite.frame = 1 
pd_sprite.crank_counter = 0
pd_sprite.total_frames = 16

-- start timer 
MAX_GAME_TIME = 4 -- define the time at 20 fps that the game will run betfore setting the "defeat" gamestate
game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "defeat" end ) 
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will move to "defeat" gamestate

function hello_world.update()

	-- update sprite animations
	gfx.sprite.update() -- updates all sprites
	
	-- update frame timer
	playdate.frameTimer.updateTimers()

	-- For testing: return 0 if "B" button is pressed
	if playdate.buttonIsPressed('b') then return 0 end

	-- For testing to see if functions from main.lua can be called without issue:
	if playdate.buttonIsPressed('down') then mobware.DpadIndicator:start("down") end

	-- Win condition:
	if pd_sprite.frame == pd_sprite.total_frames then
		playdate.wait(1000)	-- Pause 1s before returning to main.lua
		return 1
	end

	-- Loss condition
	if gamestate == "defeat" then 
		-- if player has lost, show images of playdate running out of power then exit
		local playdate_low_battery_image = gfx.image.new("Minigames/hello_world/images/playdate_low_battery")
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
	We're going to use the crank to control the hello world animation
	We'll handle this in the callback function that'll be called each time the crank is moved
]]
function hello_world.cranked(change, acceleratedChange)
	-- Once crank is turned, turn off crank indicator
	if mobware.crankIndicator then
		mobware.crankIndicator.stop()
	end

	-- Increment animation counter:
	pd_sprite.crank_counter = pd_sprite.crank_counter + change

	if pd_sprite.crank_counter > 90 then
		if pd_sprite.frame < pd_sprite.total_frames then pd_sprite.frame = pd_sprite.frame + 1 end
		pd_sprite.crank_counter = 0
	elseif pd_sprite.crank_counter < -90 then
		if pd_sprite.frame > 1 then pd_sprite.frame = (pd_sprite.frame - 1) end
		pd_sprite.crank_counter = 0
	end

	pd_sprite:setImage(playdate_helloWorld_table:getImage(pd_sprite.frame))
end


-- Minigame package should return itself
return hello_world
