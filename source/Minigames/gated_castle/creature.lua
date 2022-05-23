local gfx = playdate.graphics

Creature = {}
Creature._index = Creature

function Creature:new(x, y, speed, sprite_sheet, total_frames, collision_width, collision_height)
    local image_table = gfx.imagetable.new(sprite_sheet, 20)
    local self = AnimatedSprite.new(image_table)
    self:addState("animate", nil, nil, {tickStep = 4}, true)
    collision_width = collision_width or self.width
    collision_height = collision_height or self.height
    local frame_num = 1
    self:setImage(image_table:getImage(frame_num))
    self:moveTo(x, y)
    self:addSprite()
    self.frame = 1
    self.total_frames = total_frames
    self.speed = speed
    self:setCollideRect(0, 0, collision_width, collision_height)
    self:setZIndex(1000)

        function self:update()
            self:moveWithCollisions(self.x + self.speed, self.y)
            self:updateAnimation()
        end

        function self:collisionResponse(other)
            return gfx.sprite.kCollisionTypeOverlap
        end
end