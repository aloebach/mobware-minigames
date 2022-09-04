--[[
    Bar class
    
    Represents a Bar that blocks the player and can be moved up and down via the crank and falls back to the ground automatcially
]]

local gfx <const> = playdate.graphics
local BAR_FLOOR = 120

-- load images
local bar_image = gfx.image.new("Minigames/key_to_success/images/bar_obstacle") 
local width, height = bar_image:getSize()
--local direction = {[1] = nil, [2] = 'up', [3] = 'left', [4] = 'down', [5] = 'right'}

class('Bar').extends(gfx.sprite)

function Bar:init(x, y, i)
    Bar.super.init(self)
    self:moveTo(x,y)
    local canvas = gfx.image.new(width, height)
    
    --[[
    local rand_direction = math.random(1,5)
    self.weight = i or 1
    self.orientation = direction[rand_direction]
    ]]

    -- draw Bar
    gfx.lockFocus(canvas)
        bar_image:draw(0,0) 
    gfx.unlockFocus()
    self:setImage(canvas)
    self:add()
    self:setCollideRect(0,0,width,height)

end

