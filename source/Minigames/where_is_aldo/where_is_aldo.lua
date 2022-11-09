
--[[
	Author: Drew Loebach

	where_is_aldo for Mobware Minigames
	
	TO-DO's:
	- update background
	- Add intro
	- Add more frames to Aldo so that he waves when you find him
	--> maybe when you find him he always switches to facing forward	
	
]]

local where_is_aldo = {}

import "background"
import "MagnifyingGlass"

local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

gamestate = 'play'
local number_of_NPCs = 50
local GAME_TIME_LIMIT = 8 -- player has 8 seconds at 20fps
local game_timer = playdate.frameTimer.new( GAME_TIME_LIMIT * 20, function() gamestate = "defeat" end ) 
local found_counter = 0

local cursorSprite
local backgroundSprite

-- load sound effects
local fanfare = playdate.sound.sampleplayer.new('Minigames/where_is_aldo/sounds/fanfare')
local music = playdate.sound.sampleplayer.new('Minigames/where_is_aldo/sounds/Slow_Funny_Music_David_Renda')
music:play(0)


function initialize()
	backgroundSprite = Background()
	
	--load NPC sprites
	local NPC_image_table = gfx.imagetable.new("Minigames/where_is_aldo/images/NPCs")
	for _i = 1, number_of_NPCs do
		local NPC = gfx.sprite.new()
		random_character = math.random( NPC_image_table:getLength() )
		NPC:setImage( NPC_image_table:getImage(random_character) )
		NPC:moveTo(math.random(400), math.random(240))
		NPC:setZIndex(NPC.y)
		NPC:add()
	end

	-- load Aldo's sprite
	--local aldo_image_table = gfx.imagetable.new("Minigames/where_is_aldo/images/aldo")
	local aldo = gfx.sprite.new()
	aldo:setImage( gfx.image.new("Minigames/where_is_aldo/images/aldo") )
	--random_image = math.random( NPC_image_table:getLength() )
	--aldo:setImage( NPC_image_table:getImage(random_image) )
	aldo:moveTo(math.random(20,380), math.random(30, 210))
	aldo:setZIndex(aldo.y)
	aldo:setCollideRect(aldo.width/4, aldo.height/4 , aldo.width / 2, aldo.height / 2)

	aldo:add()
	
	-- generate double-sized copy of screen to display under magnifying glass
	gfx.sprite.update()
	zoomed_image = gfx.getWorkingImage():scaledImage(2)
	mask_image = gfx.image.new( zoomed_image:getSize())
	
	-- show magnifying glass
	cursorSprite = MagnifyingGlass()

	-- show d-pad indicator	which turns off after 1 second
	mobware.DpadIndicator.start()
	local dpad_timer = playdate.frameTimer.new( 20, function() mobware.DpadIndicator.stop() end ) 
	
end

initialize()

function where_is_aldo.update()

	-- update frame timer
	playdate.frameTimer.updateTimers()

	gfx.sprite.update()
	
	-- update image under magnifying glass if the player hits the "A" button
	if playdate.buttonJustPressed("A") then
		-- update image mask to cut out the area currently under the magnifying glass
		mask_image:clear(gfx.kColorClear)
		gfx.pushContext(mask_image)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillCircleAtPoint(cursorSprite.x*2,cursorSprite.y*2,37)
		gfx.popContext()
		zoomed_image:setMaskImage(mask_image) 
		  
	end
	
	-- show zoomed image under magnifying glass when the "A" button is pressed
	if playdate.buttonIsPressed("A") then
		zoomed_image:draw(-cursorSprite.x,-cursorSprite.y)
	end
	
	-- check if we've found Aldo
	if #cursorSprite:overlappingSprites() > 0 then
		found_counter +=1 
		-- if the magnifying glass is over Aldo for long enough then move to victory state
		if found_counter > 20 then 
			gamestate = "victory"
		end
	else
		found_counter = 0
	end
	
	-- allow the player to move when A is pressed?
	-- should I just show the magnified version always?
	
	if gamestate == "victory" then

		-- show magnified view:
		cursorSprite:setScale(2)
		mask_image:clear(gfx.kColorClear)
		gfx.pushContext(mask_image)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillCircleAtPoint(cursorSprite.x*2,cursorSprite.y*2,37)
		gfx.popContext()
		zoomed_image:setMaskImage(mask_image) 
		gfx.sprite.update()
		zoomed_image:draw(-cursorSprite.x,-cursorSprite.y)
		
		-- play victory fanfare
		fanfare:play(1)
		-- show Aldo raising his arms
		playdate.wait(2000)
		return 1
	
	elseif gamestate == "defeat" then
		-- TO-DO: add code here
		
		return 0

	end

end

-- Minigame package should return itself
return where_is_aldo
