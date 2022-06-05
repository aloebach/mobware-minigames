
--[[
	Author: Zachary Snyder

	voyage_phaser for Mobware Minigames

	feel free to search and replace "voyage_phaser" in this code with your minigame's name,
	rename the file <your_minigame>.lua, and rename the folder to the same name to get started on your own minigame!
]]


--[[ NOTE: The following libraries are already imported in main.lua, so there's no need to define them in the minigame
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer" 
import "CoreLibs/nineslice"
import "CoreLibs/ui"
import "CoreLibs/crank"
import "CoreLibs/easing"
]]

-- Import any supporting libraries from minigame's folder
	--> Note that all supporting files should be located under 'Minigames/voyage_phaser/''
--import 'Minigames/voyage_phaser/lib/AnimatedSprite' 


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
voyage_phaser = {}


-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

-- animation for on-screen Playdate sprite
--playdate_image_table = gfx.imagetable.new("Minigames/voyage_phaser/images/playdate")
--low_battery_image_table = gfx.imagetable.new("Minigames/voyage_phaser/images/playdate_low_battery")
--pd_sprite = gfx.sprite.new(image_table)

local enemysprite = gfx.image.new("Minigames/voyage_phaser/images/enemydrone")
local planetnum = math.random(1,4)
local planet = gfx.image.new("Minigames/voyage_phaser/images/planet"..planetnum)

local shipnum = math.random(1,4)
local shipfull = gfx.image.new("Minigames/voyage_phaser/images/ship"..shipnum)

-- update sprite's frame so that the sprite will reflect the crank's actual position
local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device

--> Initialize music / sound effects
--local click_noise = playdate.sound.sampleplayer.new('Minigames/voyage_phaser/sounds/click')
local die_noise = playdate.sound.sampleplayer.new('Minigames/voyage_phaser/sounds/dronedie')
local phaser_noise = playdate.sound.sampleplayer.new('Minigames/voyage_phaser/sounds/phaser')
phaser_noise:play(0)

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- start timer	 
MAX_GAME_TIME = 6 -- define the time at 20 fps that the game will run betfore setting the "defeat"gamestate
game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() 
	gamestate = "defeat"
	phaser_noise:stop(0)

end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "defeat" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame


-- set initial gamestate and start prompt for player to hit the B button
gamestate = 'shooting'

mobware.crankIndicator.start()

local animtime = 0

local enemies = {}
for i=1, 4 do
	enemies[i] = {}
	local r = (math.random() * 32) + 128
	local a = math.random() * 2 * math.pi
	enemies[i].x = r * math.cos(a)
	enemies[i].y = r * math.sin(a)
	enemies[i].h = 1
end

local particles = {}

local stars = {}
for i=1, 100 do
	stars[i] = {}
	stars[i].x = math.random() * 400
	stars[i].y = math.random() * 240
end

local shake = {}
shake.x = 0
shake.y = 0
shake.p = 0

local showcrank = true


--[[
	function <minigame name>.update()

	This function is what will be called every frame to run the minigame. 
	NOTE: The main game will initially set the framerate to call this at 20 FPS to start, and will gradually speed up to 40 FPS
]]
function voyage_phaser.update()

	-- updates all sprites

	-- update timer
	playdate.frameTimer.updateTimers()
	--print('Time:', game_timer.frame)

	animtime += 1

	if gamestate == 'shooting' then

		for i, e in ipairs(enemies) do
			local offsetx = 0-e.x
			local offsety = 0-e.y
			local mag = math.sqrt(offsetx * offsetx + offsety * offsety)
			local movex = offsetx/mag
			local movey = offsety/mag

			--shake stuff
			if(shake.p > 0)then
				shake.p *= 0.9
				shake.x = (math.random()-0.5) * shake.p
				shake.y = (math.random()-0.5) * shake.p
			else
				shake.p = 0
				shake.x = 0
				shake.y = 0
			end

			e.x += movex
			e.y += movey

			--phaser stuff

			if voyage_phaser.phasercheck(e.x, e.y, 8) == true then
				e.h -= 0.1
				--print("hit")
			end

			if(e.h <= 0)then
				--drone die
				table.remove(enemies, i)

				die_noise:play(1)

				shake.p += 16

				--particles
				local numparticles = 16
				for i=1, numparticles do
					local newp = {}
					newp.x = e.x + ((math.random()-0.5) * 16)
					newp.y = e.y + ((math.random()-0.5) * 16)
					newp.vx = (math.random()-0.5) * 4
					newp.vy = (math.random()-0.5) * 4

					table.insert(particles,newp)
				end

				if #enemies == 0 then
					gamestate = 'victory'
					phaser_noise:stop(0)
				end
			end
		end

		for i, p in ipairs(particles) do
			p.x += p.vx
			p.y += p.vy
		end

		voyage_phaser.draw()

	elseif gamestate == 'victory' then
		-- The "victory" gamestate will simply show the victory animation and then end the minigame

		voyage_phaser.draw()
		gfx.setDrawOffset(0,0)

		-- display image indicating the player has won
		mobware.print("you lived!",100, 32)

		playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- returning 1 will end the game and indicate the the player has won the minigame
		return 1


	elseif gamestate == 'defeat' then

		voyage_phaser.draw()
		gfx.setDrawOffset(0,0)

		mobware.print("you died!",100, 32)

		-- wait another 2 seconds then exit
		playdate.wait(2000)	-- Pause 2s before ending the minigame

		-- return 0 to indicate that the player has lost and exit the minigame 
		return 0

	end

end

function voyage_phaser.phasercheck(targetx, targety, targetradius)
  local hiterror = (math.atan((targetradius+4)/voyage_phaser.distance(0,0,targetx,targety)))

  local testangle = math.atan2(targety-0, targetx-0) + (math.pi/2)

  local crank_position_rad = (playdate.getCrankPosition()) * 0.0174533
  local testoffset = voyage_phaser.smallestRadDiff(testangle,crank_position_rad)

  --check if the max angle is met
  if(math.abs(testoffset) < hiterror)then
    return true
  else
    return false
  end

end

function voyage_phaser.distance ( x1, y1, x2, y2 )
	local dx = x1 - x2
	local dy = y1 - y2
	return math.sqrt ( dx * dx + dy * dy )
end

function voyage_phaser.smallestRadDiff(target, source)
   local a = target - source
   
   if (a > math.pi) then
      a = a - 2*math.pi
   elseif (a < -math.pi) then
      a = a + 2*math.pi
   end
   
   return a
end

function voyage_phaser.draw()

	gfx.sprite.update()

	gfx.clear(gfx.kColorBlack)

	gfx.setDrawOffset(shake.x,shake.y)
	gfx.setColor(gfx.kColorWhite)
	for i=1, #stars do
		local s = stars[i]
		gfx.drawPixel(s.x, s.y)
	end

	planet:draw(240,120)

	gfx.setDrawOffset(200 + shake.x,120 + shake.y)

	local crank_position = (playdate.getCrankPosition()-90)
	local crank_position_rad = (playdate.getCrankPosition()-90) * 0.0174533
	local r1 = 32
	local x1 = r1 * math.cos(crank_position_rad)
	local y1 = r1 * math.sin(crank_position_rad)
	local x2 = x1 * 8
	local y2 = y1 * 8

	shipfull:drawRotated(0,0,crank_position,0.5,0.5)
	gfx.setColor(gfx.kColorWhite)

	local rad = 4 + math.sin(animtime * 1)
	gfx.setLineWidth(rad)
	gfx.fillCircleAtPoint(x1,y1,rad)
	gfx.drawLine(x1,y1,x2,y2)

	for i=1, #enemies do
		e = enemies[i]
		enemysprite:draw(e.x - 8, e.y - 8)
	end

	for i=1, #particles do
		local p = particles[i]
		gfx.drawPixel(p.x,p.y)
		--gfx.fillCircleAtPoint(p.x,p.y,1)
	end

	gfx.setDrawOffset(0,0)

	--ahh screen white moment
	--gfx.sprite.update()

	if showcrank == true then
		mobware.crankIndicator_sprite:getImage():drawCentered(360,200)
	end

	gfx.setColor(gfx.kColorWhite)
	--printTable(game_timer)
	local perc = game_timer.frame/game_timer.duration
	--gfx.fillRect(0,240-8,perc * 400,8)
end


--[[
	You can use the playdate's callback functions! Simply replace "playdate" with the name of the minigame. 
	The minigame-version of playdate.cranked looks like this:
]]
function voyage_phaser.cranked(change, acceleratedChange)
    showcrank = false
	mobware.crankIndicator.stop()
end

-- make sure to add put your name in "credits.json" and add "credits.gif" to the minigame's root folder. 
	--> These will be used to credit your game during the overarching game's credits sequence!

--> Finally, go to main.lua and search for "DEBUG_GAME". You'll want to set this to the name of your minigame so that your minigame gets loaded every turn!

-- Minigame package should return itself
return voyage_phaser
