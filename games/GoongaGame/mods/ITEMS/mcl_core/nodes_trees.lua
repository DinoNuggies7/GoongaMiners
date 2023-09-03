-- Tree nodes: Wood, Wooden Planks, Sapling, Leaves, Stripped Wood
local S = minetest.get_translator(minetest.get_current_modname())

local mod_screwdriver = minetest.get_modpath("screwdriver")

local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

-- Check dug/destroyed tree trunks for orphaned leaves.
--
-- This function is meant to be called by the `after_destruct` handler of
-- treetrunk nodes.
--
-- Whenever a trunk node is removed, all `group:leaves` nodes in a sphere
-- with radius 6 are checked.  Every such node that does not have a trunk
-- node within a distance of 6 blocks and wasn't placed by a player is
-- converted into a orphan leaf node.
-- An ABM will gradually decay these nodes.
--
--
-- @param pos the position of the removed trunk node.
-- @param oldnode the node table of the removed trunk node.
function mcl_core.update_leaves(pos, oldnode)
	local pos1, pos2 = vector.offset(pos, -6, -6, -6), vector.offset(pos, 6, 6, 6)
	local lnode, lmeta
	local leaves = minetest.find_nodes_in_area(pos1, pos2, "group:leaves")
	for _, lpos in pairs(leaves) do
		lnode = minetest.get_node(lpos)
		lmeta = minetest.get_meta(lpos)
		-- skip already decaying leaf nodes and player leaves
		if minetest.get_item_group(lnode.name, "orphan_leaves") ~= 1 and lmeta:get_int("player_leaves") ~= 1 then
			if not minetest.find_node_near(lpos, 6, "group:tree") then
				local orphan_name = lnode.name .. "_orphan"
				local def = minetest.registered_nodes[orphan_name]
				if def then
					--minetest.log("Registered: ".. orphan_name)
					minetest.set_node(lpos, {name = orphan_name})
				else
					--minetest.log("Not registered: ".. orphan_name)
				end
			end
		end
	end
end

function mcl_core.make_player_leaves(pos)
	local meta = minetest.get_meta(pos)
	meta:set_int("player_leaves", 1)
end

-- Register tree trunk (wood) and bark
local function register_tree_trunk(subname, description_trunk, description_bark, longdesc, tile_inner, tile_bark, stripped_variant)
	minetest.register_node("mcl_core:"..subname, {
		description = description_trunk,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		tiles = {tile_inner, tile_inner, tile_bark},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		after_destruct = mcl_core.update_leaves,
		stack_max = 1,
		groups = {axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		climbable = true,
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_mcl_stripped_variant = stripped_variant,
	})

	minetest.register_node("mcl_core:"..subname.."_bark", {
		description = description_bark,
		_doc_items_longdesc = S("This is a decorative block surrounded by the bark of a tree trunk."),
		tiles = {tile_bark},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 1,
		groups = {axey=1, bark=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		is_ground_content = false,
		climbable = true,
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
		_mcl_stripped_variant = stripped_variant.."_bark",
	})

	minetest.register_craft({
		output = "mcl_core:"..subname.."_bark 3",
		recipe = {
			{ "mcl_core:"..subname, "mcl_core:"..subname },
			{ "mcl_core:"..subname, "mcl_core:"..subname },
		}
	})
end

-- Register stripped trunk and stripped wood
local function register_stripped_trunk(subname, description_stripped_trunk, description_stripped_bark, longdesc, longdesc_wood, tile_stripped_inner, tile_stripped_bark)
	minetest.register_node("mcl_core:"..subname, {
		description = description_stripped_trunk,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		tiles = {tile_stripped_inner, tile_stripped_inner, tile_stripped_bark},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 1,
		groups = {axey=1, tree=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

	minetest.register_node("mcl_core:"..subname.."_bark", {
		description = description_stripped_bark,
		_doc_items_longdesc = longdesc_wood,
		tiles = {tile_stripped_bark},
		paramtype2 = "facedir",
		on_place = mcl_util.rotate_axis,
		stack_max = 1,
		groups = {axey=1, bark=1, flammable=2, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=5},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		is_ground_content = false,
		on_rotate = on_rotate,
		_mcl_blast_resistance = 2,
		_mcl_hardness = 2,
	})

	minetest.register_craft({
		output = "mcl_core:"..subname.."_bark 3",
		recipe = {
			{ "mcl_core:"..subname, "mcl_core:"..subname },
			{ "mcl_core:"..subname, "mcl_core:"..subname },
		}
	})
end

local function register_wooden_planks(subname, description, tiles)
	minetest.register_node("mcl_core:"..subname, {
		description = description,
		_doc_items_longdesc = doc.sub.items.temp.build,
		_doc_items_hidden = false,
		tiles = tiles,
		stack_max = 1,
		is_ground_content = false,
		groups = {axey=1, flammable=3,wood=1,building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 3,
		_mcl_hardness = 2,
	})
end

local function register_leaves(subname, description, longdesc, tiles, color, paramtype2, palette, sapling, drop_apples, sapling_chances, foliage_palette)
	local apple_chances = {200, 180, 160, 120, 40}
	local stick_chances = {50, 45, 30, 35, 10}

	local function get_drops(fortune_level)
		local drop = {
			max_items = 2,
			items = {
				{
					items = {sapling},
					rarity = sapling_chances[fortune_level + 1] or sapling_chances[fortune_level],
				},
				{
					items = {"mcl_core:stick 1"},
					rarity = 4,
				},
				{
					items = {"mcl_core:stick 2"},
					rarity = 4,
				},
			}
		}
		if drop_apples == 1 then
			table.insert(drop.items, {
				items = {"mcl_throwing:acorn 1"},
				rarity = 4,
			})
			table.insert(drop.items, {
				items = {"mcl_throwing:acorn 2"},
				rarity = 4,
			})
			table.insert(drop.items, {
				items = {"mcl_core:apple"},
				rarity = apple_chances[fortune_level + 1],
			})
		elseif drop_apples == 2 then
			table.insert(drop.items, {
				items = {"mcl_throwing:banana 1"},
				rarity = 10,
			})
		end
		return drop
	end

	local l_def = {
		description = description,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "allfaces_optional",
		waving = 2,
		tiles = tiles,
		color = color,
		paramtype = "light",
		paramtype2 = paramtype2,
		palette = palette,
		stack_max = 64,
		groups = {
			handy = 1, hoey = 1, shearsy = 1, swordy = 1, dig_by_piston = 1,
			flammable = 2, fire_encouragement = 30, fire_flammability = 60,
			leaves = 1, deco_block = 1, compostability = 30, foliage_palette = foliage_palette
		},
		drop = get_drops(0),
		_mcl_shears_drop = true,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0.2,
		_mcl_hardness = 0.2,
		_mcl_silk_touch_drop = true,
		_mcl_fortune_drop = { get_drops(1), get_drops(2), get_drops(3), get_drops(4) },
		on_construct = function(pos)
			local node = minetest.get_node(pos)
			if node.param2 == 0 then
				local new_node = mcl_core.get_foliage_block_type(pos)
				if new_node.param2 ~= 0 then
					minetest.swap_node(pos, new_node)
				end
			end
		end,
		after_place_node = function(pos)
			mcl_core.make_player_leaves(pos) -- Leaves placed by the player should always be player leaves.
		end,
		}

	minetest.register_node("mcl_core:" .. subname, l_def)

	local o_def = table.copy(l_def)
	o_def._doc_items_create_entry = false
	o_def.groups.not_in_creative_inventory = 1
	o_def.groups.orphan_leaves = 1
	o_def._mcl_shears_drop = {"mcl_core:" .. subname}
	o_def._mcl_silk_touch_drop = {"mcl_core:" .. subname}

	minetest.register_node("mcl_core:" .. subname .. "_orphan", o_def)
end

local function register_sapling(subname, description, longdesc, tt_help, texture, selbox)
	minetest.register_node("mcl_core:"..subname, {
		description = description,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_hidden = false,
		drawtype = "plantlike",
		waving = 1,
		visual_scale = 1.0,
		tiles = {texture},
		inventory_image = texture,
		wield_image = texture,
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = selbox
		},
		stack_max = 64,
		groups = {
			plant = 1, sapling = 1, non_mycelium_plant = 1, attached_node = 1,
			deco_block = 1, dig_immediate = 3, dig_by_water = 1, dig_by_piston = 1,
			destroy_by_lava_flow = 1, compostability = 30
		},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_int("stage", 0)
		end,
		on_place = mcl_util.generate_on_place_plant_function(function(pos, node)
			local node_below = minetest.get_node_or_nil({x=pos.x,y=pos.y-1,z=pos.z})
			if not node_below then return false end
			local nn = node_below.name
			return minetest.get_item_group(nn, "grass_block") == 1 or
					nn == "mcl_core:podzol" or nn == "mcl_core:podzol_snow" or
					nn == "mcl_core:dirt" or nn == "mcl_core:mycelium" or nn == "mcl_core:coarse_dirt"
		end),
		node_placement_prediction = "",
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
	})
end

---------------------

register_tree_trunk("tree", S("Oak Wood"), S("Oak Bark"), S("The trunk of an oak tree."), "default_tree_top.png", "default_tree.png", "mcl_core:stripped_oak")
register_tree_trunk("darktree", S("Dark Oak Wood"), S("Dark Oak Bark"), S("The trunk of a dark oak tree."), "mcl_core_log_big_oak_top.png", "mcl_core_log_big_oak.png", "mcl_core:stripped_dark_oak")
register_tree_trunk("acaciatree", S("Acacia Wood"), S("Acacia Bark"), S("The trunk of an acacia."), "default_acacia_tree_top.png", "default_acacia_tree.png", "mcl_core:stripped_acacia")
register_tree_trunk("sprucetree", S("Spruce Wood"), S("Spruce Bark"), S("The trunk of a spruce tree."), "mcl_core_log_spruce_top.png", "mcl_core_log_spruce.png", "mcl_core:stripped_spruce")
register_tree_trunk("birchtree", S("Birch Wood"), S("Birch Bark"), S("The trunk of a birch tree."), "mcl_core_log_birch_top.png", "mcl_core_log_birch.png", "mcl_core:stripped_birch")
register_tree_trunk("jungletree", S("Jungle Wood"), S("Jungle Bark"), S("The trunk of a jungle tree."), "default_jungletree_top.png", "default_jungletree.png", "mcl_core:stripped_jungle")

register_stripped_trunk("stripped_oak", S("Stripped Oak Log"), S("Stripped Oak Wood"), S("The stripped trunk of an oak tree."), S("The stripped wood of an oak tree."), "mcl_core_stripped_oak_top.png", "mcl_core_stripped_oak_side.png")
register_stripped_trunk("stripped_acacia", S("Stripped Acacia Log"), S("Stripped Acacia Wood"), S("The stripped trunk of an acacia tree."), S("The stripped wood of an acacia tree."), "mcl_core_stripped_acacia_top.png", "mcl_core_stripped_acacia_side.png")
register_stripped_trunk("stripped_dark_oak", S("Stripped Dark Oak Log"), S("Stripped Dark Oak Wood"), S("The stripped trunk of a dark oak tree."), S("The stripped wood of a dark oak tree."), "mcl_core_stripped_dark_oak_top.png", "mcl_core_stripped_dark_oak_side.png")
register_stripped_trunk("stripped_birch", S("Stripped Birch Log"), S("Stripped Birch Wood"), S("The stripped trunk of a birch tree."), S("The stripped wood of a birch tree."),  "mcl_core_stripped_birch_top.png", "mcl_core_stripped_birch_side.png")
register_stripped_trunk("stripped_spruce", S("Stripped Spruce Log"), S("Stripped Spruce Wood"), S("The stripped trunk of a spruce tree."), S("The stripped wood of a spruce tree."), "mcl_core_stripped_spruce_top.png", "mcl_core_stripped_spruce_side.png")
register_stripped_trunk("stripped_jungle", S("Stripped Jungle Log"), S("Stripped Jungle Wood"), S("The stripped trunk of a jungle tree."), S("The stripped wood of a jungle tree."),"mcl_core_stripped_jungle_top.png", "mcl_core_stripped_jungle_side.png")
register_wooden_planks("wood", S("Oak Wood Planks"), {"default_wood.png"})
register_wooden_planks("darkwood", S("Dark Oak Wood Planks"), {"mcl_core_planks_big_oak.png"})
register_wooden_planks("junglewood", S("Jungle Wood Planks"), {"default_junglewood.png"})
register_wooden_planks("sprucewood", S("Spruce Wood Planks"), {"mcl_core_planks_spruce.png"})
register_wooden_planks("acaciawood", S("Acacia Wood Planks"), {"default_acacia_wood.png"})
register_wooden_planks("birchwood", S("Birch Wood Planks"), {"mcl_core_planks_birch.png"})


register_sapling("sapling", S("Oak Sapling"),
	S("When placed on soil (such as dirt) and exposed to light, an oak sapling will grow into an oak after some time."),
	S("Needs soil and light to grow"),
	"default_sapling.png", {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16})
register_sapling("darksapling", S("Dark Oak Sapling"),
	S("Dark oak saplings can grow into dark oaks, but only in groups. A lonely dark oak sapling won't grow. A group of four dark oak saplings grows into a dark oak after some time when they are placed on soil (such as dirt) in a 2×2 square and exposed to light."),
	S("Needs soil and light to grow") .. "\n" .. S("2×2 saplings required"),
	"mcl_core_sapling_big_oak.png", {-5/16, -0.5, -5/16, 5/16, 7/16, 5/16})
register_sapling("junglesapling", S("Jungle Sapling"),
	S("When placed on soil (such as dirt) and exposed to light, a jungle sapling will grow into a jungle tree after some time. When there are 4 jungle saplings in a 2×2 square, they will grow to a huge jungle tree."),
	S("Needs soil and light to grow") .. "\n" .. S("2×2 saplings = large tree"),
	"default_junglesapling.png", {-5/16, -0.5, -5/16, 5/16, 0.5, 5/16})
register_sapling("acaciasapling", S("Acacia Sapling"),
	S("When placed on soil (such as dirt) and exposed to light, an acacia sapling will grow into an acacia after some time."),
	S("Needs soil and light to grow"),
	"default_acacia_sapling.png", {-5/16, -0.5, -5/16, 5/16, 4/16, 5/16})
register_sapling("sprucesapling", S("Spruce Sapling"),
	S("When placed on soil (such as dirt) and exposed to light, a spruce sapling will grow into a spruce after some time. When there are 4 spruce saplings in a 2×2 square, they will grow to a huge spruce."),
	S("Needs soil and light to grow") .. "\n" .. S("2×2 saplings = large tree"),
	"mcl_core_sapling_spruce.png", {-4/16, -0.5, -4/16, 4/16, 0.5, 4/16})
register_sapling("birchsapling", S("Birch Sapling"),
	S("When placed on soil (such as dirt) and exposed to light, a birch sapling will grow into a birch after some time."),
	S("Needs soil and light to grow"),
	"mcl_core_sapling_birch.png", {-4/16, -0.5, -4/16, 4/16, 0.5, 4/16})


register_leaves("leaves", S("Oak Leaves"), S("Oak leaves are grown from oak trees."), {"default_leaves.png"}, "#48B518", "color", "mcl_core_palette_foliage.png", "mcl_core:sapling", 1, {20, 16, 12, 10}, 1)
register_leaves("darkleaves", S("Dark Oak Leaves"), S("Dark oak leaves are grown from dark oak trees."), {"mcl_core_leaves_big_oak.png"}, "#48B518", "color", "mcl_core_palette_foliage.png", "mcl_core:darksapling", 1, {20, 16, 12, 10}, 1)
register_leaves("jungleleaves", S("Jungle Leaves"), S("Jungle leaves are grown from jungle trees."), {"default_jungleleaves.png"}, "#48B518", "color", "mcl_core_palette_foliage.png", "mcl_core:junglesapling", 2, {40, 26, 32, 24, 10}, 1)
register_leaves("acacialeaves", S("Acacia Leaves"), S("Acacia leaves are grown from acacia trees."), {"default_acacia_leaves.png"}, "#48B518", "color", "mcl_core_palette_foliage.png", "mcl_core:acaciasapling", 0, {20, 16, 12, 10}, 1)
register_leaves("spruceleaves", S("Spruce Leaves"), S("Spruce leaves are grown from spruce trees."), {"mcl_core_leaves_spruce.png"}, "#619961", "none", nil, "mcl_core:sprucesapling", 0, {20, 16, 12, 10}, 0)
register_leaves("birchleaves", S("Birch Leaves"), S("Birch leaves are grown from birch trees."), {"mcl_core_leaves_birch.png"}, "#80A755", "none", nil, "mcl_core:birchsapling", 0, {20, 16, 12, 10}, 0)



-- Node aliases

minetest.register_alias("default:acacia_tree", "mcl_core:acaciatree")
minetest.register_alias("default:acacia_leaves", "mcl_core:acacialeaves")
