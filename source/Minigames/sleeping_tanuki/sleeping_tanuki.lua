--[[
	Author: <nyacchu>

	sleeping_tanuki for Mobware Minigames
]]


--import 'CoreLibs/sprites'
--import 'CoreLibs/object'
import 'Minigames/sleeping_tanuki/lib/object' --used to generate animations from spritesheet


-- Define name for minigame package
sleeping_tanuki = {}

local gfx <const> = playdate.graphics
	
-- Crank indicator prompt
mobware.crankIndicator.start()

-- Initialize animation for on-screen Playdate sprite
main_sleepingTanuki_table = gfx.imagetable.new("Minigames/sleeping_tanuki/images/sleeping_tanuki")

pd_sprite = gfx.sprite.new(image_table)
pd_sprite:setImage(main_sleepingTanuki_table:getImage(1))
pd_sprite:moveTo(200, 120)
pd_sprite:add()
pd_sprite.frame = 1 
pd_sprite.crank_counter = 0
pd_sprite.total_frames = 25

-- start timer
MAX_GAME_TIME = 8 -- 単位は秒。この時間経過したら失敗(defeat)となる
game_timer = playdate.frameTimer.new(MAX_GAME_TIME * 20,
	function()
		gamestate = 'defeat'
	end)

-- set initial gamestate ゲームモード
-- start: スタート
-- game: ゲーム中
-- victory: 成功
-- defeat: 失敗
gamestate = 'start'

-- initialize background music
local theme_music = playdate.sound.fileplayer.new('Minigames/sleeping_tanuki/sounds/sweet_memories_2')
-- theme_music:play() -- play music only once



function sleeping_tanuki.update()

	-- update sprite animations
	gfx.sprite.update() -- updates all sprites

	-- update timer
	playdate.frameTimer.updateTimers()

	if gamestate == 'start' then
		mobware.print("SLEEP!", 50, 100)
	elseif gamestate == 'game' then
		theme_music:play() -- 音楽再生
		-- Win condition:
		if pd_sprite.frame == pd_sprite.total_frames then
			gamestate = 'victory'
			playdate.wait(2000)	-- Pause 1s before returning to main.lua

			theme_music:stop() -- 音楽停止

			-- このゲームに成功したことを minigame に通知
			return 1
		end
	elseif gamestate == 'defeat' then
		local cannot_sleepingTanuki_image = gfx.image.new("Minigames/sleeping_tanuki/images/cannot_sleeping_tanuki")
		local cannot_sleepingTanuki = gfx.sprite.new(cannot_sleepingTanuki_image)
		cannot_sleepingTanuki:moveTo(200, 120)
		cannot_sleepingTanuki:addSprite()
		gfx.sprite.update()

		-- 終了まで2秒待つ
		playdate.wait(2000)

		theme_music:stop() -- 音楽停止

		-- このゲームに失敗したことを minigame に通知
		return 0
	end



end


--[[
	We're going to use the crank to control the hello world animation
	We'll handle this in the callback function that'll be called each time the crank is moved
]]
function sleeping_tanuki.cranked(change, acceleratedChange)
	-- Once crank is turned, turn off crank indicator
	if mobware.crankIndicator then
		mobware.crankIndicator.stop()
		gamestate = 'game'
	end

	-- Increment animation counter:
	pd_sprite.crank_counter = pd_sprite.crank_counter + change

	if pd_sprite.crank_counter > 90 then
		if pd_sprite.frame < pd_sprite.total_frames then pd_sprite.frame = pd_sprite.frame + 1 end
		pd_sprite.crank_counter = 0
	elseif pd_sprite.crank_counter < -90 then
		if pd_sprite.frame > 1 then pd_sprite.frame = (pd_sprite.frame - 1) end
		pd_sprite.crank_counter = 0
	end

	pd_sprite:setImage(main_sleepingTanuki_table:getImage(pd_sprite.frame))
end



-- Minigame package should return itself
return sleeping_tanuki
