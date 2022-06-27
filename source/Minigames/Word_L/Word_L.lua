
--[[
	Word_L minigame for Mobware Minigames

	Author: Drew Loebach
	
	TO-DO: Animate word to show that the player has won in victory state
	TO-DO: Make it more letters than need to be entered to make it a suitable challenge!
]]


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local Word_L = {}

-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- Initialize graphics
local background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/Word_L/images/wordL_background"))
background:moveTo(200, 120)
background:addSprite()

-- set line width for drawing rectangles in play state
gfx.setLineWidth( 2 )


-- set initial gamestate and start prompt for player to hit the B button
local gamestate = 'play'

-- start timer	 
local MAX_GAME_TIME = 8 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "text_entered" end ) 

-- display keyboard for letter input
playdate.keyboard.show()
function playdate.keyboard.textChangedCallback()
	gamestate = 'text_entered'
end

function Word_L.update()

	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()
	print('Time:', game_timer.frame)

	-- In the first stage of the minigame
	if gamestate == 'play' then
		-- display rectangle highlighting the square for the current letter
		gfx.drawRect(171, 120, 24, 26) 
		
		
	elseif gamestate == 'text_entered' then
		playdate.keyboard.hide()
		print("keyboard hidden!")
		text_letter = string.upper(playdate.keyboard.text)

		-- print entered letter to screen
		gfx.setFont(mobware_font_L) 
		gfx.drawText(text_letter, 172, 119)
		
		if text_letter == "C" then
			gamestate = 'victory'
		else
			gamestate = 'defeat'
		end


	elseif gamestate == 'victory' then

		-- display text indicating the player has won
		mobware.print("good job!",222, 120)
		
		gfx.drawText(text_letter, 172, 119)
		playdate.wait(2500)	-- Pause 2.5s before ending the minigame

		-- returning 1 will end the game and indicate the the player has won the minigame
		return 1


	elseif gamestate == 'defeat' then

		-- draw selected letter onto the playing field
		gfx.setFont(mobware_font_L) 
		gfx.drawText(text_letter, 171, 119)

		-- ridicule the player and inform them that they have lost
		mobware.print("you lose", 222, 60)
		gfx.setFont(mobware_font_M) 
		gfx.drawText('"PANI'..text_letter..'"\n ... really!?', 210, 123)
		
		-- wait another 2.5 seconds then exit
		playdate.wait(2500)	-- Pause 2s before ending the minigame

		-- return 0 to indicate that the player has lost and exit the minigame 
		return 0

	end
	
	-- rendering code
	--[[
	gfx.setFont(mobware_font_L)
	gfx.drawText("W O R D L", 20, 20)
	gfx.drawText("C H A I N", 20, 60)
	gfx.drawText("R A P I D", 20, 100)
	gfx.drawText("P A N I", 20, 140)
	]]
	

end


-- Minigame package should return itself
return Word_L
