require("__core__/lualib/story")
require("__planet-rabbasca__.control")
Rabbasca.events.init_simulation()

function simulation_warp_network()
    local surface = game.surfaces[1]
    surface.ignore_surface_conditions = true
    local player = game.simulation.create_test_player { name = "Carrot" }
    player.force.technologies["interplanetary-construction-3"].research_recursive()

    player.teleport({-30, -25})
    game.simulation.camera_player = player
    game.simulation.camera_alt_info = true
    game.simulation.camera_zoom = 0.5
    game.simulation.camera_position = { -30, -30 }
    game.simulation.camera_player_cursor_position = { -30, -25 }
    game.simulation.gui_tooltip_interval = 0.5

    local pylon = surface.create_entity {
        name = "rabbasca-warp-pylon",
        position = { 0, 0 },
        force = player.force,
        raise_built = true
    }

    surface.build_checkerboard({{-64, -64}, {64, 64}})

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
            init = function() 
                uplink = surface.create_entity {
                    name = "rabbasca-warp-uplink",
                    position = { -30, -30 },
                    force = player.force,
                    raise_built = true
                }
                table.insert(storage.inventory_warpers, uplink)
            end,
            condition = function() return game.simulation.move_cursor({ position = uplink.position, speed = 0.2 }) end,
            action = function()
                player.opened = uplink
            end, 
        },
        { condition = story_elapsed_check(3) },
        {
            condition = function() 
                local target = game.simulation.get_slot_position({ inventory_index = defines.inventory.character_main, slot_index =  17, inventory = "character" })
                return game.simulation.move_cursor({position = target, speed = 0.25})
            end,
            action = function() 
                game.simulation.control_press{ control = "inventory-transfer", notify = true } 
                assert(false, serpent.block(storage))
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
            end
        },
      }
    }

    tip_story_init(story_table)
end

function simulation_briefing() 
    local offset = { -113, 31 }
    game.simulation.camera_position = offset
    game.simulation.camera_zoom = 1.1
    game.simulation.camera_alt_info = true

    local surface = game.surfaces[1]
    surface.create_global_electric_network()
    game.forces.player.technologies["rabbascan-vault-access"].researched = true

    local tiles = { }
    for x = -32, 32 do
        for y = -32, 32 do
            table.insert(tiles, { name = "rabbasca-rough", position = { x + offset[1], y + offset[2] } })
        end
    end
    surface.set_tiles(tiles)
    local s = surface.map_gen_settings
    s.seed = 8
    s.autoplace_settings = prototypes["space_location"]["rabbasca"].map_gen_settings.autoplace_settings
    surface.map_gen_settings = s
    surface.regenerate_entity() -- Does not do anything????
    surface.regenerate_decorative()
    surface.create_entities_from_blueprint_string { position = { offset[1] + 1, offset[2] - 1 }, string = "0eNrVmt1uo0gQhd+FazPqX6At7ZOsRhbBbW8r0GShiTYT+d0HnPXPaBinTmkvZu/iAF8XpzlU69Dv2VM7+ZchxJRt37PQ9HHMtn++Z2M4xrpd/hfrzmfbLA11HF/6IeVPvk3ZaZOFuPf/ZFt5+rrJfEwhBf9x7fnH2y5O3ZMf5hM2F4ZvfZOG0ORdiCEe8/0Q2jbbZC/9OF/dx2W4mZhLWX6xm+wt2yrzxc5D7cMwX3k+ozptfhpBMUYw0AiaMYKERjDXEYa+efYpT9Mw+LRGVld15j9OKyx7ZR3qMeUhjn5I84E1lr1n/VClWSEXm188D2voq8QFBV2y0L9QoEJgGqrTsdA/qSvVClsKBK5AuGTBSaJIhbAFxtYIW2Jsw2ITBbcsUYhwxIqywlRBvCgdxq5YbKIojiUKDa4Qc8oShCPmlAUIVyw4aT6VZqlCYyPulBYUBXGnNCC8YMFpqpQsVWhsyJ1gd1OQO8HupgULTlJFS5YqNDbkTbADacicYAfShgWnqWJZqtDYiDcF2IE0Yk4BdiBdseA0VRxLFRLbIN4UYOc0iDkF2DmNYsFpqmiWKjQ24k2B9R9jWWyi4JA5wZZvShacpgrkTbBzGsicYOe0ggUnqWIlSxUaW9FjDgH2Ngt5E+zK1rDgBSVGspacI7nqsxipAHKka5nVucxDaOczP/LAS1B4pb3WU5vyumn8OObP/m0G/j3V7Tz2fDD2Q1cviVrTdy/1UKd+LiX7I1tixmn0uys5DZNfq7oEqhZA1YdZ+Xro8q4+1t9C9P9t1RXwMBe/TdUOqNr+LlUXtxfecYqPglZ1LliLNXcUkkoRjyiKSBHlI4qmUuwjyu29FOIhxPlY3vzlx9WXx8XvWp9n83LBbvQphXgclxMH3/WvfjfFjxnx+11IvrtMzFoFyNJCX1qRtqToGllZaI2xkYWFFhgbWVhoibGhMLuC2CWUZTuMDUXZJcaGouwCY0NRtsXYhvMBhci2nI8eRHbB+SxBZJeceJ/IrjjpPpHtOCE5jV0JTkZOZEtOGExks0JsIvvmy6epfX64jrmmtZr0XbdiZdjEslkRNpFdAJLoe0nWYCUnnCUWyoqsiWzHiThpbCc4ESeRLTlBIZGtOEEhka05cRuRbThxG5HNisSIbFYiRmSXnHiGyK44sRKR7TgJCo0tBZSHCRAOONM5kA0401UgG3CmK0A24ExXgmzAmc6AbMCZzoJswJlOgWzAmU6DbMCZDjTm3e6oz5YkNzRpkSbv9kZ9utq55Q4Fja3oscodvGTkKoe6Hf2P0dq/Izf10Ccf+7DP+8Gfs7Np2fO5hFNdv19OqVPe+vpc1m1r52n1jjRyR/r/cEcGmH8Nzr9lPLbF+kJa3m37AjK6kp3RfZ0vm38vtV83Cm+y13kuzgPZQjnjnK2UsMbI0+k7RiNacw==" }
    local crafter = surface.create_entity { name = "rabbasca-vault-crafter",  position = offset }
    crafter.set_recipe("vault-protocol-iron-ore")
end