
--[[
	Author: Andrew Loebach

	"Hello World" Minigame demo for Mobware Minigames
]]

-- Define name for minigame package
local geit = {}

local gfx <const> = playdate.graphics

-- start timer 
local MAX_GAME_TIME = 1 -- define the time at 20 fps that the game will run betfore setting the "defeat" gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "defeat" end ) 
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will move to "defeat" gamestate

function geit.update()


end


-- Minigame package should return itself
return geit
