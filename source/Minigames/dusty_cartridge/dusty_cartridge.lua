--[[
	Author: Andrew Loebach

	"Dusty Cartridge" Minigame for Mobware Minigames
]]

-- Define name for minigame package
dusty_cartridge = {}

-- import the classes for our movable objects
import 'Minigames/dusty_cartridge/Dust'
import 'Minigames/dusty_cartridge/Paperclip'
import 'Minigames/dusty_cartridge/Pencil'

local gfx <const> = playdate.graphics

-- initialize background
local background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/dusty_cartridge/images/NES_tv-off"))
background:moveTo(200, 120)
background:addSprite()
background:setZIndex(0)

-- Load thumb image for victory animation
local thumb_image = gfx.sprite.new()
thumb_image:setImage( gfx.image.new("Minigames/dusty_cartridge/images/thumbs_up") )
thumb_image:moveTo(0,240)
thumb_image:moveTo(thumb_image.width / 2 ,240)
thumb_image:setZIndex(4)

-- Mic input indicator
mobware.MicIndicator.start()

-- initialize timer & game variables
BLOW_THRESHOLD = 0.008
local gamestate = 'start'
local timer = playdate.timer.new(8000)

-- ADd dust sprites along the cartridge connector line: (115,195) -> (208, 156)
local _x = 115
local _y
while _x < 200 do
	-- randomize x coordinate, then set y along the line of the cartidge
	_x = _x + math.random(1,10)
	_y = -0.42 * _x +243

	-- create dust speck
	dust = Dust:new(_x,_y)
end

-- spawn paperclips & pencil
Paperclip:new(370,124, 20, -20)
Paperclip:new(220,20, 0, -10)
Pencil:new(30,130, -10, -5)

-- initialize music & sound effects
local game_theme_music = playdate.sound.fileplayer.new('Minigames/dusty_cartridge/sounds/SuperMarioBros_distorted')
local static_noise = playdate.sound.sampleplayer.new('Minigames/dusty_cartridge/sounds/static_noise')

-- Turn on microphone input
playdate.sound.micinput.startListening()


function dusty_cartridge.update()

	-- returns the current microphone input level, a value from 0.0 (quietest) to 1.0 (loudest)
	mic_input = playdate.sound.micinput.getLevel()
	--print('mic input:', mic_input) -- for debugging

	-- update sprite animations
	gfx.sprite.update() -- updates all sprites

	-- update timer
	playdate.timer.updateTimers()



	if gamestate == 'start' then
      
        mobware.print("Blow in the cartridge!", 35, 30)
	
		if mic_input > BLOW_THRESHOLD or timer.currentTime > 2000 then
			-- after input is detected from mic, remove prompt and move into "play" state
			mobware.MicIndicator.stop()
			gamestate = 'play' 
		end	
	end


	if gamestate == 'play' then

		-- Win condition:
		if gfx.sprite.spriteCount() <= 1 then
				background:setImage(gfx.image.new("Minigames/dusty_cartridge/images/NES_tv-game"))
				game_theme_music:play() -- play music only once
				gamestate = 'victory'
				thumb_image:addSprite()
				playdate.sound.micinput.stopListening()

		elseif timer.currentTime > 4000 then 
				-- if player doesn't blow off dust in time then trigger defeat aniation 
				background:setImage(gfx.image.new("Minigames/dusty_cartridge/images/NES_tv-game"))
				local tv_static_spritesheet = gfx.imagetable.new("Minigames/dusty_cartridge/images/NES_tv-static")
				tv_static = AnimatedSprite.new( tv_static_spritesheet )
				tv_static:addState("tv", nil, nil, {tickStep = 2}, true) 
				tv_static:moveTo(100, 25)
				tv_static:setZIndex(4)

				-- Play static sound effect
				static_noise:play(0) -- loop static noise
				static_noise:setVolume(0.5) -- loop static noise

				gamestate = 'defeated'
				playdate.sound.micinput.stopListening()		
		end


	elseif gamestate == 'victory' then
		thumb_image:moveTo( thumb_image.x , thumb_image.y - 1)

		if timer.currentTime >= 6000 then
			game_theme_music:stop()
			return 1
		end


	elseif gamestate == 'defeated' and timer.currentTime >= 6000 then
		static_noise:stop()
		return 0
	end

end


-- Minigame package should return itself
return dusty_cartridge
