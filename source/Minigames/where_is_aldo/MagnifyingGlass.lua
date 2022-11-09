local pd <const> = playdate
local gfx <const> = pd.graphics
local geom <const> = pd.geometry

class("MagnifyingGlass").extends(gfx.sprite)

local magnifying_glass_image = gfx.image.new("Minigames/where_is_aldo/images/magnifying-glass")

function MagnifyingGlass:init()
  MagnifyingGlass.super.init(self)
  self.x = 200
  self.y = 120
  self:moveTo(self.x, self.y)

  self.speed = 7
  self.canMove = true

  self:setImage(magnifying_glass_image)
  -- TO-DO: update collision rect to match up with center of magnifying glass
  self:setCollideRect(self.width * 0.33, self.height * 0.33, self.width * 0.33, self.height * 0.33)
  self:setZIndex(300)
  self:add()
end


function MagnifyingGlass:stop()
  self.canMove = false
end

local function keepInBounds(self)
  if self.x < 0 then
    self.x = 0
    self:moveTo(self.x, self.y)
  end
  if self.x > 400 then
    self.x = 400
    self:moveTo(self.x, self.y)
  end
  if self.y < 0 then
    self.y = 0
    self:moveTo(self.x, self.y)
  end
  if self.y > 240 then
    self.y = 240
    self:moveTo(self.x, self.y)
  end
end

local function userInput(self)
  local left = pd.buttonIsPressed(pd.kButtonLeft)
  local right = pd.buttonIsPressed(pd.kButtonRight)
  local up = pd.buttonIsPressed(pd.kButtonUp)
  local down = pd.buttonIsPressed(pd.kButtonDown)
  local a = pd.buttonJustPressed(pd.kButtonA)
  local b = pd.buttonJustPressed(pd.kButtonB)

  -- only allow player to move the MagnifyingGlass if A or B aren't held down
  if playdate.buttonIsPressed(pd.kButtonA) == false and playdate.buttonIsPressed(pd.kButtonB) == false then
    if left then
      self:moveBy(-self.speed, 0)
    end
    if right then
      self:moveBy(self.speed, 0)
    end
    if up then
      self:moveBy(0, -self.speed)
    end
    if down then
      self:moveBy(0, self.speed)
    end
  
    if left or right or up or down then
      keepInBounds(self)
    end
  end

  if a or b then

    -- zoom in on what's under the magnifying glass
    self:setScale(2)
    --self:setCollideRect(self.width / 4, self.height / 4, self.width / 2 + 1, self.height / 2 + 1)
    self:setCollideRect(self.width * 0.4, self.height *0.4, self.width *0.2 + 1, self.height * 0.2 + 1)
    
  end
  
  -- change back to standard magnifying_glass_image when A or B button is released
  if playdate.buttonJustReleased(pd.kButtonA) or playdate.buttonJustReleased(pd.kButtonB) then
    self:setScale(1)
    self:setCenter(0.5, 0.5)
    self:setCollideRect(self.width / 4, self.height / 4, self.width / 2 + 1, self.height / 2 + 1)
  end
  
end

function MagnifyingGlass:update()
  if self.canMove then
    userInput(self)
  end
  if a or b then
	  background_image:draw(0, 0)
  end
end
