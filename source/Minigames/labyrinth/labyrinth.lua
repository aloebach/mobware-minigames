
--[[
	Author: NaOH

	labyrinth for Mobware Minigames
]]


import "./voronoi"
import "./assets"

local labyrinth = {}
playdate.startAccelerometer()

-- all of the code here will be run when the minigame is loaded, so here we'll initialize our graphics and variables:
local gfx <const> = playdate.graphics
local cos <const> = math.cos
local sin <const> = math.sin

-- start timer	 
local MAX_GAME_TIME = 9
local gamestate = "load"

local difficulty = math.max(playdate.display.getRefreshRate() / 20, 1)

FPS = 42
playdate.display.setRefreshRate(FPS)
local firstmaze = false

local time_remaining = MAX_GAME_TIME * FPS / difficulty
	
mobware.AccelerometerIndicator.start()
labyrinth_ready:play()

local ball = {x=200, y=120, vx=0, vy=0, r=10}
local gravity = 750 * difficulty
local friction = 50

local walls = {}

local fillpolygons = {
	
}

local exit_sign = {
	x = 390,
	y = 100,
	dx = 1,
	dy = 0
}

local frame = 0

local function normalize(vec)
	local len = math.sqrt(vec.x * vec.x + vec.y * vec.y)
	vec.x /= len
	vec.y /= len
	return vec
end

local function precompute_wall(wall)
	wall.dx = wall.x2 - wall.x1
	wall.dy = wall.y2 - wall.y1
	wall.normal = normalize({x=wall.y1 - wall.y2, y=wall.x2 - wall.x1})
	wall.along = {x=wall.normal.y, y=-wall.normal.x}
	wall.len = math.sqrt(wall.dx * wall.dx + wall.dy * wall.dy)
	wall.bbox_x1 = math.min(wall.x1, wall.x2) - ball.r
	wall.bbox_x2 = math.max(wall.x1, wall.x2) + ball.r
end

local function do_collision()
	local collision = false
	local collision_normal
	
	for _, wall in ipairs(walls) do
		local dball = {x=ball.x - wall.x1, y=ball.y - wall.y1}
		local ndot = dball.x * wall.normal.x + dball.y * wall.normal.y
		if math.abs(ndot) <= ball.r then
			local adot = dball.x * wall.along.x + dball.y * wall.along.y
			if adot >= 0 and adot <= wall.len then
				-- collision along length
				return true, wall.normal
			elseif adot > -ball.r and adot < wall.len + ball.r then
				local colpoint = {x = wall.x1, y = wall.y1}
				if adot > wall.len / 2 then
					colpoint = {x = wall.x2, y = wall.y2}
					dball = {x = ball.x - colpoint.x, y = ball.y - colpoint.y}
				end
				local dlen = math.sqrt(dball.x * dball.x + dball.y * dball.y)
				if dlen < ball.r then
					-- collision at endpoint
					return true, normalize(dball)
				end
			end
		end
	end
	
	return false
end

local function is_border_point(x, y)
	if x == 0 then return true end
	if y == 0 then return true end
	if x == 400 then return true end
	if y == 240 then return true end
	return false
end

local function is_corner_point(x, y)
	if x == 0 or x == 400 then
		if y==0 or y == 240 then
			return true
		end
	end
	return false
end

local function polygon_get_border_edge(polygon)
	local edges = {}
	for _, edge in ipairs(polygon.edges) do
		if is_corner_point(edge[1], edge[2]) or is_corner_point(edge[3], edge[4]) then
			edges[#edges+1] = edge
		end
	end
	
	if #edges == 0 then
		return nil
	elseif #edges == 1 then
		return edges[1]
	else
		local e = {}
		for _, edge in ipairs(edges) do
			if not is_corner_point(edge[1], edge[2]) then
				e[#e+1] = edge[1]
				e[#e+1] = edge[2]
			end
			if #e == 4 then return e end
			if not is_corner_point(edge[3], edge[4]) then
				e[#e+1] = edge[3]
				e[#e+1] = edge[4]
			end
			if #e == 4 then return e end
		end
		return nil
	end
end

local function seglen(seg)
	return math.sqrt((seg[3] - seg[1]) * (seg[3] - seg[1]) + (seg[4] - seg[2]) * (seg[4] - seg[2]))
end

function coroutine.yield_cycles(cycles)
	if not coroutine.cycles then
		coroutine.yield()
	else
		coroutine.cycles -= cycles or 1
		if coroutine.cycles <= 0 then
			coroutine.yield()
		end
	end
end

function coroutine.set_cycles(cycles)
	coroutine.cycles = cycles
end

local function create_maze(maze)
	maze.walls = {}
	maze.fillpolygons = {}
	maze.exit_sign = {}
	maze.ball = {x=200, y=120, vx=0, vy=0, r=10}
	
	local status, success = pcall(function()
		local points_w = math.random(7, 8)
		local points_h = 5
		print("mazegen start...")
		
		if math.random() < 0.07 then
			points_h = 6
			points_w = 6
		end
		
		if firstmaze then
			points_w = 5
			points_h = 5
		end
		
		local minseglen = 2*ball.r + 1.5
		local count = 0
		
		local orientation = math.random(2)
		
		local points = {}
		for x = 1, points_w do
			for y = 1, points_h do
				local randoff = 0.5
				if math.random() > 0.02 then
					count += 1
					local point = {
						x=x - 0.5 - randoff + math.random() * randoff,
						y=y - 0.5 - randoff + math.random() * randoff
					}
					if (orientation == 1) then
						point.x += (y % 2) * 0.5 - 0.25
					else
						point.y += (x % 2) * 0.5 - 0.25
					end
					point.x *= 400 / points_w
					point.y *= 240 / points_h
					
					while point.x <= 0 do
						point.x += 1
					end
					while point.x >= 400 do
						point.x -= 1
					end
					while point.y <= 0 do
						point.y += 1
					end
					while point.y >= 240 do
						point.y -= 1
					end

					if x == 1 then
						point.x /= 2
						point.border = 1
					end
					if y == 1 then
						point.y /= 2
						point.border = 1
					end
					if x == points_w then
						point.x = 200 + point.x/2
						point.border = 1
					end
					if y == points_h then
						point.y = 120 + point.y/2
						point.border = 1
					end
					
					points[#points+1] = point
				end
			end
		end
		
		if #points < 20 then
			return "insufficient points"
		end
		
		print("entering voronoi...")
		local vm = voronoilib:new(points,1,0,0,400,240)
		print("voronoi complete.")
		
		local connections = {}
		local border_idxs = {}
		for index, polygon in ipairs(vm.polygons) do
			polygon.index = index
			polygon.border = false
			for _,edge in ipairs(polygon.edges) do
				if is_border_point(edge[1], edge[2]) and is_border_point(edge[3], edge[4]) then
					polygon.border = 1
					border_idxs[#border_idxs+1] = index
					break
				end
			end
			connections[index] = {}
		end
		
		coroutine.yield_cycles()
		
		if #border_idxs == 0 then
			return "not enough borders"
		end
		
		local exit_idx = border_idxs[math.random(#border_idxs)]
		local current_idx = exit_idx
		local reachable_list = {exit_idx}
		local reachable = {[exit_idx]=true}
		vm.polygons[exit_idx].processed = true
		vm.polygons[exit_idx].border = false
	
		maze.exit_sign.x = vm.polygons[exit_idx].centroid.x
		maze.exit_sign.y = vm.polygons[exit_idx].centroid.y
		local dex = normalize({x=200-maze.exit_sign.x,y=120-maze.exit_sign.y})
		maze.exit_sign.dx = -dex.x
		maze.exit_sign.dy = -dex.y
		
		-- add fillpolygons
		print("fillpolygons...")
		for _, polygon_idx in ipairs(border_idxs) do
			if polygon_idx ~= exit_idx then
				local polyfill = {}
				for _, vertex in ipairs(vm.polygons[polygon_idx].edges) do
					polyfill[#polyfill+1] = vertex[1]
					polyfill[#polyfill+1] = vertex[2]
				end
				if #polyfill >= 6 then
					maze.fillpolygons[#maze.fillpolygons+1] = polyfill
				else
					return "broken polygon"
				end
			end
		end
		
		-- add connections
		print("connections...")
		for iteration = 0,count * 2 do
			local prev_idx = current_idx
			local neighbour_polys = vm:getNeighbors("all", prev_idx)
			
			-- get list of currently unreachable neighbours
			local opt_next = {}
			for _, neighbour_poly in ipairs(neighbour_polys) do
				if not neighbour_poly.border then
					if not reachable[neighbour_poly.index] or math.random() < 0.01 then
						
						-- check width sufficient
						local segments = vm:getEdges("segment", neighbour_poly.index, prev_idx)
						if segments and #segments == 1 then
							if seglen(segments[1]) >= minseglen then
								opt_next[#opt_next+1]  = neighbour_poly.index
							end
						end
					end
				end
			end
			
			coroutine.yield_cycles()
			
			if #opt_next == 0 then
				-- no valid neighbours to expand to -- go back to somewhere random
				current_idx = reachable_list[math.random(#reachable_list)]
			else
				-- select one at random
				current_idx = opt_next[math.random(#opt_next)]
				connections[current_idx][prev_idx] = true
				connections[prev_idx][current_idx] = true
				reachable[current_idx] = true
				reachable_list[#reachable_list+1] = current_idx
			end
		end
		print("connections complete.")
		coroutine.yield_cycles()
		
		-- not enough reachables.
		if #reachable_list <= math.max(5, (count - #border_idxs) * 0.5) then
			return "not enough reachable: " .. tostring(#reachable_list)
		end
		
		-- select farthest reachable to place the player
		print("selection...")
		local len = 0
		for _, poly_idx in ipairs(reachable_list) do
			local poly = vm.polygons[poly_idx]
			local _len = seglen({poly.centroid.x, poly.centroid.y, maze.exit_sign.x, maze.exit_sign.y})
			if _len > len then
				len = _len
				maze.ball.x = poly.centroid.x
				maze.ball.y = poly.centroid.y
			end
		end
		print("selection done")
		
		coroutine.yield_cycles()
		
		-- add walls
		print("walls...")
		for poly_idx, polygon in ipairs(vm.polygons) do
			local neighbour_polys = vm:getNeighbors("all", poly_idx)
			for _, neighbour_poly in ipairs(neighbour_polys) do
				if neighbour_poly.index > poly_idx and not connections[poly_idx][neighbour_poly.index] and (not polygon.border or not neighbour_poly.border) then
					local segments = vm:getEdges("segment", neighbour_poly.index, poly_idx)
					if segments and #segments >= 1 and segments[1] then
						local segment = segments[1]
						if seglen(segment) >= 9 or polygon.border or neighbour_poly.border then
							maze.walls[#maze.walls+1] = {x1 = segment[1], x2 = segment[3], y1 = segment[2], y2 = segment[4]}
						end
					end
				end
			end
			coroutine.yield_cycles()
		end
		
		for _, wall in ipairs(maze.walls) do
			precompute_wall(wall)
		end
		
		if do_collision() then
			return "not enough starting room"
		end
		print("mazegen complete.")
		return false
	end)
	return success
end

local globstor = mobware

local function create_maze_retry(cycles)
	local maze = {}
	globstor.labyrinth_maze_coroutine_result = nil
	while create_maze(maze) do
		coroutine.yield_cycles()
	end
	globstor.labyrinth_maze_coroutine_result = maze
	return maze
end

-- predicate
local function run_maze_complete()
	return globstor.labyrinth_maze_coroutine_result
end


local function run_maze_loop(cycles)
	-- [SIC] intentionally not a predefined nor local variable.
	coroutine.set_cycles(cycles)
	if not globstor.labyrinth_maze_coroutine then 
		firstmaze = true
		globstor.labyrinth_maze_coroutine = coroutine.create(create_maze_retry)
		coroutine.resume(globstor.labyrinth_maze_coroutine)
	end
	if not run_maze_complete() then
		coroutine.resume(globstor.labyrinth_maze_coroutine)
	end
end

local function apply_maze()
	print("applying maze...")
	local s = globstor.labyrinth_maze_coroutine_result
	walls = s.walls
	fillpolygons = s.fillpolygons
	ball.x = s.ball.x
	ball.y = s.ball.y
	exit_sign = s.exit_sign
	print("done applying.")
end

local function run_maze_restart()
	globstor.labyrinth_maze_coroutine_result = nil
	globstor.labyrinth_maze_coroutine = nil
end

local shoffx = 0
local shoffy = 0
local shoffz = 0

local drawnormal = nil
local function draw()
	-- dark border
	gfx.clear(gfx.kColorWhite)
	gfx.sprite.update()
	
	if gamestate == "load" then
		labyrinth_img_ready:draw(0, 0)
		return
	end
	
	gfx.setPattern({0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55})
	for _, polygon in ipairs(fillpolygons) do
		gfx.fillPolygon(table.unpack(polygon))
	end
	
	-- smoothing
	local __shoffx, __shoffy, _shoffz = playdate.readAccelerometer()
	if __shoffx and __shoffy then
		local _shoffx = __shoffx * cos(0.7) + __shoffy * sin(0.7)
		local _shoffy = __shoffy * cos(0.7) - __shoffx * sin(0.7)
		shoffx = shoffx * 0.4 + 0.6 * (_shoffx) * 3.5
		shoffy = shoffy * 0.4 + 0.6 * (_shoffy) * 3.5
		shoffz = shoffz * 0.5 + 0.5 * _shoffz
	end
	
	gfx.setLineWidth(4)
	for _, wall in ipairs(walls) do
		gfx.drawLine(wall.x1+shoffx, wall.y1+shoffy, wall.x2+shoffx, wall.y2+shoffy)
	end
	
	gfx.setLineWidth(2)
	local flash = false
	if time_remaining < 120 then
		flash = time_remaining % 8 > 5
	end
	if time_remaining < 60 then
		flash = time_remaining % 5 >= 3
	end
	
	if gamestate == "play" and flash == false then
		gfx.fillCircleAtPoint(ball.x+shoffx, ball.y+shoffy, ball.r+1)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillCircleAtPoint(ball.x, ball.y, ball.r+1)
		gfx.setPattern({0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55, 0xaa, 0x55})
		gfx.fillCircleAtPoint(math.floor(ball.x) - ball.r/2, math.floor(ball.y) - ball.r/2, ball.r/3)
	end
	gfx.setColor(gfx.kColorBlack)
	
	if drawnormal then
		gfx.drawLine(ball.x, ball.y, ball.x + drawnormal.x * 50, ball.y + drawnormal.y * 50)
	end
	
	for _, wall in ipairs(walls) do
		gfx.drawLine(wall.x1, wall.y1, wall.x2, wall.y2)
	end
	
	-- exit
	local exlen = 20
	local exarr = 7
	if gamestate ~= "defeat" and (frame % 18 >= 9) then
		gfx.drawLine(exit_sign.x - exit_sign.dx * exlen, exit_sign.y - exit_sign.dy * exlen, exit_sign.x, exit_sign.y)
		gfx.drawLine(exit_sign.x + (-exit_sign.dx + exit_sign.dy) * exarr, exit_sign.y + (-exit_sign.dx - exit_sign.dy) * exarr, exit_sign.x, exit_sign.y)
		gfx.drawLine(exit_sign.x + (-exit_sign.dx - exit_sign.dy) * exarr, exit_sign.y + ( exit_sign.dx - exit_sign.dy) * exarr, exit_sign.x, exit_sign.y)
	end
	
	local flipped = math.abs(shoffz) < 0.9 and shoffy < -0.15
	if gamestate == "defeat" then
		labyrinth_img_failure:draw(0, 0, flipped and gfx.kImageFlippedXY or gfx.kImageUnflipped)
	elseif gamestate == "win" then
		labyrinth_img_success:draw(0, 0, flipped and gfx.kImageFlippedXY or gfx.kImageUnflipped)
	end
end

local colframes = 0
local colstorev = nil

local function physics(dt)
	ax, ay, az = playdate.readAccelerometer()
	ball.vx += dt * gravity * ax;
	ball.vy += dt * gravity * ay;
	
	-- friction
	local vl = math.sqrt(ball.vx * ball.vx + ball.vy * ball.vy)
	local p = math.min(vl / 50, 10)
	local lfric = p * friction * dt
	if vl <= lfric then
		ball.vx = 0
		ball.vy = 0
	else
		ball.vx -= ball.vx * lfric / vl
		ball.vy -= ball.vy * lfric / vl
	end
	
	local prevx = ball.x
	local prevy = ball.y
	ball.x += dt * ball.vx
	ball.y += dt * ball.vy
	
	local collision, collision_normal = do_collision()
	
	if collision then
		colframes += 1
		if colframes >= 4 then
			ball.vx = math.random(-10, 10)
			ball.vy = math.random(-10, 10)
			labyrinth_oops:setVolume(0.4 + math.random()*0.2)
			labyrinth_oops:setRate(1 + math.random() * 0.15)
			labyrinth_oops:play()
		end
		ball.x = prevx
		ball.y = prevy
		if collision_normal then
			--drawnormal = collision_normal
			local coldot = ball.vx * collision_normal.x + ball.vy * collision_normal.y
			local add = 15
			if coldot < 0 then add *= -1 end
			ball.vx -= (coldot + add) * collision_normal.x
			ball.vy -= (coldot + add) * collision_normal.y
			
			if math.abs(coldot) >= 40 then
				local randidx = math.random(#labyrinth_clicksounds)
				local sample = labyrinth_clicksounds[randidx]
				if sample == labyrinth_clicksounds[4] and math.random() > 0.05 then
					sample = labyrinth_clicksounds[1]
					randidx = 1
				end
				local p = math.min(math.abs(coldot / 500), 1)
				sample:setVolume(p * p)
				local raterand = 0.1
				sample:setRate(1.0 - raterand / 2 + raterand * math.random())
				sample:play()
				
				--echo
				if p >= 0.2 then
					labyrinth_clicksounds_echo[randidx]:playAt(playdate.sound.getCurrentTime() + 0.2, p * p * (0.1 + math.random() * 0.1))
				end
			elseif math.abs(coldot) >= 1 and vl >= 30 and math.random() > 0.2 then
				local sample = labyrinth_thistle[math.random(#labyrinth_thistle)]
				local p = math.min(vl / 300, 0.2)
				local raterand = 0.1
				sample:setVolume(p*p)
				sample:setRate((1.0 - raterand / 2 + raterand * math.random()) / 2)
				sample:play()
			end
		end
	else
		colframes = 0
	end
	
	if gamestate ~= "win" then
		if ball.x >= 400 + ball.r then
			gamestate = "win"
		elseif ball.y >= 240 + ball.r then
			gamestate = "win"
		elseif ball.x <= -ball.r then
			gamestate = "win"
		elseif ball.y <= -ball.r then
			gamestate = "win"
		end
		if gamestate == "win" then
			labyrinth_victory:play()
		end
	end
end

local labyrinth_start_time = playdate.getCurrentTimeMilliseconds()

function labyrinth.update()
	playdate.frameTimer.updateTimers()
	
	frame += 1
	
	draw()
	
	run_maze_loop(1)
	
	if (gamestate == "load") then
		if run_maze_complete() and frame == 1 then
			print("already complete")
		else
			run_maze_loop(15)
		end
		if run_maze_complete() and playdate.getCurrentTimeMilliseconds() - labyrinth_start_time >= 2300 then
			apply_maze()
			run_maze_restart()
			gamestate = "play"
			mobware.AccelerometerIndicator.stop()
		end
	elseif gamestate == "play" then
		local rate = 1/FPS * math.sqrt(math.min(time_remaining / 40, 1))
		physics(rate)
		time_remaining -= 1
		if time_remaining < 0 and gamestate ~= "win" then
			labyrinth_fail:play()
			gamestate = "defeat"
		end
	elseif (gamestate == "win" or gamestate == "defeat") then
		playdate.stopAccelerometer()
		playdate.wait(2000)
		if gamestate == "win" then
			return 1
		else
			return 0
		end
	end
end

return labyrinth
