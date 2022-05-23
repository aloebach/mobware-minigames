--[[
    Problem Trolley

    -- Ralph Class --

    Author: Andrew Loebach
    loebach@gmail.com

    Represents Ralph, who switches the tracks back and forth

    Also, i'm using this same class to animate the tracks, since it completely matches up with the animation 
    of Ralph flipping the switch... and I'm lazy    
]]

local gfx <const> = playdate.graphics

-- loading spritesheets
ralph_spriteSheet = gfx.imagetable.new("Minigames/problem_trolley/images/Ralph")
victory_spriteSheet = gfx.imagetable.new("Minigames/problem_trolley/images/Ralph_victory")
defeat_spriteSheet = gfx.imagetable.new("Minigames/problem_trolley/images/Ralph_defeated")
switch_spriteSheet = playdate.graphics.imagetable.new("Minigames/problem_trolley/images/track_switch")

victory_start_frame = 1
victory_end_frame = victory_spriteSheet:getLength()
defeat_start_frame = 1
defeat_end_frame = defeat_spriteSheet:getLength()

--Ralph = Class{}
--class('Ralph').extends(AnimatedSprite)
class('Ralph').extends(playdate.graphics.sprite)

function Ralph:new()
    self =  Ralph.super.new(ralph_spriteSheet)
    self.frame = 1 -- keep track of the frame number for animation
    self.num_animation_frames = ralph_spriteSheet:getLength()
    self:moveTo(200, 50)
    self:add()
    
    -- initialize track junction sprite
    junction_sprite = gfx.sprite.new(switch_spriteSheet)
    junction_sprite:moveTo(108,93)
    junction_sprite:add()

    function self:update()
        if gamestate == 'play' then
            -- update tracks based on crank position
            local crank_position = playdate.getCrankPosition()
            if crank_position > 90 and crank_position < 270 then
                -- crank is pointing down
                self.frame += 1
                -- if the animation is completed: 
                if self.frame >= self.num_animation_frames then 
                    self.frame = self.num_animation_frames
                    track_angled = true
                end   
                
            else
                -- crank is pointing up
                self.frame -= 1
                -- if the animation is completed: 
                if self.frame <= 1 then 
                    self.frame = 1
                    track_angled = false
                end          
                
            end     
            
            -- update sprite with animation frame 
            self:setImage(ralph_spriteSheet:getImage(self.frame))
            
            -- update track junction sprite with animation frame
            junction_sprite:setImage(switch_spriteSheet:getImage(self.frame))
           
        -- animate Ralph for victory
        elseif gamestate == 'victory' then 
            --play Ralph's victory animation
            self.frame += 1
            if self.frame > victory_end_frame then
                self.frame = victory_end_frame
            end
            self:setImage(victory_spriteSheet:getImage(self.frame))
            
        -- animate Ralph for defeat
        elseif gamestate == 'defeat' then 
            --play ralph's defeat animation
            self.frame += 1
            if self.frame > defeat_end_frame then
                self.frame = defeat_end_frame
            end
            --self.defeat_currentTime = self.defeat_currentTime + dt
            self:setImage(defeat_spriteSheet:getImage(self.frame))
        end
        
    end
    
    return self

end






