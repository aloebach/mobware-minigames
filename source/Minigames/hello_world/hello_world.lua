
--[[
	Author: Andrew Loebach

	"Hello World" Minigame demo for Mobware Minigames
]]

--NOTE: Imports to corelibs won't work in this function! they need to be included in the library
--needed for using animating playdate's sprite library
--import 'CoreLibs/sprites'
--import 'CoreLibs/object'
--import 'Minigames/hello_world/lib/AnimatedSprite' --used to generate animations from spritesheet
import 'Minigames/hello_world/lib/object' --used to generate animations from spritesheet


-- Define name for minigame package
hello_world = {}

local gfx <const> = playdate.graphics
	
-- Crank indicator prompt
mobware.crankIndicator.start()

-- Initialize animation for on-screen Playdate sprite
playdate_helloWorld_table = gfx.imagetable.new("Minigames/hello_world/images/hello_world")

pd_sprite = gfx.sprite.new(image_table)
pd_sprite:setImage(playdate_helloWorld_table:getImage(1))
pd_sprite:moveTo(200, 120)
pd_sprite:add()
pd_sprite.frame = 1 
pd_sprite.crank_counter = 0
pd_sprite.total_frames = 16


function hello_world.update()

	-- update sprite animations
	gfx.sprite.update() -- updates all sprites

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
	--[[ if timer > 8s then show "battery low icon and exit" then
		-- add low battery graphics
		playdate.wait(1000)	-- Pause 1s before returning to main.lua
		return 0
	end
	]]


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
