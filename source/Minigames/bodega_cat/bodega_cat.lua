
--[[
	Author: Andrew Loebach
	
	Original minigame design: Pawprints

	"bodega cat" Minigame for Mobware Minigames
]]

-- Define name for minigame package
bodega_cat = {}

local gfx <const> = playdate.graphics

-- set background color to black
gfx.setColor(gfx.kColorBlack)
gfx.fillRect(0, 0, 400, 240)
gfx.setBackgroundColor(gfx.kColorBlack)
gfx.setColor(gfx.kColorWhite)

-- Initialize animation for on-screen sprites
cat_spritesheet = gfx.imagetable.new("Minigames/bodega_cat/images/bc-cat")
cat = gfx.sprite.new(cat_spritesheet)
cat_frame = math.random(1,4) -- set cat in random pose
pose = {"up", "down", "left", "right"}
cat:setImage(cat_spritesheet:getImage(cat_frame))
cat:moveTo(200, 120)
cat:add()

-- initialize phone image
phone_spritesheet = gfx.imagetable.new("Minigames/bodega_cat/images/phone")
phone = gfx.sprite.new()
phone:setImage(phone_spritesheet:getImage(cat_frame))
phone:moveTo(200,190)
phone:add()

--> Initialize sound effects & background music
camera_shutter = playdate.sound.sampleplayer.new("Minigames/bodega_cat/sounds/camera-shutter")
background_music = playdate.sound.fileplayer.new("Minigames/bodega_cat/sounds/Chipho")
background_music:play() -- play music only once

-- start timer, which will move to "compare" gamestate after a set amount of time
MAX_GAME_TIME = 6 -- define the time at (20 fps) that the game will run before setting the "compare" gamestate
game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "defeat" end ) 

-- set initial gamestate and start prompt for player to use the crank
gamestate = "play"
score = 0 

-- initialize cat's pose:
target_pose = cat_frame 
while target_pose == cat_frame do
	target_pose = math.random(1,4) -- set random pose to move cat to
end



function bodega_cat.update()

	-- update sprite animations
	gfx.sprite.update() -- updates all sprites
	
	-- update frame timer
	playdate.frameTimer.updateTimers()
	
	if gamestate == "play" then

		mobware.print(pose[target_pose].."!", 20, 20)
		
		-- if correct button is pressed, increase score and change cat pose
		if playdate.buttonIsPressed(pose[target_pose]) then 
			
			-- flash camera effect
			camera_shutter:play(1)
			playdate.graphics.clear()
			gfx.fillRect(0, 0, 400, 240)
			playdate.wait(100) -- Pause 100ms to give the impression of a camera flash
			
			score+=1
			
			if score >= 3 then
				gamestate = "victory"
			end
			
			-- update cat's image 
			cat_frame = target_pose
			cat:setImage(cat_spritesheet:getImage(cat_frame))
			phone:setImage(phone_spritesheet:getImage(cat_frame))
			
			-- re-initialize cat's pose:				
			while target_pose == cat_frame do
				target_pose = math.random(1,4) -- set random pose to move cat to
			end
			
		end
		
		
	elseif gamestate == "victory" then
		
		-- show the last pose for 1 second, in all its glory
		playdate.wait(1000)
		
		-- display sweet instagram post
		gfx.sprite.removeAll()
		local insta = gfx.sprite.new()
		insta:setImage( gfx.image.new("Minigames/bodega_cat/images/insta") )
		insta:moveTo(200, 120)
		insta:add()
		
		cat = gfx.sprite.new(cat_spritesheet)
		cat:setImage(cat_spritesheet:getImage(cat_frame), playdate.graphics.kImageUnflipped, 0.5)
		cat:moveTo(200, 120)
		cat:add()
		
		gfx.sprite.update()
		
		playdate.wait(2500)
		background_music:stop()
		return 1
		
	elseif gamestate == "defeat" then
		background_music:stop()
		return 0
	end
	

end


-- Minigame package should return itself
return bodega_cat

