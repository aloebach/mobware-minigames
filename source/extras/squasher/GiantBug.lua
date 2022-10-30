import "animation"

local pd <const> = playdate
local gfx <const> = pd.graphics
local geom <const> = pd.geometry

class("GiantBug").extends(gfx.sprite)

local splat_noise = playdate.sound.sampleplayer.new('extras/squasher/sounds/splat')
local hit_noise = playdate.sound.sampleplayer.new('extras/squasher/sounds/hit')

function GiantBug:init(speed)
  GiantBug.super.init(self)

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
  self:moveTo(self.x, self.y)

  self.hp = 20
  self.speed = speed or 6.5
  self.direction = geom.vector2D.new(math.cos(math.random(0, 359)), math.sin(math.random(0, 359)))
  self:setRotation(self:getRotationDegrees())

  local GiantBugImage = gfx.imagetable.new("extras/squasher/images/bug.gif")
  self.animation = gfx.animation.loop.new(150, GiantBugImage)

  local splatImage = gfx.image.new("extras/squasher/images/splat.png")
  self.splatImage = splatImage
  self.isSquashed = false
  self.isLeaving = false
  self.inverted = 0

  self:setImage(GiantBugImage[1])
  self:setScale(6)
  --self:setCollideRect(self.width / 2, self.height / 2, self.width, self.height)
  self:setCollideRect(self.width / 4, self.height / 4, self.width/2, self.height/2)
  self:setZIndex(2)
  self:add()
end

function GiantBug:splat()

  -- play hit noise
  hit_noise:play(1)
  
  -- reduce HP
  self.hp -= 1

  -- visual effect when giant bug is hit  
  self.inverted = 10
  self.animation:image():setInverted(true)
  self:setImage(self.animation:image())
  
  if self.hp < 0 then
    -- increase score
    score += 1
    
    self.speed = 0
    self.animation = nil
    self.isSquashed = true
    self:setImage(self.splatImage)
    splat_noise:play(1)
    playdate.wait(200) -- pause briefly after squashing a GiantBug
    
    -- draw smashed GiantBug onto background and then remove sprite
    local canvas = backgroundSprite:getImage():copy()
        
    gfx.pushContext(canvas)
      self.splatImage:scaledImage(6):drawCentered(self.x, self.y)
    gfx.popContext()
    
    backgroundSprite:setImage(canvas)
    
    -- after you kill the giant bug, it spawns a bunch of smaller bugs underneath it
    for i = 1,9 do
      table.insert(bugs, Bug(10, self.x, self.y) )
    end
    
    self:remove()

  end
  
end

function GiantBug:getRotationDegrees()
  return math.deg(math.atan(self.direction.y, self.direction.x)) + 90
end

function GiantBug:isOffScreen()
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

function GiantBug:leave()
  if not self.isLeaving then
    chooseRandomDirection(self, true)
    self.isLeaving = true
  end
end

function GiantBug:update()
  if not self.isSquashed then
    --print(pd.getElapsedTime(), self.isSquashed)
    
    -- code to handle "damage" animation when giant bug is hit
    if self.inverted > 0 then
      self.inverted -= 1 -- countdown this number so that inverted effect wears off
      if self.inverted == 0 then 
        self.animation:image():setInverted(false) 
        self:setImage(self.animation:image())
      end
    else
      self.animation:image():setInverted(false) 
    end
    
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
