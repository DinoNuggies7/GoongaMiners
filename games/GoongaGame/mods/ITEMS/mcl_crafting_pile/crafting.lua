-- minetest.register_craft({
-- 	output = "mcl_tools:crowbar",
-- 	recipe = {
-- 		"mcl_core:iron_ingot",
-- 		"mcl_core:iron_ingot",
-- 		"mcl_core:iron_ingot",
-- 	}
-- })

minetest.register_craft({
	output = "mcl_tools:rock_knife",
	recipe = {
		{ItemStack("mcl_core:dirt")}
	}
})

-- minetest.register_craft({
-- 	output = "mcl_tools:flint_knife",
-- 	recipe = {
-- 		{item = ItemStack("mcl_core:stick"), requirement = "length 2", more_than = false},
-- 		{item = ItemStack("mcl_core:cut_rock"), requirement = "sharpness 50", more_than = true},
-- 	}
-- })

-- minetest.register_craft({
-- 	output = "mcl_tools:rock_axe",
-- 	recipe = {
-- 		{item = ItemStack("mcl_core:stick"), requirement = "length 3", more_than = true},
-- 		{item = ItemStack("mcl_core:vine"), requirement = nil, more_than = nil},
-- 		{item = ItemStack("mcl_core:rock_medium"), requirement = "hardness 50", more_than = true},
-- 	}
-- })

-- minetest.register_craft({
-- 	output = "mcl_tools:rock_shovel",
-- 	recipe = {
-- 		{"mcl_core:vine", "mcl_core:rock_medium", "mcl_core:vine"},
-- 		{"", "mcl_core:stick", ""},
-- 		{"", "mcl_core:stick", ""}
-- 	}
-- })