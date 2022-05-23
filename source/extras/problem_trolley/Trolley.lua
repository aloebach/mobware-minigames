--[[
    Problem Trolley

    -- Trolley Class --

    Author: Andrew Loebach
    loebach@gmail.com

    Represents the trolley, which always charges forward with reckless abandon
    Stay clear of the tracks, for the driver shows no mercy for those unfortunate enough to stand in his way
]]

class('Trolley').extends(AnimatedSprite)

local gfx <const> = playdate.graphics

-- define trolley spritesheet and animation states
local trolley_spriteSheet = playdate.graphics.imagetable.new("extras/problem_trolley/images/Trolley")


function Trolley:new(x, y, speed)
    self = Trolley.super.new(trolley_spriteSheet)

    self:addState("straight", 1, 3, {tickStep = 2}, true)
    self:addState("angled", 4, 5, {tickStep = 2})
    self:setZIndex(2)
    self:moveTo(x, y)

    self.speed = speed or 20
    self.angled = false --variable to check trolley is angled or not
    self.track = 0 -- 0 means trolley is on top track, 1 means bottom track

    function self:update()

        --Update position of trolley
        new_x = self.x + self.speed
        new_y = new_x / 3.1 + 70 --y coordinate on upper rail
        
        --if switch is flipped when the trolly hits the junction:
        if track_angled and new_x > 100 and new_x < 115 then
            --if switch is flipped when the trolley hits the junction then switch to lower track
            self.track = 1 --mark trolley as on lower track
        end

        if new_x > 100 and new_x < 155 and self.track == 1 then 
            --if trolley is on lower track and in the bent portion of the track:
            if self.angled == false then
                self.angled = true
                self:changeState("angled")
            end
            new_y = new_x * 1.25 - 55
        else
            --if the trolley is NOT on the bent portion of the track
            if self.angled == true then
                self.angled = false
                self:changeState("straight")
            end
            new_y = new_y + self.track * 66 --shifts trolley to lower track if trolley.track == 1
            new_y = new_y - 45 --shift y value by the height of the trolley sprite
        end

        self:moveTo(new_x, new_y)
        self:updateAnimation()

    end

    return self

end
