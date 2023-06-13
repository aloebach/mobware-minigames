
--[[
	Author: Oscar Rosales

	gated_castle for Mobware Minigames

	Original minotaur art and SFX: 
	https://static.gamedevmarket.net/terms-conditions/#pro-licence
	https://www.gamedevmarket.net/asset/fantasy-enemy-creatures/

	Original villager art: https://craftpix.net/file-licenses/
	https://craftpix.net/freebies/free-villagers-sprite-sheets-pixel-art/

	Original castle license: 
	https://kenney.nl/assets/platformer-pack-medieval
]]

--import 'Minigames/gated_castle/lib/AnimatedSprite' 
import "Minigames/gated_castle/creature"
import "Minigames/gated_castle/minotaur"
import "Minigames/gated_castle/oldWoman"

local gated_castle = {}

local gfx <const> = playdate.graphics

local initial_crank_position = nil

local gate_image_table = nil
local gate = nil
local gate_frame_num = 1

local castle_top = nil
local tower_top_right = nil
local tower_top_left = nil
local tower_right = nil
local tower_left = nil
local tower_right_bottom = nil
local tower_left_bottom = nil
local destroyed_tower_right = gfx.image.new("Minigames/gated_castle/images/destroyedtower_right")
local destroyed_tower_left = gfx.image.new("Minigames/gated_castle/images/destroyedtower_left")

local creature = nil
local CREATURE_SPEED = 3

local random_scenario = nil

local victory_message = ""
local defeat_message = ""

-- Initialize music / sound effects
local click_noise = playdate.sound.sampleplayer.new('Minigames/gated_castle/sounds/click')
click_noise:setVolume(0.4)
local start_theme = playdate.sound.fileplayer.new('Minigames/gated_castle/sounds/trumpet')
start_theme:setVolume(0.4)
local victory_theme = playdate.sound.fileplayer.new('Minigames/gated_castle/sounds/victory')
victory_theme:setVolume(0.4)
local castle_collapse_sound = playdate.sound.fileplayer.new('Minigames/gated_castle/sounds/castle_collapse')
castle_collapse_sound:setVolume(0.4)
local scream_sound = playdate.sound.fileplayer.new('Minigames/gated_castle/sounds/scream')
scream_sound:setVolume(0.1) 

local gamestate = nil

local function initialize()
	-- Scenario init
	random_scenario = math.random(0, 1)
	if(random_scenario == 1) then
		gamestate = 'closeGate'
		creature = Minotaur:new(0, 160, CREATURE_SPEED)
		gate_frame_num = 4
		victory_message = "Stay away, fiend!"
		defeat_message = "The keep has fallen!"
	else
		gamestate =  'openGate'
		creature = OldWoman:new(0, 170, CREATURE_SPEED)
		gate_frame_num = 1
		victory_message = "Welcome, milady!"
		defeat_message = "Milady! Oh no!"
	end

	-- Gate init
	initial_crank_position = playdate.getCrankPosition()
	gate_image_table = gfx.imagetable.new("Minigames/gated_castle/images/gate")
	gate = gfx.sprite.new(image_table)
	gate:setImage(gate_image_table:getImage(gate_frame_num))
	gate:moveTo(210, 130)
	gate:add()
	gate:setCollideRect(20, 0, gate.width-20, gate.height)
	gate.crank_counter = 0
	gate.total_frames = 16

	-- Castle init
	local castle_top_image = gfx.image.new("Minigames/gated_castle/images/castletop")
	castle_top = gfx.sprite.new(castle_top_image)
	castle_top:moveTo(210, 38)
	castle_top:add()

	-- Towers init
	local tower_x = 93
	local tower_y = 38

	local tower_top_left_image = gfx.image.new("Minigames/gated_castle/images/towertop")
	tower_top_left = gfx.sprite.new(tower_top_left_image)
	tower_top_left:moveTo(tower_x, tower_y)
	tower_top_left:setZIndex(-1)
	tower_top_left:add()

	local tower_left_image = gfx.image.new("Minigames/gated_castle/images/towermid")
	tower_left = gfx.sprite.new(tower_left_image)
	tower_left:moveTo(tower_x, tower_y + tower_top_left.height)
	tower_left:setZIndex(-1)
	tower_left:add()

	local tower_left_bottom_image = gfx.image.new("Minigames/gated_castle/images/towerleft_bottom")
	tower_left_bottom = gfx.sprite.new(tower_left_bottom_image)
	tower_left_bottom:moveTo(tower_x, tower_y + tower_top_left.height*2)
	tower_left_bottom:setZIndex(-1)
	tower_left_bottom:add()

	local tower_top_right_image = gfx.image.new("Minigames/gated_castle/images/towertop")
	tower_top_right = gfx.sprite.new(tower_top_right_image)
	tower_top_right:moveTo(tower_x + castle_top.width + tower_left.width, tower_y)
	tower_top_right:setZIndex(-1)
	tower_top_right:add()

	local tower_right_image = gfx.image.new("Minigames/gated_castle/images/towermid")
	tower_right = gfx.sprite.new(tower_right_image)
	tower_right:moveTo(tower_x + castle_top.width + tower_left.width, tower_y + tower_top_right.height)
	tower_right:setZIndex(-1)
	tower_right:add()

	local tower_right_bottom_image = gfx.image.new("Minigames/gated_castle/images/towerright_bottom")
	tower_right_bottom = gfx.sprite.new(tower_right_bottom_image)
	tower_right_bottom:moveTo(tower_x + castle_top.width + tower_left.width, tower_y + tower_top_right.height*2)
	tower_right_bottom:setZIndex(-1)
	tower_right_bottom:add()

	-- Background init
	local backgroundImage = gfx.image.new("Minigames/gated_castle/images/background")
	gfx.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			gfx.setClipRect(x, y, width, height)
			backgroundImage:draw(0, 0)
			gfx.clearClipRect()
		end
	)
	
	mobware.crankIndicator.start()

	start_theme:play(1)
end

initialize()

function gated_castle.update()
	gfx.sprite.update() 
	--gfx.setColor(gfx.kColorBlack)
	--local line = gfx.drawLine(0, 180, 400, 180)
	--line:setZIndex(-2)


	local collisions = gate:overlappingSprites()
	if #collisions >= 1 then
		-- If the goal is to close the gate, its frame must be 1
		-- Otherwise, it must be higher than 2
		if gamestate == 'closeGate' and gate_frame_num == 1 then
			gamestate = 'victory'
		elseif gamestate == 'openGate' and gate_frame_num > 2 then
			gamestate = 'victory'
		else
			gamestate = 'defeat'
		end
	end

	-- Checks if game has ended or the player must open or close the door
	if gamestate == 'openGate' then
		gfx.drawText("Open the gate!", 70, 220)

	elseif gamestate == 'closeGate' then
		gfx.drawText("Close the gate!", 70, 220)

	elseif gamestate == 'victory' then
		-- Player has won
		victory_theme:play(1)
		mobware.print(victory_message, 90, 70)
		mobware.crankIndicator.stop()
		playdate.wait(2000)
		return 1

	elseif gamestate == 'defeat' then
		-- Player has lost	
		if random_scenario == 1 then
			tower_top_left:setImage(destroyed_tower_left)
			tower_top_left:add()
			tower_top_right:setImage(destroyed_tower_right)
			tower_right:add()
			castle_collapse_sound:play(1)
		else
			scream_sound:play(1)
			local finale_enemy = Minotaur:new(20, 160, CREATURE_SPEED*5)
		end
		gfx.sprite.update()
		mobware.print(defeat_message,90, 70)

		mobware.crankIndicator.stop()
		playdate.wait(2000)
		return 0

	end
end

function gated_castle.cranked(change, acceleratedChange)
	click_noise:play(1)

	local crank_position = playdate.getCrankPosition()
	local change = playdate.getCrankChange()

	if gate_frame_num == 1 and change < 0 then
		-- Gate is already closed
		initial_crank_position = crank_position
	elseif gate_frame_num == 4 and change > 0 then
		-- Gate is already open
		initial_crank_position = crank_position
	else
		-- Gate can change state
		local crank_with_offset = crank_position - initial_crank_position
		if crank_with_offset < 0 then
			crank_with_offset = crank_with_offset + 360
		end
		gate_frame_num = math.floor( crank_with_offset / 90.1 + 1 )
		gate:setImage(gate_image_table:getImage(gate_frame_num))
	end
end

return gated_castle
