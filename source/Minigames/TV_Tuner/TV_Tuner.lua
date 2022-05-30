--[[
  TV Tuner
  Minigame for Mobware Minigames

  Author: Andrew Loebach
]]
-- TO-DO: add victory fanfare

--minigame needs to initialize its own object
local TV_Tuner = {}

local gfx <const> = playdate.graphics

-- Defining boundries of TV screen
local TV_SCREEN_LEFT = 132
local TV_SCREEN_RIGHT = 252
local TV_SCREEN_TOP = 84
local TV_SCREEN_BOTTOM = 171

TV_WIDTH = TV_SCREEN_RIGHT - TV_SCREEN_LEFT
TV_HEIGHT = TV_SCREEN_BOTTOM - TV_SCREEN_TOP
local tv_grid = {}

--initialize animation for polar bear
  --> I'm going to use Whitebrim's very convenient AnimatedSprite library
local polarbear_spritesheet = gfx.imagetable.new("Minigames/TV_Tuner/images/polar_bear")
polarbear = AnimatedSprite.new( polarbear_spritesheet )
polarbear:addState("animate", nil, nil, {tickStep = 4}, true)
polarbear:moveTo(190,120)
polarbear:setZIndex(1)

-- Create image for rendering static on the TV screen
import 'Minigames/TV_Tuner/generate_static'
local tv_static = gfx.sprite.new()
tv_static:moveTo( TV_SCREEN_LEFT, TV_SCREEN_TOP )
tv_static:setBounds(TV_SCREEN_LEFT, TV_SCREEN_TOP, TV_WIDTH * 2, TV_HEIGHT * 2) --use double TV_WIDTH 
tv_static:add()
tv_static.spriteSheet = {}
-- Call function to generate images of tv static 
for _i = 1, 10 do
  tv_static.spriteSheet[_i] = generate_static(_i)
end
tv_static:setImage(tv_static.spriteSheet[1])
tv_static:setZIndex(2) -- Render static over polar bear, but under TV

-- Load background / TV image
local background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/TV_Tuner/images/TV"))
background:moveTo(200, 120)
background:addSprite()
background:setZIndex(3)

-- Load thumb images for victory animation
local thumb_image = gfx.sprite.new()
thumb_image:setImage( gfx.image.new("Minigames/TV_Tuner/images/thumbs_up") )
thumb_image:moveTo(0,240)
thumb_image:moveTo(thumb_image.width / 2 ,240)
thumb_image:setZIndex(4)

--> Initialize music / sound effects
local static_noise = playdate.sound.sampleplayer.new('Minigames/TV_Tuner/sounds/static_noise')
static_noise:setVolume( 10/ 100 ) 
static_noise:play(0) -- loop static noise
-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- Initialize values for TV antenna
gfx.setLineWidth( 2 ) -- Set width of TV antennas
local antenna_angle = 45
local antenna_x = 40
local antenna_y = 40
local ANTENNA_MIN = 20 --left-most position of antenna (in degrees)
local ANTENNA_MAX = 175 --right-most position of antenna (in degrees)
local ANTENNA_LENGTH = 60

-- Randomly generate angle of antenna which will have good reception (win condition)
local reception_angle = math.random(ANTENNA_MIN, ANTENNA_MAX)
local has_reception_counter = 0
local game_counter = 0 

gamestate = 'play'

-- Start crank indicator animation
mobware.crankIndicator.start()


function TV_Tuner.update()
  -- Used to calculate dt, since i'm porting this from the Love2D framework
  local dt = 1 / playdate.display.getRefreshRate()

  if gamestate == 'play' then
    -- Generate static shown on TV
    --> noise_frequency will decrease down to 1 (most static) if far away from the receiption angle, and increase when close to reception angle
    local noise_frequency = math.floor( math.max( 10 - math.abs((antenna_angle - reception_angle) / 2), 1 ) )
    tv_static:setImage(tv_static.spriteSheet[noise_frequency])
    local random_x_offset = math.random( 0, TV_WIDTH )
    local random_y_offset = math.random( 0, TV_HEIGHT )
    tv_static:setBounds(TV_SCREEN_LEFT - random_x_offset, TV_SCREEN_TOP - random_y_offset, TV_WIDTH * 2, TV_HEIGHT * 2)

    -- Update volume of static noise based on amount of static
    static_noise:setVolume((10 - noise_frequency) / 100 ) 

    -- win condition
    if math.abs(antenna_angle - reception_angle) < 2 then -- get reception if you're under 2 degrees from correct angle
      has_reception_counter = has_reception_counter + dt
      tv_static:remove() --      :setVisible(flag)
      
      --player wins game if they hold reception for 1 second
      if has_reception_counter >= 1 then 
        gamestate = 'victory'
        victory_time = 0 
        game_counter = 0 --reset game counter so we can use it for the victory animation
        thumb_image:addSprite()  --clear TV screen of static
        tv_static:remove()
        static_noise:stop()
        -- TO-DO: PLAY VICTORY MUSIC
      end
    else
      has_reception_counter = 0
      tv_static:add()
    end

  end

  if gamestate == 'victory' then
    if game_counter >= 2 then return 1 end --end game after 2s of victory animation
    thumb_image:moveTo( thumb_image.x , thumb_image.y - 1)
  end

  if gamestate == 'defeat' then
    --TO-DO: ADD DEFEAT ANIMATION BEFORE RETURNING 0
    static_noise:stop()
    -- antenna snaps and static goes to full strength
    --> need snapping sound effect and animation
    return 0
  end

  --increase game counter
  game_counter = game_counter + dt
  if game_counter >= 8 then
    gamestate = 'defeat'
  end 


-- Rendering code

  gfx.sprite.update() -- updates all sprites

  --draw antennas
  gfx.drawLine( 207, 50, 165, 10)   --left antenna
  gfx.drawLine( 207, 50, 207 + antenna_x, 50 - antenna_y)  --right antenna

  --print instructions to player
  if game_counter < 2 and gamestate == "play" then
    mobware.print("Get reception!", 20, 20)
  end

end


function TV_Tuner.cranked(change, acceleratedChange)
    if gamestate == 'play' then
      antenna_angle = math.min( math.max(ANTENNA_MIN, antenna_angle + change), ANTENNA_MAX )
      antenna_x =  ANTENNA_LENGTH * math.cos(math.rad(antenna_angle)) --updates antenna's x value, based on angle
      antenna_y =  ANTENNA_LENGTH * math.sin(math.rad(antenna_angle)) --updates antenna's y value, based on angle
    end

    -- Once crank is turned, turn off crank indicator
    mobware.crankIndicator:stop()

end

--the minigame code should return its own object
return TV_Tuner
