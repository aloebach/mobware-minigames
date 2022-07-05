
--[[
	Author: Rémi Parmentier

	bong for Mobware Minigames
]]


-- Import any supporting libraries from minigame's folder
	--> Note that all supporting files should be located under 'Minigames/bong/''
import 'Minigames/bong/Ball'
import 'Minigames/bong/Bar'
import 'Minigames/bong/Wall'


bong = {}

-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

-- start timer
MAX_GAME_TIME = 6 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "win" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame

-- Game variables
local gamestate = "play"
local computer = Bar("left")
local player = Bar("right")
local ball = Ball()
local topWall = Wall(0)
local bottomWall = Wall(236)

-- added by Drew to curb computer's difficulty
computer.speed = 4

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
function drawPlayersTexts()
	gfx.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
	gfx.setFont(mobware_font_L)
	local kTextForMeasurement <const> = "CPU"
	local kControlsFont <const> = playdate.graphics.getFont()
	local kTextWidth <const> = kControlsFont:getTextWidth(kTextForMeasurement)
	gfx.drawText("CPU", 200 - 30 - kTextWidth, 20)
	gfx.drawText("YOU", 220, 20)
	gfx.setImageDrawMode(playdate.graphics.kDrawModeCopy)
end


function bong.update()

	-- updates all sprites
	gfx.sprite.update()

	-- update timer
	playdate.frameTimer.updateTimers()
	
	if gamestate == "play" then

		-- move the ball
		ball:move()

		-- move the player bar (Drew's alternative code)
		mobware.crankIndicator:stop()
		local crank_position = playdate.getCrankPosition()
		if crank_position > 180 then crank_position = 360 - crank_position end
		local new_y = 240 * crank_position / 180
		local new_y = (240 - player.height) * crank_position / 180 + player.height/2
		player:moveY(new_y)
		
		-- move the computer bar
		if ball.x < math.random(150, 300) then
			local newComputerY = computer.y
			local dist = computer.y - ball.y
			if dist < 0 then
				newComputerY += computer.speed
			else
				newComputerY -= computer.speed
			end
			computer:moveY(newComputerY)
		end

		-- setup state
		if ball.x > 400 then
			gamestate = "defeat"
		elseif ball.x < 0 then
			gamestate = "win"
		end

	elseif gamestate == "defeat" then
		return 0
	elseif gamestate == "win" then
		return 1
	end

end


function bong.cranked(change, acceleratedChange)
	-- old code to move paddle	
	--player:moveY(player.y + acceleratedChange * 0.4)
		
	
end


-- Minigame package should return itself
return bong
