data:extend {
{
    type = "tips-and-tricks-item",
    name = "rabbasca-briefing",
    category = "space-age",
    tag = "[planet=rabbasca]",
    indent = 0,
    order = "r[rabbasca]-a",
    trigger = {
        type = "research",
        technology = "planet-discovery-rabbasca",
    },
    simulation = {
        planet = "rabbasca",
        generate_map = true,
        hide_health_bars = false,
        checkboard = false,
        [[
            require("__planet-rabbasca__.scripts.tips-simulations")
            simulation_briefing()
        ]],
    }
},
{
    type = "tips-and-tricks-item",
    name = "rabbasca-vaults",
    category = "space-age",
    tag = "[entity=rabbasca-vault-crafter]",
    indent = 1,
    order = "r[rabbasca]-b",
    trigger = {
        type = "research",
        technology = "planet-discovery-rabbasca",
    },
},
{
    type = "tips-and-tricks-item",
    name = "rabbasca-bunnyhop",
    category = "space-age",
    tag = "[item=bunnyhop-engine]",
    indent = 1,
    order = "r[rabbasca]-c",
    trigger = {
        type = "research",
        technology = "bunnyhop-engine-1",
    },
},
{
    type = "tips-and-tricks-item",
    name = "rabbasca-warp-inventory",
    category = "space-age",
    tag = "[recipe=rabbasca-warp-sequence]",
    indent = 1,
    order = "r[rabbasca]-d",
    trigger = {
        type = "research",
        technology = "interplanetary-construction-1",
    },
    simulation = {
        planet = "nauvis",
        generate_map = false,
        checkboard = true,
        init_update_count = 10,
        init = [[
            require("__planet-rabbasca__.scripts.tips-simulations")
            simulation_warp_network()
        ]],
    }
},
}