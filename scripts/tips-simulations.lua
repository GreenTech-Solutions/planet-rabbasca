require("__core__/lualib/story")
require("__planet-rabbasca__.control")
Rabbasca.events.init_simulation() -- simulations dont call on_init or on_load

function simulation_warp_network()
    local surface = game.surfaces[1]
    surface.ignore_surface_conditions = true
    local player = game.simulation.create_test_player { name = "carrot" }
    player.force.technologies["interplanetary-construction-3"].research_recursive()

    player.teleport({ -30, -25 })
    game.simulation.camera_player = player
    game.simulation.camera_alt_info = true
    game.simulation.camera_zoom = 1.3
    game.simulation.camera_position = { -30, -30 }
    game.simulation.camera_player_cursor_position = { -30, -25 }
    game.simulation.gui_tooltip_interval = 0.5

    surface.build_checkerboard({ { -64, -64 }, { 64, 64 } })

    local uplink = surface.create_entity {
        name = "rabbasca-warp-uplink",
        position = { -30, -30 },
        force = player.force,
        raise_built = true
    }
    local tiles = {
        { position = { -4, 0 }, name = "rabbasca-energetic-concrete" },
        { position = { -5, 0 }, name = "rabbasca-energetic-concrete" },
        { position = { -4, 1 }, name = "rabbasca-energetic-concrete" },
        { position = { -5, 1 }, name = "rabbasca-energetic-concrete" },
    }
    surface.set_tiles(tiles, true)
    local pylon = surface.create_entity {
        name = "rabbasca-warp-pylon",
        position = { -4, 1 },
        force = player.force,
        raise_built = true
    }

    local chest = surface.create_entity {
        name = "steel-chest",
        position = { 0, 0 },
        force = player.force,
    }
    chest.get_inventory(defines.inventory.chest).insert({ name = "steel-plate", count = "1000" })
    chest.get_inventory(defines.inventory.chest).insert({ name = "coal", count = "1000" })

    player.insert("rocket-silo")
    player.insert("iron-plate")
    player.insert("construction-robot")
    player.insert({ name = "assembling-machine-1", count = 1 })
    player.insert({ name = "assembling-machine-2", count = 1 })
    player.insert({ name = "rabbasca-warp-pylon", count = 1 })
    player.insert({ name = "speed-module-3", count = 3 })

    local story_table =
    {
        {
            {
                name = "start",
                condition = story_elapsed_check(3),
            },
            {
                condition = function() return game.simulation.move_cursor({ position = uplink.position, speed = 0.2 }) end,
                action = function()
                    player.opened = uplink
                end,
            },
            { condition = story_elapsed_check(3) },
            {
                condition = function()
                    local target = game.simulation.get_slot_position({ inventory_index = defines.inventory
                    .character_main, slot_index = 17, inventory = "character" })
                    return game.simulation.move_cursor({ position = target, speed = 0.25 })
                end,
                action = function()
                    game.simulation.control_press { control = "inventory-transfer", notify = true }
                end
            },
            {
                condition = story_elapsed_check(5),
                action = function() player.opened = nil end
            },
            {
                condition = story_elapsed_check(2),
                action = function()
                    game.simulation.camera_position = { 0, 5 }
                    game.simulation.camera_player_cursor_position = { 0, 5 }
                    game.simulation.camera_zoom = 0.7
                end
            },
            {
                condition = story_elapsed_check(3),
                action = function()
                    surface.create_entity { name = "entity-ghost", inner_name = "rocket-silo", force = player.force, position = { -10, 0 }, raise_built = true }
                    surface.create_entity { name = "entity-ghost", inner_name = "rocket-silo", force = player.force, position = { 10, 0 }, raise_built = true }
                    surface.create_entity { name = "entity-ghost", inner_name = "assembling-machine-1", force = player.force, position = { -2, 5 }, raise_built = true }
                    surface.create_entity { name = "entity-ghost", inner_name = "assembling-machine-1", force = player.force, position = { 2, 5 }, raise_built = true }
                    for x = 4, 5 do
                        for y = 0, 1 do
                            surface.create_entity { name = "tile-ghost", inner_name = "rabbasca-energetic-concrete", force = player.force, position = { x, y }, raise_built = true }
                        end
                    end
                    surface.create_entity { name = "entity-ghost", inner_name = "rabbasca-warp-pylon", force = player.force, position = { 5, 1 }, raise_built = true }
                end
            },
            {
                condition = story_elapsed_check(11),
                action = function()
                    local silo = surface.find_entity("rocket-silo", { -10, 0 }) or
                    surface.find_entity("rocket-silo", { 10, 0 })
                    silo.order_deconstruction(player.force)
                end
            },
            {
                condition = story_elapsed_check(6),
                action = function()
                    local asm = surface.find_entity("assembling-machine-1", { -2, 5 }) or
                    surface.find_entity("assembling-machine-1", { 2, 5 })
                    asm.order_upgrade { target = "assembling-machine-2", force = player.force }
                end
            },
            {
                condition = story_elapsed_check(7),
                action = function()
                    player.insert("rabbasca-energetic-concrete")
                    player.opened = uplink
                end
            },
            {
                init = function()
                    player.insert("rabbasca-energetic-concrete")
                    player.opened = uplink
                end,
                condition = function()
                    local target = game.simulation.get_slot_position { inventory_index = defines.inventory.character_main, slot_index = 1, inventory = "character" }
                    return game.simulation.move_cursor({ position = target, speed = 0.2 }) and story_elapsed_check(5)
                end,
                action = function()
                    game.simulation.control_press { control = "stack-transfer", notify = true }
                end
            },
            {
                condition = story_elapsed_check(2),
                action = function()
                    player.opened = nil
                end
            },
            {
                condition = story_elapsed_check(10),
                action = function()
                    chest.order_deconstruction(player.force)
                end
            },
            {
                condition = story_elapsed_check(10),
                action = function()
                    player.teleport({ 0, -5 })
                    player.opened = pylon
                end
            },
        }
    }

    tip_story_init(story_table)
end

function simulation_briefing()
    local offset = { 26, 33 }
    game.simulation.camera_position = offset
    game.simulation.camera_zoom = 0.4
    game.simulation.camera_alt_info = true

    local surface = game.surfaces[1]
    local gen = game.planets["rabbasca"].prototype.map_gen_settings
    gen.seed = 61212
    surface.map_gen_settings = gen
    game.forces.player.technologies["rabbascan-vault-access"].research_recursive()
    surface.request_to_generate_chunks(offset, 3)
    game.forces.rabbascans.set_evolution_factor(1, surface)
    surface.force_generate_chunk_requests()
    surface.create_global_electric_network()
    surface.create_entity {
        name = "electric-furnace",
        position = { 14, 35 },
        force = game.forces.player,
    }
    surface.create_entity {
        name = "inserter",
        position = { 14, 37 },
        force = game.forces.player,
        direction = defines.direction.north,
    }
    surface.create_entity {
        name = "steel-chest",
        position = { 14, 38 },
        force = game.forces.player,
        direction = defines.direction.north,
    }
    surface.create_entity {
        name = "electric-mining-drill",
        position = { 14, 32 },
        direction = defines.direction.south,
        force = game.forces.player,
    }
end

function simulation_vaults()
    local offset = { 68, 104 }
    game.simulation.camera_position = offset
    game.simulation.camera_zoom = 0.8
    game.simulation.camera_alt_info = true


    local surface = game.surfaces[1]
    local gen = game.planets["rabbasca"].prototype.map_gen_settings
    gen.seed = 517
    surface.map_gen_settings = gen
    surface.request_to_generate_chunks(offset, 4)
    surface.force_generate_chunk_requests()
    surface.create_global_electric_network()

    local player = game.simulation.create_test_player { name = "robbery" }
    player.force.custom_color = { 1, 0.5, 0 }
    player.force.technologies["rabbasca-document-forging-1"].research_recursive()
    local vault = surface.find_entity("rabbasca-vault-crafter", { offset[1] - 6, offset[2] })
    -- vault.set_recipe("vault-protocol-iron-ore")

    for x = -40, 40 do
        surface.create_entity {
            name = "fast-transport-belt",
            position = { offset[1] + x, offset[2] + 6 },
            direction = defines.direction.west,
            force = player.force
        }
    end

    surface.create_entity {
        name = "fast-inserter",
        position = { offset[1] + 12, offset[2] + 5 },
        force = player.force,
        direction = defines.direction.south
    }
    surface.create_entity {
        name = "fast-inserter",
        position = { offset[1] + 12, offset[2] + 7 },
        force = player.force,
        direction = defines.direction.north
    }
    surface.create_entity {
        name = "gun-turret",
        position = { offset[1] + 12, offset[2] + 9 },
        force = player.force
    }
    surface.create_entity {
        name = "gun-turret",
        position = { offset[1] + 12, offset[2] + 4 },
        force = player.force
    }

    surface.create_entity {
        name = "fast-inserter",
        position = { offset[1] + 36, offset[2] + 5 },
        force = player.force,
        direction = defines.direction.north
    }
    surface.create_entity {
        name = "fast-inserter",
        position = { offset[1] + 36, offset[2] + 7 },
        force = player.force,
        direction = defines.direction.south
    }
    surface.create_entity {
        name = "steel-chest",
        position = { offset[1] + 36, offset[2] + 4 },
        force = player.force,
    }.insert("firearm-magazine")
    surface.create_entity {
        name = "steel-chest",
        position = { offset[1] + 36, offset[2] + 8 },
        force = player.force,
    }.insert({ name = "vault-access-key", count = 200 })

    tip_story_init { {
        {
            condition = function() return vault.force == player.force end,
        },
        {
            condition = story_elapsed_check(4),
        },
        {
            init = function() 
                player.teleport(vault.position)
                game.simulation.camera_player = player
                game.simulation.camera_player_cursor_position = offset 
            end,
            condition = function()
                return game.simulation.move_cursor({ position = vault.position, speed = 0.2 })
            end,
            action = function()
                game.simulation.mouse_click()
            end
        },
        {
            init = function() 
                player.teleport(vault.position)
                game.simulation.camera_player = player
                game.simulation.camera_player_cursor_position = offset 
            end,
            condition = function()
                local target = game.simulation.get_widget_position{ type = "recipe-slot", recipe = "vault-protocol-iron-ore" }
                if not target then return end
                return game.simulation.move_cursor({ position = target, speed = 0.2 })
            end,
            action = function()
                game.simulation.mouse_click()
            end
        },
        {
            condition = story_elapsed_check(4),
            action = function()
                player.opened = nil
            end
        },
    } }
end
