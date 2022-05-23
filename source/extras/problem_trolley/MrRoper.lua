--[[
    Problem Trolley

    -- MrRoper Class --

    Author: Andrew Loebach
    loebach@gmail.com

    Represents Mr. Roper, who is tragically tied up on the train tracks.
    I'm guessing he got into debt with the wrong people...
]]

class('MrRoper').extends(AnimatedSprite)

local gfx <const> = playdate.graphics

local MrRoper_spritesheet = gfx.imagetable.new("extras/problem_trolley/images/Mister-Roper")

function MrRoper:new(x, y, track, speed)

    local self = MrRoper.super.new(MrRoper_spritesheet)
    self:setZIndex(1)

    self:addState("alive", 1, 4, {tickStep = 3}, true)
    self:addState("smashed", 5, 10, {tickStep = 4, loop = false})
    self:moveTo(x, y)

    self.track = track or 0
    local trolley_speed = speed or 10
    self.smashed = false --variable to check if victim has been smashed or not
    
    
    -- Expects a object as an argument and returns true if said object is about to run them over, and false otherwise 
    function self:collides(object)
        -- check if victim is already smashed
        if self.smashed == true then
            return false 
        end
        -- check the x-axis to see if the trolley has gotten to where poor Mr. Roper is 
        if self.x > (object.x + object.width / 2) then
            return false
        end
        -- check to see if Mr. Roper is on the same track as the object
        if self.track ~= object.track then
            return false
        end 
        -- if none of the above statements are true, then it's bad news for Mr. Roper
        self:changeState("smashed")
        splat_noise:play(1)
        
        return true
    end

    return self

end

