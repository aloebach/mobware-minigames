
--[[
	Author: Brandon Dean
	
	bonus game adaptation by Andrew Loebach

	squasher for Mobware Minigames

]]

local squasher = {}

import "background"
import "bug"
import "target"

local pd <const> = playdate
local gfx <const> = pd.graphics

playdate.display.setRefreshRate( 30 )

math.randomseed(pd.getSecondsSinceEpoch())

local gamestate = 'play'
local game_counter = 0
local GAME_TIME_LIMIT = 8 -- player has 8 seconds at 20fps

local bugSprite
local targetSprite
local backgroundSprite
local bug_speed = 5
local MAX_BUG_SPEED <const> = 12
local bugs = {}

local new_hi_score
local hi_score
score = 0

-- reading high score from memory
local _status, data_read = pcall(playdate.datastore.read, "squasher_data")
if data_read then 
	hi_score = data_read["hi_score"]
else
	hi_score = 0
end

-- load and play soundtrack
local soundtrack = playdate.sound.fileplayer.new('extras/squasher/sounds/HoliznaCC0_Eat')
soundtrack:play()

local function spawn_bug()
	-- speeds up bug and spawns a new bug
	if bug_speed < MAX_BUG_SPEED then bug_speed += 1 end
	table.insert(bugs, Bug(bug_speed) )
end


-- set timer to spawn a bug every 2 seconds
local bugTimer = playdate.timer.new(2000, spawn_bug)
bugTimer.repeats = true
--bugTimer:start()	

-- set game timer to set the length of the game at 60 seconds
local gameTimer = playdate.timer.new( 10000, 
	function() 
		bugTimer:pause()
		gamestate = 'timeUp'
		soundtrack:setVolume(0.5) 
		targetSprite:stop()
		for _i, bug in ipairs(bugs) do
			bug:leave()
		end
		
		-- check for high score!
		if score > hi_score then
			print("new hi score!")
			hi_score = score
			new_hi_score = true
			
			-- save hi score to disc
			local hi_score_table = {hi_score = hi_score}
			playdate.datastore.write(hi_score_table, "squasher_data")
		else
			new_hi_score = nil
		end
		
	end )
	
gameTimer.discardOnCompletion = false


function initialize()
	
	gfx.sprite.removeAll()
	
	gamestate = 'play'
	soundtrack:setVolume(1)
	
	backgroundSprite = Background()
	bug_speed = 5
	score = 0
	bugs = {}

	table.insert(bugs, Bug(bug_speed) )
	targetSprite = Target()
	
	gameTimer:reset()
	gameTimer:start()
	bugTimer:reset()
	bugTimer:start()
	
end

initialize()

function squasher.update()

	playdate.timer.updateTimers()
	
	gfx.sprite.update()
	
	gfx.drawTextAligned(math.ceil(gameTimer.timeLeft/1000),198,10, kTextAlignment.center)
	--gfx.drawTextAligned(score, 198,220, kTextAlignment.center)

	if gamestate == "timeUp" then
		
		local bugs_on_screen = nil
		for _i, bug in ipairs(bugs) do
			if not bug:isOffScreen() then bugs_on_screen = true end
		end

		if bugs_on_screen then
			mobware.print("GAME OVER")
			mobware.print("score: " .. score, 20,20)
		if new_hi_score then mobware.print("new high score!", 20,60) end
			if playdate.buttonIsPressed("b") then initialize() end
		end
		
	end
	
end

-- Minigame package should return itself
return squasher
