--[[
	Module for generating and displaying the credits for Mobware Minigames

	Author: Andrew Loebach
	loebach@gmail.com
]]

credits = {}

local sprite_list = {}
local sprite_table = {}
local loaded_sprites = {}

local gfx <const> = playdate.graphics
local SPACE_BETWEEN_CREDITS = 70
local SCROLL_SPEED = 2
local SCROLL_MAX = 240
local credits_y = 20
local scroll_y = SCROLL_MAX --> start scroll value at SCROLL_MAX

-- load sprites for generic game credits
local default_dog_spritesheet = gfx.imagetable.new("images/default_dog")
local demon_spritesheet = gfx.imagetable.new("images/demon")
local crab_spritesheet = gfx.imagetable.new("images/crab")

-- set refresh rate
playdate.display.setRefreshRate( 20 )

-- set font
gfx.setFont(mobware_font_L)

-- set background color to black
gfx.setBackgroundColor(gfx.kColorBlack)

--> initialize music
local credits_music = playdate.sound.fileplayer.new('sounds/credits_theme', 3)
credits_music:setLoopRange(3)
credits_music:play(0) -- play music (loop after it's finished) 


function credits.update()

	-- Display the game's credits:

	-- scroll credits gradually, and allow player to adjust by turning the crank
	scroll_y -= SCROLL_SPEED
	scroll_y -= playdate.getCrankTicks(150)
	scroll_y = math.min(scroll_y, SCROLL_MAX) --> ensures you never scroll way beyond the beginning of the credits sequence
	gfx.setDrawOffset(0, scroll_y)

	-- updates all sprites
	gfx.sprite.update() 

	-- lazy load animated sprites
	for minigame_name, sprite_y in pairs(sprite_list) do
		if scroll_y + sprite_y < 240 and scroll_y + sprite_y > -240 and loaded_sprites[minigame_name] == nil then
			
			-- Add minigame credit sprite
			local status, credits_sprite = pcall(load_credit_sprite, minigame_name, sprite_y) 
			if status == true and credits_sprite ~= nil then
				--print('Sprite for', minigame_name, 'loaded successfully')
			else
				-- loads default dog if the minigame's credits sprite can't be loaded
				print('Error: could not locate credits sprite for', minigame_name)
				credits_sprite = AnimatedSprite.new( default_dog_spritesheet )
				credits_sprite:addState("animate", nil, nil, {tickStep = 2})
				credits_sprite:setZIndex(1)
			end
			credits_sprite.minigame = minigame_name
			credits_sprite:setCenter(0.5, 0)
			credits_sprite:moveTo(314,sprite_y)
			credits_sprite:playAnimation()
			credits_sprite.loaded = true

			-- add credits sprite to sprite table
			table.insert(sprite_table, credits_sprite) -- add credits sprite to sprite table
	
			-- keep track of which sprites are loaded so we don't load them multiple times
			loaded_sprites[minigame_name] = "true"

		end
	end

	-- Check sprites table and remove the ones that have moved off screen
	for _i, credits_sprite in ipairs(sprite_table) do
		if scroll_y + credits_sprite.y < -250 then
			--print("Removing sprite for", credits_sprite.minigame )
			loaded_sprites[credits_sprite.minigame ] = nil
			table.remove(sprite_table, _i)
			credits_sprite:remove()
		end

	end	

	-- End credits sequence after all credits have scrolled
	if scroll_y + credits_ending_y < 0 then
		credits_music:stop()
		return 2
	end

end


function generate_credits()

	-- create credits text that we print text to
	credits_text = gfx.image.new(400, #minigame_list * 500)
	gfx.lockFocus(credits_text)

	-- Print our title: "MOBWARE MINIGAMES"
	gfx.setFont(mobware_font_L)
	local text_width, text_height = gfx.getTextSize("mobware minigames")
	local text_x = (400 - text_width) / 2 -- this should put the minigame name in the center of the screen
	mobware.print("mobware minigames", text_x, credits_y)
	credits_y += SPACE_BETWEEN_CREDITS

	-- Add animated sprite for metagame credits 
	local credits_sprite = AnimatedSprite.new( demon_spritesheet )
	credits_sprite:addState("animate", nil, nil, {tickStep = 2})
	credits_sprite:setZIndex(1)
	credits_sprite:setCenter(0.5, 0)
	credits_sprite:moveTo(320,credits_y)
	credits_sprite.minigame = "mobware"
	credits_sprite:playAnimation()

	-- Metagame credits:
	print_credits("director", "drew loebach", credits_y)
	print_credits("music", "Triple Tritone", credits_y)
	print_credits("opening theme", "timhei", credits_y)
	print_credits("font consultant", "neven mrgan", credits_y)

	-- animated crab to be displayed next to animated sprite credit
	local credits_sprite = AnimatedSprite.new( crab_spritesheet )
	credits_sprite:addState("animate", nil, nil, {tickStep = 2}, true)
	credits_sprite:setZIndex(1)
	credits_sprite:setCenter(0.5, 0)
	credits_sprite:moveTo(320,credits_y - 8)
	credits_sprite.minigame = "animated_sprite"
	print_credits("Animated sprite library", "Whitebrim", credits_y)

	-- Special thanks:
	--add playdate with "thank you!" on the display?
	print_credits("special thanks to", "nic magnier", credits_y)

	-- Add credits from minigames:
	for _i, minigame in ipairs(minigame_list) do
		
		print("Reading credits for",minigame,"...")

		-- read credits from credits.json
		local credits_json_path = 'Minigames/' .. minigame .. '/credits.json'
		local status, working_credits = pcall(getCredits, credits_json_path) 
		if status == true and working_credits ~= nil then
			-- credits read successfully. Nothing else to do here!
		else
			print('Error reading credits for', minigame, '-> crediting to anonymous')
			-- if credits.json can't be loaded then credit the game to "anonymous"
			working_credits = {designer = "anonymous"}
		end

		-- Print minigame name
		local minigame_name = string.gsub(minigame,"_"," ")
		gfx.setFont(mobware_font_L)
		local text_width, text_height = gfx.getTextSize(minigame_name)
		local text_x = (400 - text_width) / 2 -- this should put the minigame name in the center of the screen
		credits_y += SPACE_BETWEEN_CREDITS
		mobware.print(minigame_name, text_x, credits_y)
		credits_y += SPACE_BETWEEN_CREDITS

		-- Add y-value to sprite array so we know where to lazy load our sprites later
		sprite_list[minigame] = credits_y - 8  -- subtract 8 to make sprite in line with credit text

		-- Iterate over items in minigame's credits.json, and print the text to our canvas which we'll be scrolling through
		for role, name in pairs(working_credits) do  
		  print_credits(role, name, credits_y)
		end

	end

	credits_y += SPACE_BETWEEN_CREDITS * 2
	gfx.setFont(mobware_font_L)
	mobware.print("..and you!", 60, credits_y)
	credits_y += SPACE_BETWEEN_CREDITS
	gfx.setFont(mobware_font_M)
	mobware.print("You played the greatest\nrole in this story!!!", 20, credits_y)
	credits_y += SPACE_BETWEEN_CREDITS
	mobware.print("Thank you for playing", 45, credits_y)
	credits_ending_y = credits_y + 120

	gfx.unlockFocus()

	credits_sprite = gfx.sprite:new(credits_text)
	credits_sprite:setImage(credits_text)
	credits_sprite:setCenter(0.5, 0) -- set credits_text y=0 at top of the image 
	credits_sprite:moveTo(200, 0)
	credits_sprite:addSprite()
	--credits_sprite:setZIndex(0) -- credits will be displayed behind sprites
	credits_sprite:setZIndex(2) -- make sure credits are displayed on top of sprites

end


-- Parse json file with credits
function getCredits(path)
	return json.decodeFile(path)
end


-- initialize text box used for print_credits function
text_box_outer_width = 16
text_box_outer_height = 16
text_box = gfx.nineSlice.new("images/text-bubble", 16, 16, 32, 32)

-- Function to print text in auto-sized comic-styled bubble
function print_credits(role, name, y)
	local x = 20
	local role_width, role_height = gfx.getTextSizeForMaxWidth(role, 320, 0, mobware_font_S)
	local name_width, name_height = gfx.getTextSizeForMaxWidth(name, 320, 0, mobware_font_M)
	local bubble_width = math.max(role_width, name_width) + 32
	local bubble_height = role_height + name_height + 32

	text_box:drawInRect(x - 16, y - 16, bubble_width, bubble_height)
	gfx.setFont(mobware_font_S)
	gfx.drawTextAligned(role, x, y)
	gfx.setFont(mobware_font_M)
	gfx.drawTextAligned(name, x, y + role_height)

	credits_y += SPACE_BETWEEN_CREDITS
end

-- Function to load credit sprite from minigame path
function load_credit_sprite(minigame, y)
	local sprite_path = 'Minigames/' .. minigame .. '/credits'
	local credits_spritesheet = gfx.imagetable.new(sprite_path)
	local credits_sprite = AnimatedSprite.new( credits_spritesheet )
	credits_sprite:addState("animate", nil, nil, {tickStep = 3}, true)
	credits_sprite:setZIndex(1)
	return credits_sprite
end

-- call function to generate credits table
generate_credits()

return credits
