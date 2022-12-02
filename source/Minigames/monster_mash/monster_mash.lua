--[[
	Author: Andrew Loebach

	"Monster Mash" Minigame for Mobware Minigames
]]

-- Define name for minigame package
monster_mash = {}

local gfx <const> = playdate.graphics

-- initialize background
-- draw XL black background to make "shake" animation look cleaner
gfx.setBackgroundColor(gfx.kColorBlack)

local background = gfx.sprite.new()
background:setImage(gfx.image.new("Minigames/monster_mash/images/toyko_dark"))
background:moveTo(200, 120)
background:addSprite()

--initialize animations:
--> I'm going to use Whitebrim's AnimatedSprite library

-- animate mechamonzilla 
local mechamonzilla_spritesheet = gfx.imagetable.new("Minigames/monster_mash/images/mechamonzilla")
local mechamonzilla = AnimatedSprite.new( mechamonzilla_spritesheet )
mechamonzilla:addState("fight",1,4, {tickStep = 3, loop = true}, true)
mechamonzilla:addState("victory",3,3, {}) --use this victory sprite instead for mechamonzilla
mechamonzilla:addState("defeated",5,10, {tickStep = 3, loop = false})
mechamonzilla:moveTo(235,160)

-- animate monzilla
local monzilla_spritesheet = gfx.imagetable.new("Minigames/monster_mash/images/monzilla")
local monzilla = AnimatedSprite.new( monzilla_spritesheet )
monzilla:addState("idle",1,1, {tickStep = 3, loop = false})
monzilla:addState("fight",1,4, {tickStep = 2, loop = false, nextAnimation = "idle"}, true).asDefault()
monzilla:addState("victory",11,11, {})
monzilla:addState("defeated",6,10, {tickStep = 3, loop = false})
monzilla:moveTo(140,165)


-- button mash indicator
mobware.AbuttonIndicator.start()

-- variable for keeping score
local zilla_score = 0
local zilla_gamestate = 'start'
local timer = playdate.timer.new(8000)
monzilla:changeState('idle') --start with monzilla in idle state

--> initialize background music
local theme_music = playdate.sound.fileplayer.new('Minigames/monster_mash/sounds/godzilla')
theme_music:play() -- play music only once


function monster_mash.update()

	-- update sprite animations
	gfx.sprite.update() -- updates all sprites

	-- update timers
	playdate.timer.updateTimers()

	if zilla_gamestate == 'start' then
		-- show text:
		mobware.print("MASH!", 50, 100)

		-- after "A" is pressed, start game, and animate Monzilla
		if playdate.buttonJustPressed('a') or timer.currentTime > 2000 then
			zilla_gamestate = 'play' 
			monzilla:changeState('fight')
		end	
	end

	if zilla_gamestate == 'play' then
		-- player mashing A will score points for monzilla
		if playdate.buttonJustPressed('a') then 
			monzilla:changeState('fight')	-- play punching animation
			zilla_score = zilla_score + 1.4 	-- increase score
		end

		-- mechamonzilla will slowly and surely chip away at monzilla
		zilla_score = zilla_score - 0.15

		-- Win condition:
		if timer.currentTime > 3500 then 
			mobware.AbuttonIndicator.stop()
			if zilla_score > 10 then
				background:setImage(gfx.image.new("Minigames/monster_mash/images/toyko_sunrise"))
				monzilla:changeState('victory')
				mechamonzilla:changeState('defeated')
				zilla_gamestate = 'victory'
			else
				-- Monzilla is defeated if score drops below -10 or 5 seconds have elapsed
				monzilla:changeState('defeated')
				mechamonzilla:changeState('victory')
				zilla_gamestate = 'defeated'		
			end
		end

	end

	-- Add dramatic shake effect
	if timer.currentTime > 3500 and timer.currentTime < 4000 then
		random_shake_x = math.random(-10,10)
		random_shake_y = math.random(-10,10)
		playdate.display.setOffset(random_shake_x, random_shake_y)
	elseif timer.currentTime >= 4000 then
		playdate.display.setOffset(0,0)
	end

	-- TO-DO: add "bang-pow" stress lines during KO punch?

	if zilla_gamestate == 'victory' and timer.currentTime >= 6000 then
		theme_music:stop()
		return 1
	elseif zilla_gamestate == 'defeated' and timer.currentTime >= 6000 then
		theme_music:stop()
		return 0
	end

end


-- Minigame package should return itself
return monster_mash
