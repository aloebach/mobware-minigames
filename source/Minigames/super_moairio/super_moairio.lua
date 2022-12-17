-- Define minigame package
local super_moairio = {}
--[[
	
	Super Moairio for Mobware Minigames
	- built on top of "Level 1-1" from the Playdate SDK game examples
	
Files:

level.lua
	- contains the main logic for the game including sprite movement and background tilemap drawing.
		
levelLoader.lua
	- helper class for level.lua that handles reading from the Tiled JSON file.
	
animations.lua
	- responsible for creating and drawing animations such as brick breaks and question box bumps

player.lua
	- responsible for moving the player sprite to it's desired location based on game-physics. Does not handle collisions except to notify Level about coin and enemy collisions when notified by the sprite system.
	
coin.lua
	- coin sprites
	
enemy.lua
	- example enemy sprite
	
input.lua
	- button input handler
	
level.json
	- json exported from Tiled.app
	
soundManager
	- responsible for loading and playing sound effects
	


Notes:
	- Layers in the Tiled file have a custom property to specify their tile map images so they can be imported automatically. This might actually be more complicated than convenient.
	- Graphics and sprites are all too small for the actual device.
	- There is no vertical scrolling, but it would be fairly easy to add.
	- Enemy behavior is very simple. There is only one enemy type. Enemies can't collide with each other, and they don't move vertically at all.
	- The maximum velocities used are calculated so that the player is never moving fast enough to move through an entire tile in one frame, and the code depends on this being true.


--]]

import 'Minigames/super_moairio/level'
import 'Minigames/super_moairio/player'
import 'Minigames/super_moairio/soundManager'

-- local references
local FrameTimer_update = playdate.frameTimer.updateTimers
local spritelib = playdate.graphics.sprite
local gfx = playdate.graphics

-- global gamestate variable
gGameState = "play"

-- load our level
local level = Level('Minigames/super_moairio/level_1-1.json')

function super_moairio.update()

	spritelib.update()
	
	if gGameState == "game_over" then
		
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, 400, 240) 
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		local text_width, text_height = gfx.getTextSize("GAME OVER")
		local centered_x = (400 - text_width) / 2 -- this should put the minigame name in the center of the screen
		local centered_y = (240 - text_height) / 2 -- this should put the minigame name in the center of the screen
		gfx.drawText("GAME OVER", centered_x, centered_y)
		
		playdate.wait(2000)
		return 0
		
	elseif gGameState == "load_next_level" then
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, 400, 240) 
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)		
		local text_width, text_height = gfx.getTextSize("Level clear!")
		local centered_x = (400 - text_width) / 2 -- this should put the minigame name in the center of the screen
		local centered_y = (240 - text_height) / 2 -- this should put the minigame name in the center of the screen
		gfx.drawText("Level clear!", centered_x, centered_y)
		
		-- player wins minigame if they make it to the flagpole
		playdate.wait(2000)
		return 1

	end
	
	FrameTimer_update()

end

-- Return minigame package
return super_moairio