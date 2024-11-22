--[[
	Author: Andrew Loebach

	"Hello World" Minigame demo for Mobware Minigames
]]

-- Define name for minigame package
local geit = {}

local gfx <const> = playdate.graphics

local text_box_nine_slice
local text_box
local button_timer
local nietOpSelfie
local selfieTime
local text_image
local text_box_offset = 0
local MOVEMENT_DIRECTION = -1  -- -1 for left first, then 1 for right

-- start timer 
local MAX_GAME_TIME = 8 -- define the time at 20 fps that the game will run betfore setting the "defeat" gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() winOrLose() end ) 
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will move to "defeat" gamestate
local closeDelay = 20 * 3 -- 3 seconds at 20 fps
local current_word = ""
local gameState = "idle"
local correctWord = "geit"
local score = 0
local scoreGoal = 3
local singleWordTimeout = 40 -- one frame


local function prepareList(geitChance, list)
	-- Calculate how many times we need to add "geit" to achieve the desired probability
	local currentListSize = #list
	-- Formula: x/(x+n) = p, where x is number of "geit" entries we need,
	-- n is current list size, and p is desired probability
	local geitCount = math.max(1, math.floor((currentListSize * geitChance) / (1 - geitChance)))
	
	-- Create a new list with the original words
	local newList = {}
	for _, word in ipairs(list) do
		table.insert(newList, word)
	end
	
	-- Add "geit" the calculated number of times
	for i = 1, geitCount do
		table.insert(newList, correctWord)
	end
	
	-- print the list
	for _, word in ipairs(newList) do
		print(word)
	end
	return newList
end
local incorrectWords = { "schaap", "schijt", "leidt", "confijt", "rijdt", "meid", "feit", "tijd", "kijkt", "hakvoort", "ik ben beleid", "volgende slide"}
local word_list = prepareList(0.3, incorrectWords)



local bubble_image
local function maraSays(text, x, y)
	gfx.setFont(mobware_font_S)
	local text_width, text_height = gfx.getTextSize(text)
	local centered_x = (400 - text_width) / 2
	local centered_y = (240 - text_height) / 2
	local draw_x = x or centered_x
	local draw_y = y or centered_y
	
	-- Create an image for the text bubble and text
	local bubble_width = text_width + 48
	local bubble_height = text_height + 48


	bubble_image = gfx.image.new(bubble_width, bubble_height)
	
	-- Draw the bubble and text onto the image
	gfx.pushContext(bubble_image)
		text_box_nine_slice:drawInRect(0, 0, bubble_width, bubble_height)
		gfx.drawTextAligned(text, 24, 24)
	gfx.popContext()
	
	-- Create and return a sprite with the bubble image
	local bubble_sprite = gfx.sprite.new(bubble_image)
	bubble_sprite:moveTo(draw_x + bubble_width/2, draw_y + bubble_height/2)
	bubble_sprite:add()
	
	return bubble_sprite
end



local buttonAPos = 250	
local buttonBPos = 50
local buttonYPos = 200
local audioFiles = {}
function geit.init()
	text_box_nine_slice = gfx.nineSlice.new("Minigames/geit/images/text-bubble-point", 24, 24, 16, 16)
	
	-- Pick a random word
	current_word = word_list[math.random(#word_list)]
	
	-- Update text box to show instructions and current word
	local message = current_word
	text_box = maraSays(message, 200, 40)
	text_box:setZIndex(2)
	
	-- setup background gif
	local background_gif = gfx.imagetable.new("Minigames/geit/images/mara")
	local background_sprite = AnimatedSprite.new(background_gif)
	background_sprite:addState("animate", 1, 4, { tickStep = 2, loop = true, nextAnimation = "idle" }, true)
	background_sprite:moveTo(120, 120)
	background_sprite:setZIndex(0)

	background_sprite:changeState("animate")
	mobware.AbuttonIndicator.start()
	mobware.BbuttonIndicator.start()
	-- move the a and b buttons to the correct position, and add text boxes
	mobware.AbuttonIndicator.AbuttonIndicator_sprite:moveTo(buttonAPos, buttonYPos)
	mobware.BbuttonIndicator.BbuttonIndicator_sprite:moveTo(buttonBPos, buttonYPos)
	-- draw text to an image
	local img = gfx.image.new(400, 240)
	local text_width_1, text_height_1 = gfx.getTextSize("Do nothing")
	local text_width_2, text_height_2 = gfx.getTextSize("Next slide")
	local padding = 5
	gfx.pushContext(img)
		gfx.setFont(mobware_font_M)
		local title = gfx.imageWithText("Geit Trainer", 200, 200, gfx.kColorWhite)
		gfx.setFont(mobware_font_S)
		local imageA = gfx.imageWithText("Do nothing", 200, 200, gfx.kColorWhite)
		local imageB = gfx.imageWithText("Next slide", 200, 200, gfx.kColorWhite)

		-- draw a box with a padding around imageA, use .height and .width to get the size of the image
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(buttonBPos - padding, buttonYPos-5 - padding, imageB.width + padding*2, imageB.height + padding*2)
		gfx.fillRect(buttonAPos - padding, buttonYPos-5 - padding, imageA.width + padding*2, imageA.height + padding*2)
		gfx.setColor(gfx.kColorBlack)
		imageA:draw(buttonBPos, buttonYPos-5)
		imageB:draw(buttonAPos, buttonYPos-5)
		title:draw(0, 10)
		-- draw white rectangle for text
	gfx.popContext()
	text_image = gfx.sprite.new(img)
	text_image:moveTo(240, 120)
	text_image:add()

	-- init sounds
	nietOpSelfie = playdate.sound.sampleplayer.new("Minigames/geit/sounds/niet_op_selfie")
	selfieTime = playdate.sound.sampleplayer.new("Minigames/geit/sounds/selfie_time")
	teLangzaam = playdate.sound.sampleplayer.new("Minigames/geit/sounds/te_langzaam")

	-- go over the list and load all the audio files
	for _, word in ipairs(word_list) do
		audioFiles[word] = playdate.sound.sampleplayer.new("Minigames/geit/sounds/words/" .. word)
	end
	audioFiles["geit"] = playdate.sound.sampleplayer.new("Minigames/geit/sounds/words/geit")
	gameState = "playing"
end
function hideButtons()
	mobware.AbuttonIndicator.AbuttonIndicator_sprite:setVisible(false)
	mobware.BbuttonIndicator.BbuttonIndicator_sprite:setVisible(false)
	text_image:setVisible(false)
end

local timer = 1000000000000000;
function geit.update()
	-- Add button handling
	if gameState == "playing" then
		handleButtons();
		-- is timer expired?
		if timer <= 0 then
			toTooSlow()
		end
		timer-=1
	elseif gameState == "not_playing" then
		-- hide the buttons
		hideButtons()
	elseif gameState == "lost" then
		return 0;
	elseif gameState == "victory" then
		return 1;
	end

		-- Some animation stuff, first move the text box side to side
	if text_box then
		text_box:setZIndex(2)
		
		-- Move text box side to side
		text_box_offset = text_box_offset + (MOVEMENT_DIRECTION)
		if text_box_offset >= 3 then
			MOVEMENT_DIRECTION = -1
		elseif text_box_offset <= -3 then
			MOVEMENT_DIRECTION = 1
		end
		
		text_box:moveBy(MOVEMENT_DIRECTION, 0)
	end

	gfx.sprite.update()

end


function handleButtons()
	if playdate.buttonJustPressed(playdate.kButtonA) then
		if current_word == correctWord then
			score += 1
			nextWord()
			-- maybeToWin()
		else
			toLost()
		end
	elseif playdate.buttonJustPressed(playdate.kButtonB) then
		if current_word ~= correctWord then
			score += 1
			nextWord()
			-- maybeToWin()
		else
			toLost()
		end
	end
end
function nextWord()
	current_word = word_list[math.random(#word_list)]
	-- play the audio file
	if audioFiles[current_word] then
		audioFiles[current_word]:play(1)
	end
	-- remove the current text_box
	if text_box then
		text_box:remove()
	end
	text_box = maraSays(current_word, 200, 40)
	text_box:setZIndex(2)
	timer = singleWordTimeout
end

function winOrLose()
	if gameState ~= "playing" then return end

	if score >= scoreGoal  then
		toVictory()
	else
		toLost()
	end
end

function toVictory()
	if text_box then
		text_box:remove()
	end
	text_box = maraSays("JAAA!\nSelfie time!", 200, 40)
	if selfieTime then
		selfieTime:play(1)
	end
	gameState = "not_playing"
	playdate.frameTimer.performAfterDelay(closeDelay, function()
		gameState = "victory"
	end)
end

function toLost()
	if text_box then
		text_box:remove()
	end
	text_box = maraSays("Jij mag niet\n op mijn selfie!", 200, 40)
	if nietOpSelfie then
		nietOpSelfie:play(1)
	end
	gameState = "not_playing"
	playdate.frameTimer.performAfterDelay(closeDelay, function()
		gameState = "lost"
	end)
end

function toTooSlow()
	if text_box then
		text_box:remove()
	end
	text_box = maraSays("Je bent te\nlangzaam!", 200, 40)
	if teLangzaam then
		teLangzaam:play(1)
	end
	gameState = "not_playing"
	playdate.frameTimer.performAfterDelay(closeDelay, function()
		gameState = "lost"
	end)
	
end

-- Minigame package should return itself
return geit
