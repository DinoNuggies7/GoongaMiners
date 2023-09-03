local minetest, math = minetest, math
mcl_offhand = {}

local max_offhand_px = 128
-- only supports up to 128px textures

function mcl_offhand.get_offhand(player, index)
	return player:get_inventory():get_stack("main", index)
end

local function offhand_get_wear(player, index)
	return mcl_offhand.get_offhand(player, index):get_wear()
end

local function offhand_get_count(player, index)
	return mcl_offhand.get_offhand(player, index):get_count()
end

minetest.register_on_joinplayer(function(player, last_login)
	mcl_offhand[player] = {
		hud = {},
		last_wear1 = offhand_get_wear(player, 1),
		last_count1 = offhand_get_count(player, 1),
		last_wear2 = offhand_get_wear(player, 2),
		last_count2 = offhand_get_count(player, 2),
	}
end)

local function remove_hud(player, hud)
	local offhand_hud = mcl_offhand[player].hud[hud]
	if offhand_hud then
		player:hud_remove(offhand_hud)
		mcl_offhand[player].hud[hud] = nil
	end
end

function rgb_to_hex(r, g, b)
	return string.format("%02x%02x%02x", r, g, b)
end

local function update_wear_bar1(player, itemstack)
	local wear_bar_percent = (65535 - offhand_get_wear(player, 1)) / 65535

	local color = {255, 255, 255}
	local wear = itemstack:get_wear() / 65535;
	local wear_i = math.min(math.floor(wear * 600), 511);
	wear_i = math.min(wear_i + 10, 511);
	if wear_i <= 255 then
		color = {wear_i, 255, 0}
	else
		color = {255, 511 - wear_i, 0}
	end
	local wear_bar = mcl_offhand[player].hud.wear_bar1
	player:hud_change(wear_bar, "text", "mcl_wear_bar.png^[colorize:#" .. rgb_to_hex(color[1], color[2], color[3]))
	player:hud_change(wear_bar, "scale", {x = 40 * wear_bar_percent, y = 3})
	player:hud_change(wear_bar, "offset", {x = -320 - (20 - player:hud_get(wear_bar).scale.x / 2), y = -13})
end

local function update_wear_bar2(player, itemstack)
	local wear_bar_percent = (65535 - offhand_get_wear(player, 2)) / 65535

	local color = {255, 255, 255}
	local wear = itemstack:get_wear() / 65535;
	local wear_i = math.min(math.floor(wear * 600), 511);
	wear_i = math.min(wear_i + 10, 511);
	if wear_i <= 255 then
		color = {wear_i, 255, 0}
	else
		color = {255, 511 - wear_i, 0}
	end
	local wear_bar = mcl_offhand[player].hud.wear_bar2
	player:hud_change(wear_bar, "text", "mcl_wear_bar.png^[colorize:#" .. rgb_to_hex(color[1], color[2], color[3]))
	player:hud_change(wear_bar, "scale", {x = 40 * wear_bar_percent, y = 3})
	player:hud_change(wear_bar, "offset", {x = -320 - (20 - player:hud_get(wear_bar).scale.x / 2), y = -13})
end

local swapped = false
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local itemstack1 = mcl_offhand.get_offhand(player, 1)
		local itemstack2 = mcl_offhand.get_offhand(player, 2)
		local offhand_item1 = itemstack1:get_name()
		local offhand_item2 = itemstack2:get_name()
		local offhand_hud = mcl_offhand[player].hud
		local item1 = minetest.registered_items[offhand_item1]
		local item2 = minetest.registered_items[offhand_item2]
		if not swapped and player:get_player_control().aux1 then
			local inventory = player:get_inventory()
			inventory:set_stack("main", 1, itemstack2)
			inventory:set_stack("main", 2, itemstack1)
		end
		if player:get_player_control().aux1 then swapped = true else swapped = false end
		if offhand_item1 ~= "" and item1 then
			local item_texture = item1.inventory_image .. "^[resize:" .. max_offhand_px .. "x" .. max_offhand_px
			local position = {x = 0.5, y = 1}
			local offset = {x = 160, y = -32}

			if not offhand_hud.slot1 then
				offhand_hud.slot1 = player:hud_add({
					hud_elem_type = "image",
					position = position,
					offset = offset,
					scale = {x = 3, y = 3},
					text = "mcl_offhand_slot.png",
					z_index = 0,
				})
			end
			if not offhand_hud.item1 then
				offhand_hud.item1 = player:hud_add({
					hud_elem_type = "image",
					position = position,
					offset = offset,
					scale = {x = 0.375, y = 0.375},
					text = item_texture,
					z_index = 2,
				})
			else
				player:hud_change(offhand_hud.item1, "text", item_texture)
			end
			if not offhand_hud.wear_bar_bg1 and minetest.registered_tools[offhand_item1] then
				if offhand_get_wear(player, 1) > 0 then
					local texture = "mcl_wear_bar.png^[colorize:#000000"
					offhand_hud.wear_bar_bg1 = player:hud_add({
						hud_elem_type = "image",
						position = position,
						offset = {x = 160, y = -13},
						scale = {x = 40, y = 3},
						text = texture,
						z_index = 4,
					})
					offhand_hud.wear_bar1 = player:hud_add({
						hud_elem_type = "image",
						position = position,
						offset = {x = 160, y = -13},
						scale = {x = 10, y = 3},
						text = texture,
						z_index = 6,
					})
					update_wear_bar1(player, itemstack1)
				end
			end

			if not offhand_hud.item_count1 and offhand_get_count(player, 1) > 1 then
				offhand_hud.item_count1 = player:hud_add({
					hud_elem_type = "text",
					position = position,
					offset = {x = 182, y = -18},
					scale = {x = 1, y = 1},
					alignment = {x = -1, y = 0},
					text = offhand_get_count(player, 1),
					z_index = 8,
					number = 0xFFFFFF,
				})
			end

			if offhand_hud.wear_bar1 then
				if offhand_hud.last_wear1 ~= offhand_get_wear(player, 1) then
					update_wear_bar1(player, itemstack1)
					offhand_hud.last_wear1 = offhand_get_wear(player, 1)
				end
				if offhand_get_wear(player, 1) <= 0 or not minetest.registered_tools[offhand_item1] then
					remove_hud(player, "wear_bar_bg1")
					remove_hud(player, "wear_bar1")
				end
			end

			if offhand_hud.item_count1 then
				if offhand_hud.last_count1 ~= offhand_get_count(player, 1) then
					player:hud_change(offhand_hud.item_count1, "text", offhand_get_count(player, 1))
					offhand_hud.last_count1 = offhand_get_count(player, 1)
				end
				if offhand_get_count(player, 1) <= 1 then
					remove_hud(player, "item_count1")
				end
			end

		else
			remove_hud(player, "item1")
			remove_hud(player, "item_count1")
			remove_hud(player, "wear_bar1")
			remove_hud(player, "wear_bar_bg1")
		end

		if offhand_item2 ~= "" and item2 then
			local item_texture = item2.inventory_image .. "^[resize:" .. max_offhand_px .. "x" .. max_offhand_px
			local position = {x = 0.5, y = 1}
			local offset = {x = -160, y = -32}

			if not offhand_hud.slot2 then
				offhand_hud.slot2 = player:hud_add({
					hud_elem_type = "image",
					position = position,
					offset = offset,
					scale = {x = 3, y = 3},
					text = "mcl_offhand_slot.png",
					z_index = 1,
				})
			end
			if not offhand_hud.item2 then
				offhand_hud.item2 = player:hud_add({
					hud_elem_type = "image",
					position = position,
					offset = offset,
					scale = {x = 0.375, y = 0.375},
					text = item_texture,
					z_index = 3,
				})
			else
				player:hud_change(offhand_hud.item2, "text", item_texture)
			end
			if not offhand_hud.wear_bar_bg2 and minetest.registered_tools[offhand_item2] then
				if offhand_get_wear(player, 2) > 0 then
					local texture = "mcl_wear_bar.png^[colorize:#000000"
					offhand_hud.wear_bar_bg2 = player:hud_add({
						hud_elem_type = "image",
						position = position,
						offset = {x = -160, y = -13},
						scale = {x = 40, y = 3},
						text = texture,
						z_index = 5,
					})
					offhand_hud.wear_bar2 = player:hud_add({
						hud_elem_type = "image",
						position = position,
						offset = {x = -160, y = -13},
						scale = {x = 10, y = 3},
						text = texture,
						z_index = 7,
					})
					update_wear_bar2(player, itemstack2)
				end
			end

			if not offhand_hud.item_count2 and offhand_get_count(player, 2) > 1 then
				offhand_hud.item_count2 = player:hud_add({
					hud_elem_type = "text",
					position = position,
					offset = {x = -138, y = -18},
					scale = {x = 1, y = 1},
					alignment = {x = -1, y = 0},
					text = offhand_get_count(player, 2),
					z_index = 9,
					number = 0xFFFFFF,
				})
			end

			if offhand_hud.wear_bar2 then
				if offhand_hud.last_wear2 ~= offhand_get_wear(player, 2) then
					update_wear_bar2(player, itemstack2)
					offhand_hud.last_wear2 = offhand_get_wear(player, 2)
				end
				if offhand_get_wear(player, 2) <= 0 or not minetest.registered_tools[offhand_item2] then
					remove_hud(player, "wear_bar_bg2")
					remove_hud(player, "wear_bar2")
				end
			end

			if offhand_hud.item_count2 then
				if offhand_hud.last_count2 ~= offhand_get_count(player, 2) then
					player:hud_change(offhand_hud.item_count2, "text", offhand_get_count(player, 2))
					offhand_hud.last_count2 = offhand_get_count(player, 2)
				end
				if offhand_get_count(player, 2) <= 1 then
					remove_hud(player, "item_count2")
				end
			end

		else
			remove_hud(player, "item2")
			remove_hud(player, "item_count2")
			remove_hud(player, "wear_bar2")
			remove_hud(player, "wear_bar_bg2")
		end
	end
end)

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "move" and inventory_info.to_list == "offhand" then
		local itemstack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
		return itemstack:get_stack_max()
		-- if not (minetest.get_item_group(itemstack:get_name(), "offhand_item") > 0)  then
		-- 	return 0
		-- else
		-- 	return itemstack:get_stack_max()
		-- end
	end
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	local from_offhand = inventory_info.from_list == "offhand"
	local to_offhand = inventory_info.to_list == "offhand"
	if action == "move" and from_offhand or to_offhand then
		mcl_inventory.update_inventory_formspec(player)
	end
end)
