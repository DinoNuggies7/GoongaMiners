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

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	meta:set_string("time", tostring(0))
end)

local kick_time = 0
local jump_time = 0
local jump_press = false
local jump_hold = false
-- local grabbing = false
local KICK_FORCE = 6
local LONGJUMP_FORCE = 9
minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local dir = player:get_look_dir()
		local ndir = vector.normalize(vector.new(dir.x, 0, dir.z))
		local vel = player:get_velocity()
		local shifting = player:get_player_control().sneak
		local privs = minetest.get_player_privs(player:get_player_name())
		local node_front = minetest.get_node(pos + vector.new(ndir.x, 1, ndir.z))
		local node_stand = minetest.get_node(pos + vector.new(0, -0.4, 0))

		if shifting then
			privs.interact = nil
			minetest.set_player_privs(player:get_player_name(), privs)
		else
			privs.interact = true
			minetest.set_player_privs(player:get_player_name(), privs)
		end

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
			if jump_time > 1 then
				if shifting and is_solid(node_stand, true) then
					player:add_velocity(vector.new(ndir.x * LONGJUMP_FORCE, 4 - vel.y, ndir.z * LONGJUMP_FORCE))
					jump_time = 0
				end
			end
		end

		if jump_press then
			if kick_time > 0.4 then
				if vel.y < 1 then
					if is_solid(node_front, false) then
						player:add_velocity(vector.new(ndir.x * -KICK_FORCE, KICK_FORCE - vel.y, ndir.z * -KICK_FORCE))
						kick_time = 0
					end
				end
			end
		end
		kick_time = kick_time + dtime
		jump_time = jump_time + dtime
	end

end)