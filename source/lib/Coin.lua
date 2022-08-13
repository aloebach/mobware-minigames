--[[

    -- Coin Class --

    Author: Andrew Loebach
    loebach@gmail.com

    Represents the a coin which will be displayed when the antagonist profits from microtransactions
]]

class('Coin').extends(AnimatedSprite)

local gfx <const> = playdate.graphics

-- define coin spritesheet
local coin_spritesheet = gfx.imagetable.new("images/coin")

function Coin:new(x, y)
    self = Coin.super.new(coin_spritesheet)
    
    -- Set up Coin sprite animation states			
    self:addState("animate", nil, nil, {tickStep = 1, loop = 2,
        onAnimationEndEvent = function (self) self.animation_finished = true end 
        }, true)

    self:setZIndex(100)
    self.x = x
    self.y = y
    self:moveTo(x, y)
    
    function self:update()
    
        self:updateAnimation()
        
        -- remove sprite if animation is finished
        if self.animation_finished then self:remove() end
    
    end

    return self

end
