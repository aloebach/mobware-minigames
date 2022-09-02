-- Define minigame package
local asheteroids = {}

import 'extras/asheteroids/asteroid'
import 'extras/asheteroids/player'

local gfx = playdate.graphics

playdate.display.setRefreshRate( 30 )

-- initialize font
local asheteroids_font = gfx.font.new('extras/asheteroids/font/asheteroids_white')
gfx.setFont(asheteroids_font)

function hypot(x,y)
	return math.sqrt(x*x+y*y)
end

-- local variables
local aspeed = 2
local lives = 3
local new_hi_score

local STARTING_NUM_OF_ASTEROIDS = 5
local number_of_asteroids = STARTING_NUM_OF_ASTEROIDS

-- global variables
score = 0
gamestate = "play" 

-- reading high score from memory
local _status, data_read = pcall(playdate.datastore.read, "asheteroids_data")
if data_read then 
	hi_score = data_read["hi_score"]
else
	hi_score = 0
end

function setup_lives()
	-- icons showing player's lives
	local lives_icon = gfx.image.new("extras/asheteroids/images/1up")
	life1 = gfx.sprite.new(lives_icon)
	life1:add()
	life1:moveTo(20, 40) -- display in upper left corner
	
	life2 = gfx.sprite.new(lives_icon)
	life2:add()
	life2:moveTo(36, 40) -- display in upper left corner
	
	life3 = gfx.sprite.new(lives_icon)
	life3:add()
	life3:moveTo(52, 40) -- display in upper left corner
end


function setup_asteroids()
	
	asteroidCount = 0
	
	for i = 1,number_of_asteroids do
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
	-- remove existing sprites on screen
	gfx.sprite.removeAll()
	
	-- reset the number of asteroids to spawn
	number_of_asteroids = STARTING_NUM_OF_ASTEROIDS
	
	setup_asteroids()
	setup_player()
	setup_lives()
	
	if lives < 1 then life1:setVisible(false) end
	if lives < 2 then life2:setVisible(false) end
	if lives < 3 then life3:setVisible(false) end
end


setup()

gfx.setColor(gfx.kColorBlack)
gfx.fillRect(0, 0, 400, 240)
gfx.setBackgroundColor(gfx.kColorBlack)
gfx.setColor(gfx.kColorWhite)


function asheteroids.update()
	
	gfx.sprite.update()
	
	if gamestate == "player_hit" then
		
		-- dramatic shake effect when player is hit
		local frame_counter = 0
		while frame_counter < 20 do
			local random_shake_x = math.random(-6,6)
			local random_shake_y = math.random(-6,6)
			playdate.display.setOffset(random_shake_x, random_shake_y)
			frame_counter += 1
			playdate.wait(0.05)
		end
		playdate.display.setOffset(0,0)
		playdate.wait(500)
		
		lives -= 1
		
		if lives <= 0 then 
			gamestate = "game_over"
			life1:setVisible(false) 
			player.thrust[1]:remove()
			player.thrust[2]:remove()
			player:remove()
			
			if score > hi_score then
				print("new hi score!")
				hi_score = score
				new_hi_score = true

				-- save hi score to disc
				local hi_score_table = {hi_score = hi_score}
				playdate.datastore.write(hi_score_table, "asheteroids_data")
			else
				new_hi_score = nil
			end
			
		else
			gamestate = "play" 

			-- reset player
			player:remove()
			player.thrust[1]:remove()
			player.thrust[2]:remove()
			setup_player()
			player.invincibility = 40
			
			-- update player's lives in UI
			if lives < 1 then life1:setVisible(false) end
			if lives < 2 then life2:setVisible(false) end
			if lives < 3 then life3:setVisible(false) end
		end
		
	elseif gamestate == "game_over" then
		gfx.drawText("GAME OVER",139,100)
		gfx.drawTextAligned("HIGH SCORE " .. hi_score ,200, 10, kTextAlignment.center)
		if new_hi_score then gfx.drawTextAligned("NEW HIGH SCORE!",200, 35, kTextAlignment.center) end
		
		if playdate.buttonIsPressed("B") then 
			lives = 3
			life1:setVisible(true)
			life2:setVisible(true)
			life3:setVisible(true)
			score = 0
			gamestate = "play"
			setup() 
		end
	end
	
	gfx.drawText(score,10,10)
	
end

local turn = 0

function asheteroids.leftButtonDown()	turn -= 1; player:turn(turn)	end
function asheteroids.leftButtonUp()	turn = 0; player:turn(turn)	end
function asheteroids.rightButtonDown()	turn += 1; player:turn(turn)	end
function asheteroids.rightButtonUp()	turn = 0; player:turn(turn)	end

function asheteroids.upButtonDown()	if gamestate == "play" then player:startThrust() end end
function asheteroids.upButtonUp()		player:stopThrust()	end
function asheteroids.AButtonDown()	if gamestate == "play" then player:shoot() end end

function levelCleared() 
	print("LEVEL CLEAR!")
	player.invincibility = 40
	number_of_asteroids += 1 -- increase difficulty by spawning more astroids with each level
	setup_asteroids() 
end

-- Return minigame package
return asheteroids