--[[
	Author: ThaCuber (@thacuber2a03)

	Dungeon Dweller for Mobware Minigames
]]

--[[ Already imported libraries for reference
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer" 
import "CoreLibs/nineslice"
import "CoreLibs/GUI"
import "CoreLibs/crank"
import "CoreLibs/easing"
]]

local DATADIR = "Minigames/Dashing_Adventurer/"

local blockSize = 40

--[[
	A set amount of maps,
	since what's the probability that
	this game appears more than once?
--]]

-- Legend:
--[[
	Empty - 0
	Wall - 1
	Player - 2
	Key - 3
	Door - 4
	Goal - 5
--]]

-- Used by the game
--[[
	Goal and Player - 6
	Open door - 7
	Player and Open Door - 8
--]]

--[[
	NOTE: Do not use the "Used by the game" tiles.
	They're not supposed to be used.
	All maps have to be 7x6, surrounded by walls.
--]]

local maps = {
	{
		time = 140,
		map = {
			{1, 1, 1, 1, 1, 1, 1},
			{1, 1, 0, 2, 0, 1, 1},
			{1, 0, 0, 1, 0, 0, 1},
			{1, 0, 1, 1, 1, 4, 1},
			{1, 0, 0, 3, 1, 5, 1},
			{1, 1, 1, 1, 1, 1, 1},
		}
	},
	{
		time = 100,
		map = {
			{1, 1, 1, 1, 1, 1, 1},
			{1, 2, 0, 0, 0, 0, 1},
			{1, 0, 3, 1, 3, 0, 1},
			{1, 1, 1, 1, 1, 0, 1},
			{1, 5, 4, 4, 0, 0, 1},
			{1, 1, 1, 1, 1, 1, 1},
		}
	},
	{
		time = 100,
		map = {
			{1, 1, 1, 1, 1, 1, 1},
			{1, 0, 0, 0, 1, 5, 1},
			{1, 0, 1, 2, 1, 0, 1},
			{1, 0, 1, 1, 1, 0, 1},
			{1, 0, 0, 0, 0, 0, 1},
			{1, 1, 1, 1, 1, 1, 1},
		}
	},
	{
		time = 120,
		map = {
			{1, 1, 1, 1, 1, 1, 1},
			{1, 1, 0, 2, 1, 3, 1},
			{1, 3, 0, 0, 1, 0, 1},
			{1, 1, 1, 4, 1, 0, 1},
			{1, 5, 4, 0, 0, 0, 1},
			{1, 1, 1, 1, 1, 1, 1},
		}
	},
	{
		time = 100,
		map = {
			{1, 1, 1, 1, 1, 1, 1},
			{1, 0, 2, 1, 1, 1, 1},
			{1, 0, 1, 0, 0, 0, 1},
			{1, 0, 0, 0, 1, 0, 1},
			{1, 1, 1, 1, 5, 0, 1},
			{1, 1, 1, 1, 1, 1, 1},
		}
	},
	{
		time = 120,
		map = {
			{1, 1, 1, 1, 1, 1, 1},
			{1, 2, 0, 4, 3, 3, 1},
			{1, 0, 0, 1, 1, 1, 1},
			{1, 0, 0, 0, 4, 1, 1},
			{1, 3, 0, 1, 4, 5, 1},
			{1, 1, 1, 1, 1, 1, 1},
		}
	}
}

-- Map constants
local EMPTY, WALL, PLAYER, KEY, CLOSED_DOOR, GOAL, OPEN_DOOR, PLAYER_AND_OPEN_DOOR = 0, 1, 2, 3, 4, 5, 6, 7

-- Global variables
local selectedMap
local MAX_GAME_TIME
local game_time
do
	math.randomseed(playdate.getSecondsSinceEpoch())
	local map = maps[math.random(#maps)]
	selectedMap = map.map
	MAX_GAME_TIME = map.time
	game_time = MAX_GAME_TIME
end

-- Aliases
local gfx      <const> = playdate.graphics
local geom     <const> = playdate.geometry
local Point    <const> = geom.point.new
local Vector2D <const> = geom.vector2D.new

local dwidth, dheight <const> = playdate.display.getWidth(), playdate.display.getHeight()
local btn <const> = playdate.buttonIsPressed

-- Assets
local function loadImage(path) return assert(gfx.image.new(DATADIR..path)) end
local function loadSound(path) return assert(playdate.sound.sampleplayer.new(DATADIR..path)) end

local keyImage = loadImage "images/key"
local closedDoorImage = loadImage "images/closedDoor"
local openDoorImage = loadImage "images/openDoor"
local stairsImage = loadImage "images/stairs"

local moveSound = loadSound "sounds/move"
local keySound = loadSound "sounds/key"
local doorSound = loadSound "sounds/door"
local startSound = loadSound "sounds/start"
local endSound = loadSound "sounds/end"

local win, start = false, true

local function loopThroughMap(map, func)
	for y=1, #map do
		for x=1, #map[y] do
			func(map[y][x], x, y)
		end
	end
end

local function drawGrid()
	gfx.pushContext()

	gfx.clear(gfx.kColorWhite)

	loopThroughMap(selectedMap, function(block, x, y)
		local pos = Point((x+1)*blockSize-blockSize/2, (y-1)*blockSize)
		local centeredPos = pos:copy() + Vector2D(blockSize/2, blockSize/2)

		if block == WALL then
			gfx.fillRect(pos.x, pos.y, blockSize, blockSize)
		elseif block == KEY then
			keyImage:drawCentered(centeredPos:unpack())
		elseif block == CLOSED_DOOR then
			closedDoorImage:drawCentered(centeredPos:unpack())
		elseif block == OPEN_DOOR or block == PLAYER_AND_OPEN_DOOR then
			openDoorImage:drawCentered(centeredPos:unpack())
		elseif block == GOAL then
			stairsImage:drawCentered(centeredPos:unpack())
		end
	end)

	-- Black borders at the sides
	gfx.fillRect(0, 0, 60, dheight)
	gfx.fillRect(dwidth-60, 0, 60, dheight)

	gfx.popContext()
end

local player = {}

player.keys = 0
player.border = -1000
player.borderDelta = 0

function player.update()
	-- There's some weird code inside of this function :/

	player.pos += (player.goal-player.pos)*0.8
	local distance = (player.pos-player.goal):magnitudeSquared()
	if distance > 0 then drawGrid() end

	local nextpos = Vector2D(0, 0)
	if not win then
		if distance < 0.001 then
			if     btn "right" then nextpos += Vector2D( 1,  0)
			elseif btn "left"  then nextpos += Vector2D(-1,  0)
			elseif btn "down"  then nextpos += Vector2D( 0,  1)
			elseif btn "up"    then nextpos += Vector2D( 0, -1) end
		end
	elseif player.pos == player.goal then
		if not endSound:isPlaying() then endSound:play() end
		player.border += ((-700-player.border)*0.3)
		if -700-player.border > -0.5 then return 1 end
	end

	if player.border ~= 10 and not win then
		win = false
		drawGrid()
		player.border += ((10-player.border)*0.65)
		if 10-player.border < 0.5 then player.border = 10 end
	end

	-- using magnitudeSquared saves the Playdate's CPU from processing a square root
	if nextpos:magnitudeSquared() > 0 then
		local nextblock = selectedMap[player.goal.y + nextpos.y][player.goal.x + nextpos.x]

		if nextblock ~= WALL then
			-- helps on making the doors behave like, well, doors
			local door = false

			if nextblock == CLOSED_DOOR then
				door = true
				if player.keys > 0 then
					player.keys -= 1
					door = false
					doorSound:play()
				end
			elseif nextblock == KEY then
				player.keys += 1
				door = false
				keySound:play()
			elseif nextblock == GOAL then
				win = true
			end

			if not door then
				local thisblock = EMPTY
				if selectedMap[player.goal.y][player.goal.x] == PLAYER_AND_OPEN_DOOR then
					thisblock = OPEN_DOOR
				end
				selectedMap[player.goal.y][player.goal.x] = thisblock

				if win then nextblock = GOAL
				elseif nextblock == CLOSED_DOOR or nextblock == OPEN_DOOR then
					nextblock = PLAYER_AND_OPEN_DOOR
				else nextblock = PLAYER end
				selectedMap[player.goal.y + nextpos.y][player.goal.x + nextpos.x] = nextblock

				player.goal += nextpos
				moveSound:play()
			end
		end
	end
end

function player.draw()
	gfx.pushContext()

	local rect = geom.rect.new(
		(player.pos.x+1)*blockSize-blockSize/2, (player.pos.y-1)*blockSize,
		blockSize, blockSize
	)
	local border = player.border
	local multidist = (player.goal-player.pos)*8
	gfx.setColor(gfx.kColorBlack)
	gfx.fillEllipseInRect(
		rect.x+math.min(multidist.x, 0)+math.abs(multidist.y)/2+border/2,
		rect.y+math.min(multidist.y, 0)+math.abs(multidist.x)/2+border/2,
		rect.width+math.abs(multidist.x)-math.abs(multidist.y)-border,
		rect.height+math.abs(multidist.y)-math.abs(multidist.x)-border
	)
	gfx.popContext()
end

function gui()
	gfx.pushContext()

	gfx.setImageDrawMode "inverted"
	keyImage:drawScaled(5, 5, 0.8)
	gfx.drawText(
		"*"..player.keys.."*",
		35, gfx.getSystemFont("bold"):getHeight()/2-2.5
	)

	local y = dheight-15
	local t = game_time/MAX_GAME_TIME
	gfx.setLineWidth(10)
	gfx.drawLine(dwidth-10, dheight-15, 10, dheight-15)
	gfx.setColor(gfx.kColorWhite)
	gfx.drawLine(10, dheight-15, 10+math.max(t*dwidth-20, 0), dheight-15)

	gfx.popContext()
end

loopThroughMap(selectedMap, function(block, x, y)
	if block == PLAYER then
		player.pos = Point(x, y)
		player.goal = player.pos:copy()
	end
end)

drawGrid()
player.draw()
startSound:play()

local Dashing_Adventurer = {}

function Dashing_Adventurer.update()
	local endgame = player.update()
	if endgame then return endgame end
	gui()
	player.draw()

	if not win then
		if game_time < 0 then
			return 0
		else
			game_time -= 1
		end
	end
end

-- make sure to add put your name in "credits.json" and add "credits.gif" to the minigame's root folder. 
	--> These will be used to credit your game during the overarching game's credits sequence!

return Dashing_Adventurer
