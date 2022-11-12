--[[
  TV Tuner
  Minigame for Mobware Minigames

  Author: Andrew Loebach
]]

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

local GAME_TIME_LIMIT = 7 -- player has 7 seconds at 20fps

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

-- if tv static files have already been generated, then load the images from the playdate's memory:
if playdate.file.isdir("tv_static") then
  -- read images from disk and load into spritesheet
  for _i = 1, 10 do
    tv_static.spriteSheet[_i] = playdate.datastore.readImage( "tv_static/" .. _i)
  end
  
else
  -- if the tv_static images aren't found in memory, then we generate them here:
  print("no image files found for TV static. Generating...")
  for _i = 1, 10 do
    tv_static.spriteSheet[_i] = generate_static(_i)
    playdate.datastore.writeImage(tv_static.spriteSheet[_i], "tv_static/" .. _i )
  end
  print("tv_static files written to disk")
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
local oh_yeah = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/oh_yeah')
local snap_sound = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/snap')

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
local noise_frequency = math.floor( math.max( 10 - math.abs((antenna_angle - reception_angle) / 2), 1 ) )
local has_reception_counter = 0
local game_counter = 0 

-- Used to calculate dt, since I ported this from the Love2D framework
local dt = 1 / 20 -- setting a static dt value will mean the player has less time as FPS increases

gamestate = 'play'

-- instantiate timer that will end game after GAME_TIME_LIMIT is reached
local game_timer = playdate.frameTimer.new( GAME_TIME_LIMIT * 20, 
  function() 
      
    game_counter = 0 --reset game counter so we can use it for the victory/defeat animation

    -- check one last time if the player is in the sweet spot:
    if math.abs(antenna_angle - reception_angle) < 2 then -- get reception if you're under 2 degrees from correct angle
      tv_static:remove() --      :setVisible(flag)      
      gamestate = 'victory'
      thumb_image:addSprite()  --clear TV screen of static
      tv_static:remove()
      static_noise:stop()
      oh_yeah:play(1)  -- play victory sound
        
    else
      gamestate = "defeat" 
      
      -- If time runs out and antenna isn't in the sweet spot, then the player loses    
      snap_sound:play(1)
      static_noise:setVolume( 15 / 100 ) -- set static to hi volume 
      noise_frequency = 1
      
      -- recalculate antenna values to display broken antenna
      antenna_x =  ANTENNA_LENGTH/2 * math.cos(math.rad(antenna_angle)) --updates antenna's x value, based on angle
      antenna_y =  ANTENNA_LENGTH/2 * math.sin(math.rad(antenna_angle)) --updates antenna's y value, based on angle
            
    end
  end ) --runs for 6 seconds at 20fps, and 3 seconds at 40fps

-- Start crank indicator animation
mobware.crankIndicator.start()


function TV_Tuner.update()

  -- update timer
  playdate.frameTimer.updateTimers()

  -- Generate static shown on TV
  tv_static:setImage(tv_static.spriteSheet[noise_frequency])
  local random_x_offset = math.random( 0, TV_WIDTH )
  local random_y_offset = math.random( 0, TV_HEIGHT )
  tv_static:setBounds(TV_SCREEN_LEFT - random_x_offset, TV_SCREEN_TOP - random_y_offset, TV_WIDTH * 2, TV_HEIGHT * 2)

  if gamestate == 'play' then
    
    --> noise_frequency will decrease down to 1 (most static) if far away from the reception angle, and increase when close to reception angle
    noise_frequency = math.floor( math.max( 10 - math.abs((antenna_angle - reception_angle) / 2), 1 ) )

    -- Update volume of static noise based on amount of static
    static_noise:setVolume((10 - noise_frequency) / 100 ) 

    -- win condition
    if math.abs(antenna_angle - reception_angle) < 2 then -- get reception if you're under 2 degrees from correct angle
      has_reception_counter = has_reception_counter + dt
      tv_static:remove() --      :setVisible(flag)
      
      --player wins game if they hold reception for 1 second
      if has_reception_counter >= 1 then 
        gamestate = 'victory'
        game_counter = 0 --reset game counter so we can use it for the victory animation
        thumb_image:addSprite()  --clear TV screen of static
        tv_static:remove()
        static_noise:stop()
        -- play victory sound
        oh_yeah:play(1)
      end
    else
      has_reception_counter = 0
      tv_static:add()
    end


  elseif gamestate == 'victory' then
    if game_counter >= 1.5 then return 1 end --end game after 2s of victory animation
    thumb_image:moveTo( thumb_image.x , thumb_image.y - 1)


  elseif gamestate == 'defeat' then
    if game_counter >= 2 then return 0 end --end game after 2s of defeat animation
    
  end

  --increase game counter
  game_counter = game_counter + dt

  -- Rendering code
  gfx.sprite.update() -- updates all sprites

  --draw antennas
  gfx.drawLine( 207, 50, 165, 10)   --left antenna
  gfx.drawLine( 207, 50, 207 + antenna_x, 50 - antenna_y)  --right antenna
  -- draw broken antenna in defeat gamestate:
  if gamestate == "defeat" then gfx.drawLine( 207 + antenna_x, 50 - antenna_y, 207 + 2*antenna_x, 50 + antenna_y )  end

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
