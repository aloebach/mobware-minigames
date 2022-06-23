
local gfx <const> = playdate.graphics

class("Background").extends(gfx.sprite)

function Background:init()
  Background.super.init(self)

  -- create background sprite by drawing tiles onto canvas
  local canvas = gfx.image.new(400, 240)
  gfx.setLineWidth( 2 )
  gfx.lockFocus(canvas)
    gfx.drawLine( 0, 80, 400, 80)
    gfx.drawLine( 0, 160, 400, 160)	
    
    gfx.drawLine( 80, 0, 80, 240)	
    gfx.drawLine( 160, 0, 160, 240)	
    gfx.drawLine( 240, 0, 240, 240)	
    gfx.drawLine( 320, 0, 320, 240)	
  gfx.unlockFocus()

  self.x = 200
  self.y = 120
  self:moveTo(self.x, self.y)
  self:setImage(canvas)
  self:add()
end
