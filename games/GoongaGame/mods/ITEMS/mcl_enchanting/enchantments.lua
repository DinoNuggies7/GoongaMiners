local S = minetest.get_translator(minetest.get_current_modname())

-- Taken from https://minecraft.gamepedia.com/Enchanting

local function increase_damage(damage_group, factor)
	return function(itemstack, level)
		local tool_capabilities = itemstack:get_tool_capabilities()
		tool_capabilities.damage_groups[damage_group] = (tool_capabilities.damage_groups[damage_group] or 0) + level * factor
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)
	end
end

-- for tools & weapons implemented via on_enchant; for bows implemented in mcl_bows; for armor implemented in mcl_armor and mcl_tt; for fishing rods implemented in mcl_fishing
mcl_enchanting.enchantments.durability = {
	name = "Durability",
	max_level = 100,
	primary = {tool = true, craftitem = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 0,
	description = "Overall endurance of the item.",
	curse = false,
	on_enchant = function(itemstack, level)
		local name = itemstack:get_name()
		if not minetest.registered_tools[name].tool_capabilities then
			return
		end

		local tool_capabilities = itemstack:get_tool_capabilities()
		tool_capabilities.punch_attack_uses = tool_capabilities.punch_attack_uses * (1 + level)
		itemstack:get_meta():set_tool_capabilities(tool_capabilities)

		-- Updating digging durability is handled by update_groupcaps
		-- which is called from load_enchantments.
	end,
	requires_tool = false,
	treasure = false,
	-- power_range_table = {{5, 61}, {13, 71}, {21, 81}},
	inv_combat_tab = false,
	inv_tool_tab = false,
}

-- implemented via on_enchant
mcl_enchanting.enchantments.sharpness = {
	name = "Sharpness",
	max_level = 100,
	primary = {rock = true},
	secondary = {},
	disallow = {},
	incompatible = {hardness = true, bouncy = true},
	weight = 0,
	description = "This item is sharp, it will cut",
	curse = false,
	on_enchant = increase_damage("fleshy", 0.5),
	requires_tool = false,
	treasure = false,
	-- power_range_table = {{1, 21}, {12, 32}, {23, 43}, {34, 54}, {45, 65}},
	inv_combat_tab = false,
	inv_tool_tab = false,
}

mcl_enchanting.enchantments.hardness = {
	name = "Hardness",
	max_level = 100,
	primary = {rock = true, stick = true},
	secondary = {},
	disallow = {},
	incompatible = {sharpness = true, bouncy = true},
	weight = 0,
	description = "This item is hard, it will not cut, but it still hurts",
	curse = false,
	on_enchant = increase_damage("hardy", 0.5),
	requires_tool = false,
	treasure = false,
	-- power_range_table = {{1, 21}, {12, 32}, {23, 43}, {34, 54}, {45, 65}},
	inv_combat_tab = false,
	inv_tool_tab = false,
}

-- implemented in mcl_mobs and via register_on_punchplayer callback
mcl_enchanting.enchantments.aflame = {
	name = "Aflame",
	max_level = 1,
	primary = {flammable = true},
	secondary = {},
	disallow = {},
	incompatible = {},
	weight = 1,
	description = "This item is literally on fire.",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	power_range_table = {{10, 61}, {30, 71}},
	inv_combat_tab = false,
	inv_tool_tab = false,
}

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if hitter and hitter:is_player() then
		local wielditem = hitter:get_wielded_item()
		if wielditem then
			local flame_intensity = mcl_enchanting.get_enchantment(wielditem, "aflame")
			if flame_intensity > 0 then
				mcl_burning.set_on_fire(player, flame_intensity * 4)
			end
		end
	end
end)

-- implemented via minetest.calculate_knockback
mcl_enchanting.enchantments.bouncy = {
	name = "Bouncy",
	max_level = 5,
	primary = {bouncy = true},
	secondary = {},
	disallow = {},
	incompatible = {sharpness = true, hardness = true},
	weight = 0,
	description = "This item is very bouncy...",
	curse = false,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	-- power_range_table = {{5, 61}, {25, 71}},
	inv_combat_tab = false,
	inv_tool_tab = false,
}

local old_calculate_knockback = minetest.calculate_knockback
function minetest.calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
	local knockback = old_calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
	local luaentity
	if hitter then
		luaentity = hitter:get_luaentity()
	end
	if hitter and hitter:is_player() then
		local wielditem = hitter:get_wielded_item()
		knockback = knockback + 3 * mcl_enchanting.get_enchantment(wielditem, "bouncy")
	elseif luaentity and luaentity._knockback then
		knockback = knockback + luaentity._knockback
	end
	return knockback
end

--Sticks only
mcl_enchanting.enchantments.length = {
	name = "Length",
	max_level = 5,
	primary = {stick = true},
	secondary = {},
	disallow = {},
	incompatible = {rock = true},
	weight = 0,
	description = "Length of the Stick",
	curse = true,
	on_enchant = function() end,
	requires_tool = false,
	treasure = false,
	inv_combat_tab = false,
	inv_tool_tab = false,
}