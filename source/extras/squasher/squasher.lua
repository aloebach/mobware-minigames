
--[[
	Author: Brandon Dean
	
	bonus game adaptation by Andrew Loebach

	squasher for Mobware Minigames
	
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

gamestate = 'play'
local game_counter = 0
local game_time_limit = 10 -- starting time limit

local targetSprite
local bug_speed = 5
local bug_spawn_time = 2
local MAX_BUG_SPEED <const> = 9
bugs = {}

local max_score = game_time_limit / bug_spawn_time
score = 0

-- set font
local game_font = gfx.font.new("extras/squasher/font/Mobware_outlined")
gfx.setFont(game_font)

-- load and play soundtrack
local soundtrack = playdate.sound.fileplayer.new('extras/squasher/sounds/HoliznaCC0_Eat')
soundtrack:setLoopRange(3.5, 165)
soundtrack:play(0)

-- initialize sound effects
local perfect_noise = playdate.sound.sampleplayer.new('extras/squasher/sounds/perfect-sound-effect')
local clapping_noise = playdate.sound.sampleplayer.new('extras/squasher/sounds/clapping')

function spawn_bug()
	-- speeds up bug and spawns a new bug
	if bug_speed < MAX_BUG_SPEED then bug_speed += 0.5 end
	table.insert(bugs, Bug(bug_speed) )
end


-- set timer to spawn a bug every 2 seconds
local bugTimer = playdate.timer.new(bug_spawn_time * 1000, spawn_bug)
bugTimer.repeats = true

-- set game timer to stop the game after time expires 
local gameTimer = playdate.timer.new( (game_time_limit) * 1000, 
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
	gameTimer.duration = (game_time_limit + 0.9) * 1000
	max_score = game_time_limit / bug_spawn_time
	gameTimer:start()

	-- if the player has progressed enough, initiate boss battle
	if game_time_limit == 30 or game_time_limit == 60 then
		--spawn boss
		gamestate = 'boss'
		table.insert(bugs, GiantBug(10) )
		-- spawn second boss if player is at the maximum level
		if game_time_limit == 60 then table.insert(bugs, GiantBug(10) ) end
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
	
	-- remove bug spawning timer if we're close to the end of the time limit 
	if gameTimer.timeLeft < bug_spawn_time * 1000 then 	bugTimer:pause() end
	
	gfx.sprite.update()
	
	if gamestate == "play" then
		gfx.drawTextAligned(math.floor(gameTimer.timeLeft/1000),198,10, kTextAlignment.center)

	elseif gamestate == "boss" then
		--if score >= 7 then
		if score >= 10 * game_time_limit / 30 then
			gameTimer:pause()
			gamestate = "victory" 
			clapping_noise:play(1)
			
			-- display a hand that you have to high five to continue!
			local high_five = gfx.sprite.new(gfx.image.new("extras/squasher/images/hand_palm"))
			high_five:moveTo(350, 120)
			high_five:setZIndex(2)
			high_five:setCollideRect(high_five.width / 4, high_five.height / 4, high_five.width/2, high_five.height/2)
			function high_five:splat()
				-- if player high fives this hand then move to next gamestate
				gamestate = "ending" 			
			end
			high_five:add()
			
		else
			-- if player is still squashing, show game time
			gfx.drawTextAligned(math.floor(gameTimer.timeLeft/1000),198,10, kTextAlignment.center)
		end
	
	elseif gamestate == "victory" then
		
		mobware.print("CONGRATULATIONS!", 40, 105)
		
		-- if player high-fives onscreen hand then it will move to "ending" gamestate
		
	elseif gamestate == "ending" then
		
		-- draw impact lines around high five!
		gfx.setLineWidth( 3 )
		gfx.drawLine( targetSprite.x - targetSprite.width/2, targetSprite.y, targetSprite.x - targetSprite.width/2 * 1.3,  targetSprite.y) -- drawing line left of hand
		gfx.drawLine( targetSprite.x + targetSprite.width/2, targetSprite.y, targetSprite.x + targetSprite.width/2 * 1.3,  targetSprite.y) -- drawing line right of hand
		gfx.drawLine( targetSprite.x, targetSprite.y - targetSprite.height/2, targetSprite.x,  targetSprite.y - targetSprite.height/2 * 1.3) -- drawing line above hand
		gfx.drawLine( targetSprite.x, targetSprite.y + targetSprite.height/2, targetSprite.x,  targetSprite.y + targetSprite.height/2 * 1.3) -- drawing line below hand
		gfx.drawLine( targetSprite.x + targetSprite.width/2, targetSprite.y + targetSprite.height/2, targetSprite.x + targetSprite.width/2 * 1.3,  targetSprite.y + targetSprite.height/2 * 1.3) -- drawing line to lower-right of hand
		gfx.drawLine( targetSprite.x + targetSprite.width/2, targetSprite.y - targetSprite.height/2, targetSprite.x + targetSprite.width/2 * 1.3,  targetSprite.y - targetSprite.height/2 * 1.3) -- drawing line to upper-right of hand
		gfx.drawLine( targetSprite.x - targetSprite.width/2, targetSprite.y + targetSprite.height/2, targetSprite.x - targetSprite.width/2 * 1.3,  targetSprite.y + targetSprite.height/2 * 1.3) -- drawing line to lower-left of hand
		gfx.drawLine( targetSprite.x - targetSprite.width/2, targetSprite.y - targetSprite.height/2, targetSprite.x - targetSprite.width/2 * 1.3,  targetSprite.y - targetSprite.height/2 * 1.3) -- drawing line to upper-left of hand

		
		mobware.print("YOU DID IT!", 40, 105)		
		playdate.wait(1000)
		if game_time_limit < 60 then 
			game_time_limit += 10
			initialize()
		else
			targetSprite:remove()
			gfx.setFont(mobware_default_font)
			gamestate = "credits" 
		end
		

	elseif gamestate == "credits" then
		mobware.print("minigame by Brandon Dean\nbonus game by drew-lo\nmusic by HoliznaCC0")
		mobware.print("thanks for playing!", 60, 200)
		


	elseif gamestate == "timeUp" then
		
		local bugs_on_screen = nil
		for _i, bug in ipairs(bugs) do
			if not bug:isOffScreen() and not bug.isSquashed then bugs_on_screen = true end
		end

		if not bugs_on_screen then
			if playdate.buttonJustPressed("a") or playdate.buttonJustPressed("b") then initialize() end
		end
		
		if score == max_score then 
			mobware.print("exterminated!")
		else
			mobware.print("try again!")
		end		
		
	end
	
end

-- Minigame package should return itself
return squasher
