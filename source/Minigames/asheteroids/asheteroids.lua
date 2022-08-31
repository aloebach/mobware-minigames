-- Asheteroids minigame
-- created for Mobware Minigames

-- Define minigame package
local asheteroids = {}

import 'Minigames/asheteroids/asteroid'
import 'Minigames/asheteroids/player'

local gfx = playdate.graphics

asheteroids_font = gfx.font.new('Minigames/asheteroids/font/asheteroids_white')

function hypot(x,y)
	return math.sqrt(x*x+y*y)
end

local aspeed = 2
local acount = 5

-- global variables
score = 0
player_hit = nil

local gamestate = "intro" 
mobware.AbuttonIndicator.start()
mobware.DpadIndicator.start("left","right")

function setup()
	for i = 1,5 do
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

player = Player:new()
player:moveTo(200, 120)
player:setScale(3)
player:setFillPattern({0xf0, 0xf0, 0xf0, 0xf0, 0x0f, 0x0f, 0x0f, 0x0f})
player:setStrokeColor(gfx.kColorWhite)
player.wraps = 1
player:addSprite()

setup()

gfx.setColor(gfx.kColorBlack)
gfx.fillRect(0, 0, 400, 240)
gfx.setBackgroundColor(gfx.kColorBlack)

gfx.setColor(gfx.kColorWhite)


function asheteroids.update()
	gfx.sprite.update()
	
	if player_hit then

		-- Add dramatic shake effect
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
		gfx.drawText("GAME OVER",139,100)
		playdate.wait(1500)
		return 0
	end
	
	if score >= 10 then
		local victory_text = "NEW HIGH SCORE!"
		local text_width, text_height = gfx.getTextSize(victory_text)
		local centered_x = (400 - text_width) / 2 -- this should put the minigame name in the center of the 
		gfx.drawText(score,10,10)
		gfx.drawTextAligned(victory_text,centered_x,60)
		playdate.wait(1500)		
		return 1
	end

	if gamestate == "intro" then	

		mobware.print("shoot the asteroids!", 55, 20)
		
		-- if player shoots a bullet then start game
		if playdate.buttonJustPressed("A") or playdate.buttonJustPressed("B") then
			gamestate = "play"
			mobware.AbuttonIndicator.stop()
			mobware.DpadIndicator.stop()
			gfx.setFont(asheteroids_font)
		end
		
	else
		gfx.drawText(score,10,10)
	end
	
end

local turn = 0

function asheteroids.leftButtonDown()	turn -= 1; player:turn(turn)	end
function asheteroids.leftButtonUp()	turn = 0; player:turn(turn)	end
function asheteroids.rightButtonDown()	turn += 1; player:turn(turn)	end
function asheteroids.rightButtonUp()	turn = 0; player:turn(turn)	end

-- DISABLING THRUSTER FOR MINIGAME
--function asheteroids.upButtonDown()	player:startThrust()	end
--function asheteroids.upButtonUp()		player:stopThrust()	end
function asheteroids.AButtonDown()		player:shoot()	end

function levelCleared() setup() end

-- Return minigame package
return asheteroids