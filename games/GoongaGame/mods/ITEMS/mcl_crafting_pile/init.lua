mcl_crafting_pile = {}

minetest.register_node("mcl_crafting_pile:crafting_pile", {
	drawtype = "nodebox",
	description = "Crafting Pile",
	_doc_items_longdesc = "A crafting pile is a pile used for crafting.",
	_doc_items_usagehelp = "Drop items on the pile to craft them",
	tiles = {"crafting_pile.png"},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
	},
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5},
	},
	paramtype = "light",
	groups = {handy=1, deco_block=1, flammable=1, attached_node = 1, place_flowerlike = 1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1},
	on_rightclick = function(pos, node, clicker)
		local items = minetest.get_objects_inside_radius(pos, 0.5)
		local crafted = false
		for _, obj in pairs(items) do
			if obj and obj:get_luaentity() and obj:get_luaentity().itemstring then
				local item = string.split(obj:get_luaentity().itemstring, " ")[1]
				local recipe = {
					ItemStack("mcl_core:stick"),
					ItemStack("mcl_core:cut_rock"),
				}
				local result = minetest.get_craft_result({method = "normal", width = 1, items = {ItemStack(item)}})
				minetest.chat_send_all(item.." > "..tostring(result.item))
				if result.item and not result.item:is_empty() then
					minetest.clear_objects(pos, 1)
					minetest.add_item(pos, result.item)
				end
			end
		end
	end,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.01,
})

minetest.register_craft({
	output = "mcl_crafting_pile:crafting_pile",
	recipe = {
		{"mcl_core:rock_small", "group:leaves"},
		{"group:leaves", "mcl_core:rock_small"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_crafting_pile:crafting_pile",
	burntime = 15,
})

minetest.register_alias("crafting:workbench", "mcl_crafting_pile:crafting_pile")
minetest.register_alias("mcl_inventory:workbench", "mcl_crafting_pile:crafting_pile")
