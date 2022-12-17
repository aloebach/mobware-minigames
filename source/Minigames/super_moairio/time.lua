
class('Time').extends(playdate.graphics.sprite)

local gfx = playdate.graphics

-- load assets to be used to display time
local font = gfx.font.new('Minigames/super_moairio/img/SMB')
local clock_image = gfx.image.new('Minigames/super_moairio/img/clock_icon')

function Time:init(initial_time)
	
	Time.super.init(self)

	self.font = playdate.graphics.font.new('Minigames/super_moairio/img/SMB')
	self.time = initial_time or 0
	self.fps = playdate.display.getRefreshRate()
	self.frameCounter = 0
	
	self:setZIndex(900)
	self:setIgnoresDrawOffset(true)
	self:setCenter(0, 0)
	self:setSize(65, 20)
	self:moveTo(330, 10)
end

function Time:updateGameTime()
	self.frameCounter += 1
	
	-- once one second has elapsed decrease time
	if self.time >= 0 and self.frameCounter >= self.fps then
		self.frameCounter = 0
		self.time -= 1
		
		-- speed up music for last 10 seconds
		if self.time == 10 then
			SoundManager:speedUpBackgroundMusic()
		end
		
		-- tell game to end if time is below zero
		if self.time < 0 then 
			
			self.time = 0
			
			-- add sprite to display "TIME UP!" on screen after time expires
			local text = "TIME UP!"
			local time_up_sprite = gfx.sprite.new()
			local window_width, window_height = gfx.getTextSizeForMaxWidth(text, 400)
			local canvas = gfx.image.new(window_width+4, window_height+4)			
			gfx.lockFocus(canvas)
				gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
				gfx.drawText(text, 0, 0)
				gfx.setImageDrawMode("copy")
				gfx.drawText(text, 2, 2)
			gfx.unlockFocus()
			time_up_sprite:setImage(canvas)
			time_up_sprite:setIgnoresDrawOffset(true)
			time_up_sprite:moveTo(200, 100)
			time_up_sprite:setZIndex(900)
			time_up_sprite:add()
			
			return 1 
			
		else
			self:markDirty()

		end		
		
	end
end

function Time:draw()
	clock_image:draw(0,0)
	gfx.setFont(self.font)
	gfx.drawText(tostring(self.time), 16, 1)
end
