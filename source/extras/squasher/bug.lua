import "animation"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geom <const> = pd.geometry

class("Bug").extends(gfx.sprite)

local splat_noise = playdate.sound.sampleplayer.new('extras/squasher/sounds/splat')

function Bug:init(speed, initial_x, initial_y)
  Bug.super.init(self)
  --self.x = math.random(20, 380)
  local random_num = math.random()
  if random_num >0.5 then
    self.x = 0
    self.direction = geom.vector2D.new(math.cos(math.random(0, 89)), math.sin(math.random(0, 359)))
  else
    self.x = 400
    self.direction = geom.vector2D.new(math.cos(math.random(91, 180)), math.sin(math.random(0, 359)))
  end
  --self.x = math.random(20, 380)
  self.y = math.random(20, 220)
  
  if initial_x and initial_y then
    self:moveTo(initial_x, initial_y)
  else
    self:moveTo(self.x, self.y)
  end

  self.width = 20
  self.height = 20

  self.speed = speed or 6.5
  self.direction = geom.vector2D.new(math.cos(math.random(0, 359)), math.sin(math.random(0, 359)))
  self:setRotation(self:getRotationDegrees())

  local bugImage = gfx.imagetable.new("extras/squasher/images/bug.gif")
  self.animation = gfx.animation.loop.new(150, bugImage)

  local splatImage = gfx.image.new("extras/squasher/images/splat.png")
  self.splatImage = splatImage
  self.isSquashed = false

  self.isLeaving = false

  self:setScale(2)
  self:setImage(bugImage[1])

  --self:setCollideRect(self.width / 2, self.height / 2, self.width, self.height)
  self:setCollideRect(self.width / 4, self.height / 4, self.width/2, self.height/2)
  self:setZIndex(4)
  self:add()
end

function Bug:splat()

  -- increase score
  score += 1
  
  self.speed = 0
  self.animation = nil
  self.isSquashed = true
  self:setImage(self.splatImage)
  splat_noise:play(1)
  playdate.wait(200) -- pause briefly after squashing a bug
  
  -- draw smashed bug onto background and then remove sprite
  local canvas = backgroundSprite:getImage():copy()
      
  gfx.pushContext(canvas)
    self.splatImage:scaledImage(2):drawCentered(self.x, self.y)
  gfx.popContext()
  
  backgroundSprite:setImage(canvas)
  self:remove()
  
end

function Bug:getRotationDegrees()
  return math.deg(math.atan(self.direction.y, self.direction.x)) + 90
end

function Bug:isOffScreen()
  if (self.x < 0 - self.width or self.x > 400 + self.width or self.y < 0 - self.height or self.y > 240 + self.height) then
    return true
  end

  return false
end

local function keepInBounds(self)
  if self.x < 0 + self.width / 2 then
    self.x = 0 + self.width / 2
    self.direction.x = math.cos(math.random(1, 179))
    self:moveTo(self.x, self.y)
  end
  if self.x > 400 - self.width / 2 then
    self.x = 400 - self.width / 2
    self.direction.x = math.cos(math.random(181, 359))
    self:moveTo(self.x, self.y)
  end
  if self.y < 0 + self.height / 2 then
    self.y = 0 + self.height / 2
    self.direction.y = math.sin(math.random(91, 269))
    self:moveTo(self.x, self.y)
  end
  if self.y > 240 - self.height / 2 then
    self.y = 240 - self.height / 2
    self.direction.y = math.sin(math.random(271, 359))
    self:moveTo(self.x, self.y)
  end

  self.direction:normalize()
end

local function chooseRandomDirection(self, force)
  -- choose a random direction x% this is called
  local percentage = 5
  if force or math.random() < percentage / 100 then
    self.direction = geom.vector2D.new(math.cos(math.random(0, 359)), math.sin(math.random(0, 359)))
    self.direction:normalize()
  end
end

function Bug:leave()
  if not self.isLeaving then
    chooseRandomDirection(self, true)
    self.isLeaving = true
  end
end

function Bug:update()
  if not self.isSquashed then
    --print(pd.getElapsedTime(), self.isSquashed)
    if self.animation then
      self:setImage(self.animation:image())
    end

    if (not self.isLeaving) then
      keepInBounds(self)
      chooseRandomDirection(self)
    end

    self:moveBy(self.speed * self.direction.x, self.speed * self.direction.y)
    self:setRotation(self:getRotationDegrees())
  end
end
