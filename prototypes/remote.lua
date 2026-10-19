local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local function make_warp_sequence(name, icon, tint)
return {
    type = "recipe",
    name = name,
    icons = Rabbasca.icons({
      { icon = "__rabbasca-assets__/graphics/icons/warp.png", icon_size = 64 },
      { proto = icon, icon_size = 64, scale = 0.5, shift = { 0, 0 } },
    }),
    enabled = false,
    hide_from_player_crafting = true,
    hidden = true,
    hide_from_stats = true,
    hide_from_signal_gui = true,
    hidden_in_factoriopedia = true,
    energy_required = 5,
    ingredients = { },
    results = { },
    raise_on_crafted = true,
    crafting_machine_tint = {primary = tint or {1, 1, 1}},
    categories = { "rabbasca-remote" },
    subgroup = "rabbasca-remote-warping",
    order = "c[sequence]",
}
end

local warp_icons = {
      { icon = "__rabbasca-assets__/graphics/recolor/icons/item-warp-slot.png", icon_size = 64 },
      { icon = "__rabbasca-assets__/graphics/icons/warp.png", icon_size = 64, scale = 0.25, shift = {0, -3} }
}

for i = 1,7 do
  data:extend{{
    type = "module",
    name = "rabbasca-pylon-speedup-module-"..i,
    icons = Rabbasca.icons({
      { icon = "__rabbasca-assets__/graphics/icons/warp.png" },
      { icon = "__core__/graphics/icons/technology/constants/constant-speed.png", icon_size = 128, scale = 1, shift = { 4.3, 2.7 }, floating = true }
    }),
    hidden = true,
    tier = 0,
    effect = { speed = 2 * i - 1 },
    flags = { "ignore-spoil-time-modifier", "spawnable" },
    localised_name = { "item-name.rabbasca-pylon-speedup-module", tostring(i) },
    category = "rabbasca-speedup",
    stack_size = 1,
    weight = 0,
    spoil_ticks = 2.5 * second + 2
  }}
end

data:extend {
  {
    type = "module-category",
    name = "rabbasca-speedup"
  },
  {
    type = "virtual-signal",
    name = "rabbasca-warp-inventory",
    icon = "__rabbasca-assets__/graphics/icons/warp.png",
    icon_size = 64,
    subgroup = "pictographs",
    order = "r[warp-inventory]"
  },
  {
    type = "logistic-container",
    name = "rabbasca-warp-uplink",
    icon = "__rabbasca-assets__/graphics/by-hurricane/research-center-icon.png",
    icon_size = 64,
    flags = { "placeable-player", "player-creation", "no-automated-item-removal" },
    minable = {mining_time = 0.5, result = "rabbasca-warp-uplink"},
    max_health = 100,
    corpse = "requester-chest-remnants",
    dying_explosion = "requester-chest-explosion",
    collision_box = {{-0.85, -0.85}, {0.85, 0.85}},
    selection_box = {{-1, -1}, {1, 1}},
    damaged_trigger_effect = hit_effects.entity(),
    resistances =
    {
      {
        type = "fire",
        percent = 90
      },
      {
        type = "impact",
        percent = 60
      }
    },
    fast_replaceable_group = "container",
    inventory_size = 9,
    icon_draw_specification = {scale = 0.7},
    trash_inventory_size = 10,
    logistic_mode = "requester",
    open_sound = sounds.metallic_chest_open,
    close_sound = sounds.metallic_chest_close,
    impact_category = "metal",
    surface_conditions = { { property = "rabbasca-or-space", min = 1, max = 1 } },
    picture =
    {
      layers =
      {
        {
          filename = "__rabbasca-assets__/graphics/by-hurricane/research-center-animation.png",
          frame_count = 8 * 10,
          line_length = 10,
          width = 5900 / 10,
          height = 5120 / 8,
          scale = 0.1,
          shift = {0, 0},
        },
        {
          filename = "__rabbasca-assets__/graphics/by-hurricane/research-center-hr-shadow.png",
          frame_count = 1,
          repeat_count = 80,
          width = 1200,
          height = 700,
          scale = 0.1,
          shift = {0, 0},
          draw_as_shadow = true
        },
      }
    },
  },
  {
      type = "item",
      name = "rabbasca-warp-uplink",
      icon = "__rabbasca-assets__/graphics/by-hurricane/research-center-icon.png",
      icon_size = 64,
      stack_size = 10,
      place_result = "rabbasca-warp-uplink",
      weight = 100 * kg,
      subgroup = "rabbasca-remote-warping",
      order = "a[placeable]-b[input]",
  },
  {
    type = "recipe",
    name = "rabbasca-warp-uplink",
    energy_required = 8,
    enabled = false,
    hide_from_player_crafting = true,
    categories = { "complex-machinery" },
    ingredients = { { type = "item", name = "rabbasca-warp-core", amount = 10 }, { type = "item", name = "steel-plate", amount = 20 }, { type = "item", name = "processing-unit", amount = 5 } },
    results = { { type = "item", name = "rabbasca-warp-uplink", amount = 1 } }
  },
  {
    type = "assembling-machine",
    name = "rabbasca-warp-pylon",
    icon = "__rabbasca-assets__/graphics/by-hurricane/conduit-icon.png",
    icon_size = 64,
    flags = { "placeable-player", "player-creation" },
    crafting_categories = { "rabbasca-remote" },
    minable = { result = "rabbasca-warp-pylon", mining_time = 1 },
    placeable_by = { item = "rabbasca-warp-pylon", count = 1 },
    max_health = 240,
    module_slots = 7,
    allowed_effects = { "speed" },
    allowed_module_categories = { "rabbasca-speedup" },
    effect_receiver = { 
      uses_beacon_effects = false,
      uses_module_effects = true,
      uses_surface_effects = true,
    },
    icons_positioning = {
      {
        inventory_index = defines.inventory.crafter_modules,
        max_icons_per_row = 7,
        max_icon_rows = 2,
        scale = 0.25
      }
    },
    surface_conditions = {
      { property = "gravity", min = 0.01 }
    },
    trash_inventory_size = 10,
    energy_usage = "1MW",
    crafting_speed = 1,
    crafting_speed_quality_multiplier = { }, -- filled in final-fixes
    energy_source = { type = "void" },
    collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selection_box = {{-1, -1}, {1, 1}},
    tile_buildability_rules = { Rabbasca.ears_flooring_rule({{-0.8, -0.8}, {0.8, 0.8}}) },
    radius_visualisation_specification = {
      sprite = data.raw["utility-sprites"]["default"].construction_radius_visualization,
      distance = Rabbasca.get_warp_radius(),
      distance_quality_multiplier = { }
    },
    custom_tooltip_fields = {
      {
        name = {"tooltip.rabbasca-warp-pylon-range"},
        value = {"tooltip-value.rabbasca-warp-pylon-range", "21"},
        quality_header = "quality-tooltip.increases",
        quality_values = { },
      }
    },
    graphics_set = {
      working_visualisations = {{
        animation = {
              filename = "__rabbasca-assets__/graphics/by-hurricane/conduit-emission.png",
              frame_count = 60,
              line_length = 10,
              width = 200,
              height = 290,
              draw_as_glow = true,
              blend_mode = "additive-soft",
              scale = 1.0/3,
              shift = {0, -0.5},
              apply_runtime_tint = true
        },
        apply_recipe_tint = "primary"
      }},
      default_recipe_tint = { primary = {0.5, 1, 0} },
      idle_animation = {
        layers = {
          {
            filename = "__rabbasca-assets__/graphics/by-hurricane/conduit-animation.png",
            frame_count = 60,
            line_length = 10,
            width = 200,
            height = 290,
            scale = 1.0/3,
            flags = {"no-scale"},
            shift = {0, -0.5},
          },
          {
              filename = "__rabbasca-assets__/graphics/by-hurricane/conduit-hr-shadow.png",
              repeat_count = 60,
              width = 600,
              height = 400,
              scale = 1.0/3,
              draw_as_shadow = true,
              shift = {0, -0.5},
          },
        }
      },
      always_draw_idle_animation = true
    },
  },
  {
      type = "item",
      name = "rabbasca-warp-pylon",
      icon = "__rabbasca-assets__/graphics/by-hurricane/conduit-icon.png",
      icon_size = 64,
      stack_size = 5,
      place_result = "rabbasca-warp-pylon",
      weight = 200 * kg,
      subgroup = "rabbasca-remote-warping",
      order = "a[placeable]-a[pylon]",
  },
  {
    type = "recipe",
    name = "rabbasca-warp-pylon",
    enabled = false,
    hidden = true,
    hidden_in_factoriopedia = true,
    hide_from_player_crafting = true,
    factoriopedia_alternative = "rabbasca-warp-pylon-recycling",
    energy_required = 10,
    ingredients = {
        { type = "item", name = "rabbasca-warp-core", amount = 20 },
        { type = "item", name = "haronite-plate",  amount = 4 },
    },
    results = { { type = "item", name = "rabbasca-warp-pylon", amount = 1 } },
    categories = { "complex-machinery" },
  },
{
    type = "recipe-category",
    name = "rabbasca-remote",
},
{
    type = "item-subgroup",
    name = "rabbasca-remote",
    group = data.raw["item-group"]["rabbasca-extensions"] and "rabbasca-extensions" or "space",
    order = "03[remote]"
},
{
    type = "item-subgroup",
    name = "rabbasca-remote-warping",
    group = data.raw["item-group"]["rabbasca-extensions"] and "rabbasca-extensions" or "space",
    order = "03[remote-warping]"
},
make_warp_sequence("rabbasca-warp-sequence-building",data.raw["entity-ghost"]["entity-ghost"], {1, 1, 1}),
make_warp_sequence("rabbasca-warp-sequence-tile",    data.raw["tile-ghost"]["tile-ghost"], {1, 0.6, 1}),
make_warp_sequence("rabbasca-warp-sequence-module",  data.raw["item-request-proxy"]["item-request-proxy"], {1, 1, 0.7}),
make_warp_sequence("rabbasca-warp-sequence-reverse", data.raw["deconstruction-item"]["deconstruction-planner"], {1, 0.3, 0,3}),
make_warp_sequence("rabbasca-warp-sequence-upgrade", data.raw["upgrade-item"]["upgrade-planner"], {0.5, 1, 0.5}),
{
    type = "recipe",
    name = "rabbasca-warp-sequence",
    icons = warp_icons,
    subgroup = "rabbasca-remote-warping",
    order = "b[warp-sequence]",
    enabled = false,
    hidden = false,
    hide_from_player_crafting = true,
    hide_from_stats = true,
    hide_from_signal_gui = true,
    energy_required = 5,
    ingredients = { },
    results = { },
    raise_on_crafted = true,
    categories = { "rabbasca-remote" },
    crafting_machine_tint = {primary = {0.3, 0.35, 0.4}}
},
{
    type = "animation",
    name = "rabbasca-warp-smoke",
    lines_per_file = 2,
    line_length = 8,
    frame_count = 16,
    max_advance = 1,
    width = 128,
    height = 128,
    draw_as_glow = true,
    filename = "__rabbasca-assets__/graphics/textures/warp-smoke.png"
},
}

local uplink = data.raw["logistic-container"]["rabbasca-warp-uplink"]
PlanetsLib.create_planet_entity_variant("space-platform", uplink, { render_not_in_network_icon = false }, "rabbasca-entity-replacements")

local warpers = data.raw["mod-data"]["rabbasca-warpers"].data
warpers.pylons["rabbasca-warp-pylon"] = true
warpers.uplinks["rabbasca-warp-uplink"] = true
warpers.uplinks["rabbasca-warp-uplink-PlanetsLib-space-platform"] = true

data:extend {
  {
    type = "recipe",
    name = "rabbasca-warp-pylon-indicator",
    enabled = false,
    categories = { "parameters" }, -- for unlocking filters and factoriopedia entries
    hidden_in_factoriopedia = true,
    hidden = true,
    requires_ingredients_to_unlock_results = false,
    hide_from_player_crafting = true,
    -- hidden but potentially craftable via "set recipe" to one of the results. Set all amounts to 0 to prevent
    results = { 
      { type = "item", name = "haronite-plate", amount = 0 },
      { type = "item", name = "rabbasca-warp-core", amount = 0 },
      { type = "item", name = "rabbasca-warp-pylon", amount = 0 },
    },
    main_product = "rabbasca-warp-pylon"
  }
}