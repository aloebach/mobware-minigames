
--[[
	Word_L bonus game for Mobware Minigames!

	Author: Drew Loebach
	
	TO-DO: Detect if a letter is used multiple times
	TO-DO: draw dither and outlines instead of adding sprites
	TO-DO: Fix logic so that game restarts properly after player wins/loses
]]

-- Define name for minigame package
local Word_L = {}

import 'Outline'
import 'Dither'
import 'wordList'

local gfx <const> = playdate.graphics

-- set initial gamestate
local gamestate = 'play'

-- choose word
--local DEBUG_WORD = 'PANIC' -- you can set this variable to expressly choose which word to use
local _word_index = math.random(#wordList)
local TARGET_WORD = DEBUG_WORD or string.upper(wordList[_word_index])
print('Target word:', TARGET_WORD) -- FOR DEBUGGING; DELETE LATER

--local word = string.sub(TARGET_WORD,1,3) -- start with the first 3 letters of the word
local word = ''
local row = 1
local column = 1

-- Initialize graphics
local background = gfx.sprite.new()
background:setImage(gfx.image.new("extras/Word_L/images/wordL_background"))
background:moveTo(200, 120)
background:add()

local letters_on_screen = gfx.sprite.new( gfx.image.new(400,240) )
letters_on_screen:moveTo(200, 120)
letters_on_screen:add()

local cursor_spritesheet = gfx.imagetable.new("extras/Word_L/images/cursor")
local cursor = AnimatedSprite.new( cursor_spritesheet )
cursor:addState("blink",1,2, {tickStep = 5, loop = true}, true)

local cursor_x = 38 * (#word + 1) - 7
local cursor_y = 40 * row + 13 
cursor:moveTo(38 * (#word + 1) - 7, cursor_y)  -- move cursor to highlight current space

local text_y = 40 * row - 1

-- display keyboard for letter input
playdate.keyboard.show()
function playdate.keyboard.textChangedCallback()
	word = string.upper(playdate.keyboard.text)
	print(word)
	if #word >= 5 then gamestate = 'text_entered' end
end


function initialize_wordL()
	-- initalize new game here
	gamestate = 'play'
	local _word_index = math.random(#wordList)
	TARGET_WORD = DEBUG_WORD or wordList[_word_index]
	
	--[[
	letters_on_screen:remove()
	letters_on_screen = gfx.sprite.new( gfx.image.new(400,240) )
	letters_on_screen:moveTo(200, 120)
	letters_on_screen:add()
	]]
	letters_on_screen:setImage( gfx.image.new(400,240) )
	
	row = 1
	column = 1
	cursor_y = 40 * row + 13 
	text_y = 40 * row - 1
	word = '' -- reset word in keyboard buffer
	gamestate = 'play'
	cursor = AnimatedSprite.new( cursor_spritesheet )
	cursor:addState("blink",1,2, {tickStep = 5, loop = true}, true)
	playdate.keyboard.text = ''
	playdate.keyboard.show()

end


function Word_L.update()

	-- updates all sprites
	gfx.sprite.update() 

	-- display letters entered by the player	
	gfx.setFont(mobware_font_L) 
	-- character X = 38 * word - 8
	-- character Y = 40 * row - 1
	if #word > 0 then gfx.drawTextAligned( string.sub(word,1,1), 30, text_y, kTextAlignment.center) end
	if #word > 1 then gfx.drawTextAligned( string.sub(word,2,2), 68, text_y, kTextAlignment.center) end
	if #word > 2 then gfx.drawTextAligned( string.sub(word,3,3), 106, text_y, kTextAlignment.center) end
	if #word > 3 then gfx.drawTextAligned( string.sub(word,4,4), 144, text_y, kTextAlignment.center) end
	if #word > 4 then gfx.drawTextAligned( string.sub(word,5,5), 182, text_y, kTextAlignment.center) end
		
	-- In the first stage of the minigame
	if gamestate == 'play' then
		
		if not playdate.keyboard.isVisible() then
			print("show keyboard!")
			playdate.keyboard.show()
		end
		
		-- display rectangle highlighting the square for the current letter
		cursor:moveTo(38 * (#word + 1) - 7, cursor_y)  -- move cursor to highlight current space
		
		if #word > 4 then
			-- all letters have been entered, move to next gamestate
			gamestate =  "text_entered"
		end
		
		
	elseif gamestate == 'text_entered' then
		playdate.keyboard.hide()
		cursor:remove()
		
		-- score word
		local _y = cursor_y
		for i = 1, #word do
			--check if letter is correct and mark accordingly
			if string.sub(word,i,i) == string.sub(TARGET_WORD,i,i) then
				print("letter",i,"is a match (", string.sub(word,i,i),")")
				outline = Outline:new(38 * i - 7,_y)
			elseif string.find(TARGET_WORD, string.sub(word,i,i) ) then
				print("letter",i,"found in target word")
				dither_block = Dither:new(38 * i - 7,_y, "thin")
			else  -- if no match at all then color with thick dithering
				print("letter",i,"not found in word")
				dither_block = Dither:new(38 * i - 7,_y, "thick")
			end
			
			--TO-DO: write letters and outlines/dithers to a sprite
				--> for the outline and dither i should do this in the code for their respective classes?
					--> alternatively in the code above i can simply use push/pop context to write it to the sprite directly 
			
			-- render letters and outlines
			draw_letters_to_sprite()
			gfx.sprite.update() 
			
			--[[
			if #word > 0 then
				gfx.drawTextAligned( string.sub(word,1,1), 30, text_y, kTextAlignment.center)
			end
			if #word > 1 then
				gfx.drawTextAligned( string.sub(word,2,2), 68, text_y, kTextAlignment.center)
			end
			if #word > 2 then
				gfx.drawTextAligned( string.sub(word,3,3), 106, text_y, kTextAlignment.center)
			end
			if #word > 3 then
				gfx.drawTextAligned( string.sub(word,4,4), 144, text_y, kTextAlignment.center)
			end
			if #word > 4 then
				gfx.drawTextAligned( string.sub(word,5,5), 182, text_y, kTextAlignment.center)
			end
			]]
			playdate.wait(300)
		end
		
		if word == TARGET_WORD then
			gamestate = 'victory'
			
		elseif row < 5 then -- game is still going, move on to the next row
			row += 1
			column = 1
			cursor_y = 40 * row + 13 
			text_y = 40 * row - 1
			word = '' -- reset word in keyboard buffer
			gamestate = 'play'
			cursor = AnimatedSprite.new( cursor_spritesheet )
			cursor:addState("blink",1,2, {tickStep = 5, loop = true}, true)
			playdate.keyboard.text = ''
			playdate.keyboard.show()
			
		else
			gamestate = 'defeat'
		end


	elseif gamestate == 'victory' then

		-- display text indicating the player has won
		mobware.print("good job!",222, 120)
		playdate.wait(2500)	-- Pause 2.5s before ending the minigame
		
		initialize_wordL()


	elseif gamestate == 'defeat' then

		-- ridicule the player and inform them that they have lost
		mobware.print("you lose", 222, 60)
		gfx.setFont(mobware_font_M) 
		gfx.drawText(word..'\n ... really!?', 210, 123)
		
		-- wait another 3 seconds then exit
		playdate.wait(3000)	-- Pause 2s before ending the minigame
		initialize_wordL()
	end
	
end


function draw_letters_to_sprite()

	local canvas = letters_on_screen:getImage()
	gfx.lockFocus(canvas)
		gfx.drawTextAligned( string.sub(word,1,1), 30, text_y, kTextAlignment.center )
		gfx.drawTextAligned( string.sub(word,2,2), 68, text_y, kTextAlignment.center )
		gfx.drawTextAligned( string.sub(word,3,3), 106, text_y, kTextAlignment.center )
		gfx.drawTextAligned( string.sub(word,4,4), 144, text_y, kTextAlignment.center )
		gfx.drawTextAligned( string.sub(word,5,5), 182, text_y, kTextAlignment.center )
	gfx.unlockFocus()
	letters_on_screen:setImage(canvas)

end

-- Minigame package should return itself
return Word_L
