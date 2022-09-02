--[[
	Problem Trolley

	Developed by:	Andrew Loebach
					Neil Austin

	Life if full of tough decisions! You control Railway Ralph, who needs to decide where to route the trolley
	But this means sometimes choosing the lesser of two evils...
	
	-TO-DO: Add logic to prevent Mr. Ropers from being too close together
]]

-- import support libraries  
--[[
import 'extras/problem_trolley/lib/AnimatedSprite' --used to generate animations from spritesheet
import 'CoreLibs/object' 
--import 'CoreLibs/frameTimer'-- for using frame timer: playdate.frameTimer.updateTimers
import 'CoreLibs/sprites' -- see if this can help animate the sprites
import 'CoreLibs/crank'
]]

problem_trolley = {}
-- import the classes that we're using for our animated objects
import 'extras/problem_trolley/Ralph'
import 'extras/problem_trolley/MrRoper'
import 'extras/problem_trolley/Trolley'

local gfx <const> = playdate.graphics

function track_y(x)
	--given x coordinate, returns y coordinate of track track
	local y = x / 3.1 + 40 --y coordinate on upper rail
	return y
end

playdate.display.setRefreshRate( 20 )

--> Initialize sound effects
splat_noise = playdate.sound.sampleplayer.new('extras/problem_trolley/sounds/splat')
trolley_sound = playdate.sound.sampleplayer.new('extras/problem_trolley/sounds/chug-a-chug')

-- set font
scribble_font = gfx.font.new("extras/problem_trolley/font/scribble_thin")
gfx.setFont(scribble_font)

-- load high score
function read_high_score()
	local scoreFile = playdate.file.open("problem_trolley_data.txt", playdate.file.kFileRead)
	high_score = tonumber(scoreFile:readline())
	scoreFile:close()
end
local status, _val = pcall(read_high_score)
if status == false then 
	print("No high score found in memory")
	high_score = 0
end

function load_new_game()

    local s, ms = playdate.getSecondsSinceEpoch()
	math.randomseed(ms,s)

    gamestate = 'play'
    --[[ gamestates:
    	1) 'title' - shows title screen and waits for user input
    	2) 'transition' - shows score and transitions between rounds
    	3) 'play' - play a round of Problem Trolley 
    	4) 'done' - round is over
    	5) 'game_over' - ...game over of course
    ]]
	trolley_sound:setRate(1)
	trolley_sound:play(1)

	trolley_speed = 4
	MAX_TROLLEY_SPEED = 10
	number_of_victims = 5 --change the number of victims on the tracks
	smashed_total = 0 --used for score in 'done' state
	saved_total = 0 --used for score in 'done' state
	score = 0

	--background = playdate.graphics.image.new("images/Switchyard_background.png")
	background = gfx.sprite.new()
	background:setImage(gfx.image.new("extras/problem_trolley/images/Switchyard_background"))
	background:moveTo(200, 120)
	background:add()

	--Initialize Railway Ralph
	ralph = Ralph:new()

	--Initialize victims on tracks
	victims = {}
    for i = 1, number_of_victims do
		local x = math.random(190,360)  --random x value between 180 and 350, which will place them somewhere along the rail on the x-axis
    	local y = track_y(x) + 10 --returns y coordinate on the track given the x value, and move down slightly to fit onto rail 
    	local up_or_down = math.random(0,1) --50% chance the victoms are on the lower track
    	y = y + up_or_down * 64 --shifts 50% of victims to lower track
        table.insert(victims, MrRoper:new(x, y, up_or_down, trolley_speed))
    end

	--Initialize trolley
	trolley = Trolley:new(0,25,trolley_speed) --Trolley(x,y,speed)
	--> Later we will increase the trolley speed with each successful run

end

-- run function above to load game
load_new_game()


function problem_trolley.update()

	-- update sprite animations
	gfx.sprite.update() -- updates all sprites

	if gamestate == 'play' then
		
		-- check if victims are smashed:
		for i, victim in ipairs(victims) do
	        --check if victim is hit by the trolley
	        if victim:collides(trolley) then
	        	victim.smashed = true
	        end
	    end
	    
	    if trolley.x > 400 then
	    	-- 'play' state ends when the trolley drives off the screen
	    	gamestate = 'done'
			trolley_sound:stop()
			
			ralph.frame = 1
			
	    	--calculate score
			smashed_total = 0
			saved_total = 0
			for i, victim in pairs(victims) do
		        --check victims to see what their score is 
		        if victim.smashed then
		        	smashed_total = smashed_total + 1
		        else
		        	saved_total = saved_total + 1
		        end
		    end	
			--> (I could have done this more easily by just increasing a counter whenever a victim is smashed, but whatevs...)
			
		    if saved_total >= smashed_total then 
			    -- increment score if Ralph saves more than die
		    	score = score + 1 
		    else
		    	-- ..otherwise game over
		    	gamestate = 'game_over'
				ralph.frame = 1
		    end
			
	    end
		
		
	elseif gamestate == 'done' then
	    --if player hits a button, re-initialize game objects and move back to play state
				
		if any_button_pressed() then
			gamestate = 'play'
			trolley_sound:play(1)
			
			-- reset animation for ralph
			ralph.frame = 1
			
			--re-Initialize trolley
			trolley = nil
			trolley_speed = trolley_speed * 1.1
			trolley_sound:setRate( math.min( trolley_sound:getRate() * 1.05, 3 ) )
			trolley_speed = math.min(trolley_speed, MAX_TROLLEY_SPEED) -- cap trolley speed
			trolley = Trolley:new(-50,0,trolley_speed) --Trolley(x,y,speed)
			
			-- remove victim old sprites before re-loading:
			for i, victim in ipairs(victims) do
				victim:remove()
			end
			number_of_victims = number_of_victims + 1 --increase the number of victims on the tracks
						
			--re-initialize victims on tracks
			victims = {}
		    for i = 1, number_of_victims do
		    	local x = math.random(190,360)  --random x value between 180 and 350, which will place them somewhere along the rail on the x asis
				local y = track_y(x) + 10 --returns y coordinate on the track given the x value, and move down slightly to fit onto rail 
		    	local up_or_down = math.random(0,1) --50% chance the victoms are on the lower track
		    	y = y + up_or_down * 64 --shifts 50% of victims to lower track
		        table.insert(victims, MrRoper:new(x, y, up_or_down, trolley_speed))
		    end
			
		end
		

	elseif gamestate == 'game_over' then
		-- save high score
		if score > high_score then
			high_score = score
			local scoreFile = playdate.file.open("problem_trolley_data.txt", playdate.file.kFileWrite)
			scoreFile:write(tostring(high_score))
			scoreFile:close()
		end
		
		-- after button is pressed reset game
		if any_button_pressed() then
			--after game over, reload game to start over!	
			gfx.sprite.removeAll()
			load_new_game()
		end	
	end


	-- at end of stage display score:
	if gamestate == 'done' or gamestate == 'game_over' then
		playdate.graphics.drawText("Score: " .. score, 20, 10)
		playdate.graphics.drawText("Smashed: " .. smashed_total, 235, 10)
		playdate.graphics.drawText("Saved: " .. saved_total, 235, 30)
		if saved_total >= smashed_total then
			playdate.graphics.drawText("Good Job!", 235, 60)
		else
			playdate.graphics.drawText("Whoops!", 235, 60)
			playdate.graphics.drawText("High score: " .. high_score, 20, 210)
		end
	end

end


function any_button_pressed()
	-- returns 1 if any button is pressed
	if playdate.buttonIsPressed('a') then return 1 end
	if playdate.buttonIsPressed('b') then return 1 end
	if playdate.buttonIsPressed('up') then return 1 end
	if playdate.buttonIsPressed('down') then return 1 end
	if playdate.buttonIsPressed('left') then return 1 end
	if playdate.buttonIsPressed('right') then return 1 end

	-- if no button is pressed, return nil
	return nil
end

return problem_trolley
