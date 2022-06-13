--[[
	Apple Chopper minigame for Mobware Minigames
	
	Original Microgame design by Nic Magnier
	Ported to Mobware Minigames by Drew Loebach
	]]
	
local apple_chopper = {}

--import 'CoreLibs/easing'
import "Minigames/apple_chopper/libs/sequence"

hand = playdate.graphics.image.new("Minigames/apple_chopper/hand")
apple = playdate.graphics.image.new("Minigames/apple_chopper/apple")
apple_slice = playdate.graphics.image.new("Minigames/apple_chopper/apple_slice")
handTransform = playdate.geometry.affineTransform.new()

anim_x = sequence.new():from(70):to(20, 0.5, "inSine")
anim_y = sequence.new():from(100):to(240, 0.5, "inBack")

is_apple_cut = false
mobware.crankIndicator.start()

local gamestate = "play"
local game_timer = playdate.frameTimer.new( 20 * 4, function() gamestate = "defeat" end ) 


function apple_chopper.update()
	sequence.update()
	
	-- update frame timers
	playdate.frameTimer.updateTimers()


	local angle = 405
	if playdate.isCrankDocked()==false then
		angle = (360-playdate.getCrankPosition()) + 90
	end
	handTransform:reset()
	handTransform:translate( -150, 0 )
	handTransform:rotate( angle )

	if is_apple_cut==false and angle < 370 and angle > 340 then
		anim_x:start()
		anim_y:start()
		is_apple_cut = true
		game_timer = playdate.frameTimer.new( 20, function() gamestate = "victory" end ) 
	end

	if gamestate == "victory" then
		return 1
	end

	if gamestate == "defeat" then
		return 0
	end
	
	playdate.graphics.clear( playdate.graphics.kColorWhite )
	playdate.graphics.sprite.update() -- updates all sprites

	if is_apple_cut then
		apple_slice:draw(70, 100)
	end
	hand:drawWithTransform( handTransform, 350, 120)
	apple:draw( anim_x:get(), anim_y:get() )
end


function apple_chopper.cranked(change, acceleratedChange)
	-- Once crank is turned, turn off crank indicator
	if mobware.crankIndicator then
		mobware.crankIndicator.stop()
	end
end


return apple_chopper
