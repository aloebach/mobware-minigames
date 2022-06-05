
--[[
	Author: Brandon Dean

	squasher for Mobware Minigames
]]


--[[ NOTE: The following libraries are already imported in main.lua, so there's no need to define them in the minigame
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"
import "CoreLibs/nineslice"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/easing"
]]

-- Import any supporting libraries from minigame's folder
	--> Note that all supporting files should be located under 'Minigames/squasher/''
--import 'Minigames/squasher/lib/AnimatedSprite'


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua
squasher = {}

import "bug"
import "target"

local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

gamestate = 'play'
local game_counter = 0

local bugSprite
local targetSprite

function initialize()
	bugSprite = Bug()
	targetSprite = Target()
end

initialize()

function squasher.update()
	local dt = 1 / playdate.display.getRefreshRate()
	gfx.sprite.update()

	if bugSprite.isSquashed then
		playdate.wait(1000)
		return 1
	end

	if gamestate == "defeat" then
		bugSprite:leave()
		targetSprite:stop()
		print('isOffScreen', bugSprite:isOffScreen())
		while bugSprite:isOffScreen() do
			playdate.wait(1000)
			return 0
		end
	end

	game_counter = game_counter + dt
	if game_counter >= 8 then
		gamestate = "defeat"
	end
end

-- make sure to add put your name in "credits.json" and add "credits.gif" to the minigame's root folder.
	--> These will be used to credit your game during the overarching game's credits sequence!

--> Finally, go to main.lua and search for "DEBUG_GAME". You'll want to set this to the name of your minigame so that your minigame gets loaded every turn!

-- Minigame package should return itself
return squasher
