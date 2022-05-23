--[[
    Bar class
    
    Represents a Bar that blocks the player and can be moved up and down via the crank and falls back to the ground automatcially
]]

local gfx <const> = playdate.graphics
local BAR_FLOOR = 120

-- load images
local bar_image = gfx.image.new("Minigames/key_to_success/images/bar_obstacle") 
local Dpad_spritesheet = gfx.imagetable.new("Minigames/key_to_success/images/Dpad")
local width, height = bar_image:getSize()
local direction = {[1] = nil, [2] = 'up', [3] = 'left', [4] = 'down', [5] = 'right'}

class('Bar').extends(gfx.sprite)

function Bar:init(x, y, i)
    Bar.super.init(self)
    self:moveTo(x,y)
    local canvas = gfx.image.new(width, height)
    
    local rand_direction = math.random(1,5)
    self.weight = i or 1
    self.orientation = direction[rand_direction]

    -- draw Bar as filled rectangle
    gfx.lockFocus(canvas)
        -- draw bar image
        bar_image:draw(0,0) 
        -- draw direction indicator on bar
        local dpad = Dpad_spritesheet:getImage(rand_direction)
        dpad:draw(2, height/2)
    gfx.unlockFocus()
    self:setImage(canvas)
    self:add()
    self:setCollideRect(0,0,width,height)

end


-- update Bar objects every frame
function Bar:update()
    -- call parent class's update function to update sprite
    Bar.super.update(self)
    
    -- move pillar downwards if not at bottom
    if self.y < BAR_FLOOR then
        self:moveTo(self.x, math.min( self.y + self.weight, BAR_FLOOR ) )
    end 
end 
