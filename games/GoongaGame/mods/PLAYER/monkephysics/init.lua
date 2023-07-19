function is_solid(node, allow_leaves)
	local nodedef = minetest.registered_nodes[node.name]
	local solid = false
	local non_solid_drawtypes = {
		"airlike",
		"firelike",
		"plantlike",
		"nodebox",
		"signlike",
		"liquid",
		"torchlike",
		"signlike_wall",
		"flowingliquid",
		"raillike",
		"mesh",
	}
	local leaves = {
		"mcl_core:leaves",
		"mcl_core:darkleaves",
		"mcl_core:jungleleaves",
		"mcl_core:acacialeaves",
		"mcl_core:spruceleaves",
		"mcl_core:birchleaves",
	}
	if allow_leaves then
		for _, name in ipairs(leaves) do
			if node and node.name and node.name == name then
				solid = true
				return true
			end
		end
	end
	for _, drawtype in ipairs(non_solid_drawtypes) do
		if nodedef and nodedef.drawtype and nodedef.drawtype ~= drawtype then
			solid = true
		else
			return false
		end
	end
	return solid
end

local time = 0
local jump_force = 7
local longjump_force = 10
local jump_press = false
local jump_hold = false
-- local grabbing = false

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local dir = player:get_look_dir()
		local ndir = vector.normalize(vector.new(dir.x, 0, dir.z))
		local shifting = player:get_player_control().sneak
		local node_front = minetest.get_node(pos + vector.new(dir.x, 1, dir.z))
		local node_stand = minetest.get_node(pos + vector.new(0, -0.4, 0))

		if player:get_player_control().jump and jump_hold == false then
			jump_press = true
		else
			jump_press = false
		end

		if player:get_player_control().jump then
			jump_hold = true
		else
			jump_hold = false
		end

		-- if shifting and not is_solid(node_stand) and is_solid(node_front) then
		-- 	if not grabbing then
		-- 		local vel = player:get_velocity()
		-- 		player:add_velocity(vector.new(vel.x * -1, vel.y * -1, vel.z * -1))
		-- 	end
		-- 	player:set_physics_override({gravity = 0})
		-- 	grabbing = true
		-- else
		-- 	player:set_physics_override({gravity = 1})
		-- 	grabbing = false
		-- end 

		if player:get_player_control().jump then
			if time > 1 then
				if shifting and is_solid(node_stand, true) then
					player:add_velocity(vector.new(ndir.x * longjump_force, 0.5, ndir.z * longjump_force))
					time = 0
				end
			end
		end

		if jump_press then
			if time > 0.4 then
				if player:get_velocity().y < 0 then
					if is_solid(node_front, false) then
						local vel = player:get_velocity()
						player:add_velocity(vector.new(dir.x * -jump_force - vel.x, jump_force - vel.y, dir.z * -jump_force - vel.z))
						time = 0
						break
					end
				end
			end
		end

	end
	time = time + dtime
end)