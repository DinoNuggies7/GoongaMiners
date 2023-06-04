bettertrees = {
    path = minetest.get_modpath('bettertrees'),
    mods = {
        default = minetest.global_exists('default'),
        armor = minetest.global_exists('3d_armor'),
        mcl = minetest.global_exists('mcl_core'),
        -- stripped_tree = minetest.global_exists('stripped_tree'),
        -- hunger_ng = minetest.global_exists('hunger_ng')
    },
    config = {
        bushy = minetest.settings:get_bool('bettertrees.bushy', true),
        cheap_bushy = minetest.settings:get_bool('bettertrees.cheap_bushy', false)
    }
}

if bettertrees.mods.default then
    bettertrees.stick = 'default:stick'
    bettertrees.stick_sound = default.node_sound_wood_defaults()
elseif bettertrees.mods.mcl then
    bettertrees.stick = 'mcl_core:stick'
    bettertrees.stick_sound = mcl_sounds.node_sound_wood_defaults()
else
    bettertrees.stick = nil
    bettertrees.stick_sound = nil
end

--- Runs code to place hidden node that regenerates leaves
---@param pos table
---@param node_name string
local function spawn_hidden(pos, node_name)
    minetest.set_node(pos, {
        name = "bettertrees:hidden"
    })
    local meta = minetest.get_meta(pos)
    meta:set_string("leaf", node_name)
end

--- Runs code to break leaves, by either dropping them or decaying them into sticks
---@param pos table
---@param node_name string
---@param decay boolean
local function break_leaf(pos, node_name, decay)
    if decay == true and bettertrees.stick then
        minetest.swap_node(pos, {
            name = bettertrees.stick
        })
        minetest.check_single_for_falling(pos)
    else
        minetest.dig_node(pos)
    end
    spawn_hidden(pos, node_name)
end

minetest.register_on_mods_loaded(function()
    local tree_nodes = {}
    local dirt_nodes = {}
    for node_name, def in pairs(minetest.registered_nodes) do
        if def.groups and def.groups.leaves then
            local override = {}
            if not string.match(node_name, "bush") then
                override = {
                    walkable = false,
                    climbable = true,
                    -- Climbing through leaves should slow players down
                    move_resistance = 3,
                    waving = 2,
                    -- Make leaves fall when placed
                    after_place_node = function(pos, oldnode, oldmeta, drops)
                        minetest.spawn_falling_node(pos)
                    end,
                    -- Adapted from Tenplus1's regrow mod, licensed under MIT
                    after_dig_node = function(pos, oldnode, oldmetadata, digger)
                        -- if node has been placed by player then do not regrow
                        if oldnode.param2 > 0 then
                            return
                        end
                        -- replace leaf with regrowth node, set leaf name
                        spawn_hidden(pos, node_name)
                    end,
                    on_construct = function(pos)
                        local time = math.random(60 * 20, 60 * 30)
                        minetest.get_node_timer(pos):start(time)
                    end,
                    -- when timer reached, check which leaf to remove
                    on_timer = function(pos, elapsed)
                        if math.random(200) == 1 then
                            local pos2 = table.copy(pos)
                            pos2.y = pos2.y - 1
                            local check_node = minetest.get_node(pos2)
                            if check_node.name == 'air' then
                                break_leaf(pos, node_name, true)
                                return false
                            end
                        end
                        return true
                    end
                }
            end
            if bettertrees.config.bushy then
                override.drawtype = 'mesh'
                override.mesh = bettertrees.config.bushy_cheap and "bushy_leaves_cheap_model.obj" or "bushy_leaves_full_model.obj"
            end
            minetest.override_item(node_name, override)
        elseif def.groups and def.groups.tree then
            table.insert(tree_nodes, node_name)
            local groups = table.copy(def.groups)
            groups.oddly_breakable_by_hand = 0
            groups.falling_node = 1
            minetest.override_item(node_name, {
                groups = groups,
                on_punch = function(pos, node, puncher, pointed_thing)
                    local wielded_item = puncher:get_wielded_item();
                    if wielded_item:is_empty() then
                        -- take a little damage
                        local hp = puncher:get_hp()
                        puncher:set_hp(hp - 0.1, 'node_damage')
                    end
                    minetest.node_punch(pos, node, puncher, pointed_thing)
                end
            })
        elseif def.groups and (def.groups.soil or def.groups.snowy) then
            table.insert(dirt_nodes, node_name)
        elseif def.groups and def.groups.leafdecay_drop then
            minetest.override_item(node_name, {
                after_dig_node = function(pos, oldnode, oldmetadata, digger)
                    -- if node has been placed by player then do not regrow
                    if oldnode.param2 > 0 then
                        return
                    end
                    -- replace leaf with regrowth node, set leaf name
                    minetest.set_node(pos, {
                        name = "bettertrees:hidden"
                    })
                    local meta = minetest.get_meta(pos)
                    meta:set_string("leaf", minetest.get_node(minetest.find_node_near(pos, 1, 'group:leaves')).name)
                    meta:set_string("fruit", node_name)
                end
            })
        end
    end
    minetest.log('verbose', 'bettertrees: tree_nodes = '..minetest.serialize(tree_nodes))
    minetest.log('verbose', 'bettertrees: dirt_nodes = '..minetest.serialize(dirt_nodes))
    if bettertrees.stick then
        minetest.register_decoration({
            name = bettertrees.stick,
            deco_type = 'simple',
            place_on = dirt_nodes,
            sidelen = 8,
            decoration = bettertrees.stick,
            rotation = 'random',
            spawn_by = tree_nodes,
            num_spawn_by = 1,
            fill_ratio = 0.1,
        })
    end
end)

-- Regrow leaves or fruit, adapted from Tenplus1's regrow mod, licensed under MIT
minetest.register_node('bettertrees:hidden', {
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drop = "",
    groups = {
        not_in_creative_inventory = 1
    },
    -- once placed start random timer between 20 and 30 minutes
    on_construct = function(pos)
        local time = math.random(60 * 20, 60 * 30)
        minetest.get_node_timer(pos):start(time)
    end,
    -- when timer reached check which leaf or fruit to place if tree still exists
    on_timer = function(pos, elapsed)
        local meta = minetest.get_meta(pos)
        if not meta then
            return
        end
        local fruit = meta:get_string("fruit") or ""
        local leaf = meta:get_string("leaf") or ""
        if fruit == "" then
            if leaf == "" or not minetest.find_node_near(pos, 1, leaf) then
                leaf = "air"
            end
            minetest.set_node(pos, {
                name = leaf
            })
        else
            if leaf == "" or fruit == "" or not minetest.find_node_near(pos, 1, leaf) then
                fruit = "air"
            end
            minetest.set_node(pos, {
                name = fruit
            })
        end
    end
})

if bettertrees.stick then
    -- Basically strip leaves off branches
    minetest.register_craft({
        type = 'shapeless',
        output = bettertrees.stick,
        recipe = {'group:leaves'}
        -- replacements = 'pile of leaves?'
    })
    minetest.register_node(':'..bettertrees.stick, {
        description = 'Stick',
        drawtype = 'mesh',
        paramtype = 'light',
        paramtype2 = 'none',
        selection_box = {
            type = 'fixed',
            fixed = {-8 / 16, -8 / 16, -8 / 16, 8 / 16, -7 / 16, 8 / 16}
        },
        mesh = 'extrusion_mesh_16.obj',
        tiles = {'default_stick.png'},
        use_texture_alpha = 'clip',
        inventory_image = "default_stick.png",
        wield_image = "default_stick.png",
        floodable = true,
        walkable = false,
        sunlight_propagates = true,
        buildable_to = true,
        is_ground_content = false,
        groups = {
            stick = 1,
            falling_node = 1,
            oddly_breakable_by_hand = 3,
            snappy = 3,
            flammable = 2,
            choppy = 3,
            attached_node = 1,
            dig_immediate = 3,
        },
        sounds = bettertrees.stick_sound
    })
end

-- chance of limbs breaking while player is in leaves
minetest.register_globalstep(function(dtime)
    local players = minetest.get_connected_players()
    for i, player in ipairs(players) do
        if minetest.is_player(player) then
            local pos = player:get_pos()
            local pos2 = table.copy(pos)
            pos2.y = pos2.y + 1
            local nodes = minetest.find_nodes_in_area(pos, pos2, 'group:leaves', true)
            for node_name, node_poss in pairs(nodes) do
                for i, node_pos in ipairs(node_poss) do
                    local chance = 200
                    -- calculate "weight" of armor and deduct from `chance`
                    if bettertrees.mods.armor then
                        local sum_gravity = 1
                        local worn_armor = armor:get_weared_armor_elements(player)
                        for el, i in ipairs(worn_armor) do
                            if el.groups and el.groups.physics_gravity then
                                sum_gravity = sum_gravity + (el.groups.physics_gravity * 10)
                            end
                        end
                        chance = chance / sum_gravity
                    end
                    if math.random(chance) == 1 then
                        break_leaf(node_pos, node_name, false)
                    end
                end
            end
        end
    end
end)
