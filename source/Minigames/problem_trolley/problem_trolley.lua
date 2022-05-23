--[[
	Problem Trolley minigame for MobWare Minigames

	Developed by:	Andrew Loebach
					Neil Austin

	Life if full of tough decisions! You control Railway Ralph, who needs to decide where to route the trolley
	But this means sometimes choosing the lesser of two evils...
	
	TO-DO: Maybe have a "READY" and crank prompt, then add the victims afterwards to maintain the challenge
		-> maybe always have 1 victim on one side and 4 on the other to make it easier
]]

-- import the classes that we're using for our animated objects
import 'Minigames/problem_trolley/Ralph'
import 'Minigames/problem_trolley/MrRoper'
import 'Minigames/problem_trolley/Trolley'

local gfx <const> = playdate.graphics

problem_trolley = {}

function track_y(x)
	--given x coordinate, returns y coordinate of track track
	local y = x / 3.1 + 40 --y coordinate on upper rail
	return y
end

--> Initialize sound effects
splat_noise = playdate.sound.sampleplayer.new('Minigames/problem_trolley/sounds/splat')
trolley_sound = playdate.sound.sampleplayer.new('Minigames/problem_trolley/sounds/chug-a-chug')

-- set font
scribble_font = gfx.font.new("Minigames/problem_trolley/font/scribble_thin")
gfx.setFont(scribble_font)


local s, ms = playdate.getSecondsSinceEpoch()
math.randomseed(ms,s)

gamestate = 'play'

trolley_sound:setRate(1)
trolley_sound:play(1)

trolley_speed = 3
MAX_TROLLEY_SPEED = 10
number_of_victims = 5 --change the number of victims on the tracks
smashed_total = 0 --used for score in 'done' state
saved_total = 0 --used for score in 'done' state
score = 0

--background = playdate.graphics.image.new("images/Switchyard_background.png")
background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/problem_trolley/images/Switchyard_background"))
background:moveTo(200, 120)
background:add()

--Initialize Railway Ralph
ralph = Ralph:new()

--Initialize victims on tracks
victims = {}
for i = 1, number_of_victims do
	local x = math.random(190,330)  --random x value between 180 and 350, which will place them somewhere along the rail on the x-axis
	local y = track_y(x) + 10 --returns y coordinate on the track given the x value, and move down slightly to fit onto rail 
	local up_or_down = math.random(0,1) --50% chance the victoms are on the lower track
	y = y + up_or_down * 64 --shifts 50% of victims to lower track
    table.insert(victims, MrRoper:new(x, y, up_or_down, trolley_speed))
end

--Initialize trolley
trolley = Trolley:new(-60,25,trolley_speed)

-- initialize crank indicator
mobware.crankIndicator.start()


function problem_trolley.update()

	-- update sprite animations
	gfx.sprite.update() -- updates all sprites

	if gamestate == 'play' then
		
		-- check if victims are smashed:
		for i, victim in ipairs(victims) do
	        if victim:collides(trolley) then
	        	victim.smashed = true
	        end
	    end
		
		if trolley.x < 100 then playdate.graphics.drawText("save lives!", 235, 45) end
		
		-- remove crank indicator
		if mobware.crankIndicator and trolley.x > 80 then mobware.crankIndicator.stop() end
	    
	    if trolley.x > 400 then
	    	-- 'play' state ends when the trolley drives off the screen
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
			
			ending_timer = playdate.timer.new(2000)
			
		    if saved_total >= smashed_total then 
			    -- you win the minigame if Ralph saves more than die
				gamestate = 'victory'
		    else
		    	-- ..otherwise game over
		    	gamestate = 'defeat'
		    end
			
	    end
		
		
	elseif gamestate == 'victory' then
		playdate.graphics.drawText("Good Job!", 235, 45)
		playdate.timer.updateTimers()
		if ending_timer.timeLeft == 0 then return 1 end

	elseif gamestate == 'defeat' then
		playdate.graphics.drawText("Whoops!", 235, 45)
		playdate.timer.updateTimers()
		if ending_timer.timeLeft == 0 then return 0 end

	end


end


function problem_trolley.cranked(change, acceleratedChange)
	if mobware.crankIndicator then mobware.crankIndicator.stop() end
end

return problem_trolley