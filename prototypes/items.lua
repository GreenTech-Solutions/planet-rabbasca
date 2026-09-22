local sounds = require("__base__.prototypes.entity.sounds")
require("prototypes.warp-grenade")

local core_impact_effects = {
{
  type = "direct",
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "create-entity",
        entity_name = "rabbasca-warp-grenade-fissure"
      },
    }
  }
},
{
  type = "area",
  radius = 5,
  action_delivery =
  {
    type = "instant",
    target_effects =
    {
      {
        type = "damage",
        damage = {amount = 55, type = "explosion"}
      },
      {
        type = "create-entity",
        entity_name = "explosion"
      }
    }
  }
}
}

data:extend {
{
    type = "projectile",
    name = "rabbasca-warp-core",
    flags = {"not-on-map"},
    hidden = true,
    acceleration = 0.01,
    action = core_impact_effects,
    light = {intensity = 0.5, size = 4},
    animation =
    {
      filename = "__base__/graphics/entity/grenade/grenade.png",
      draw_as_glow = true,
      frame_count = 15,
      line_length = 8,
      animation_speed = 0.250,
      width = 48,
      height = 54,
      shift = util.by_pixel(0.5, 0.5),
      priority = "high",
      scale = 0.5
    },
    shadow =
    {
      filename = "__base__/graphics/entity/grenade/grenade-shadow.png",
      frame_count = 15,
      line_length = 8,
      animation_speed = 0.250,
      width = 50,
      height = 40,
      shift = util.by_pixel(2, 6),
      priority = "high",
      draw_as_shadow = true,
      scale = 0.5
    }
  },
}

data:extend {
{
  type = "fuel-category",
  name = "carotene",
  fuel_value_type = {
    "description.food-energy-value"
  },
},
{
    type = "item",
    icon = "__rabbasca-assets__/graphics/by-hurricane/gravity-assembler-icon.png",
    icon_size = 64,
    name = "machining-assembler",
    place_result = "machining-assembler",
    stack_size = 5,
    weight = 100 * kg,
    subgroup = "production-machine",
    order = "fr[machining-assembler]",
},
{
    type = "item",
    icon = "__rabbasca-assets__/graphics/recolor/icons/haronite.png",
    icon_size = 64,
    name = "haronite",
    stack_size = 50,
    weight = 20*kg,
    subgroup = "rabbasca-processes",
    order = "h[haronite]-a[haronite]",
    spoil_ticks = 15 * minute,
    spoil_result = "stone"
},
{
    type = "item",
    icon = "__Krastorio2Assets__/icons/items/imersium-plate.png",
    icon_size = 64,
    name = "haronite-plate",
    stack_size = 50,
    weight = 50 * kg,
    subgroup = "rabbasca-processes",
    order = "h[haronite]-d[haronite-plate]",
    place_as_tile = { 
      result = "haronite-plate", 
      condition = { 
        layers = { empty_space = true } 
      }, 
      invert = true,
      condition_size = 1,
    },
},
{
    type = "item",
    icon = "__rabbasca-assets__/graphics/recolor/icons/haronite-lds.png",
    icon_size = 64,
    name = "haronite-rocket-frame",
    stack_size = 50,
    weight = 20*kg,
    subgroup = "rabbasca-processes",
    order = "h[haronite]-d[haronite-rocket-frame]",
},
{
    type = "item",
    icon = "__rabbasca-assets__/graphics/recolor/icons/harenic-stabilizer.png",
    icon_size = 64,
    name = "harenic-stabilizer",
    stack_size = 50,
    subgroup = "rabbasca-processes",
    order = "b[processed]-h[harenic-stabilizer]",
},
{
    type = "item",
    icon = "__rabbasca-assets__/graphics/recolor/icons/harene-ears-core.png",
    icon_size = 64,
    name = "harene-ears-core",
    stack_size = 5,
    weight = 50 * kg,
    subgroup = "rabbasca-processes",
    order = "v[vault]-d[harene-ears-core]",
    auto_recycle = false,
},
{
    type = "item",
    icons = {
      { icon = "__rabbasca-assets__/graphics/recolor/icons/harene-ears-core.png", icon_size = 64, scale = 0.5, shift = { -8, 0 } },
      { icon = "__rabbasca-assets__/graphics/recolor/icons/harene-ears-core.png", icon_size = 64, scale = 0.5 },
      { icon = "__rabbasca-assets__/graphics/recolor/icons/harene-ears-core.png", icon_size = 64, scale = 0.5, shift = { 8, 0 } },
    },
    name = "harene-ears-subcore",
    stack_size = 50,
    weight = 5 * kg,
    subgroup = "rabbasca-processes",
    order = "v[vault]-d[harene-ears-subcore]",
    auto_recycle = false,
},
{
    type = "item",
    icon = "__rabbasca-assets__/graphics/recolor/icons/bunnyhop-engine.png",
    icon_size = 64,
    name = "bunnyhop-engine-equipment",
    stack_size = 1,
    group = "combat",
    subgroup = "equipment",
    order = "r[personal-transport]-b[bunnyhop-engine]",
    place_as_equipment_result = "bunnyhop-engine-equipment",
    custom_tooltip_fields = {
      {
        name = {"tooltip.bunnyhop-engine-weight-multiplier"},
        value = {"tooltip-value.bunnyhop-engine-weight-multiplier", "100"},
        quality_header = "quality-tooltip.increases",
        quality_values = { },
      }
    }
},
util.merge {
  data.raw["item"]["fusion-reactor-equipment"],
  {
    name = "ears-subcore-reactor-equipment",
    place_as_equipment_result = "ears-subcore-reactor-equipment",
    weight = 100 * kg,
  }
},
{
    type = "capsule",
    icon = "__rabbasca-assets__/graphics/recolor/icons/bunnyhop-engine.png",
    icon_size = 64,
    name = "bunnyhop-engine",
    flags = {"only-in-cursor", "not-stackable", "spawnable"},
    auto_recycle = false,
    stack_size = 1,
    group = "others",
    subgroup = "spawnables",
    capsule_action = {
      type = "use-on-self",
      uses_stack = true,
      attack_parameters = {
        type = "projectile",
        activation_type = "activate",
        range = 0,
        cooldown = 30,
        ammo_categories = { "electric" },
        ammo_type =
        {
          target_type = "position",
          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "instant",
              target_effects =
              {
                {
                  type = "script",
                  effect_id = "rabbasca_teleport"
                }
              }
            }
          }
        }
      }
    },
    order = "b[personal-transport]-b[bunnyhop-engine]-r[remote]",
},
util.merge {
    table.deepcopy(data.raw["capsule"]["raw-fish"]),
    {
      name = "rabbasca-turbofish",
      icon = "__rabbasca-assets__/graphics/recolor/icons/turbofish.png",
      icon_size = 64,
      spoil_ticks = 3 * minute,
      spoil_result = "spoilage",
      subgroup = "rabbasca-processes",
      order = "b[organic]-a[turbofish]"
    },
  },
  util.merge {
    table.deepcopy(data.raw["capsule"]["raw-fish"]),
    {
      name = "rabbasca-protein-shake",
      icon = "__rabbasca-assets__/graphics/recolor/icons/protein-shake.png",
      icon_size = 64,
      spoil_ticks = 0,
      spoil_result = nil,
      weight = 20 * kg,
      fuel_categories = { "nutrients" },
      fuel_value = "17.63MJ",
      burnt_result = "plastic-bottle",
      subgroup = "rabbasca-processes",
      order = "b[organic]-f[protein-shake]"
    },
  },
util.merge { data.raw["item"]["rocket-fuel"],
{
  name = "rabbasca-turbofuel",
  icon = "__rabbasca-assets__/graphics/recolor/icons/turbofuel.png",
  icon_size = 64,
  fuel_value = "220MJ",
  fuel_top_speed_multiplier = 2.142,
  subgroup = "rabbasca-processes",
  order = "b[processed]-a[rabbasca-turbofuel]"
}},
{
    type = "item",
    icon = "__rabbasca-assets__/graphics/recolor/icons/carotenoid.png",
    icon_size = 64,
    name = "carotenoid-ore",
    stack_size = 50,
    weight = 100 * kg,
    subgroup = "rabbasca-processes",
    order = "a[raw-resource]-a[carotenoid]",
    fuel_categories = { "carotene" },
    fuel_value = "720kJ"
},
{
    type = "item",
    icons = {
      { icon = "__rabbasca-assets__/graphics/recolor/icons/harene-gas.png", icon_size = 64 },
      { icon = "__space-age__/graphics/icons/nutrients.png", scale = 0.3, icon_size = 64, shift = {0, -1}  }
    },
    name = "protein-powder",
    stack_size = 200,
    subgroup = "rabbasca-processes",
    order = "b[organic]-d[protein-powder]",
},
{
    type = "item",
    name = "plastic-bottle",
    icon = "__rabbasca-assets__/graphics/recolor/icons/plastic-bottle.png",
    stack_size = 200,
    subgroup = "rabbasca-processes",
    order = "b[processed]-a[bottle]",
},
{
    type = "capsule",
    icons = {
      { icon = "__rabbasca-assets__/graphics/by-openai/warp-trace.png", icon_size = 256 },
      { icon = "__rabbasca-assets__/graphics/recolor/icons/warp-core.png", icon_size = 64 }
    },
    name = "rabbasca-warp-core",
    capsule_action =
    {
      type = "throw",
      attack_parameters =
      {
        type = "projectile",
        activation_type = "throw",
        ammo_category = "grenade",
        cooldown = 30,
        projectile_creation_distance = 0.6,
        range = 25,
        ammo_type =
        {
          target_type = "position",
          action =
          {
            {
              type = "direct",
              action_delivery =
              {
                type = "projectile",
                projectile = "rabbasca-warp-core",
                starting_speed = 0.5
              }
            },
            {
              type = "direct",
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "play-sound",
                    sound = sounds.throw_projectile
                  },
                  {
                    type = "play-sound",
                    sound = sounds.throw_grenade
                  },
                }
              }
            }
          }
        }
      }
    },
    stack_size = 5,
    weight = 100*kg,
    subgroup = "rabbasca-processes",
    order = "w[warp]-a[warp-core]",
    spoil_ticks = settings.startup["rabbasca-warp-core-spoils"].value and 2 * hour or 0,
    spoil_to_trigger_result = {
      items_per_trigger = 1,
      trigger = core_impact_effects,
    },
    auto_recycle = false,
},
{
  type = "fluid",
    name = "harene",
    icon = "__rabbasca-assets__/graphics/recolor/icons/harene.png",
    icon_size = 64,
    subgroup = "fluid",
    base_color = {r=0.65, g=0.31, b=0.92},
    flow_color = {r=0.65, g=0.31, b=0.92},
    default_temperature = -45.0,
    max_temperature = -10,
    heat_capacity = "8MJ",
    fuel_value = "100MJ",
    auto_barrel = true,
    order = "r[rabbasca]-c[harene]"
},
{
    type = "fluid",
    name = "harene-gas",
    icon = "__rabbasca-assets__/graphics/recolor/icons/harene-gas.png",
    icon_size = 64,
    subgroup = "fluid",
    base_color = {r=0.65, g=0.31, b=0.92},
    flow_color = {r=0.65, g=0.31, b=0.92},
    default_temperature = 35.0,
    fuel_value = "120kJ",
    auto_barrel = true,
    order = "r[rabbasca]-b[harene-gas]"
},
{
    type = "fluid",
    name = "beta-carotene",
    icon = "__rabbasca-assets__/graphics/recolor/icons/beta-carotene.png",
    icon_size = 64,
    subgroup = "fluid",
    base_color = { 0.8, 0.42, 0.02 },
    flow_color = { 0.8, 0.42, 0.02 },
    default_temperature = 14.0,
    auto_barrel = true,
    order = "r[rabbasca]-a[beta-carotene]",
},
{
    type = "fluid",
    name = "energetic-residue",
    icon = "__rabbasca-assets__/graphics/recolor/icons/energetic-residue.png",
    icon_size = 64,
    subgroup = "fluid",
    base_color = {0, 0.14, 0.53},
    flow_color = {0, 0.14, 0.53},
    default_temperature = 72.0,
    auto_barrel = true,
    order = "r[rabbasca]-b[energetic-residue]"
},
{
    type = "fluid",
    name = "harenic-lava",
    icon = "__rabbasca-assets__/graphics/recolor/icons/harenic-lava.png",
    icon_size = 64,
    subgroup = "fluid",
    base_color = {0.8, 0.13, 0.44},
    flow_color = {0.8, 0.13, 0.44},
    default_temperature = 1800,
    auto_barrel = false,
    order = "r[rabbasca]-c[harenic-lava]"
},
{
    type = "item",
    name = "harene-cryo-container-empty",
    icon = "__rabbasca-assets__/graphics/by-malcolmriley/part-fuel-rod.png",
    icon_size = 64,
    stack_size = 10,
    weight = 25 * kg,
    subgroup = "rabbasca-processes",
    order = "r[lategame]-a[harene-cryo-container-empty]"
},
{
    type = "item",
    name = "harene-cryo-container-filled",
    icon = "__rabbasca-assets__/graphics/by-malcolmriley/part-fuel-rod-2.png",
    icon_size = 64,
    stack_size = 10,
    weight = 50 * kg,
    subgroup = "rabbasca-processes",
    order = "r[lategame]-a[harene-cryo-container-filled]",
    spoil_ticks = 7 * minute,
    spoil_result = "harene-cryo-container-empty",
},

util.merge { data.raw["item"]["automation-science-pack"], {
  name = "athletic-science-pack",
  icon = "__rabbasca-assets__/graphics/recolor/icons/athletic-science-pack.png",
  icon_size = 64,
  order = "j-r[rabbasca]",
  weight = 0.1 * kg,
  stack_size = 500
}},
util.merge{
  data.raw["item"]["concrete"],
  {
    type = "item",
    name = "rabbasca-energetic-concrete",
    icons = { { icon = "__base__/graphics/icons/concrete.png", tint = {r=0.65, g=0.31, b=0.92}, icon_size = 64 } },
    stack_size = 50,
    place_as_tile =
    {
      result = "rabbasca-energetic-concrete",
    },
    order = "b[concrete]-f[energetic-concrete]",
  }
},
{
    type = "ammo",
    name = "vault-access-key",
    subgroup = "rabbasca-security",
    order = "a[vault-access-key]",
    icon = "__Krastorio2Assets__/icons/cards/optimization-tech-card.png",
    icon_size = 64,
    stack_size = 20,     
    flags = { "hide-from-bonus-gui" },
    ammo_type = {
      action = {
        action_delivery = {
          source_effects = {
            entity_name = "explosion-gunshot",
            only_when_visible = true,
            type = "create-explosion",
          },
          target_effects = {
            entity_name = "rabbasca-capture-robot",
            show_in_tooltip = true,
            type = "create-entity"
          },
          type = "instant"
        },
        type = "direct"
      },
      target_filter = { "rabbasca-vault-spawner" }
    },
    ammo_category = "bullet",
    shoot_protected = true,
    reload_time = 2 * second
},
{
    type = "ammo",
    icon = "__Krastorio2Assets__/icons/cards/advanced-tech-card.png",
    icon_size = 64,
    name = "vault-security-key",
    subgroup = "rabbasca-security",
    order = "a[vault-security-key]",
    stack_size = 20,
    flags = { "hide-from-bonus-gui" },
    ammo_type = {
      action = {
        action_delivery = {
          source_effects = {
            entity_name = "explosion-gunshot",
            only_when_visible = true,
            type = "create-explosion",
          },
          target_effects = {
            entity_name = "rabbasca-capture-robot-2",
            show_in_tooltip = true,
            type = "create-entity"
          },
          type = "instant"
        },
        type = "direct"
      },
      target_filter = { "rabbasca-vault-spawner", "rabbasca-vault-warp-spawner" }
    },
    ammo_category = "bullet",
    shoot_protected = true,
    reload_time = 10 * second
},
Rabbasca.make_trigger_item({
  name = "rabbasca-security-modulator",
  categories = { "rabbasca-security" },
  order = "b[vault-access-key]",
  icons = {
    {icon = "__Krastorio2Assets__/icons/cards/advanced-tech-card.png", icon_size = 64, shift = {-8,  0}, scale = 0.4 },
    {icon = data.raw["virtual-signal"]["up-arrow"].icon,   icon_size = 64, shift = { 8, -8}, scale = 0.4, tint = {1, 0, 0} },
    {icon = data.raw["virtual-signal"]["down-arrow"].icon, icon_size = 64, shift = { 8,  8}, scale = 0.4, tint = {0, 1, 0} },
  },
},"rabbasca_on_modulate_vault_security"),
}

data:extend {
util.merge {
  data.raw["item"]["rabbasca-turbofuel"],
  {
      name = "rabbasca-hyperfuel",
      weight = 10 * kg,
      icon = "__rabbasca-assets__/graphics/recolor/icons/hyperfuel.png",
      icon_size = 64,
      fuel_value = "8.765GJ",
      fuel_acceleration_multiplier = 5.5,
      fuel_top_speed_multiplier = 4.2,
      subgroup = "rabbasca-processes",
      order = "b[processed]-a[rabbasca-turbofuel]-b",
      stack_size = 5,
      -- place_as_equipment_result = "todo",
  },
},
util.merge {
  data.raw["fluid"]["beta-carotene"],
  {
    name = "omega-carotene",
    icon = "__rabbasca-assets__/graphics/recolor/icons/omega-carotene.png",
    base_color = { 0.9, 0.42, 0.1 },
    flow_color = { 0.9, 0.5, 0.33 },
    default_temperature = 4.0,
  },
},
}

local fish_action = table.deepcopy(require("__space-age__.prototypes.item-effects").jellynut_speed)
fish_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1].sticker = "turbofish-speed-sticker"
data.raw["capsule"]["rabbasca-turbofish"].capsule_action = fish_action

local shake_action = table.deepcopy(fish_action)
shake_action.attack_parameters.ammo_type.action.action_delivery.target_effects[1].sticker = "protein-shake-speed-sticker"
data.raw["capsule"]["rabbasca-protein-shake"].capsule_action = shake_action