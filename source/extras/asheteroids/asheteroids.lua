-- Define minigame package
local asheteroids = {}

import 'extras/asheteroids/asteroid'
import 'extras/asheteroids/player'

local gfx = playdate.graphics

playdate.display.setRefreshRate( 20 )

asheteroids_font = gfx.font.new('extras/asheteroids/font/asheteroids_white')
gfx.setFont(asheteroids_font)

function hypot(x,y)
	return math.sqrt(x*x+y*y)
end

local aspeed = 3
local acount = 5
score = 0
player_hit = nil

local gamestate = "intro" 

function setup_asteroids()
	
	for i = 1,5 do
	--for i = 1,2 do
		a = Asteroid:new()
		
		local x,y,dx,dy
		
		repeat
			x,y = math.random(400), math.random(240)
			dx,dy = aspeed * (2*math.random() - 1), aspeed * (2*math.random() - 1)
		until hypot(x+10*dx-200, y+10*dy-120) > 100
		
		a:moveTo(x,y)
		a:setVelocity(dx, dy, math.random(100) / 200.0 - 0.25)
		a:addSprite()
	end

end

function setup_player()
	
	player = Player:new()
	player:moveTo(200, 120)
	player:setScale(3)
	player:setFillPattern({0xf0, 0xf0, 0xf0, 0xf0, 0x0f, 0x0f, 0x0f, 0x0f})
	player:setStrokeColor(gfx.kColorWhite)
	player.wraps = 1
	player:addSprite()

end

function setup()
	setup_asteroids()
	setup_player()
end


setup()


gfx.setColor(gfx.kColorBlack)
gfx.fillRect(0, 0, 400, 240)
gfx.setBackgroundColor(gfx.kColorBlack)
gfx.setColor(gfx.kColorWhite)


function asheteroids.update()
	gfx.sprite.update()
	
	if player_hit then
		-- dramatic shake effect
		local frame_counter = 0
		while frame_counter < 20 do
			random_shake_x = math.random(-6,6)
			random_shake_y = math.random(-6,6)
			playdate.display.setOffset(random_shake_x, random_shake_y)
			frame_counter += 1
			playdate.wait(0.05)
		end
		-- once frame counter hits its threshold reset screen and return 0 
		playdate.display.setOffset(0,0)
		
		-- remove sprites on screen
		gfx.sprite.removeAll()
		
		-- after player hits a button...
		score = 0
		player_hit = nil
		setup()
		
	end

	--[[
	if gamestate == "intro" then	
		
		-- if player shoots a bullet then start game
		if playdate.buttonJustPressed("A") or playdate.buttonJustPressed("B") then
			setup()
			gamestate = "play"
			mobware.AbuttonIndicator.stop()
			gfx.setFont(asheteroids_font)
		end
		
	else
		
	end
	]]
	gfx.drawText(score,10,10)
	
end

local turn = 0

function asheteroids.leftButtonDown()	turn -= 1; player:turn(turn)	end
function asheteroids.leftButtonUp()	turn = 0; player:turn(turn)	end
function asheteroids.rightButtonDown()	turn += 1; player:turn(turn)	end
function asheteroids.rightButtonUp()	turn = 0; player:turn(turn)	end

function asheteroids.upButtonDown()	player:startThrust()	end
function asheteroids.upButtonUp()		player:stopThrust()	end
function asheteroids.AButtonDown()		player:shoot()	end
--function asheteroids.BButtonDown()		player:shoot()	end

--function levelCleared() setup() end
function levelCleared() 
	print("LEVEL CLEAR!")
	setup_asteroids() 
end


-- Return minigame package
return asheteroids