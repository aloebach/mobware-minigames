	--[[
	Playdate Charger minigame for Mobware Minigames
	
	Original Microgame design by Nic Magnier
	Ported to Mobware Minigames by Drew Loebach
]]

local playdate_charger = {}

local background = playdate.graphics.image.new("Minigames/playdate_charger/battery_indicator")
local power = 0
local target_power = 4000
local gamestate = "start"

-- at 20fps, player has 5 seconds before minigame ends in defeat
local game_timer = playdate.frameTimer.new( 20 * 8, function() gamestate = "defeat" end ) 
mobware.crankIndicator.start()


function playdate_charger.update()
	
	-- update frame timer
	playdate.frameTimer.updateTimers()

	-- update game logic
	power += math.abs( playdate.getCrankChange() )
	
	-- rendering code
	playdate.graphics.sprite.update() -- updates all sprites (needed for crank indicator)
	background:draw(0,0)

	local segment_count = 5
	local visible_segment_count = math.floor( segment_count * power / target_power )
	for i = 0, visible_segment_count-1 do
		playdate.graphics.fillRect(90 + i*44, 80, 40, 80)
	end


	if power > target_power then
		--TO-DO: Make cooler victory animation
		mobware.print('Ready to game!')
		playdate.wait(1500)
		return 1
	end
		
	if gamestate == "start" then
		mobware.print('Charge your Playdate!')
	end
	
	if gamestate == "defeat" then
		-- Display low-battery animation
		background:draw(0,0)
		playdate.graphics.fillRect(90, 80, 15, 80)
		playdate.wait(1000)
		playdate.graphics.fillRect(0, 0, 400, 240)
		playdate.wait(1000)
		return 0
	end

end

function playdate_charger.cranked(change, acceleratedChange)

	-- When crank is turned, play sound effect
	--sound_effect:play(1)

	-- Once crank is turned, turn off crank indicator
	if mobware.crankIndicator then
		mobware.crankIndicator.stop()
	end
	if gamestate == "start" then
		gamestate = "play"
	end
end


return playdate_charger
