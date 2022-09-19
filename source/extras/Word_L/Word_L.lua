--[[
	Word_L bonus game for Mobware Minigames!

	Author: Drew Loebach

]]

-- Define name for minigame package
local Word_L = {}

import 'wordList'
import '5_letter_word_dictionary'

local gfx <const> = playdate.graphics

playdate.display.setRefreshRate( 20 )

-- set initial gamestate
local gamestate = 'play'

-- choose word from list
local _word_index = math.random(#wordList)
local target_word = DEBUG_WORD or string.upper(wordList[_word_index])

-- generating dictionary from entries in 5_letter_word_dictionary.lua 
local dictionary = {}
for _, i in ipairs(wordDict) do
	dictionary[i] = true
end
-- check if selected word is in the dictionary
if dictionary[target_word] then
	print("selected word found in the dictionary")
else
	print("WARNING! Selected word is NOT in dictionary!")
end

local word = ''
local row = 1

--Initialize sound effects
nope_sound_effect = playdate.sound.sampleplayer.new("extras/Word_L/sounds/nope")

-- Initialize graphics
local background = gfx.sprite.new()
background:setImage(gfx.image.new("extras/Word_L/images/wordL_background"))
background:moveTo(200, 120)
background:add()

local outline_image = gfx.image.new("extras/Word_L/images/correct_letter_indicator")
local thick_dither = gfx.image.new("extras/Word_L/images/thick_dither_32x34")
local thin_dither = gfx.image.new("extras/Word_L/images/thin_dither_32x34")

-- this is the sprite we'll draw our letters and outlines to so we can display and manage them easily
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
end


function initialize_wordL()
	-- initialize new game here
	gamestate = 'play'
	_word_index = math.random(#wordList)
	target_word = string.upper(wordList[_word_index])

	letters_on_screen:setImage( gfx.image.new(400,240) )
	
	row = 1
	cursor_y = 40 * row + 13 
	text_y = 40 * row - 1
	word = '' -- reset word in keyboard buffer
	gamestate = 'play'
	cursor = AnimatedSprite.new( cursor_spritesheet )
	cursor:addState("blink",1,2, {tickStep = 5, loop = true}, true)
	cursor:moveTo(38 * (#word + 1) - 7, cursor_y)  -- move cursor to highlight current space
	playdate.keyboard.text = ''
	playdate.keyboard.show()

end


function Word_L.update()

	-- updates all sprites
	gfx.sprite.update() 

	-- display letters entered by the player	
	gfx.setFont(mobware_font_L) 

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

		if #word > 4 then
			-- all letters have been entered, move to next gamestate
			
			-- check if word is a valid entry in the dictionary
			if dictionary[word] then
				-- if word is in the dictionary move to "text_entered" state
				--print(word,"found in dictionary")
				gamestate =  "text_entered"
			else
				-- if word is NOT in the dictionary then we do a dramatic shake effect and erase the last letter entered
				nope_sound_effect:play(1)
				print(word,"not found in dictionary")
				playdate.display.setOffset(0, 5)
				playdate.wait(60)
				playdate.display.setOffset(0, -5)
				playdate.wait(60)
				playdate.display.setOffset(0,0)
				
				playdate.keyboard.text = string.sub(word,1,4)
				word = string.sub(word,1,4)
			end
			
		end
		
		-- display rectangle highlighting the square for the current letter
		cursor:moveTo(38 * (#word + 1) - 7, cursor_y)  -- move cursor to highlight current space
		
		
	elseif gamestate == 'text_entered' then
		playdate.keyboard.hide()
		cursor:remove()
		
		-- score word
		local _y = cursor_y
		for i = 1, #word do
			--check if letter is correct and mark accordingly
			if string.sub(word,i,i) == string.sub(target_word,i,i) then
				print("letter",i,"is a match (", string.sub(word,i,i),")")
				draw_outline(38 * i - 7,_y)
				
			elseif string.find(target_word, string.sub(word,i,i) ) then
				print("letter",i,"found in target word")
				-- count the number of times this letter occurs in the target word
					--> count how many times the letter has been guessed and how many future matches for the letter 
				local total_letter_count = count_occurrences( string.sub(word,i,i), target_word )
				local current_letter_count = count_occurrences( string.sub(word,i,i), string.sub(word,1,i) )
				local future_matches = check_future_match(string.sub(word,i,i), string.sub(word,i+1,5), string.sub(target_word,i+1,5) )
				
				if current_letter_count + future_matches > total_letter_count then
					print("letter is in word, but not this many times!")
					draw_dither(38 * i - 7,_y, "thick")
				else
					draw_dither(38 * i - 7,_y, "thin")
				end

			else  -- if no match at all then color with thick dithering
				print("letter",i,"not found in word")
				draw_dither(38 * i - 7,_y, "thick")
			end
			
			-- render letters and outlines
			draw_letters_to_sprite()
			gfx.sprite.update() 

			playdate.wait(300)
		end
		
		if word == target_word then
			gamestate = 'victory'
			
		elseif row < 5 then -- game is still going, move on to the next row
			row += 1
			cursor_y = 40 * row + 13 
			text_y = 40 * row - 1
			word = '' -- reset word in keyboard buffer
			gamestate = 'play'
			cursor = AnimatedSprite.new( cursor_spritesheet )
			cursor:addState("blink",1,2, {tickStep = 5, loop = true}, true)
			cursor:moveTo(38 * (#word + 1) - 7, cursor_y)  -- move cursor to highlight current space
			playdate.keyboard.text = ''
			playdate.keyboard.show()
			
		else
			gamestate = 'defeat'
		end


	elseif gamestate == 'victory' then

		-- display text indicating the player has won
		mobware.print("good job!",222, 120)
		
		if playdate.buttonJustPressed("A") then		
			initialize_wordL()
		end


	elseif gamestate == 'defeat' then

		-- ridicule the player and inform them that they have lost
		mobware.print("you lose", 222, 60)
		gfx.setFont(mobware_font_M) 
		gfx.drawText(word..'\n ... really!?', 210, 123)
		gfx.drawText('-> '..target_word, 210, 202)
		
		if playdate.buttonJustPressed("A") then		
			initialize_wordL()
		end

	end
	
end


function draw_letters_to_sprite()
	-- draw the row's letters to the "letters_on_screen" sprite
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


function draw_outline(x,y)
	--draw outline of the letter at x, y
	local canvas = letters_on_screen:getImage()
	gfx.lockFocus(canvas)
		outline_image:drawCentered(x,y)
	gfx.unlockFocus()
	letters_on_screen:setImage(canvas)
end


function draw_dither(x,y, ditherType)
	--draw dithered pattern over the letter at x, y
	local canvas = letters_on_screen:getImage()
	gfx.lockFocus(canvas)
		if ditherType == "thick" then
			thick_dither:drawCentered(x,y)
		else
			thin_dither:drawCentered(x,y)
		end
	gfx.unlockFocus()
	letters_on_screen:setImage(canvas)
end

function count_occurrences(search_char, string )
	-- counts the number of occurrences of search_char in string
	local counter = 0
	for _letter = 1, #string do
		if search_char == string.sub(string,_letter,_letter)  then
			counter += 1
		end
	end
	return counter
end

function check_future_match(letter, string1, string2 )
	-- counts the number of times a letter is the same position in two strings
	local counter = 0
	for _i = 1, #string2 do
		if letter == string.sub(string1,_i,_i) and letter == string.sub(string2,_i,_i) then
			counter += 1
		end
	end
	return counter
end

-- Minigame package should return itself
return Word_L
