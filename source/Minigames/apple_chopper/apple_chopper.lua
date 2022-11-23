--[[
	Apple Chopper minigame for Mobware Minigames
	
	Original Microgame design by Nic Magnier
	Ported to Mobware Minigames by Drew Loebach
	]]
	
local apple_chopper = {}

--import 'CoreLibs/easing'
import "Minigames/apple_chopper/libs/sequence"

local hand = playdate.graphics.image.new("Minigames/apple_chopper/hand")
local apple = playdate.graphics.image.new("Minigames/apple_chopper/apple")
local apple_slice = playdate.graphics.image.new("Minigames/apple_chopper/apple_slice")
local handTransform = playdate.geometry.affineTransform.new()

local anim_x = sequence.new():from(70):to(20, 0.5, "inSine")
local anim_y = sequence.new():from(100):to(240, 0.5, "inBack")

local is_apple_cut = false
mobware.crankIndicator.start()

local gamestate = "play"
local game_timer = playdate.frameTimer.new( 20 * 4, function() gamestate = "defeat" end ) 

-- loading sound effect
local hyuh = playdate.sound.sampleplayer.new("Minigames/apple_chopper/hyuh")

function apple_chopper.update()
	sequence.update()
	
	-- update frame timers
	playdate.frameTimer.updateTimers()


	local angle = 405
	local cx, ca = 0, 0
	if playdate.isCrankDocked()==false then
		cx, ca = playdate.getCrankChange()
		angle = (360-playdate.getCrankPosition()) + 90
	end
	handTransform:reset()
	handTransform:translate( -150, 0 )
	handTransform:rotate( angle )

	if is_apple_cut==false and angle < 370 and angle > 340 and cx > 15 then
		anim_x:start()
		anim_y:start()
		is_apple_cut = true
		hyuh:play(1)
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
