-- local climb_speed = -0.2
-- local climbable_nodes = {
-- 	"mcl_core:dirt",
-- 	"mcl_core:dirt_with_grass",
-- 	"mcl_core:granite",
-- 	"mcl_core:diorite",
-- 	"mcl_core:leaves",
-- 	"mcl_core:darkleaves",
-- 	"mcl_core:jungleleaves",
-- 	"mcl_core:acacialeaves",
-- 	"mcl_core:spruceleaves",
-- 	"mcl_core:birchleaves",
-- }

-- function is_climbable(node)
-- 	for _, nodes in ipairs(climbable_nodes) do
-- 		if (node.name == nodes) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

function is_opaque(node)
    local node_def = minetest.registered_nodes[node.name]
    if node_def.drawtype == "normal" or node_def.drawtype == "allfaces" or node_def.drawtype == "allfaces_optional" then
        return true
    else
        return false
    end
end

local time = 0
local jump_force = 7
local jump_press = false
local jump_hold = false
local isClimbing = false

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		local dir = player:get_look_dir()
		local node_above = minetest.get_node(pos + {x = dir.x, y = 1, z = dir.z})

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

		if jump_press then
			if time > 5 then
				if player:get_velocity().y < 0 then
					if is_opaque(node_above) then
						local vel = player:get_velocity()
						player:add_velocity({x = dir.x * -jump_force - vel.x, y = jump_force - vel.y, z = dir.z * -jump_force - vel.z})
						time = 0
						break
					end
				end
			end
		end

	end
	time = time + 1
end)