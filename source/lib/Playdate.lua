--[[

    -- Playdate Class --

    Author: Andrew Loebach
    loebach@gmail.com

    Represents the a playdate which will be thrown by the game's antagonist and spin off of the screen
]]

class('Playdate').extends(AnimatedSprite)

local gfx <const> = playdate.graphics

-- define Playdate spritesheet
--local playdate_spritesheet = gfx.imagetable.new("images/playdate_spinning")
--local playdate_spritesheet = gfx.imagetable.new("images/playdate_small")
local playdate_spritesheet = gfx.imagetable.new("images/playdate_XS")

function Playdate:new(x, y, speed)
    self = Playdate.super.new(playdate_spritesheet)

    -- Set up PlayDate sprite animation states			
    self:addState("animate", nil, nil, {tickStep = 2, reverse = false, loop = true}, true)
   
    -- make sprite rotate counter-clockwise if speed is negative
    if speed < 0 then
        self.states.animate.reverse = true
    end
    --self.states.animate.onAnimationEndEvent = function (self) self:remove() end -- remove sprite once animation completes
    self:setZIndex(100)
    self.x = x or 200
    self.y = y or 120
    self:moveTo(x, y)
    self.speed = speed or 20

    function self:update()

        --Update position of Playdate
        local new_x = self.x + self.speed
        
        self:moveTo(new_x, self.y)
        self:updateAnimation()
        
        -- remove sprite if it goes off screen
        if new_x > 400 + self.width /2 or new_x < -1 * self.width / 2 then
            self:remove()
        end

    end

    return self

end
