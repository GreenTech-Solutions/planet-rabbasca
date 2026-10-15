local tile_collision_masks = require("__base__/prototypes/tile/tile-collision-masks")
local tile_sounds = require("__space-age__/prototypes/tile/tile-sounds")
local tile_trigger_effects = require("__space-age__/prototypes/tile/tile-trigger-effects")

-- Some globals black magic or something happening here, required for water borders
table.insert(water_tile_type_names, "rabbasca-harenic-sludge")
table.insert(water_tile_type_names, "harenic-lava")
table.insert(lava_tile_type_names, "harenic-lava")

local is_dark_mode = settings.startup["rabbasca-map-dark-mode"].value

local lava_effect = util.merge { data.raw["tile-effect"]["lava"],
{
  name = "harenic-lava",
}}
lava_effect.foam_color = { 155, 60, 130 }
lava_effect.water.image_textures[1].filename = "__rabbasca-assets__/graphics/recolor/textures/lava.png"

local lava = util.merge{ table.deepcopy(data.raw["tile"]["lava"]), {
    name = "harenic-lava",
    effect = "harenic-lava",
    fluid = "harenic-lava",
}}
lava.effect_color = { 155, 60, 130 }
lava.effect_color_secondary = { 140, 52, 111 }
lava.map_color = { 0.6, 0.28, 0.53 }
lava.particle_tints = { primary = { 155, 60, 130 }, secondary = { 140, 52, 111 },}
lava.autoplace = nil
lava.variants.main[1].picture = "__rabbasca-assets__/graphics/recolor/textures/lava-transitions.png"
lava.variants.main[2].picture = "__rabbasca-assets__/graphics/recolor/textures/lava-transitions.png"
lava.variants.main[3].picture = "__rabbasca-assets__/graphics/recolor/textures/lava-transitions.png"

table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "harenic-lava")
table.insert(data.raw["item"]["foundation"].place_as_tile.tile_condition, "rabbasca-harenic-sludge")

data:extend{
{
  type = "collision-layer",
  name = "harene",
},
lava, lava_effect,
util.merge{table.deepcopy(data.raw["tile"]["ammoniacal-ocean"]), {
  name = "rabbasca-harenic-sludge",
  default_cover_tile = "foundation",
  autoplace = { probability_expression = "rabbasca_harene_pools" },
  -- destroys_dropped_items = true,
  effect = "brash-ice-2",
  effect_color = { 60,55,97 },
  effect_color_secondary = { 70, 40, 120 },
  map_color = { 0.4, 0.1, 0.65 },
  fluid = "energetic-residue"
}},
{
  type = "tile",
  name = "rabbasca-rough",
  order = "c[gleba-land-tiles]-a[highland-dark-rock]",
  subgroup = "gleba-tiles",
  collision_mask = tile_collision_masks.ground(),
  layer = 55,
  layer_group = "ground-natural",
  -- sprite_usage_surface = "rabbasca",
  variants = tile_variations_template_with_transitions(
    "__rabbasca-assets__/graphics/recolor/textures/rabbasca-rough.png",
    {
      max_size = 4,
      [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
      [2] = { probability = 1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
      [4] = { probability = 0.1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
    }
  ),
  transitions = table.deepcopy(data.raw["tile"]["volcanic-pumice-stones"].transitions),
  -- transitions_between_transitions = table.deepcopy(data.raw["tile"]["volcanic-pumice-stones"].transitions_between_transitions),
  autoplace =
  {
    probability_expression = "rabbasca_rocky"
  },
  walking_sound = tile_sounds.walking.dry_rock,
  landing_steps_sound = tile_sounds.landing.rock,
  map_color = is_dark_mode and {0.07, 0.061, 0.1} or {0.21, 0.21, 0.21},
  walking_speed_modifier = 1,
  vehicle_friction_modifier = 1,
  trigger_effect = tile_trigger_effects.dirt_2_trigger_effect()
},
{
  type = "tile",
  name = "rabbasca-rough-2",
  order = "c[gleba-land-tiles]-a[highland-dark-rock]",
  subgroup = "gleba-tiles",
  collision_mask = tile_collision_masks.ground(),
  layer = 56,
  layer_group = "ground-natural",
  variants = tile_variations_template_with_transitions(
    "__rabbasca-assets__/graphics/recolor/textures/rabbasca-rough-2.png",
    {
      max_size = 4,
      [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
      [2] = { probability = 1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
      [4] = { probability = 0.1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
    }
  ),
  transitions = table.deepcopy(data.raw["tile"]["volcanic-pumice-stones"].transitions),
  -- transitions_between_transitions = table.deepcopy(data.raw["tile"]["volcanic-pumice-stones"].transitions_between_transitions),
  autoplace =
  {
    probability_expression = "rabbasca_rocky + rabbasca_rocky_variance"
  },
  walking_sound = tile_sounds.walking.dry_rock,
  landing_steps_sound = tile_sounds.landing.rock,
  map_color = is_dark_mode and {0.07, 0.061, 0.1} or {0.19, 0.19, 0.20},
  walking_speed_modifier = 1,
  vehicle_friction_modifier = 1,
  trigger_effect = tile_trigger_effects.dirt_2_trigger_effect()
},
util.merge{ table.deepcopy(data.raw["tile"]["volcanic-ash-cracks"]), {
    name = "rabbasca-wasted",
    autoplace = nil,
    
}},
{
  type = "tile",
  name = "rabbasca-fertile",
  order = "c[gleba-land-tiles]-a[highland-dark-rock]",
  subgroup = "gleba-tiles",
  collision_mask = tile_collision_masks.ground(),
  layer = 44,
  layer_group = "ground-natural",
  -- sprite_usage_surface = "rabbasca",
  variants = tile_variations_template_with_transitions_and_effect_map(
    "__rabbasca-assets__/graphics/recolor/textures/rabbasca-fertile.png",
    "__space-age__/graphics/terrain/effect-maps/water-gleba-mask.png",
    {
      max_size = 4,
      [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
      [2] = { probability = 1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
      [4] = { probability = 0.1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
      --[8] = { probability = 1.00, weights = {0.090, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.025, 0.125, 0.005, 0.010, 0.100, 0.100, 0.010, 0.020, 0.020} },
    }
  ),
  autoplace =
  {
    probability_expression = "rabbasca_fertile * 1.1"
  },
  walking_sound = tile_sounds.walking.dry_rock,
  landing_steps_sound = tile_sounds.landing.rock,
  map_color = {0.61, 0.282, 0.1},
  walking_speed_modifier = 1,
  vehicle_friction_modifier = 1,
  trigger_effect = tile_trigger_effects.dirt_2_trigger_effect()
},
util.merge { 
    table.deepcopy(data.raw["tile"]["concrete"]),
    {
      name = "rabbasca-energetic-concrete",
      collision_mask = { layers = { harene = true } },
      -- material_background = { tint  = {60,55,97}, },
      minable = { result = "rabbasca-energetic-concrete" },
      variants = { material_background = { picture = "__rabbasca-assets__/graphics/recolor/icons/concrete.png", } },
      frozen_variant = "rabbasca-energetic-concrete",
      check_collision_with_entities = true
    }
},
util.merge { 
    table.deepcopy(data.raw["tile"]["space-platform-foundation"]),
    {
      name = "haronite-plate",
      collision_mask = { layers = { harene = true } },
      minable = { result = "haronite-plate" },
      max_health = 500,
      layer = data.raw["tile"]["foundation"].layer,
      transition_overlay_layer_offset = 2,
      layer_group = "ground-artificial",
      variants = { 
        material_background = { picture = "__rabbasca-assets__/graphics/foundation/haronite-plate.png", count = 1 }, 
        transition = table.deepcopy(data.raw["tile"]["foundation"].variants.transition)
      },
      allowed_neighbors = { "space-platform-foundation" },
      frozen_variant = "haronite-plate",
      check_collision_with_entities = true
    }
}
}

local dirt_transitions_1 = tile_variations_template_with_transitions(
  "__space-age__/graphics/terrain/vulcanus/volcanic-ash-dark.png",
  {
    max_size = 4,
    [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
    [2] = { probability = 1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
    [4] = { probability = 0.1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
  }
).transition
dirt_transitions_1.transition_group = 1
dirt_transitions_1.to_tiles = { "rabbasca-rough-2" }
table.insert(data.raw["tile"]["rabbasca-rough"].transitions, dirt_transitions_1)
local dirt_transitions_2 = tile_variations_template_with_transitions (
  "__space-age__/graphics/terrain/vulcanus/volcanic-pumice-stones.png",
  {
    max_size = 4,
    [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
    [2] = { probability = 1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
    [4] = { probability = 0.1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
  }
).transition
dirt_transitions_2.to_tiles = { "rabbasca-rough" }
dirt_transitions_2.transition_group = 1
table.insert(data.raw["tile"]["rabbasca-rough-2"].transitions, dirt_transitions_2)

data.raw["tile"]["haronite-plate"].bound_decoratives = nil