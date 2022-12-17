
Animations = {}

-- local refs
local gfx = playdate.graphics
local Point = playdate.geometry.point
local Vector2D = playdate.geometry.vector2D

-- constants
local dt = 0.05

--! Brick Break animation

local gravityStep = 600 * dt
local brickImg = gfx.image.new('Minigames/super_moairio/img/brick')

local brickStartPoint = {}
brickStartPoint[1] = Point.new(0,0)
brickStartPoint[2] = Point.new(8,0)
brickStartPoint[3] = Point.new(0,8)
brickStartPoint[4] = Point.new(8,8)


local function drawBrickBreak(brickTimer)

	-- calculate new vertical brick velocities
	brickTimer.topYVelocity = brickTimer.topYVelocity + gravityStep
	brickTimer.bottomYVelocity = brickTimer.bottomYVelocity + gravityStep
	
	-- and the offsets based on the current frame
	local xOffset = brickTimer.xVelocity * (brickTimer.frame-1) * dt
	local topYOffset = brickTimer.topYVelocity * (brickTimer.frame-1) * dt
	local bottomYOffset = brickTimer.bottomYVelocity * (brickTimer.frame-1) * dt
	
	-- turns out this isn't very noticible at 8x8 b&w pixels, but the bricks flip about every 8 frames
	local flipFlag = playdate.geometry.kUnflipped
	if (brickTimer.frame > 3 and brickTimer.frame < 12) or (brickTimer.frame > 20 and brickTimer.frame < 29) then
		flipFlag = playdate.geometry.kFlippedX
	end
	
	
	-- high left
	brickImg:draw(brickTimer.tileRect.x + brickStartPoint[1].x - xOffset, brickTimer.tileRect.y + brickStartPoint[1].y + topYOffset, flipFlag)
	
	-- high right
	brickImg:draw(brickTimer.tileRect.x + brickStartPoint[2].x + xOffset, brickTimer.tileRect.y + brickStartPoint[2].y + topYOffset, flipFlag)
	
	-- low left
	brickImg:draw(brickTimer.tileRect.x + brickStartPoint[3].x - xOffset, brickTimer.tileRect.y + brickStartPoint[3].y + bottomYOffset, flipFlag)
	
	-- low right
	brickImg:draw(brickTimer.tileRect.x + brickStartPoint[4].x + xOffset, brickTimer.tileRect.y + brickStartPoint[4].y + bottomYOffset, flipFlag)

end


-- starts a brick break animation
function Animations:addBrickAnimation(tileRect)
	
	local brickTimer = playdate.frameTimer.new(30)
	brickTimer.tileRect = tileRect
	brickTimer.topYVelocity = -400
	brickTimer.bottomYVelocity = -300
	brickTimer.xVelocity = 100
	brickTimer.updateCallback = drawBrickBreak
end


--! Question Block Bump Animation

local emptyQBox = gfx.image.new('Minigames/super_moairio/img/emptyQBox')
local coinImageTable = gfx.imagetable.new('Minigames/super_moairio/img/coin')
local coinGravityStep = 800 * dt	-- no actual logic to this difference in gravities, it just looks better
local QBoxBumpDuration = 5

local function drawBumpedQBox(boxTimer)
	
	-- figure out the offset for the current frame (could probably do this more cleverly, but this is easy enough for so few frames)
	local yOffset = -8
	if boxTimer.frame == 1 then yOffset = -2
	elseif boxTimer.frame == 2 then yOffset = -4
	elseif boxTimer.frame == 3 then yOffset = -5
	elseif boxTimer.frame == 4 then yOffset = -2
	elseif boxTimer.frame == 5 then yOffset = 1
	end
		
	emptyQBox:draw(boxTimer.tileRect.x, boxTimer.tileRect.y + yOffset)
end


local function drawQBoxCoin(coinTimer)
	
	local coinFrame = ((coinTimer.frame-1) % coinImageTable:getLength()) + 1
	coinTimer.yVelocity = coinTimer.yVelocity + coinGravityStep
	local yOffset = coinTimer.yVelocity * (coinTimer.frame-1) * dt
	
	coinImageTable:getImage(coinFrame):draw(coinTimer.xPos, coinTimer.yPos + yOffset)
end


-- does a question box bump plus coin animation
function Animations:addQBoxBumpAnimation(tileRect)
	
	local coinTimer = playdate.frameTimer.new(10)
	coinTimer.yVelocity = -460
	coinTimer.xPos = tileRect.x + 2
	coinTimer.yPos = tileRect.y - 4
	coinTimer.updateCallback = drawQBoxCoin
		
	local boxTimer = playdate.frameTimer.new(QBoxBumpDuration)
	boxTimer.tileRect = tileRect
	boxTimer.updateCallback = drawBumpedQBox
end


function Animations:QBoxBumpDuration()
	return QBoxBumpDuration-1
end
