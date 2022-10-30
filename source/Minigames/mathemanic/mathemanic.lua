
--[[
	math manic minigame for Mobware Minigames

	Author: Drew Loebach
]]

-- Define name for minigame package
local mathemanic = {}

local gfx <const> = playdate.graphics

-- set initial gamestate
local gamestate = 'play'

-- set font
local scribble_white = gfx.font.new("Minigames/mathemanic/font/scribble_white")
gfx.setFont(scribble_white)

-- Initialize graphics
local background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/mathemanic/images/chalkboard"))
background:moveTo(200, 120)
background:add()

local chalk_hand = gfx.sprite.new()
chalk_hand:setImage(gfx.image.new("Minigames/mathemanic/images/chalk_hand"))
chalk_hand:setCenter(0,0) -- sets x, y or sprite to the end of the chalk
local answer_x, answer_y =  102, 114 -- x and y coordinates where the answer will be written
chalk_hand:moveTo(answer_x, answer_y)
chalk_hand:add()


-- Initialize music / sound effects
local writing_noise = playdate.sound.sampleplayer.new('Minigames/mathemanic/sounds/scribble')
local erasing_noise = playdate.sound.sampleplayer.new('Minigames/mathemanic/sounds/erase')
local applause = playdate.sound.sampleplayer.new('Minigames/mathemanic/sounds/applause')
applause:setVolume(0.6)

-- start timer	 
local MAX_GAME_TIME = 9 -- define the time at 20 fps that the game will run before setting the "defeat" gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, 
	-- callback function called when timer expires:
	function() 
		chalk_hand:remove()
		gfx.sprite.update() 
		gamestate = "defeat" 
	end 
) 

-- calculate math problem
local operation
local operator
local MAX_NUMBER = 12
local number1 = math.random(MAX_NUMBER) 
local number2 = math.random(MAX_NUMBER)

-- randomly pick if the problem is addition, subtraction or multiplication: 
local random_number = math.random(3) 
if random_number == 3 then
	-- addition
	operator = "+"
	correct_answer = number1 + number2
elseif random_number == 2 then
	-- subtraction
	operator = "-"
	number1 += MAX_NUMBER
	correct_answer = number1 - number2
else
	-- multiplication
	operator = "x"
	correct_answer = number1 * number2
end	

local problem_string = tostring(number1) .. " " .. operator .. " " .. tostring(number2) .. " ="
print("New math problem:", problem_string)

-- display keyboard for number input
print("showing keyboard")
playdate.keyboard.show()
answer = ""
function playdate.keyboard.textChangedCallback()
	local previous_text = answer
	answer = playdate.keyboard.text
	
	-- play writing or erasing sound effect
	if #answer < #previous_text then
		erasing_noise:play(1)
	else
		writing_noise:play(1)
	end
	
	-- move hand sprite
	chalk_hand:moveTo(answer_x + 16 * #answer, answer_y)
	
	-- check if correct answer has been answered
	if answer == tostring(correct_answer) then
		chalk_hand:remove()
		gamestate = 'victory'
	end
	
end


function mathemanic.update()

	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()

	-- display number/text on chalkboard
	gfx.drawTextAligned(problem_string, 86, 90)
	gfx.drawTextAligned(answer, answer_x, answer_y)
	
	-- In the first stage of the minigame
	if gamestate == 'play' then
		
		if not playdate.keyboard.isVisible() then
			print("keyboard not visible!!!!")
			print("showing keyboard (again)")
			playdate.keyboard.show()
		end
		
		-- currently nothing else to do in play state
			--> game changes when player enters a character and we call playdate.keyboard.textChangedCallback()

	elseif gamestate == 'victory' then
		print("hiding keyboard")
		playdate.keyboard.hide()
		
		-- pause for a moment..
		playdate.wait(500)	-- Pause 2.5s before ending the minigame
		
		writing_noise:play(1)
		applause:play(1)

		-- display text indicating the player has won
		gfx.drawTextAligned("A+",168, 132)
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineWidth(3)
		gfx.drawLine( 100, 130, 104+16*string.len(answer), 132) -- line under correct answer
		gfx.drawEllipseInRect(160, 124, 48, 32) 
		playdate.wait(2500)	-- Pause 2.5s before ending the minigame

		-- returning 1 will end the game and indicate the the player has won the minigame
		return 1


	elseif gamestate == 'defeat' then
		print("hiding keyboard")
		playdate.keyboard.hide()
		
		-- strike through the answer and write the correct answer underneath
		writing_noise:play(2)
		local teacher_voice = playdate.sound.sampleplayer.new('Minigames/mathemanic/sounds/teacher')
		teacher_voice:play(1)

		gfx.setColor(gfx.kColorWhite)
		gfx.setLineWidth(3)

		if string.len(answer) > 0 then
			-- strike through incorrect answer
			gfx.drawLine(100, 126, 102 + 16*string.len(answer), 118)
		else
			-- if no answer was entered draw a question mark on the board
			gfx.drawTextAligned("?", 102, 114)
		end
		
		-- draw correct answer
		gfx.drawTextAligned(correct_answer, 102, 132)

		-- display text letting the player know that they have failed
		gfx.drawTextAligned("F",168, 132)
		gfx.drawEllipseInRect(160, 124, 34, 32) 

		-- wait another 3 seconds then exit
		playdate.wait(3000)	-- Pause 2s before ending the minigame
		return 0 -- return 0 to indicate that the player has lost and exit the minigame 

	end
	
end


-- Minigame package should return itself
return mathemanic
