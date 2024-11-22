-- import 'lib/AnimatedSprite' --used to generate animations from spritesheet
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


function geit.init()
	-- setup background gif
	background_gif = gfx.imagetable.new("Minigames/geit/images/mara")
	background_sprite = AnimatedSprite.new(background_gif)
	background_sprite:addState("animate", 1, 4, { tickStep = 2, loop = true, nextAnimation = "idle" }, true)
	background_sprite:moveTo(120, 120)
	background_sprite:setZIndex(1)

	background_sprite:changeState("animate")
	gfx.sprite.update()
end

function geit.update()
	gfx.sprite.update()

end


-- Minigame package should return itself
return geit
