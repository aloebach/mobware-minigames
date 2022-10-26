
--[[
	Author: Brandon Dean
	
	bonus game adaptation by Andrew Loebach

	squasher for Mobware Minigames
	
	TO-DO: add ending after beating boss
]]

local squasher = {}

import "background"
import "bug"
import "GiantBug"
import "target"

local pd <const> = playdate
local gfx <const> = pd.graphics

playdate.display.setRefreshRate( 30 )

math.randomseed(pd.getSecondsSinceEpoch())

local gamestate = 'play'
local game_counter = 0
local game_time_limit = 10 -- player has 8 seconds at 20fps

local targetSprite
local bug_speed = 5
local bug_spawn_time = 2
local MAX_BUG_SPEED <const> = 10
bugs = {}

local max_score = game_time_limit / bug_spawn_time
score = 0


-- load and play soundtrack
local soundtrack = playdate.sound.fileplayer.new('extras/squasher/sounds/HoliznaCC0_Eat')
soundtrack:setLoopRange(3.5, 165)
soundtrack:play(0)

local perfect_noise = playdate.sound.sampleplayer.new('extras/squasher/sounds/perfect-sound-effect')

local function spawn_bug()
	-- speeds up bug and spawns a new bug
	if bug_speed < MAX_BUG_SPEED then bug_speed += 0.5 end
	table.insert(bugs, Bug(bug_speed) )
end


-- set timer to spawn a bug every 2 seconds
local bugTimer = playdate.timer.new(bug_spawn_time * 1000, spawn_bug)
bugTimer.repeats = true

-- set game timer to stop the game after time expires 
local gameTimer = playdate.timer.new( game_time_limit * 1000, 
	function() 
		bugTimer:pause()
		gamestate = 'timeUp'
		soundtrack:setVolume(0.4) 
		targetSprite:stop()
		for _i, bug in ipairs(bugs) do
			bug:leave()
		end
		
		-- play "perfect" sound effect if player has a perfect game!
		if score == max_score then 
			perfect_noise:play(1) 
			-- increase game time for next playthrough!	
			if game_time_limit < 60 then 
				game_time_limit += 10
			end
		end
		
	end )
	
gameTimer.discardOnCompletion = false

-- TO-DO: Add code to initialize boss battle
function initialize()
	
	gfx.sprite.removeAll()
	
	gamestate = 'play'
	soundtrack:setVolume(1)
	
	backgroundSprite = Background()
	bug_speed = 5
	score = 0
	bugs = {}

	targetSprite = Target()
	
	gameTimer:reset()
	gameTimer.duration = game_time_limit * 1000
	max_score = game_time_limit / bug_spawn_time
	gameTimer:start()

	-- if the player has progressed enough, initiate boss battle
	if game_time_limit > 20 then
		gamestate = 'boss'
		--spawn boss
		table.insert(bugs, GiantBug(10) )
		bugTimer:pause()
	else
		-- spawn normal bug & start bug timer
		table.insert(bugs, Bug(bug_speed) )
		bugTimer:reset()
		bugTimer:start()
	end
	
end

initialize()

function squasher.update()

	playdate.timer.updateTimers()
	
	gfx.sprite.update()
	
	gfx.drawTextAligned(math.ceil(gameTimer.timeLeft/1000),198,10, kTextAlignment.center)
	--gfx.drawTextAligned(score, 198,220, kTextAlignment.center)

	if gamestate == "boss" then
		if score >= 7 then
			mobware.print("CONGRATULATIONS!")
			--TO-DO: add ending logic 
		end
	end

	if gamestate == "timeUp" then
		
		local bugs_on_screen = nil
		for _i, bug in ipairs(bugs) do
			if not bug:isOffScreen() then bugs_on_screen = true end
		end

		if bugs_on_screen then
			if score == max_score then 
				mobware.print("exterminated!")
			else
				mobware.print("try again!")
			end

			if playdate.buttonIsPressed("b") then initialize() end
		end
		
	end
	
end

-- Minigame package should return itself
return squasher
