
--[[
	Author: Brandon Dean
	
	bonus game adaptation by Andrew Loebach

	squasher for Mobware Minigames
	
	IDEA: after 30s timer there is a boss -> giant big with like 10 hit points 
--> if you manage to kill it within the time limit, it explodes into 10 smaller bugs which scurry off and you get the ending screen

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
local game_time_limit = 10 -- player has 8 seconds at 20fps

local targetSprite
local bug_speed = 5
local bug_spawn_time = 2
local MAX_BUG_SPEED <const> = 10
local bugs = {}

local new_hi_score
local hi_score
local max_score = game_time_limit / bug_spawn_time
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

-- set game timer to set the length of the game at 60 seconds
local gameTimer = playdate.timer.new( game_time_limit * 1000, 
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
	gameTimer.duration = game_time_limit * 1000
	max_score = game_time_limit / bug_spawn_time
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
			if score == max_score then 
				mobware.print("exterminated!")
			else
				mobware.print("try again!")
			end
			mobware.print("score: " .. score, 20,20)
		if new_hi_score then mobware.print("new high score!", 20,60) end
			if playdate.buttonIsPressed("b") then initialize() end
		end
		
	end
	
end

-- Minigame package should return itself
return squasher
