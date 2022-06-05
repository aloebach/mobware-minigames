local pd <const> = playdate
local gfx <const> = pd.graphics
local geom <const> = pd.geometry

class("Target").extends(gfx.sprite)

function Target:init()
  Target.super.init(self)
  self.x = 200
  self.y = 120
  self:moveTo(self.x, self.y)

  self.speed = 7
  self.canMove = true

  self:setImage(gfx.image.new("Minigames/squasher/images/target"))
  self:setCollideRect(self.width / 3 + 1, self.height / 3 + 1, self.width / 3, self.height / 3)
  self:add()
end

function Target:squash()
  if #self:overlappingSprites() > 0 then
    print("squashing")
    self:overlappingSprites()[1]:splat()
  end
end

function Target:stop()
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

  if a or b then
    self:squash()
  end
end

function Target:update()
  if self.canMove then
    userInput(self)
  end
end
