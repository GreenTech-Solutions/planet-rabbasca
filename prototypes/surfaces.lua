local parent_name = settings.startup["rabbasca-orbits"].value
local gleba = data.raw["planet"][parent_name]
local planet_catalogue_aquilo = require("__space-age__.prototypes.planet.procession-catalogue-aquilo")

data:extend{
{
  type = "autoplace-control",
  name = "rabbasca_rocks",
  order = "r[rabbasca]-c[rocks]",
  category = "terrain",
  richness = false, 
},
{
  type = "autoplace-control",
  name = "harene",
  order = "r[rabbasca]-a[harene]",
  category = "resource",
  richness = true, 
  can_be_disabled = false,
},
{
  type = "autoplace-control",
  name = "rabbasca_carotenoids",
  order = "r[rabbasca]-b[carotenoids]",
  category = "resource",
  richness = true, 
  can_be_disabled = false,
},
{
  type = "autoplace-control",
  name = "rabbasca_vaults",
  order = "r[rabbasca]-b[vaults]",
  category = "resource",
  richness = true, 
  can_be_disabled = false,
}
}

data:extend {
  util.merge{
    data.raw["optimized-decorative"]["yellow-lettuce-lichen-cups-3x3"],
    {
      name = "rabbasca-yellow-lettuce-lichen-3x3",
      autoplace = { probability_expression = "(rabbasca_fertile > 1.2) * rpi(0.6) * decorative_knockout", tile_restriction = { "rabbasca-fertile" } }
    }
  },
  util.merge{
    data.raw["optimized-decorative"]["yellow-lettuce-lichen-cups-6x6"],
    {
      name = "rabbasca-yellow-lettuce-lichen-6x6",
      autoplace = { probability_expression = "(rabbasca_fertile > 1.3) * rpi(0.4) * decorative_knockout", tile_restriction = { "rabbasca-fertile" } }
    }
  },
  util.merge{
    data.raw["optimized-decorative"]["crater-large"],
    {
      name = "rabbasca-crater-large",
      autoplace = { probability_expression = "crater_large * (1.3 - max(rabbasca_down(1), rabbasca_fertile))" } 
    }
  },
  util.merge{
    data.raw["optimized-decorative"]["vulcanus-dune-decal"],
    {
      name = "rabbasca-dune-decal",
      autoplace = { probability_expression = "vulcanus_dune_decal * rpi(0.2) * decorative_knockout - max(rabbasca_fertile, rabbasca_rocks(4)) - rabbasca_down(1)" }
    }
  },
  util.merge{
    data.raw["optimized-decorative"]["tiny-volcanic-rock"],
    {
      name = "rabbasca-tiny-rock",
      autoplace = { probability_expression = "rabbasca_rocks(1.9)" }
    }
  },
  util.merge{
    data.raw["optimized-decorative"]["small-volcanic-rock"],
    {
      name = "rabbasca-small-rock",
      autoplace = { probability_expression = "rabbasca_rocks(1.3)" }
    }
  },
  util.merge{
    data.raw["optimized-decorative"]["brown-asterisk-mini"],
    {
      name = "rabbasca-asterisk-mini",
      autoplace = { probability_expression = "rabbasca_carrot_noise", tile_restriction = { "rabbasca-fertile" } }
    }
  },
  {
    type = "optimized-decorative",
    name = "rabbasca-gravewort",
    order = "a[fulgora]-b[decorative]",
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {layers={water_tile=true}, colliding_with_tiles_only=true},
    autoplace = { probability_expression = "rabbasca_carrot_noise * rpi(0.72) * decorative_knockout", tile_restriction = { "rabbasca-fertile" } },
    pictures = util.spritesheets_to_pictures({{path = "__rabbasca-assets__/graphics/recolor/entities/fulgoran-gravewort", frame_count = 7}})
  },
}

local map_gen = {
    cliff_settings = {},
    autoplace_controls = 
    {
        ["harene"] = {},
        ["rabbasca_rocks"] = {},
        ["rabbasca_carotenoids"] = {},
        ["rabbasca_vaults"] = {},
    },
    autoplace_settings = {
      tile =
      {
        settings =
        {
          ["rabbasca-harenic-sludge"] = {},
          ["rabbasca-fertile"] = {},
          ["rabbasca-rough"] = {},
          ["rabbasca-rough-2"] = {},
        }
      },
      decorative =
      {
        settings =
        {
          ["rabbasca-crater-large"] = {},
          ["rabbasca-yellow-lettuce-lichen-3x3"] = {},
          ["rabbasca-yellow-lettuce-lichen-6x6"] = {},
          ["shroom-decal"] = {},
          ["rabbasca-tiny-rock"] = {},
          ["rabbasca-small-rock"] = {},
          ["rabbasca-dune-decal"] = {},
          ["rabbasca-asterisk-mini"] = {},
          ["rabbasca-gravewort"] = {},
        }
      },
      entity =
      {
        settings =
        {
          ["rabbasca-vault-spawner"] = {}, -- Only to show current evolution in factoriopedia
          ["rabbasca-vault-warp-spawner"] = {}, -- Only to show current evolution in factoriopedia 
          ["rabbasca-energy-source"] = {},
          ["rabbasca-vault-crafter"] = {},
          ["carotenoid-ore"] = {},
          ["rabbascan-scrap"] = {},
          ["harene-vent"] = {},
          ["rabbasca-turbofish"] = {},
          ["rabbasca-big-rock"] = {},
        }
      }
    }
}
local platform_render = table.deepcopy(data.raw.planet["nauvis"].platform_surface_render_parameters)
platform_render.platform_backdrop =
{
  emission_scales_with_shadow = false,
  radius = 417,
  rotation_seconds = -1175,
  light_radius = 10,
  cloudiness = 0.1,
  surface_vertical_offset = 0.1,
  cloud_vertical_offset = 0.05,
  specular_intensity = 0,
  atmosphere_color = {0.052, 0.023, 0.067, 0.03},
  cloud_flow_intensity = 0.05,
  cloud_panning_rate = -0.025,
  planet_axis = {5.0, 9.0},
  planet_axis_deviation_amplitude = {1.4, 2.6},
  planet_axis_deviation_seconds = {320.5*2/4.66, 285*2/4.66},
  position = {-300, 250},
  parallax_strength = {0.95, 0.95},
  light_direction = {-0.42, 0.23, 0.67},
  light_intensity_contrast = 0.4,
  planet_surface =
  {
    filename = "__rabbasca-assets__/graphics/recolor/textures/space-planet.png",
    width = 2048,
    height = 1024
  },
  planet_normal = nil,
  planet_emission =
  {
    filename = "__rabbasca-assets__/graphics/recolor/textures/space-planet-emission.png",
    width = 2048,
    height = 1024
  },
  global_cloud =
  {
    filename = "__space-age__/graphics/space/vulcanus-cloud.png",
    width = 2048,
    height = 1024
  },
  global_cloud_normal =
  {
    filename = "__space-age__/graphics/space/vulcanus-cloud-normal.png",
    width = 2048,
    height = 1024
  },
  global_cloud_flow =
  {
    filename = "__space-age__/graphics/space/vulcanus-cloud-flow.png",
    width = 2048,
    height = 1024
  }
}

local spawn_definitions = table.deepcopy(gleba.asteroid_spawn_definitions)
PlanetsLib:extend({
{
    type = "planet",
    name = "rabbasca",
    icon = "__rabbasca-assets__/graphics/by-talandar/rabbasca64.png",
    icon_size = 64,
    starmap_icon = "__rabbasca-assets__/graphics/by-talandar/rabbasca256.png",
		starmap_icon_size = 256,
    solar_power_in_space = gleba.solar_power_in_space,
    auto_save_on_first_trip = true,
    gravity_pull = 10,
    subgroup = "satellites",
    order = gleba.order .. "-r[rabbasca]",
    label_orientation = 0.14,
    magnitude = gleba.magnitude*3/5,
    persistent_ambient_sounds= table.deepcopy(data.raw["space-platform-hub"]["space-platform-hub"].persistent_ambient_sounds),
    localised_description={"planetslib-templates.moon-description",{"space-location-description.rabbasca"},"[planet="..gleba.name.."]"},
    asteroid_spawn_definitions = spawn_definitions,
    asteroid_spawn_influence = 0.7,

    -- robot energy usage = gravity/pressure*100, gravity > 0.1 (allow chests), robots should be expensive and limited by energy field
    -- on x8+(?) energy usage, normal robots are stuck in recharge loop
    surface_properties = {
        ["gravity"] = 1,
        ["solar-power"] = 0,
        ["day-night-cycle"] = 12 * minute,
        ["pressure"] = 20,
        ["robot-energy-usage"] = 4,
        ["magnetic-field"] = 0.01,
        ["harenic-energy-signatures"] = Rabbasca.surface_megawatts(),
        ["rabbasca-or-space"] = 1,
    },
    surface_render_parameters = {
      shadow_opacity = 0.73,
      draw_sprite_clouds = false,
      clouds = nil,
      fog = nil,
      day_night_cycle_color_lookup = {
          {0.0,  "__rabbasca-assets__/graphics/recolor/textures/lut-rabbasca-day.png"},
          {0.25, "__rabbasca-assets__/graphics/recolor/textures/lut-rabbasca-day.png"},
          {0.45, "__rabbasca-assets__/graphics/recolor/textures/lut-rabbasca.png"},
          {0.55, "__rabbasca-assets__/graphics/recolor/textures/lut-rabbasca.png"},
          {0.75, "__rabbasca-assets__/graphics/recolor/textures/lut-rabbasca-day.png"},
      },
    },
    map_gen_settings = map_gen,
    parked_platforms_orientation = 0.55,
    draw_orbit = true,
    orbit = {
      orientation = 0.9,
      distance = 1.8,
      parent = {
        type = "planet",
        name = gleba.name,
      },
    },
    platform_surface_render_parameters = platform_render,
    platform_procession_set =
    {
      arrival = {"planet-to-platform-b"},
      departure = {"platform-to-planet-a"}
    },
    planet_procession_set =
    {
      arrival = {"platform-to-planet-b"},
      departure = {"planet-to-platform-a"}
    },
    procession_graphic_catalogue = planet_catalogue_aquilo
}
})

data:extend{
{
  type = "space-connection",
  name = gleba.name.."-rabbasca",
  order = "a-b-c",
  from = gleba.name,
  to = "rabbasca",
  subgroup = data.raw["space-connection"]["gleba-fulgora"].subgroup,
  length = 1000,
},
{
  type = "surface-property",
  name = "harenic-energy-signatures",
  default_value = 0
},
{
  type = "surface-property",
  name = "rabbasca-or-space",
  hidden_in_factoriopedia = true, -- not hidden for space-platform (because not a planet?); set name to empty in locale to actually hide
  default_value = 0
},
}

data.raw["surface"]["space-platform"].surface_properties["rabbasca-or-space"] = 1