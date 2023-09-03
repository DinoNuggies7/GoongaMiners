local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

mcl_structures = {}

dofile(modpath.."/api.lua")
-- dofile(modpath.."/shipwrecks.lua")
-- dofile(modpath.."/desert_temple.lua")
-- dofile(modpath.."/jungle_temple.lua")
-- dofile(modpath.."/ocean_ruins.lua")
-- dofile(modpath.."/witch_hut.lua")
-- dofile(modpath.."/igloo.lua")
-- dofile(modpath.."/woodland_mansion.lua")
-- dofile(modpath.."/ruined_portal.lua")
-- dofile(modpath.."/geode.lua")
-- dofile(modpath.."/pillager_outpost.lua")
-- dofile(modpath.."/end_spawn.lua")
-- dofile(modpath.."/end_city.lua")


mcl_structures.register_structure("desert_well",{
	place_on = {"group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	not_near = { "desert_temple_new" },
	solid_ground = true,
	sidelen = 4,
	chunk_probability = 600,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -2,
	biomes = { "Desert" },
	filenames = { modpath.."/schematics/mcl_structures_desert_well.mts" },
})

mcl_structures.register_structure("fossil",{
	place_on = {"group:material_stone","group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	sidelen = 13,
	chunk_probability = 1000,
	y_offset = function(pr) return ( pr:next(1,16) * -1 ) -16 end,
	y_max = 15,
	y_min = mcl_vars.mg_overworld_min + 35,
	biomes = { "Desert" },
	filenames = {
		modpath.."/schematics/mcl_structures_fossil_skull_1.mts", -- 4×5×5
		modpath.."/schematics/mcl_structures_fossil_skull_2.mts", -- 5×5×5
		modpath.."/schematics/mcl_structures_fossil_skull_3.mts", -- 5×5×7
		modpath.."/schematics/mcl_structures_fossil_skull_4.mts", -- 7×5×5
		modpath.."/schematics/mcl_structures_fossil_spine_1.mts", -- 3×3×13
		modpath.."/schematics/mcl_structures_fossil_spine_2.mts", -- 5×4×13
		modpath.."/schematics/mcl_structures_fossil_spine_3.mts", -- 7×4×13
		modpath.."/schematics/mcl_structures_fossil_spine_4.mts", -- 8×5×13
	},
})

mcl_structures.register_structure("boulder",{
	filenames = {
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder_small.mts",
		modpath.."/schematics/mcl_structures_boulder.mts",
		-- small boulder 3x as likely
	},
},true) --is spawned as a normal decoration. this is just for /spawnstruct

-- mcl_structures.register_structure("ice_spike_small",{
-- 	filenames = { modpath.."/schematics/mcl_structures_ice_spike_small.mts"	},
-- },true) --is spawned as a normal decoration. this is just for /spawnstruct
-- mcl_structures.register_structure("ice_spike_large",{
-- 	sidelen = 6,
-- 	filenames = { modpath.."/schematics/mcl_structures_ice_spike_large.mts"	},
-- },true) --is spawned as a normal decoration. this is just for /spawnstruct

-- Debug command
local function dir_to_rotation(dir)
	local ax, az = math.abs(dir.x), math.abs(dir.z)
	if ax > az then
		if dir.x < 0 then
			return "270"
		end
		return "90"
	end
	if dir.z < 0 then
		return "180"
	end
	return "0"
end

minetest.register_chatcommand("spawnstruct", {
	params = "dungeon",
	description = S("Generate a pre-defined structure near your position."),
	privs = {debug = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then return end
		local pos = player:get_pos()
		if not pos then return end
		pos = vector.round(pos)
		local dir = minetest.yaw_to_dir(player:get_look_horizontal())
		local rot = dir_to_rotation(dir)
		local pr = PseudoRandom(pos.x+pos.y+pos.z)
		local errord = false
		local message = S("Structure placed.")
		if param == "dungeon" and mcl_dungeons and mcl_dungeons.spawn_dungeon then
			mcl_dungeons.spawn_dungeon(pos, rot, pr)
		elseif param == "" then
			message = S("Error: No structure type given. Please use “/spawnstruct <type>”.")
			errord = true
		else
			for n,d in pairs(mcl_structures.registered_structures) do
				if n == param then
					mcl_structures.place_structure(pos,d,pr,math.random(),rot)
					return true,message
				end
			end
			message = S("Error: Unknown structure type. Please use “/spawnstruct <type>”.")
			errord = true
		end
		minetest.chat_send_player(name, message)
		if errord then
			minetest.chat_send_player(name, S("Use /help spawnstruct to see a list of avaiable types."))
		end
	end
})
minetest.register_on_mods_loaded(function()
	local p = ""
	for n,_ in pairs(mcl_structures.registered_structures) do
		p = p .. " | "..n
	end
	minetest.registered_chatcommands["spawnstruct"].params = minetest.registered_chatcommands["spawnstruct"].params .. p
end)
