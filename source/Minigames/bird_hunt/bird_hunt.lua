--[[
	bird_hunt
	Minigame for Mobware Minigames 

	Author: Andrew Loebach
]]

bird_hunt = {}

local gfx <const> = playdate.graphics

local SCREEN_WIDTH = playdate.display.getWidth()
local SCREEN_HEIGHT = playdate.display.getHeight()

-- initialize background
local background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/bird_hunt/images/duck_hunt_background"))
background:moveTo(200, 120)
background:addSprite()
background:setZIndex(1)

-- initialize grass (foreground)
local grass = gfx.sprite.new()
grass:setImage(gfx.image.new("Minigames/bird_hunt/images/bird_hunt_grass"))
grass:moveTo(200, 120)
grass:addSprite()
grass:setZIndex(3)

-- initialize dog
	--> I'm going to use Whitebrim's very convenient AnimatedSprite library
local pointing_dog = gfx.image.new("Minigames/bird_hunt/images/pointing_dog")
local dog_spritesheet = gfx.imagetable.new("Minigames/bird_hunt/images/pointer")
local dog = AnimatedSprite.new( dog_spritesheet )
dog:addState("wag",1,8, {tickStep = 1}, true).asDefault()
dog:addState("pointing",9,9, {})
dog:addState("defeated",10,10, {})
dog:moveTo(200,200)
dog:setZIndex(2) -- Sets sprite rendering in front of background, but behind grass
local dog_pointing = false 
local dog_direction = 1

--Initialize duck
local duck_spritesheet = gfx.imagetable.new("Minigames/bird_hunt/images/duck")
local duck = AnimatedSprite.new(duck_spritesheet)
duck:addState("flying",1,3, {tickStep = 2, loop = true}, true).asDefault()
duck:addState("shot",4,4, {})
duck:addState("falling",5,5, {})
duck:setZIndex(2) -- Sets sprite rendering in front of background, but behind grass

local duck_dx
local duck_dy = 5
if math.random() > 0.5 then
	duck:moveTo(150,240)
	duck_dx = -5
    duck.states.flying.flip = 1
else
	duck:moveTo(250,240)
	duck_dx = 5
end

-- Visual indicator for D-pad input
mobware.DpadIndicator.start("left","right")

-- game states:
--> start: show controls and show tail-waging dog
--> play: animate duck, and left or right will freeze the pointer into the pointing animation
--> end: show outcome, then return value based on if player was successfull
local gamestate = 'start'

-- start timer
local timer = playdate.timer.new(8000)
--playdate.timer.new(2000, callback)


function bird_hunt.update()

	-- update timer
	playdate.timer.updateTimers()

	-- Register inputs
	if dog_pointing == false then
		if playdate.buttonJustPressed("left") then
			dog_direction = -1
            dog.states.wag.flip = 1
            dog.states.pointing.flip = 1            
            dog.states.defeated.flip = 1            
			if gamestate == 'play' then 
                dog_pointing = true 	              
                dog:changeState("pointing")
            end
            -- remove D-pad indicator
            if mobware.DpadIndicator then mobware.DpadIndicator.stop() end
		end
		if playdate.buttonJustPressed("right") then
			dog_direction = 1
            dog.states.wag.flip = 0
            dog.states.pointing.flip = 0     
			dog.states.defeated.flip = 0
			if gamestate == 'play' then 
				dog_pointing = true 
			    dog:changeState("pointing")
			end
            -- remove D-pad indicator
            if mobware.DpadIndicator then mobware.DpadIndicator.stop() end
		end
	end


	if gamestate == 'start' then

		--mobware.print("point!", 165, 100)
		mobware.print("point at the bird!")

		-- move gamestate to play after 2 seconds
		if timer.currentTime >= 2000 then
			gamestate = 'play'

            -- remove D-pad indicator
            if mobware.DpadIndicator then mobware.DpadIndicator.stop() end
		end

        -- ALTERNATIVELY ADD SHORT INTRO SHOWNING D-PAD PROMPT AND DOG LOOKING BACK AND FORTH
	end

	if gamestate == 'play' then
		-- Update duck's position 
		duck:moveTo(duck.x + duck_dx ,duck.y - duck_dy) 
	
		-- Game over if the duck flies off the screen
		if duck.x + duck.width < 0 or duck.x - duck.width > SCREEN_WIDTH then
		--if duck.x < 0 or duck.x > SCREEN_WIDTH then
			dog:changeState("defeated")
			gfx.sprite.update() 
            playdate.wait(500)
			return 0 
		end

        -- If dog is pointing at the duck, trigger victory animation
    	if dog_pointing == true and duck_dx * dog_direction > 0 then
            playdate.graphics.clear()
            playdate.wait(150) -- Pause 250ms to give the impression of a gun blast
            duck:changeState("shot")
            gfx.sprite.update() 
            playdate.wait(250) -- Pause 250ms to give the impression of a gun blast
            duck:changeState("falling")
            duck_dx = 0
            duck_dy = 4
            gamestate = 'end'
        end
    end 

    if gamestate == 'end' then
        duck:moveTo(duck.x, duck.y + duck_dy)
        if duck.y > SCREEN_HEIGHT then return 1 end
	end

    -- Rendering
	gfx.sprite.update() -- updates all sprites

	if gamestate == 'start' then
        mobware.print("point!", 165, 100)
	end

end


function bird_hunt.credits()
	--Make sure to freshly load the image, since game:load() will	not be called beforehand
	credits_sprite = gfx.image.new("Minigames/bird_hunt/images/pointing_dog.png")
	credits_name = 'Andrew Loebach'
	return credits_sprite, credits_name
end


return bird_hunt
