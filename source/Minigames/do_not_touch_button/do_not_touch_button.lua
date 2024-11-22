--[[
    Author: Jan van Overbeek

    Do not Touch the Button for QWarioWare

]]

-- Define name for minigame package
local do_not_touch_button = {}

local graphics <const> = playdate.graphics

-- Import the animatedImage class
local button_gif = AnimatedImage.new("Minigames/do_not_touch_button/images/button_gif", {delay = 200, loop = true, first = 1, last = 5})
local explosion_gif = AnimatedImage.new("Minigames/do_not_touch_button/images/explosion", { delay = 100, loop = false, first = 1, last = 9 })
local mission_failed = graphics.image.new("Minigames/do_not_touch_button/images/mission_failed.png")
local mission_passed = graphics.image.new("Minigames/do_not_touch_button/images/mission_passed.png")

assert(button_gif ~= nil, "Error: button_gif failed to load")
assert(explosion_gif ~= nil, "Error: explosion_gif failed to load")
assert(mission_failed ~= nil, "Error: mission_failed failed to load")
assert(mission_passed ~= nil, "Error: mission_passed failed to load")

-- Load the explosion sound
local explosion_sound = playdate.sound.sampleplayer.new('Minigames/do_not_touch_button/sounds/explosion.wav')
local mission_passed_sound = playdate.sound.sampleplayer.new('Minigames/do_not_touch_button/sounds/mission_passed.wav')
local mission_failed_sound = playdate.sound.sampleplayer.new('Minigames/do_not_touch_button/sounds/mission_failed.wav')

local explosion_playing = false

local buttonHasBeenPressed = false

local function isButtonPressed()
    local aButton = playdate.buttonIsPressed(playdate.kButtonA)
    local bButton = playdate.buttonIsPressed(playdate.kButtonB)
    local upButton = playdate.buttonIsPressed(playdate.kButtonUp)
    local downButton = playdate.buttonIsPressed(playdate.kButtonDown)
    local leftButton = playdate.buttonIsPressed(playdate.kButtonLeft)
    local rightButton = playdate.buttonIsPressed(playdate.kButtonRight)

    return aButton or bButton or upButton or downButton or leftButton or rightButton
end

-- start timer
local MAX_GAME_TIME = 5 -- define the time at 20 fps that the game will run betfore setting the "defeat" gamestate
local game_timer = playdate.frameTimer.new(MAX_GAME_TIME * 20, function() gamestate = "mission_passed" end)
--> after <MAX_GAME_TIME> seconds (at 20 fps) will move to "defeat" gamestate

-- Scale factor for the explosion gif
local explosion_scale = 2
local explosion_offset_x = 20
local explosion_offset_y = -15

function do_not_touch_button.update()
    -- Update the frameTimer, so that the game stops after x seconds
    playdate.frameTimer.updateTimers()

    if isButtonPressed() and not buttonHasBeenPressed then
        buttonHasBeenPressed = true

        explosion_sound:play()

        button_gif:reset()
        explosion_gif:reset()
        button_gif:setPaused(true)
        explosion_gif:setPaused(false)
        explosion_playing = true
    end

    -- graphics.clear(graphics.kColorWhite)

    if explosion_playing then
        explosion_gif:drawScaled(explosion_offset_x, explosion_offset_y, explosion_scale)
        if explosion_gif:getFrame() == 9 then
            explosion_playing = false
        end
    else
        button_gif:draw(0, 0)
    end

    if not explosion_playing and buttonHasBeenPressed then
        graphics.clear(graphics.kColorWhite)
        mission_failed_sound:play()
        mission_failed:draw(0, 0)
        playdate.wait(2000)
        return 0;
    end

    if gamestate == "mission_passed" then
        graphics.clear(graphics.kColorWhite)
        mission_passed_sound:play()
        mission_passed:draw(0, 0)
        playdate.wait(2100)
        return 1;
    end
end

-- Minigame package should return itself
return do_not_touch_button
