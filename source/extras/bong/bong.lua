
--[[
	Original Author: Rémi Parmentier
	
	Bonus game adaptation: Drew Loebach

	bong bonus game for Mobware Minigames
]]

import 'extras/bong/Ball'
import 'extras/bong/Bar'
import 'extras/bong/Wall'

local bong = {}

local gfx <const> = playdate.graphics
local kControlsFont <const> = playdate.graphics.getFont()

-- Game variables
local gamestate = "play"
local computer = Bar("left")
local player = Bar("right")
local ball = Ball()
local topWall = Wall(0)
local bottomWall = Wall(236)

local P1_score = 0
local P2_score = 0

playdate.display.setRefreshRate( 30 )

-- Game background
gfx.setBackgroundColor(gfx.kColorBlack)
gfx.sprite.setBackgroundDrawingCallback(
	function(x, y, width, height)
		gfx.setClipRect(x, y, width, height)
		gfx.setBackgroundColor(gfx.kColorBlack)
		drawLineInTheMiddle()
		drawPlayersTexts()
		gfx.clearClipRect()
	end
)

-- Line in the middle
function drawLineInTheMiddle()
	local lineWidth = 4
	local img = gfx.image.new(lineWidth, 240)
	gfx.pushContext(img)
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineWidth(lineWidth)
		gfx.drawLine(0, 0, 0, 240)
	gfx.popContext()
	img:drawFaded(200 - (lineWidth / 2), 0, 0.5, gfx.image.kDitherTypeHorizontalLine)
end

-- Players texts
local kTextForMeasurement <const> = "0"
local kTextWidth <const> = kControlsFont:getTextWidth(kTextForMeasurement)

function drawPlayersTexts()
	gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
	gfx.setFont(mobware_font_L)
	--gfx.drawText(P1_score, 200 - 20 - kTextWidth, 20)
	gfx.drawText(P1_score, 172 - kTextWidth, 20)
	gfx.drawText(P2_score, 220, 20)
	gfx.setImageDrawMode(playdate.graphics.kDrawModeCopy)
end

-- initialize sounds
bounce_sound = playdate.sound.sampleplayer.new('Minigames/bong/blipHigh')

-- add crank indicator
mobware.crankIndicator.start()
local gamestate = "show_controls" 

function bong.update()

	-- updates all sprites
	gfx.sprite.update()

	-- display score	
	drawPlayersTexts()

	-- show controls until player touches the crank, then remove indicator and move to play state
	if gamestate == "show_controls" then
		local _change, _accelleration = playdate.getCrankChange() 
		if _change ~= 0 then
			mobware.crankIndicator.stop()
			gamestate = "play"
		end
	
	elseif gamestate == "play" then

		-- move the ball
		ball:move()

		-- move the player bar (Drew's alternative code to control paddle)
		mobware.crankIndicator:stop()
		local crank_position = playdate.getCrankPosition()
		if crank_position > 180 then crank_position = 360 - crank_position end
		local new_y = (240 - player.height) * crank_position / 180 + player.height/2
		player:moveY(new_y)
		
		-- move the computer bar
		--if ball.x < math.random(150, 300) then
		if ball.x < math.random(60, 180) then -- tweaking difficulty level to make computer less unbeatable
		--if ball.x < math.random(60, 400) then -- tweaking difficulty level to make computer less unbeatable
		--if ball.x < math.random(10 + (20 * P2_score) , 300) then -- tweaking difficulty level to make computer less unbeatable
		--if ball.x < math.random(200, 350) then

			local newComputerY = computer.y
			local dist = computer.y - ball.y
			if dist < 0 then
				newComputerY += computer.speed
			else
				newComputerY -= computer.speed
			end
			computer:moveY(newComputerY)
		end

		-- detect if either player has scored
		if ball.x > 400 then
			gamestate = "P1_scores"
		elseif ball.x < 0 then
			gamestate = "P2_scores"
		end

	elseif gamestate == "P1_scores" then
		P1_score += 1
		if P1_score > 9 then
			gamestate = "P1_wins"
		else
			gamestate = "play"
			ball:reset()
		end
		
	elseif gamestate == "P2_scores" then
		P2_score += 1
		-- increase computer paddle speed every time P2 scores
		computer.speed = math.max(4,P2_score)
		if P2_score > 9 then
			gamestate = "P2_wins"
		else
			gamestate = "play"
			ball:reset()
		end

	elseif gamestate == "P1_wins" then
		mobware.print("player 1 wins!")
		if playdate.buttonJustPressed("A") then
			P1_score = 0
			P2_score = 0
			computer.speed = 3
			ball:reset()
			gamestate = "play"
		end
		

	elseif gamestate == "P2_wins" then
		mobware.print("player 2 wins!")
		if playdate.buttonJustPressed("A") then
			P1_score = 0
			P2_score = 0
			computer.speed = 3
			ball:reset()
			gamestate = "play"
		end
	end

end


-- Minigame package should return itself
return bong
