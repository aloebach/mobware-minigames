-- import 'Minigames/super_moairio/CoreLibs/object'
import 'Minigames/super_moairio/levelLoader'
import 'Minigames/super_moairio/animations'
import 'Minigames/super_moairio/coin'
import 'Minigames/super_moairio/time'
import 'Minigames/super_moairio/player'
import 'Minigames/super_moairio/enemy'
import 'Minigames/super_moairio/exit'
import 'Minigames/super_moairio/score'

-- local references
local gfx = playdate.graphics
local Point = playdate.geometry.point
local Rect = playdate.geometry.rect
local abs, floor, ceil, min, max = math.abs, math.floor, math.ceil, math.min, math.max

-- precalculated values
local displayWidth, displayHeight = playdate.display.getSize()
local halfDisplayWidth = displayWidth / 2

-- tilemaps
local walls
local background
local player
local score
local game_time

-- constants
local TOP_EDGE, BOTTOM_EDGE, RIGHT_EDGE, LEFT_EDGE = 1, 2, 4, 8

local QBOX_GID = 2
local BRICK_GID = 3

local ENEMY_GID = 1
local COIN_GID = 2
local EXIT_GID = 3

local TILE_SIZE = 16

local MAX_PLAYER_Y = 400	-- if player falls below this height he'll die (or respawn)


-- local variables
local minX = 0
local maxX = 0 -- real value set in init()


-- Global Variables
cameraX = 0
cameraY = 0


-- Level doesn't really need to be a sprite subclass, but it gives us automatic calls to our draw() and update() functions.

class('Level').extends(gfx.sprite)


function Level:init(pathToLevelJSON)
	
	Level.super.init(self)

	self:setZIndex(0)
	self:setCenter(0, 0)	-- set center point to center bottom
	cameraX = 0
	cameraY = 0
	
	self.coins = {}
	self.enemies = {}
	
	-- (re)initialize player, score and time
	player = Player()
	score = Score()
	game_time = Time(15)
	
	self.layers = importTilemapsFromTiledJSON(pathToLevelJSON)
	
	-- set up local references for the layers we read
	walls = self.layers["Walls"]
	background = self.layers["Background"]
	sprites = self.layers["Sprites"]
	
	self:setBounds(0, 0, background.pixelWidth, background.pixelHeight)

	maxX = background.pixelWidth - displayWidth - TILE_SIZE
	player:setMaxX(background.pixelWidth - 24)
	
	self:setupWallSprites()
	self:setupSprites()
	
	-- enemies sprites and coins were already added in importTilemapsFromTiledJSON()
	player:addSprite()	-- we want player's update() to be called before layer's, so add it first
	self:addSprite()
	score:addSprite()
	game_time:addSprite()
	
	-- start playing background music
	SoundManager:playBackgroundMusic()
end


--! Utility

-- returns the bounds rect for the tile at column, row
local function boundsForTileAtPosition(column, row)
	return Rect.new(column * TILE_SIZE - TILE_SIZE, row * TILE_SIZE - TILE_SIZE, TILE_SIZE, TILE_SIZE)
end


-- returns a range of currently visible tiles as the tuple (startRow, endRow, startColumn, endColumn)
function Level:rangeOfTilesInRect(rect)

	local startRow = floor((rect.y) / TILE_SIZE + 1) 
	local endRow = ceil((rect.y + rect.height) / TILE_SIZE)
	
	local startColumn = floor((rect.x) / TILE_SIZE  + 1)
	local endColumn = ceil((rect.x + rect.width) / TILE_SIZE)
	
	return startRow, endRow, startColumn, endColumn
end


-- sets the tile to the new value and updates our wall edges array
function Level:setTileAtPosition(column, row, newTileValue)
	walls.tilemap:setTileAtPosition(column, row, newTileValue)
end


--! Sprite Movement

function Level:movePlayer()
	
	player:move()
	
	if player.position.y > MAX_PLAYER_Y then	-- fell off of the world! Player dies
		player:die()
		return
	end
	
	local collisions, len
	player.position.x, player.position.y, collisions, len = player:moveWithCollisions(player.position)
	
	for i=1, len do
		local col = collisions[i]      
		if col.normal.x ~= 0 then -- hit something in the X direction
			-- check if player hits enemy
			if col.other:isa(Enemy) then
				player:die()
				game_time.frameCounter = 0
			end
		end
	end
	
	player:setOnGround(false)
	
	for i = 1, len do
		
		local c = collisions[i]

		if c.other.isWall == true then
			
			if c.normal.y < 0 then	-- feet hit
				player.velocity.y = 0
				player:setOnGround(true)
			elseif c.normal.y > 0 then	-- head hit
				player.velocity.y = 100 -- start with some initial downward velocity when a barrier above is hit
				self:handlePlayerHeadHit(c.other)
			end
			
			if c.normal.x ~= 0 then	-- sideways hit. stop moving
				player.velocity.x = 0
			end
		
		elseif c.other:isa(Coin) then	-- player's collisionResponse returns "overlap" for coins
			self:collectCoin(c.other)

		elseif c.other:isa(Exit) then	-- player's collisionResponse returns "overlap" for coins
			self:exitLevel(c.other)
		
		elseif c.other:isa(Enemy) then 
			
			if c.normal.y == -1 then
				self:killEnemy(c.other)	-- feet hit an enemy
			elseif c.normal.x ~= 0 then
				player.velocity.x = 0		-- treat enemies like barriers instead of having them kill player
			end
		end
	end
	
end


function Level:moveEnemies()
	
	local enemies = self.enemies
	for i=1, #enemies do
		local enemy = enemies[i]
		
		if not enemy.crushed then		
			
			enemy.position.x, enemy.position.y, cols, cols_len = enemy:moveWithCollisions(enemy.position.x, enemy.position.y)
			
			for i=1, cols_len do
				local col = cols[i]      
				if col.normal.x ~= 0 then -- hit something in the X direction
					-- check if enemy hits player
					if col.other == player and player.alive then
						player:die()
						game_time.frameCounter = 0
					end
					enemy:changeDirections()
				end
			end
			
		end
		
	end
	
end


-- moves the camera horizontally based on player's current position
function Level:updateCameraPosition()
	local newX = max(min(player.position.x - halfDisplayWidth + 60, maxX), minX)
	
	if newX ~= -cameraX then
		cameraX = -newX
		gfx.setDrawOffset(cameraX,0)
		gfx.sprite.addDirtyRect(newX, 0, displayWidth, displayHeight)	
	end
end


--! Sprite library callbacks

function Level:update()
	
	if gGameState == "play" then

		self:movePlayer()
		
		-- player dies if time expires
		local time_expired = game_time:updateGameTime()
		if time_expired then 
			game_time.frameCounter = 0
			player:die()
		end
		
	elseif gGameState == "player_dead" then
		-- screen flash effect when player dies
		game_time.frameCounter += 1
		if game_time.frameCounter < 5 then
			playdate.display.setInverted(game_time.frameCounter % 2)
			if game_time.frameCounter == 1 then playdate.wait(300) end
		end
		
		-- death animation of player popping up before falling off the screen
		player:moveTo(player.x, player.player_death_y.value)
		if player.y  > MAX_PLAYER_Y then
			Level:unloadLevel()
			gGameState = "game_over"
		end
	end

	self:moveEnemies()
	self:updateCameraPosition()
	
end


function Level:draw(x, y, width, height)
	walls.tilemap:draw(0, 0)
	background.tilemap:draw(0, 0)
end


--! Sprite setup (coins, enemies)

function Level:addCoinSprite(column, row)
	
	local tilePosition = boundsForTileAtPosition(column, row)
	local coinPosition = Point.new(tilePosition.x + 2, tilePosition.y)
	local newCoin = Coin(coinPosition)
	newCoin:addSprite()
	self.coins[#self.coins+1] = newCoin
end


function Level:addEnemySprite(column, row)
	local tilePosition = boundsForTileAtPosition(column, row)
	local newEnemy = Enemy(tilePosition)
	newEnemy:addSprite()
	self.enemies[#self.enemies+1] = newEnemy
end


function Level:addExit(column, row)
	local tilePosition = boundsForTileAtPosition(column, row)
	local exitPosition = Point.new(tilePosition.x + 2, tilePosition.y)
	local newExit = Exit(exitPosition)
	newExit:addSprite()
end


function Level:setupSprites()
		
	local tilemap = sprites.tilemap	
	local width, height = tilemap:getSize()

	for column = 1, width do
		
		for row = 1, height do
		
			local gid = tilemap:getTileAtPosition(column, row)
			
			if gid ~= nil and gid > 0 then
				
				if gid == COIN_GID then
					self:addCoinSprite(column, row)
				elseif gid == ENEMY_GID then
					self:addEnemySprite(column, row)
				elseif gid == EXIT_GID then
					self:addExit(column, row)
				end
			end
			
		end
	end
	
end


--! Wall setup

function Level:setupWallSprites()
	
	-- for a real game, you'd probably want to dynamically load and unload sprites as the player moves around the level
	-- for the purposes of this demo we'll just load them all

	local tilemap = walls.tilemap	
	local width, height = tilemap:getSize()
	
	local x = 0
	local y = 0
	
	for row = 1, height do
		local column = 1
		while column <= width do
		
			local gid = tilemap:getTileAtPosition(column, row, gid)

			if gid ~= nil and gid > 0 then
				
				local startX = x
				local cellWidth = TILE_SIZE
				
				-- add "wall" sprites for briks and question blocks
				if gid == BRICK_GID or gid == QBOX_GID then
					local w = gfx.sprite.new()
					w:setUpdatesEnabled(false) -- remove from update cycle
					w:setVisible(false) -- invisible sprites can still collide
					w:setCenter(0,0)
					w:setBounds(startX, y, cellWidth, TILE_SIZE)
					w:setCollideRect(0, 0, cellWidth, TILE_SIZE)
					w:addSprite()
					w.gid = gid
					w.column = column
					w.row = row
					w.isWall = true
				end
			end
			x += TILE_SIZE
			column += 1
					
		end
		
		x = 0
		y = y + TILE_SIZE
	end
	
	-- group the wall/floor/pipe areas into larger areas and add wall sprites for them so we have fewer total sprites
	local walls = gfx.sprite.addWallSprites(tilemap, {1, 2, 3})
	for i = 1, #walls do
		local w = walls[i]
		w.isWall = true
	end
	
end



--! Collision Handling

function Level:handlePlayerHeadHit(brickSprite)
	
	local column = brickSprite.column
	local row = brickSprite.row
	
	if brickSprite.gid == BRICK_GID then
		self:setTileAtPosition(column, row, 0)			-- clear the tile
		local tileRect = boundsForTileAtPosition(column, row)
		Animations:addBrickAnimation(tileRect)		-- start a brick breaking animation
		SoundManager:playSound(SoundManager.kSoundBreakBlock)
		brickSprite:removeSprite()
	
	elseif brickSprite.gid == QBOX_GID then
		walls.tilemap:setTileAtPosition(column, row, 1000)	-- set the brick to a blank brick that will still block player - any high number should work
		self:setTileAtPosition(column, row, 1000)
		local tileRect = boundsForTileAtPosition(column, row)
		Animations:addQBoxBumpAnimation(tileRect)
		local function setToBlankQBox(column, row)
			self:setTileAtPosition(column, row, 1)
			brickSprite.gid = 1000
		end
		playdate.frameTimer.performAfterDelay(Animations:QBoxBumpDuration(), setToBlankQBox, column, row)	-- set brick to empty question box after delay
		SoundManager:playSound(SoundManager.kSoundCoin)
		score:addOne()
	end
end

function Level:exitLevel(exit)
	-- stop music and play level clear sound effect
	SoundManager:stopMusic()
	SoundManager:playSound(SoundManager.kSoundLevelClear)
	exit:remove()
	gGameState = "level_clear"
	local exit_timer = playdate.frameTimer.new( 40, 
		function() 
			Level:unloadLevel()
			gGameState = "load_next_level"
		end )
end

function Level:collectCoin(coin)
	
	local coins = self.coins
	
	-- remove the coin from our coins array
	for i=1, #coins do
		if coins[i] == coin then
			table.remove(coins, i)
			break
		end
	end
	
	score:addOne()

	-- and from the sprite system
	coin:removeSprite()
	
	SoundManager:playSound(SoundManager.kSoundCoin)
	
end


function Level:killEnemy(enemy)
	
	enemy:crush()
		
	local function removeEnemy(enemy)
		local enemies = self.enemies
		for i=1, #enemies do
			if enemies[i] == enemy then
				table.remove(enemies, i)
				break
			end
		end

		enemy:removeSprite()
	end

	playdate.frameTimer.performAfterDelay(20, removeEnemy, enemy)	-- show the squashed enemy for a bit
	player.velocity.y = -300 -- bounce player off enemy
	SoundManager:playSound(SoundManager.kSoundStomp)
end


function Level:unloadLevel()
	
	-- reset game time
	game_time = nil
		
	gfx.setDrawOffset(0,0)
	
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(0, 0, 400, 240) 
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	--gfx.drawText("GAME OVER", 120, 100)
	gfx.drawText("TIME UP", 144, 100)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	
	-- stop music
	SoundManager:stopMusic()
	
	-- remove enemies		
	local function removeEnemy(enemy)
		local enemies = self.enemies
		for i=1, #enemies do
			if enemies[i] == enemy then
				table.remove(enemies, i)
			end
		end

		enemy:removeSprite()
	end
	
	gfx.sprite.removeAll()


end