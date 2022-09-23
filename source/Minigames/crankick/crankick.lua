crankick = {}

local gfx <const> = playdate.graphics
local sfx <const> = playdate.sound.synth.new(playdate.sound.kWaveTriangle)

local ballX = 0
local ballY = 0
local ballR <const> = 15
local ballSpeed <const> = 12
local ballDirX = 0
local ballDirY = 0

local shotDelay <const> = 40
local shotTimer = 0
local exitTimer = 0
local shooting = false

local arrowSprite = nil

local goalX = 0
local goalY = 0
local goalSide = 0
local goalWidth = 0
local goalSprite = nil

local score = 0
local targetScore <const> = 3

local function randomizeBallLocation()
	ballX = math.random(80,320)
	ballY = math.random(80,160)
end

local function randomizeGoalLocation()
	local side = math.random(0,3)
	goalSide = side

	if side == 0 then --top
		goalX = math.random(110, 330)
		goalY = 10
		goalSprite:setRotation(0)
	elseif side == 1 then --bottom
		goalX = math.random(70, 330)
		goalY = 230
		goalSprite:setRotation(180)
	elseif side == 2 then --left
		goalX = 10
		goalY = math.random(80, 180)
		goalSprite:setRotation(270)
	elseif side == 3 then --right
		goalX = 390
		goalY = math.random(70, 180)
		goalSprite:setRotation(90)
	end

	goalSprite:moveTo(goalX, goalY)
end

local function updateArrow()
		local crankPosition = playdate.getCrankPosition()	
		-- gfx.drawText("Crank: " .. crankPosition, 10, 220)
		arrowSprite:setRotation(crankPosition)
		local radians = crankPosition * (math.pi / 180)
		local shiftX = math.sin(radians)
		local shiftY = -math.cos(radians)
		-- gfx.drawText(shiftX .. " / " .. shiftY, 10, 220)
		arrowSprite:moveTo(ballX + shiftX * (ballR*2+5), ballY + shiftY * (ballR*2+5))
end

local function loadSprites()
	-- load arrow
	local arrowImage = gfx.image.new("Minigames/crankick/images/arrow")
	assert(arrowImage)
	arrowSprite = gfx.sprite.new(arrowImage)
	-- load goal
	local goalImage = gfx.image.new("Minigames/crankick/images/goal")
	assert(goalImage)
	goalSprite = gfx.sprite.new(goalImage)
	goalWidth = goalSprite.width
	-- load background
	local backgroundImage = gfx.image.new("Minigames/crankick/images/background")
    assert(backgroundImage)
	gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            backgroundImage:draw(0, 0)
        end
	)
end

local function gameSetup(restart)
	randomizeBallLocation()
	randomizeGoalLocation()
	shooting = false
	shotTimer = 0
	ballDirX = 0
	ballDirY = 0
	if restart then
		score = 0
	else
		arrowSprite:add()
		goalSprite:add()
	end

	updateArrow()
end

local function shoot()
	arrowSprite:remove()
	shooting = true

	local crankPosition = playdate.getCrankPosition()
	local radians = crankPosition * (math.pi / 180)
	local dirX = math.sin(radians)
	local dirY = -math.cos(radians)

	ballDirX = dirX * ballSpeed
	ballDirY = dirY * ballSpeed
end

local function outOfBounds()
	return ballX < 0 - ballR*2 or ballX > 400 + ballR*2 or ballY < 0 - ballR*2 or ballY > 240 + ballR*2
end

local function ballInGoal()
	if goalSide <= 1 then -- goal at top or bottom
		return math.abs(ballY-goalY) < 10 and playdate.geometry.distanceToPoint(ballX,ballY,goalX,goalY) < goalWidth / 2
	else -- goal at left or right
		return math.abs(ballX-goalX) < 10 and playdate.geometry.distanceToPoint(ballX,ballY,goalX,goalY) < goalWidth / 2
	end
end

function crankick.gameWillPause()
	if sfx:isPlaying() then
		sfx:noteOff()
	end
end

local goalTrack = playdate.sound.track.new()
goalTrack:setInstrument(playdate.sound.synth.new(playdate.sound.kWaveSine))
goalTrack:addNote(1,"c4",1,1)
goalTrack:addNote(2,"e4",1,1)
local goalSequence = playdate.sound.sequence.new()
goalSequence:setTempo(12)
goalSequence:addTrack(goalTrack)

local missTrack = playdate.sound.track.new()
missTrack:setInstrument(playdate.sound.synth.new(playdate.sound.kWaveSine))
missTrack:addNote(1,"c4",1,1)
missTrack:addNote(2,"a3",1,1)
local missSequence = playdate.sound.sequence.new()
missSequence:setTempo(12)
missSequence:addTrack(missTrack)


-- MAIN GAME
loadSprites()

gameSetup(true)

mobware.crankIndicator.start()

local mode = "start"

function crankick.update()
	gfx.sprite.update()
	
	if mode == "start" then
		mobware.print("CranKick")
		return
	end

	if not shooting then shotTimer += 1 end

	-- calculate movement
	ballX += ballDirX
	ballY += ballDirY

	if shooting == false then
		-- draw arrow
		updateArrow()
	end

	-- draw ball
	gfx.drawCircleAtPoint(ballX, ballY, ballR)
	gfx.setColor(gfx.kColorWhite)
	gfx.fillCircleAtPoint(ballX, ballY, ballR-2)
	gfx.setColor(gfx.kColorBlack)

	-- draw shot progress
	gfx.fillCircleAtPoint(ballX, ballY, ballR * shotTimer / shotDelay)
	if (shooting == false and shotTimer >= 8) then
		sfx:playNote(50 + 100 * shotTimer / shotDelay, 1)
	end

	if shotTimer >= shotDelay and shooting == false then
		sfx:noteOff()
		sfx:playNote("e2", 1, 0.1)
		shoot()
	end

	--gfx.drawText(shotDelay, 10, 220)

	if ballInGoal() then
		goalSequence:play()
		score += 1
		if score >= targetScore then
			return 1
		end
		gameSetup(false)
	end

	if  mode == "play" and outOfBounds() then
		-- this will cause the game to crash if it is directly followed by game_over, since that calls playdate.wait()
		missSequence:play()
		mode = "defeated" 
	end
	
	-- if ball is out of bounds wait ~1s before exiting 
	if mode == "defeated" then
		exitTimer += 1
		if  exitTimer >= 16 then
			return 0
		end
	end

	local scoreString = score.."/"..targetScore
	gfx.setColor(gfx.kColorWhite)
	local w,h = gfx.getTextSize(scoreString)
	gfx.fillRect(0,0,w+7,h+2)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawText(scoreString, 5, 5)
end

function crankick.cranked(change, acceleratedChange)
	if mode == "start" then
		mobware.crankIndicator.stop()
		mode = "play"
		arrowSprite:add()
		goalSprite:add()
	end
end

return crankick
