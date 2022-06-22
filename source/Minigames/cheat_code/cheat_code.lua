
--[[
	Author: Drew Loebach

	cheat code minigame for Mobware Minigames
	
]]

-- Define name for minigame package 
local cheat_code = {}

-- import code for "cranktra" minigame
import 'Minigames/cheat_code/cranktra/Player'
import 'Minigames/cheat_code/cranktra/Bullet'

local gfx <const> = playdate.graphics

-- animate title screen which will slowly scroll into the middle of the screen
set_black_background()
local title_screen_image = gfx.sprite.new(gfx.image.new('Minigames/cheat_code/images/cranktra_title_screen'))
title_screen_image:moveTo(-200, 120)
title_screen_image:addSprite()

--> Initialize music / sound effects
local cranktra_theme = playdate.sound.sampleplayer.new('Minigames/cheat_code/sounds/cranktra_title_theme')
cranktra_theme:play(1) 
local explosion = playdate.sound.sampleplayer.new('Minigames/cheat_code/sounds/explosion')
explosion:setVolume(5)

local cranktra_font = gfx.font.new("Minigames/cheat_code/font/Cranktra_M")

-- set initial gamestate and prompt for player to hit the up on D-pad
local gamestate = 'up1'
mobware.DpadIndicator.start('up')

-- start timer	 
local MAX_GAME_TIME = 7 -- define the time at 20 fps that the game will run before setting the "defeat" gamestate
local game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "defeat" end ) --runs for 6 seconds at 20fps, and 3 seconds at 40fps


function cheat_code.update()

	-- scroll title screen image in
	title_screen_image:moveTo( math.min(200, title_screen_image.x  + 3) , 120 )	
	
	-- updates all sprites
	gfx.sprite.update() 
	
	-- update timer
	playdate.frameTimer.updateTimers()

	-- player needs to input Konami code in order: up, up, down, down, left, right, left, right, then CRANK
	if gamestate == 'up1' then
		--mobware.print('enter the codami code!',40,50)
		mobware.print('↑ ↑ ↓ ↓ ← → ← → Ⓑ Ⓐ 🎣',35,50)		

		if playdate.buttonJustPressed('up') then
			-- If player hits the "up" button during this gamestate, move to next gamestate
			gamestate = 'up2'
		end
		
	elseif gamestate == 'up2' then
		if playdate.buttonJustPressed('up') then
			mobware.DpadIndicator.stop()			
			mobware.DpadIndicator.start('down')
			gamestate = 'down1'
		end

	elseif gamestate == 'down1' then
		if playdate.buttonJustPressed('down') then
			gamestate = 'down2'
		end

	elseif gamestate == 'down2' then
		if playdate.buttonJustPressed('down') then
			mobware.DpadIndicator.stop()
			mobware.DpadIndicator.start('left')
			gamestate = 'left1'
		end

	elseif gamestate == 'left1' then
		if playdate.buttonJustPressed('left') then
			mobware.DpadIndicator.stop()
			mobware.DpadIndicator.start('right')
			gamestate = 'right1'
		end

	elseif gamestate == 'right1' then
		if playdate.buttonJustPressed('right') then
			mobware.DpadIndicator.stop()
			mobware.DpadIndicator.start('left')
			gamestate = 'left2'
		end
		
	elseif gamestate == 'left2' then
		if playdate.buttonJustPressed('left') then
			mobware.DpadIndicator.stop()
			mobware.DpadIndicator.start('right')
			gamestate = 'right2'
		end
		
	elseif gamestate == 'right2' then
		if playdate.buttonJustPressed('right') then
			mobware.DpadIndicator.stop()
			mobware.BbuttonIndicator.start()
			gamestate = 'hitB'
		end		

	elseif gamestate == 'hitB' then
		if playdate.buttonJustPressed('b') then
			mobware.BbuttonIndicator.stop()
			mobware.AbuttonIndicator.start()
			gamestate = 'hitA'
		end				
		

	elseif gamestate == 'hitA' then
		if playdate.buttonJustPressed('a') then
			mobware.AbuttonIndicator.stop()
			mobware.crankIndicator.start()
			gamestate = 'turnCrank'
		end

	-- In the final stage of the minigame the user needs to turn the crank
	elseif gamestate == 'turnCrank' then
		if playdate.getCrankTicks(1) >= 1 then
			mobware.crankIndicator.stop()
			game_timer:remove()

			-- play explosion sound effect
			explosion:play(1)

			-- move title screen to center and creating flashing text animation by drawing black box over text	
			title_screen_image:moveTo( 200 , 120 )
			gfx.sprite.update() 
			playdate.wait(300)
			gfx.setColor(gfx.kColorBlack)
			gfx.fillRect(100, 198, 90, 14) 
			playdate.wait(300)
			gfx.clear()
			gfx.sprite.update() 
			playdate.wait(300)
			gfx.fillRect(100, 198, 90, 14) 
			playdate.wait(300)
			gfx.clear()
			gfx.sprite.update() 
			playdate.wait(500)
						
			gamestate = '30_lives'
			set_black_background()
			
			gfx.clear()
			gfx.setFont(cranktra_font)
			gfx.setImageDrawMode("fillWhite")
			gfx.sprite.removeAll()
		end


	elseif gamestate == '30_lives' then
		-- Show the level introduction screen displaying that the player has 30 lives

		gfx.drawText("1P       0", 20, 20)
		gfx.drawText("REST 30", 20, 52)
		
		gfx.drawText("HI   20000", 148, 84)
		
		gfx.drawText("STAGE 1", 144, 128)
		gfx.drawText("JUNGLE", 144, 160)
		
		
		playdate.wait(2000)	-- Pause 2s before ending the minigame
		
		--> let the player play Cranktra for a few seconds before moving to victory gamestate and ending the minigame!
		-- load "cranktra" assets:
		local cranktra_background = gfx.sprite.new(gfx.image.new('Minigames/cheat_code/cranktra/images/cranktra_background'))
		cranktra_background:moveTo(200, 120)
		cranktra_background:add()		
				
		-- medals indicating 30 lives
		lives = gfx.sprite.new()
		lives:setImage(gfx.image.new("Minigames/cheat_code/cranktra/images/30_lives"))
		lives:add()
		lives:moveTo(198, 20) -- display in upper left corner
		
		gfx.sprite.addEmptyCollisionSprite(124, 32 ,368 ,10)
		playdate.display.setRefreshRate(20)
		player = Player:new(50, 10)
		
		-- play stage music
		cranktra_theme:stop()
		jungle_music = playdate.sound.sampleplayer.new('Minigames/cheat_code/cranktra/sounds/Contra_Jungle')
		jungle_music:setVolume(0.4)
		jungle_music:play(1) 

		-- end minigame after a few seconds of Cranktra
		gamestate = 'cranktra'
		game_timer = playdate.frameTimer.new( 3 * 20, function() gamestate = "victory" end ) 
		
		
	elseif gamestate == 'victory' then
		jungle_music:stop()
		return 1


	elseif gamestate == 'defeat' then

		-- move title screen to center and creating flashing text animation by drawing black box over text	
		gfx.sprite.removeAll()
		title_screen_image:addSprite()
		title_screen_image:moveTo( 200 , 120 )
		
		gfx.sprite.update() 
		playdate.wait(300)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(100, 198, 90, 14) 
		playdate.wait(300)
		gfx.clear()
		gfx.sprite.update() 
		playdate.wait(300)
		gfx.fillRect(100, 198, 90, 14) 
		playdate.wait(300)
		gfx.clear()
		gfx.sprite.update() 
		playdate.wait(500)


		-- Show the level introduction screen displaying that the player has 3 lives then exit minigame	
		set_black_background()
		gfx.clear()
		gfx.setFont(cranktra_font)
		gfx.setImageDrawMode("fillWhite")
		gfx.sprite.removeAll()
		
		gfx.drawText("1P", 20, 20)
		gfx.drawText("0", 164, 20)
		gfx.drawText("REST 3", 20, 52)
		
		gfx.drawText("HI   20000", 148, 84)
		
		gfx.drawText("STAGE 1", 144, 128)
		gfx.drawText("JUNGLE", 144, 160)
		
		-- wait another 2 seconds then exit
		playdate.wait(2000)	-- Pause 2s before ending the minigame
		
		-- return 0 to indicate that the player has lost and exit the minigame 
		return 0

	end

end


-- Minigame package should return itself
return cheat_code
