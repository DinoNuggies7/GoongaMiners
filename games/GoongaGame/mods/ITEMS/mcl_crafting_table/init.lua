local S = minetest.get_translator(minetest.get_current_modname())
local formspec_escape = minetest.formspec_escape
local show_formspec = minetest.show_formspec
local C = minetest.colorize
local text_color = "#313131"
local itemslot_bg = mcl_formspec.get_itemslot_bg

mcl_crafting_pile = {}

function mcl_crafting_pile.show_crafting_form(player)
	player:get_inventory():set_width("craft", 3)
	player:get_inventory():set_size("craft", 9)

	show_formspec(player:get_player_name(), "main",
		"size[9,8.75]"..
		"image[4.7,1.5;1.5,1;gui_crafting_arrow.png]"..
		"label[0,4;"..formspec_escape(C(text_color, S("Inventory"))).."]"..
		"list[current_player;main;0,4.5;9,3;9]"..
		itemslot_bg(0,4.5,9,3)..
		"list[current_player;main;0,7.74;9,1;]"..
		itemslot_bg(0,7.74,9,1)..
		"label[1.75,0;"..formspec_escape(C(text_color, S("Crafting"))).."]"..
		"list[current_player;craft;1.75,0.5;3,3;]"..
		itemslot_bg(1.75,0.5,3,3)..
		"list[current_player;craftpreview;6.1,1.5;1,1;]"..
		itemslot_bg(6.1,1.5,1,1)..
		"image_button[0.75,1.5;1,1;craftguide_book.png;__mcl_craftguide;]"..
		"tooltip[__mcl_craftguide;"..formspec_escape(S("Recipe book")).."]"..
		"listring[current_player;main]"..
		"listring[current_player;craft]"
	)
end

local pile_box = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
minetest.register_node("mcl_crafting_pile:crafting_pile", {
	drawtype = "nodebox",
	description = S("Crafting Pile"),
	_tt_help = S("3×3 crafting grid"),
	_doc_items_longdesc = S("A crafting pile is a pile which grants you access to a 3×3 crafting grid which allows you to perform advanced crafts."),
	_doc_items_usagehelp = S("Rightclick the crafting pile to access the 3×3 crafting grid."),
	_doc_items_hidden = false,
	is_ground_content = false,
	tiles = {"crafting_pile.png"},
	selection_box = {
		type = "fixed",
		fixed = {pile_box},
	},
	node_box = {
		type = "fixed",
		fixed = {pile_box},
	},
	paramtype = "light",
	groups = {handy=1, deco_block=1, flammable=1, attached_node = 1, place_flowerlike = 1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1},
	on_rightclick = function(pos, node, player, itemstack)
		if not player:get_player_control().sneak then
			mcl_crafting_pile.show_crafting_form(player)
		end
	end,
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.01,
})

minetest.register_craft({
	output = "mcl_crafting_pile:crafting_pile",
	recipe = {
		{"mcl_core:rock", "group:leaves"},
		{"group:leaves", "mcl_core:rock"}
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_crafting_pile:crafting_pile",
	burntime = 15,
})

minetest.register_alias("crafting:workbench", "mcl_crafting_pile:crafting_pile")
minetest.register_alias("mcl_inventory:workbench", "mcl_crafting_pile:crafting_pile")
