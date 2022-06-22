
--[[
	Programming: Drew Loebach
	Game Design & art: 6AT0

	key_to_success for Mobware Minigames
]]

key_to_success = {}

import 'Minigames/key_to_success/Bar' 

local gfx <const> = playdate.graphics

-- parameters to determine game's difficulty level
local CRANK_POWER = 14	-- represents how much cranking will lift the bars
local NUMBER_OF_BARS = 6 -- the number of bars generated that our key has to navigate through
local WALKING_SPEED = 2 -- how fast the key moves across the screen

-- load images / sprite-sheets animation for on-screen sprites
local key_spritesheet = gfx.imagetable.new("Minigames/key_to_success/images/key")
local background_image = gfx.image.new("Minigames/key_to_success/images/background") 
local crank_bar = gfx.image.new("Minigames/key_to_success/images/Crank_bar_obstacle") 

-- initialize background
local background = gfx.sprite.new()
background:setImage(background_image)
background:moveTo(200, 120)
background:addSprite()

--initialize our key character
key = AnimatedSprite.new( key_spritesheet )
key:addState("idle", 1, 5, {tickStep = 3, nextAnimation = "walking"}, true).asDefault()
key:addState("walking", 6, 10, {tickStep = 3})
key:addState("hit", 11, 17, {tickStep = 1, nextAnimation = "game_over"}, true)
key:addState("game_over", 13, 17, {tickStep = 1, loop = false}, true)

key:changeState('idle') --start with key in idle state
key:moveTo(20,220)
key:setZIndex(1)
key:setCollideRect(2,10,30,20)

-- initialize obstacles
local x = 400 - NUMBER_OF_BARS * 40 -- x position of first bar
local y = 120 -- initial y for bars
bars = {}
for i = 1, NUMBER_OF_BARS do
	table.insert(bars, Bar(x,y,i))
	x += 40 -- make the bars 40 pixels apart
end

--> Initialize music / sound effects
local click_noise = playdate.sound.sampleplayer.new('Minigames/key_to_success/sounds/click')
local scream_noise = playdate.sound.sampleplayer.new('Minigames/key_to_success/sounds/scream')
local victory_sound = playdate.sound.sampleplayer.new('Minigames/key_to_success/sounds/alright')

-- set initial gamestate and start prompt for player to hit the B button
gamestate = 'play'
mobware.crankIndicator.start()
mobware.DpadIndicator.start()
local game_timer = playdate.frameTimer.new( 1 * 20, function() mobware.DpadIndicator.stop() end ) -- removes d-pad indicator after 1 second (at 20fps)


function key_to_success.update()

	-- updates all sprites
	gfx.sprite.update() 
	
	-- update timer
	playdate.frameTimer.updateTimers()
	
	if gamestate == 'play' then
		
		-- our key character should march forward every frame
		if key.currentState == "walking" then
			local _actualX, _actualY, _collisions, length = key:moveWithCollisions(key.x + WALKING_SPEED , key.y)
			if length > 0 then 
				gamestate = 'defeat' 
				key:changeState('hit')
			end
			
		end
		
		-- if the player has cranked sufficiently, then raise bars according to what is pressed on the D-pad
		if playdate.getCrankTicks(12) >0  then
			-- check if D-pad directions are down, and if so.. move the relevant bar
			for _i, bar in ipairs(bars) do
				-- raise bar if it's corresponding direction on the D-pad is pressed:
				
				-- for bars with a direction specified check if that button is pressed 				
				if playdate.buttonIsPressed("up") or playdate.buttonIsPressed("down") or playdate.buttonIsPressed("left") or playdate.buttonIsPressed("right") then -- for bars with a direction specified check if that button is pressed 				
					if playdate.buttonIsPressed(bar.orientation) then
						bar:moveTo(bar.x, bar.y - CRANK_POWER)
					end
				-- bars with no orientation will only be raised if no inputs are given on the D-pad
				elseif bar.orientation == nil then
					bar:moveTo(bar.x, bar.y - CRANK_POWER)
				end
			end		
		end
		
		-- win condition: the key character makes it to the end of the screen
		if key.x > 416 then gamestate = 'victory' end


	elseif gamestate == 'victory' then
		-- The "victory" gamestate will simply show the victory animation and then end the minigame

		-- display image indicating the player has won
		--mobware.print("ending unlocked!",100, 70)
		victory_sound:play(1)

		playdate.wait(2000)	-- Pause 2s before ending the minigame
		return 1	-- returning 1 will end the game and indicate the the player has won the minigame


	elseif gamestate == 'defeat' then
		
		-- end minigame after "hit" animation is over 
		if key.currentState == "game_over" then
			scream_noise:play(1)
			-- wait another 1 second then exit minigame
			playdate.wait(1000)	-- Pause 2s before ending the minigame			
			return 0	-- return 0 to indicate that the player has lost and exit the minigame 
		end

	end

end


function key_to_success.cranked(change, acceleratedChange)
	-- When crank is turned, play clicking noise
	click_noise:play(1)
	
	-- Once crank is turned, turn off crank indicator
	if mobware.crankIndicator then mobware.crankIndicator:stop() end

end

return key_to_success
