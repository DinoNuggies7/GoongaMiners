minetest.register_on_dieplayer(function(player)
	minetest.chat_send_player(player:get_player_name(), "You died at "..tostring(math.floor(player:get_pos().x))..","..tostring(math.floor(player:get_pos().y))..","..tostring(math.floor(player:get_pos().z)))
end)