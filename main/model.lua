-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.

local M = {}

function M.new_state(size)
	return {
		size = size,
		segments = {
			{ x = 7,  y = 24 },
			{ x = 8,  y = 24 },
			{ x = 9,  y = 24 },
			{ x = 10, y = 24 }
		},
		dir = { x = 1, y = 0 },
		dirqueue = {},
		-- speed in tiles per second
		speed = 7.0,
		alive = true,
		t = 0,
		food = { x = math.random(2, size - 1), y = math.random(2, size - 1) }
	}
end

-- todo make sure food doesn't appear on snake
function move_food(state)
	state.food = { x = math.random(2, state.size - 1), y = math.random(2, state.size - 1) }
end

local function deep_copy(original)
	local copy
	if type(original) == 'table' then
		copy = {}
		for key, value in next, original, nil do
			copy[deep_copy(key)] = deep_copy(value)
		end
		setmetatable(copy, deep_copy(getmetatable(original)))
	else
		copy = original
	end
	return copy
end

-- Update the game state based on dt
function M.tick(state, dt)
	if (not state.alive) then
		return state
	end
	local new_state = deep_copy(state)
	new_state.t = new_state.t + dt
	if new_state.t >= 1.0 / new_state.speed and new_state.alive then
		local newdir = table.remove(new_state.dirqueue, 1)

		if newdir then
			local opposite = newdir.x == -new_state.dir.x or newdir.y == -new_state.dir.y
			if not opposite then
				new_state.dir = newdir
			end
		end

		local head = new_state.segments[#new_state.segments]
		local newhead = { x = head.x + new_state.dir.x, y = head.y + new_state.dir.y }
		local tile = tilemap.get_tile("#grid", "layer1", newhead.x, newhead.y)

		if tile == 2 or tile == 4 then
			-- if snake hit himself or hit wall
			new_state.alive = false
			new_state.t = 0
			return new_state
		elseif tile == 3 then
			-- if snake ate food
			new_state.speed = new_state.speed + 1
			move_food(new_state)
			new_state.moved_food = true
		else
			local tail = table.remove(new_state.segments, 1)
			new_state.removed_tail = tail
		end

		-- only show new head if snake is alive
		table.insert(new_state.segments, newhead)
		new_state.t = 0
	end
	return new_state
end

return M
