
--[[
	Word_L minigame for Mobware Minigames

	Author: Drew Loebach
	
	TO-DO: Animate word to show that the player has won in victory state
]]

-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
local Word_L = {}

-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

-- set initial gamestate
local gamestate = 'play'
local TARGET_WORD = 'PANIC'
local word = string.sub(TARGET_WORD,1,3) -- start with the first 3 letters of the word
print(word)

-- Initialize graphics
local background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/Word_L/images/wordL_background"))
background:moveTo(200, 120)
background:add()

local cursor_spritesheet = gfx.imagetable.new("Minigames/Word_L/images/cursor")
local cursor = AnimatedSprite.new( cursor_spritesheet )
cursor:addState("blink",1,2, {tickStep = 5, loop = true}, true)
cursor:moveTo(38 * (#word + 1) - 7, 133)  -- move cursor to highlight current space

-- start timer	 
local MAX_GAME_TIME = 10 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "text_entered" end ) 

-- display keyboard for letter input
playdate.keyboard.show( string.sub(TARGET_WORD,1,3) )
function playdate.keyboard.textChangedCallback()
	word = string.upper(playdate.keyboard.text)
	print(word)
	if #word >= 5 then gamestate = 'text_entered' end
end


function Word_L.update()

	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()

	-- display letters entered by the player	
	gfx.setFont(mobware_font_L) 
	if #word > 3 then
		gfx.drawTextAligned( string.sub(word,4,4), 144, 119, kTextAlignment.center)
	end
	if #word > 4 then
		gfx.drawTextAligned( string.sub(word,5,5), 182, 119, kTextAlignment.center)
	end
		
	-- In the first stage of the minigame
	if gamestate == 'play' then
		-- display rectangle highlighting the square for the current letter
		cursor:moveTo(38 * (#word + 1) - 7, 133)  -- move cursor to highlight current space
		
		if #word > 4 then
			-- all letters have been entered, move to next gamestate
			gamestate =  "text_entered"
		end
		
		
	elseif gamestate == 'text_entered' then
		game_timer:remove()
		playdate.keyboard.hide()
		cursor:remove()
		
		if word == TARGET_WORD then
			gamestate = 'victory'
		else
			gamestate = 'defeat'
		end


	elseif gamestate == 'victory' then

		-- display text indicating the player has won
		mobware.print("good job!",222, 120)
		playdate.wait(2500)	-- Pause 2.5s before ending the minigame

		-- returning 1 will end the game and indicate the the player has won the minigame
		return 1


	elseif gamestate == 'defeat' then

		-- ridicule the player and inform them that they have lost
		mobware.print("you lose", 222, 60)
		gfx.setFont(mobware_font_M) 
		gfx.drawText(word..'\n ... really!?', 210, 123)
		
		-- wait another 3 seconds then exit
		playdate.wait(3000)	-- Pause 2s before ending the minigame
		return 0 -- return 0 to indicate that the player has lost and exit the minigame 

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
