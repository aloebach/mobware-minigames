
--[[
	Author: Abramaran, Juanan Pascual

	catch_the_thief for Mobware Minigames

	feel free to search and replace "catch_the_thief" in this code with your minigame's name,
	rename the file <your_minigame>.lua, and rename the folder to the same name to get started on your own minigame!
]]


-- Define name for minigame package -> should be the same name as the name of the folder and name of <minigame>.lua 
catch_the_thief = {}

local winstate = 0 -- 1 win, 0 lose

-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics

local backgroundMusic = playdate.sound.fileplayer.new("Minigames/catch_the_thief/sounds/music")
local loseSoundFX = playdate.sound.fileplayer.new("Minigames/catch_the_thief/sounds/roarwrong")
local winSoundFX = playdate.sound.fileplayer.new("Minigames/catch_the_thief/sounds/housealarmcorrect")
backgroundMusic:play()

local MIN_DRAW_OFFSET <const> = -303
local MAX_DRAW_OFFSET <const> = 303
local INIT_DRAW_OFFSET <const> = 0--MAX_DRAW_OFFSET / 2

gfx.setDrawOffset(INIT_DRAW_OFFSET, 0)


local darkroom = gfx.image.new("Minigames/catch_the_thief/images/DarkRoom-dither")
local clearroom = gfx.image.new("Minigames/catch_the_thief/images/LightRoom-dither")
local torch = gfx.image.new("Minigames/catch_the_thief/images/torch")
local maskroom = gfx.imagetable.new("Minigames/catch_the_thief/images/masks/mask")
local torchcrank = gfx.imagetable.new("Minigames/catch_the_thief/images/crank/crank")

local s_darkroom = gfx.sprite.new(darkroom)
local s_clearroom = gfx.sprite.new(clearroom)
local s_torch = gfx.sprite.new(torch)
local s_torchcrank = gfx.sprite.new(torchcrank:getImage(1))


s_darkroom:setCenter(0.5,0)
s_darkroom:moveTo(INIT_DRAW_OFFSET + 200, 0)
s_darkroom:setZIndex(-5)
s_clearroom:moveTo(INIT_DRAW_OFFSET + 200, 0)
s_clearroom:setCenter(0.5,0)
s_darkroom:setAlwaysRedraw(true)
s_clearroom:setZIndex(-32768)
s_darkroom:add()
s_clearroom:add()

s_torch:add()
s_torch:setCenter(0,1)
s_torch:setZIndex(-4)
s_torch:moveTo(0, 240)
s_torch:setIgnoresDrawOffset(true)

s_torchcrank:add()
s_torchcrank:setCenter(0.436, 0.345)
s_torchcrank:setZIndex(-3)
s_torchcrank:moveTo(40, 230)
s_torchcrank:setIgnoresDrawOffset(true)

local sleeping
local s_sleeping
local burglar
local s_burglar

if (math.random(0, 1) == 0) then
	sleeping = gfx.image.new("Minigames/catch_the_thief/images/SleepHead")
	s_sleeping = gfx.sprite.new(sleeping)
	s_sleeping:moveTo(543 - 303, 98)
else
	sleeping = gfx.image.new("Minigames/catch_the_thief/images/Sleepwalker")
	s_sleeping = gfx.sprite.new(sleeping)
	s_sleeping:moveTo(452 -303, 141)
end

if (math.random(0, 1) == 0) then
	burglar = gfx.image.new("Minigames/catch_the_thief/images/Burglar_A")
	s_burglar = gfx.sprite.new(burglar)
	s_burglar:moveTo(803 -303, 138)
else
	burglar = gfx.image.new("Minigames/catch_the_thief/images/Burglar_B")
	s_burglar = gfx.sprite.new(burglar)
	s_burglar:moveTo(285 -303, 160)
end
s_sleeping:add()
s_burglar:add()
s_sleeping:setZIndex(-20)
s_burglar:setZIndex(-21)

local endBurglar = gfx.image.new("Minigames/catch_the_thief/images/BurglarDetected")
local endSleeping = gfx.image.new("Minigames/catch_the_thief/images/Awake1")

local s_endBurglar = gfx.sprite.new(endBurglar)
local s_endSleeping = gfx.sprite.new(endSleeping)

s_endBurglar:add()
s_endBurglar:setCenter(1, 0)
s_endBurglar:setIgnoresDrawOffset(true)
s_endBurglar:moveTo(400, 240)
s_endBurglar:setZIndex(-1)
s_endSleeping:add()
s_endSleeping:setCenter(1, 0)
s_endSleeping:setIgnoresDrawOffset(true)
s_endSleeping:moveTo(400, 240)
s_endSleeping:setZIndex(-2)

local endTimerAnimation = playdate.frameTimer.new(20, 240, 0, playdate.easingFunctions.outBounce)
endTimerAnimation:pause()

local endTimerReturn = playdate.frameTimer.new(40, function(timer) gamestate = "return" end)
endTimerReturn:pause()



-- 
local TORCH_CENTER <const> = 258
local BURGLAR_OFFSET_CENTER <const> = -(s_burglar.x - TORCH_CENTER)
local SLEEPING_OFFSET_CENTER <const> = -(s_sleeping.x - TORCH_CENTER)
local BURGLAR_OFFSET <const> = {BURGLAR_OFFSET_CENTER - s_burglar.width / 2, BURGLAR_OFFSET_CENTER + s_burglar.width / 2}
local SLEEPING_OFFSET <const> = {SLEEPING_OFFSET_CENTER - s_sleeping.width / 2, SLEEPING_OFFSET_CENTER + s_sleeping.width / 2}

local MAX_LIGHT_TIMER <const> = 20 -- 1 second initially 
local burglarLightTimer = MAX_LIGHT_TIMER
local sleepingLightTimer = MAX_LIGHT_TIMER

gfx.setBackgroundColor(gfx.kColorWhite)

-- animation for on-screen Playdate sprite
-- playdate_image_table = gfx.imagetable.new("Minigames/catch_the_thief/images/playdate")
-- low_battery_image_table = gfx.imagetable.new("Minigames/catch_the_thief/images/playdate_low_battery")
-- pd_sprite = gfx.sprite.new(image_table)

-- update sprite's frame so that the sprite will reflect the crank's actual position
-- local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
-- local frame_num = math.floor( crank_position / 45 + 1 )
-- pd_sprite:setImage(playdate_image_table:getImage(frame_num))


-- pd_sprite:moveTo(200, 120)
-- pd_sprite:add()
-- pd_sprite.frame = 1 
-- pd_sprite.crank_counter = 0
-- pd_sprite.total_frames = 16


--> Initialize music / sound effects
-- local click_noise = playdate.sound.sampleplayer.new('Minigames/catch_the_thief/sounds/click')

-- TO-DO: ADD VICTORY THEME
--local victory_theme = playdate.sound.fileplayer.new('Minigames/TV_Tuner/sounds/static_noise')

-- start timer	 
MAX_GAME_TIME = 10 -- define the time at 20 fps that the game will run betfore setting the "return"gamestate
game_timer = playdate.frameTimer.new( MAX_GAME_TIME * 20, function() gamestate = "return" end ) --runs for 8 seconds at 20fps, and 4 seconds at 40fps
	--> after <MAX_GAME_TIME> seconds (at 20 fps) will set "return" gamestate
	--> I'm using the frame timer because that allows me to increase the framerate gradually to increase the difficulty of the minigame


-- set initial gamestate and start prompt for player to hit the B button
gamestate = "start"
mobware.crankIndicator.start()
mobware.DpadIndicator.start("left","right")

local blend = 1
local offset = INIT_DRAW_OFFSET

function catch_the_thief.keyPressed(key)
	for i = 0, 100 do
		playdate.simulator.writeToFile(maskroom:blendWithImage(maskBlack, i/100, gfx.image.kDitherTypeAtkinson), "D:/PlaydateSDK-1.9.3/Projects/Lua/Minigame-Jam/Minigames/catch_the_thief/images/masks/mask-table-"..i..".png")
	end
end

function updateTorchCrank()
	local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
	local frame_num = math.floor(((crank_position + 22.5) / 22.5) + 0.5)
	if frame_num > 16 then
		frame_num = 1
	end
	s_torchcrank:setImage(torchcrank:getImage(frame_num))
end


--[[
	function <minigame name>.update()

	This function is what will be called every frame to run the minigame. 
	NOTE: The main game will initially set the framerate to call this at 20 FPS to start, and will gradually speed up to 40 FPS
]]
function catch_the_thief.update()
	if not maskroom then -- There's a bug sometimes where the imagetable is nil
		return 1 -- free win for the inconvenience
	end

	-- updates all sprites
	gfx.sprite.update() 

	-- update timer
	playdate.frameTimer.updateTimers()
	--print('Time:', game_timer.frame)
	if gamestate == "start" then
		mobware.print("Catch the thief")
		updateTorchCrank()
	elseif gamestate == "return" then
		winSoundFX:stop()
		loseSoundFX:stop()
		backgroundMusic:stop()
		return winstate
	elseif gamestate == "playing" then
		-- Decrease blend but make sure it stays in range
		if blend > 1 then
			blend = blend - 3
		end

		if blend < 1 then
			blend = 1
		end

		-- Torch opacity
		if maskroom then
			local newMask = maskroom:getImage(blend)
			if newMask then
				s_darkroom:setStencilImage(newMask)
			end
		end

		-- Scroll
		if playdate.buttonIsPressed(playdate.kButtonRight) then
			offset -= 10
			--print(offset)
			if offset < MIN_DRAW_OFFSET then
				offset = MIN_DRAW_OFFSET
			end
			gfx.setDrawOffset(offset, 0)
			mobware.DpadIndicator.stop()
		elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
			offset += 10
			if offset > MAX_DRAW_OFFSET then
				offset = MAX_DRAW_OFFSET
			end
			gfx.setDrawOffset(offset, 0)
			mobware.DpadIndicator.stop()
		end

		-- print(offset)
		-- printTable(BURGLAR_OFFSET)
		-- printTable(SLEEPING_OFFSET)
		-- print("---------------------------------------")

		-- Collision
		if burglarLightTimer < MAX_LIGHT_TIMER then
			burglarLightTimer += 1
		end

		if sleepingLightTimer < MAX_LIGHT_TIMER then
			sleepingLightTimer += 1
		end

		if blend > 68 then
			if offset > BURGLAR_OFFSET[1] and offset < BURGLAR_OFFSET[2] then
				burglarLightTimer -= 2
				
				if burglarLightTimer < 0 then
					winstate = 1
					endTimerAnimation:start()
					endTimerReturn:start()
					gamestate = "win"
				end

				if burglarLightTimer % 2 == 0 then
					s_burglar:moveBy(-3, 0)
				else
					s_burglar:moveBy(3, 0)
				end
			end

			if offset > SLEEPING_OFFSET[1] and offset < SLEEPING_OFFSET[2] then
				sleepingLightTimer -= 2
				
				if sleepingLightTimer < 0 then
					winstate = 0
					endTimerAnimation:start()
					endTimerReturn:start()
					gamestate = "lose"
				end

				if sleepingLightTimer % 2 == 0 then
					s_sleeping:moveBy(-3, 0)
				else
					s_sleeping:moveBy(3, 0)
				end
			end
		end
	-- #endregion gamestate == "playing"
	elseif gamestate == "win" then
		s_endBurglar:moveTo(400, endTimerAnimation.value)
		winSoundFX:play()
	elseif gamestate == "lose" then
		s_endSleeping:moveTo(400, endTimerAnimation.value)
		loseSoundFX:play()
	end
end

--[[
	You can use the playdate's callback functions! Simply replace "playdate" with the name of the minigame. 
	The minigame-version of playdate.cranked looks like this:
]]
function catch_the_thief.cranked(change, acceleratedChange)
	if gamestate == "start" then
		gamestate = "playing"
	end

	if mobware.crankIndicator then
		mobware.crankIndicator.stop()
	end

	if acceleratedChange > 0 then
		blend += math.floor(acceleratedChange / 5)

		if blend > maskroom:getLength() then
			blend = maskroom:getLength()
		end
	end

	updateTorchCrank()
	-- -- When crank is turned, play clicking noise
	-- click_noise:play(1)

	-- -- update sprite's frame so that the sprite will reflect the crank's actual position
	-- local crank_position = playdate.getCrankPosition() -- Returns the absolute position of the crank (in degrees). Zero is pointing straight up parallel to the device
	-- local frame_num = math.floor( crank_position / 45 + 1 )
	-- pd_sprite:setImage(playdate_image_table:getImage(frame_num))

end

function catch_the_thief.leftButtonDown()
	if gamestate == "start" then
		gamestate = "playing"
	end
end

function catch_the_thief.rightButtonDown()
	if gamestate == "start" then
		gamestate = "playing"
	end
end

-- make sure to add put your name in "credits.json" and add "credits.gif" to the minigame's root folder. 
	--> These will be used to credit your game during the overarching game's credits sequence!

--> Finally, go to main.lua and search for "DEBUG_GAME". You'll want to set this to the name of your minigame so that your minigame gets loaded every turn!

-- Minigame package should return itself
return catch_the_thief
