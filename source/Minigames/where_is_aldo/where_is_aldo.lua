
--[[
	Author: Drew Loebach

	where_is_aldo for Mobware Minigames
	
]]

local where_is_aldo = {}

import "background"
import "MagnifyingGlass"

local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

gamestate = 'intro'
local number_of_NPCs = 20 + playdate.display.getRefreshRate() -- number of NPCs scales with the difficulty
local GAME_TIME_LIMIT = 8 -- minigame time limit (at 20fps)
local found_counter = 0

local cursorSprite
local backgroundSprite

-- load sound effects
local fanfare = playdate.sound.sampleplayer.new('Minigames/where_is_aldo/sounds/fanfare')
local aww_sound = playdate.sound.sampleplayer.new('Minigames/where_is_aldo/sounds/aww')
local music = playdate.sound.sampleplayer.new('Minigames/where_is_aldo/sounds/Slow_Funny_Music_David_Renda')
music:play(0)


-- initialize sprites and game
local backgroundSprite = Background()

-- load Aldo's sprite
local aldo = gfx.sprite.new()
local aldo_image = gfx.image.new("Minigames/where_is_aldo/images/aldo")
aldo:setImage( aldo_image )
aldo:moveTo(math.random(20,380), math.random(30, 210))
aldo:setZIndex(aldo.y)
aldo:setCollideRect(aldo.width/4, aldo.height/4 , aldo.width / 2, aldo.height / 2)
aldo:add()

--load NPC sprites
local NPC_image_table = gfx.imagetable.new("Minigames/where_is_aldo/images/NPCs")
for _i = 1, number_of_NPCs do
	local NPC = gfx.sprite.new()
	random_character = math.random( NPC_image_table:getLength() )
	NPC:setImage( NPC_image_table:getImage(random_character) )
	NPC:moveTo(math.random(400), math.random(240))
	-- check if NPC is directly in front of Aldo
	while (NPC.x - aldo.x)^2 < 200 and (NPC.y - aldo.y)^2 < 200 do
		--print("NPC covering aldo, moving to new location...")
		NPC:moveTo(math.random(400), math.random(240))
	end
	
	NPC:setZIndex(NPC.y)
	NPC:add()
end

-- generate double-sized copy of screen to display under magnifying glass for zoom effect
gfx.sprite.update()
local zoomed_image = gfx.getWorkingImage():scaledImage(2)
local mask_image = gfx.image.new( zoomed_image:getSize())
-- obscure sprites with background image before moving into "play" state:
backgroundSprite:getImage():draw(0,0)

-- show magnifying glass
local cursorSprite = MagnifyingGlass()

-- set timer to go to defeat state after time has expired
local game_timer = playdate.frameTimer.new( GAME_TIME_LIMIT * 20, 
	function() 
		if #cursorSprite:overlappingSprites() > 0 then
			gamestate = "victory"
		else 
			gamestate = "defeat"
		end 
	end ) 

function where_is_aldo.update()

	-- update frame timer
	playdate.frameTimer.updateTimers()
	
	if gamestate == "intro" then

		--draw background image (obscuring other sprites during intro)
		backgroundSprite:getImage():draw(0,0)

		mobware.print("where is aldo?")
		
		-- draw aldo in display bubble		
		local display_bubble = gfx.image.new("images/text-bubble")
		local display_bubble_width, display_bubble_height = display_bubble:getSize()
		display_bubble:draw(200 - display_bubble_width/2, 160 - display_bubble_height/2)
		local aldo_offset_width, aldo_offset_height = aldo_image:getSize()
		aldo_image:draw(200 - aldo_offset_width/2, 160 - aldo_offset_height/2)
		
		-- wait 3 seconds, then move to "play" state
		playdate.wait(3000)
		
		-- show d-pad indicator	which turns off after 1 second
		mobware.DpadIndicator.start()
		local dpad_timer = playdate.frameTimer.new( 20, function() mobware.DpadIndicator.stop() end ) 	
		
		-- move to "play" state
		gamestate = "play" 


	elseif gamestate == "play" then
		
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
		
		-- show zoomed image under magnifying glass while the "A" button is pressed
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
		
	elseif gamestate == "victory" then

		-- show magnified view:
		cursorSprite:setScale(2)
		gfx.sprite.update()
		mask_image:clear(gfx.kColorClear)
		gfx.pushContext(mask_image)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillCircleAtPoint(cursorSprite.x*2,cursorSprite.y*2,37)
		gfx.popContext()
		zoomed_image:setMaskImage(mask_image) 
		zoomed_image:draw(-cursorSprite.x,-cursorSprite.y)
		
		-- play victory fanfare
		fanfare:play(1)
		-- show Aldo raising his arms or giving a thumbs up?
		playdate.wait(2000)
		return 1
	
	elseif gamestate == "defeat" then
		
		-- Draw circle around Aldo
		gfx.setLineWidth( 4 )
		gfx.drawCircleAtPoint(aldo.x, aldo.y, 30) 
		
		-- point to Aldo with cartoon hand
		local pointer = gfx.image.new("Minigames/where_is_aldo/images/pointer")
		pointer:draw(aldo.x + 25, aldo.y - 10)

		-- play disappointed sound effect
		aww_sound:play(1)
		
		playdate.wait(2500)
		return 0

	end

end

-- Minigame package should return itself
return where_is_aldo
