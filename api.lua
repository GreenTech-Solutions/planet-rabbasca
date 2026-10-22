if Rabbasca then return end

Rabbasca = { 
    bunnyhop = { },
    warpers = helpers.stage == "runtime" and prototypes.mod_data["rabbasca-warpers"].data,
    warper_names = helpers.stage == "runtime" and { pylons = { }, uplinks = { } },
    events = helpers.stage == "runtime" and require("__planet-rabbasca__.scripts.event_handler_plus")
}

if helpers.stage == "runtime" then
    for name, _ in pairs(Rabbasca.warpers.pylons) do
        table.insert(Rabbasca.warper_names.pylons, name)
    end
    for name, _ in pairs(Rabbasca.warpers.uplinks) do
        table.insert(Rabbasca.warper_names.uplinks, name)
    end
end

-- shorthands for settings
function Rabbasca.is_aps_planet() return settings.startup["aps-planet"] and settings.startup["aps-planet"].value == "rabbasca" end
function Rabbasca.parent() return settings.startup["rabbasca-orbits"].value end
function Rabbasca.surface_megawatts() return settings.startup["rabbasca-surface-megawatts"].value end
function Rabbasca.get_warp_radius(quality) return math.min(160, 40 + (quality and quality.level or 0) * 5) end
function Rabbasca.high_energy_device_threshold() return "3.75MW" end
function Rabbasca.max_energy_device_threshold() return tostring(Rabbasca.surface_megawatts()).."MW" end
function Rabbasca.alertness_modulation_step() return 10 end
function Rabbasca.alertness_modulation_max() return 50 end

function Rabbasca.get_spoiled_in(event)
    local e = event.source_entity or event.target_entity
    if e and e.type == "inserter" then
        local pos = event.source_position or event.target_position
        if not pos then return nil end
        local surface = game.surfaces[event.surface_index]
        if surface then 
            for _, e2 in pairs(surface.find_entities_filtered{position = pos, type = "inserter"}) do
                return e2.pickup_target
            end
        end
    end
    return e
end

if remote then
    function Rabbasca.add_to_warp_inventory(inventory)
        if inventory and inventory.valid then
            for i = 1, #inventory do
                local stack = inventory[i]
                if stack and stack.valid_for_read then
                    local inserted = remote.call("rabbasca_warp_inventory", "try_insert", stack)
                    stack.count = stack.count - inserted
                end
            end
        end
    end
end

if not data then return end

local recycling = require("__recycler__.recycling")

local function bunnyhop_range(value)
return {
  type = "nothing",
  icon = "__base__/graphics/technology/engine.png",
  icon_size = 256,
  effect_description = { "modifier-description.bunnyhop-engine-range", tostring(value) }
}
end

local function bunnyhop_weight(value)
return {
  type = "nothing",
  icon = "__base__/graphics/technology/engine.png",
  icon_size = 256,
  effect_description = { "modifier-description.bunnyhop-engine-weight", tostring(value) }
}
end

function Rabbasca.bunnyhop.add_range_bonus(tech_name, range_in_km_per_level)
  local tech = data.raw["technology"][tech_name]
  if not tech then return end
  data.raw["mod-data"]["rabbasca-bunnyhop-effects"].data[tech_name] = data.raw["mod-data"]["rabbasca-bunnyhop-effects"].data[tech_name] or { }
  data.raw["mod-data"]["rabbasca-bunnyhop-effects"].data[tech_name].range = range_in_km_per_level
  table.insert(tech.effects, bunnyhop_range(range_in_km_per_level))
end

function Rabbasca.bunnyhop.add_weight_bonus(tech_name, weight_in_kg_per_level)
  if settings.startup["rabbasca-bunnyhop-force-naked"].value then return end
  local tech = data.raw["technology"][tech_name]
  if not tech then return end
  data.raw["mod-data"]["rabbasca-bunnyhop-effects"].data[tech_name] = data.raw["mod-data"]["rabbasca-bunnyhop-effects"].data[tech_name] or { }
  data.raw["mod-data"]["rabbasca-bunnyhop-effects"].data[tech_name].weight = weight_in_kg_per_level
  table.insert(tech.effects, bunnyhop_weight(weight_in_kg_per_level))
end

function Rabbasca.bunnyhop.set_requirements(name, requirements)
  if not data.raw.planet[name] then return end
  data.raw["mod-data"]["rabbasca-bunnyhop-requirements"].data[name] = requirements
end

function Rabbasca.bunnyhop.dont_allow(name)
  Rabbasca.bunnyhop.set_requirements(name, { "bunnyhop-never" })
end

function Rabbasca.below_harenic_threshold(multiplier)
    return { property = "harenic-energy-signatures", max = Rabbasca.surface_megawatts() / 2.5 * (multiplier or 1) }
end

function Rabbasca.above_harenic_threshold(multiplier)
    return { property = "harenic-energy-signatures", min = Rabbasca.surface_megawatts() / 2.5 * (multiplier or 1) }
end

function Rabbasca.within_harenic_threshold(multiplier_min, multiplier_max)
    return { property = "harenic-energy-signatures", min = Rabbasca.surface_megawatts() / 2.5 * multiplier_min, max = Rabbasca.surface_megawatts() / 2.5 * multiplier_max }
end

function Rabbasca.not_on_harenic_surface(proto, multiplier)
proto.surface_conditions = proto.surface_conditions or { }
table.insert(proto.surface_conditions, Rabbasca.below_harenic_threshold(multiplier))
end

function Rabbasca.only_on_harenic_surface(proto, multiplier)
proto.surface_conditions = proto.surface_conditions or { }
table.insert(proto.surface_conditions, Rabbasca.above_harenic_threshold(multiplier))
end

function Rabbasca.ears_flooring_rule(bbox)
    return 
    { 
        area = bbox, 
        required_tiles = { layers = { harene = true } },
        remove_on_collision = true 
    }
end

function Rabbasca.require_ears_flooring(proto)
    if not proto.collision_box then return false end
    proto.tile_buildability_rules = proto.tile_buildability_rules or { }
    table.insert(proto.tile_buildability_rules, Rabbasca.ears_flooring_rule(proto.collision_box))
    -- TODO: Should check whether rules conflict?
    return true
end

function Rabbasca.create_vault_recipe(input, values)
data:extend{
  util.merge {
    values,
  {
      name = input,
      type = "recipe",
      enabled = false,
      hide_from_signal_gui = false,
      hide_from_player_crafting = true,
      allow_decomposition = false,
      always_show_products = true,
      ingredients = { },
      categories = { "rabbasca-vault-extraction" },
      subgroup = "rabbasca-vault-extraction",
      auto_recycle = false, 
  }
}
}
end

local function energy_source_matches(e1, e2)
    return e1.energy_source and e2.energy_source 
    and e1.energy_source.type == "electric" and e2.energy_source.type == "electric" 
    and e1.energy_usage == e2.energy_usage
end

local function create_ears_entity(original, replacement_for)
    local new = table.deepcopy(original)
    if not Rabbasca.require_ears_flooring(new) then return nil end
    new.name = "harene-infused-"..original.name
    if data.raw[original.type][new.name] then return end
    new.localised_name = {"rabbasca-extra.with-ears", original.localised_name or {"entity-name." .. original.name}}
    new.localised_description = original.localised_description and {"rabbasca-extra.with-ears-description", original.localised_description} or {"rabbasca-extra.with-ears-description-noparam"}
    new.factoriopedia_alternative = original.name
    new.hidden_in_factoriopedia = true
    new.icons = Rabbasca.icons({
        { proto = original },
        { proto = data.raw["item"]["harene-ears-core"], scale = 0.5, shift = { 0, 8 } }
    })
    new.no_ears_upgrade = true
    new.fast_replaceable_group = (original.fast_replaceable_group or original.name) .. "-with-ears" -- bots ignore tile restrictions on upgrades, so we cannot upgrade from base variants
    new.next_upgrade = nil
    new.placeable_by = replacement_for and replacement_for.placeable_by or { item = new.name, count = 1 } -- for pipette, always point at original
    if replacement_for then
        new.minable = replacement_for.minable
    elseif new.minable then
        if new.minable.result == original.name then new.minable.result = new.name end
        if new.minable.results then
            for _, entry in pairs(new.minable.results) do
                if entry.name and entry.name == original.name then
                    entry.name = new.name
                end
            end
        end
    end
    new.flags = new.flags or { }
    table.insert(new.flags, "not-in-made-in")
    new.factoriopedia_alternative = original.name
    new.energy_source = util.merge{
        original.energy_source,
        { type = "void" }
    }
    if settings.startup["rabbasca-ears-local-only"].value then
        Rabbasca.only_on_harenic_surface(new, 0.1)
    end

    -- If the original entity uses PL's replacement feature, copy the replacements for EARS variants.
    -- i.e. if we just made furnace-with-ears and some mod does 
    -- PlanetsLib.assign_entity_replacement("my-planet", "furnace", "giga-furnace")
    -- and giga-furnace is EARS-able and does not differ in energy consumption or type, add giga-furnace-with-ears and
    -- PlanetsLib.assign_entity_replacement("my-planet", "furnace-with-ears", "giga-furnace-with-ears") 
    local pl_replacements = PlanetsLib and PlanetsLib.constants and PlanetsLib.constants.on_entity_placed_on_planet_replacements
    if pl_replacements then
        for planet, t in pairs(pl_replacements) do
            for replaced_entity, rep in pairs(t) do
                local original_replacement = replaced_entity == original.name and rep and rep.enabled and rep.entity ~= replaced_entity and data.raw[original.type][rep.entity]
                if original_replacement and energy_source_matches(original, original_replacement) and not original_replacement.no_ears_upgrade then
                    local new_replacement = create_ears_entity(original_replacement, new)
                    if new_replacement then
                        data.extend{ new_replacement }
                        PlanetsLib.assign_entity_replacement(planet, new.name, new_replacement.name)
                    elseif data.raw[original.type]["harene-infused-"..original_replacement.name] then
                        -- EARS variant of replacement entity already exists (i.e. for PlanetsLib.assign_entity_replacement("my-planet", "furnace", "electric-furnace"))
                        PlanetsLib.assign_entity_replacement(planet, new.name, "harene-infused-"..original_replacement.name)
                    end
                end
            end
        end
    end

    return new
end

local function create_infused_thing_with_effect(original, extra_cost)
    if original.no_ears_upgrade or original.hidden then return nil end 
    local item = data.raw["item"][original.name]
    -- TODO: should no subgroup be supported? 
    if (not item) or item.hidden or not item.subgroup then return nil end
    local new = create_ears_entity(original)
    if not new then return end
    -- RenaiTransportation looks up a thrower's range by entity name (mod-data "RTRealRange<name>"):
    -- without its own entry the copy crashes Renai when built
    local range = data.raw["mod-data"] and data.raw["mod-data"]["RTRealRange" .. original.name]
    if range then
        data:extend { { type = "mod-data", name = "RTRealRange" .. new.name, data = table.deepcopy(range.data) } }
    end
    if not extra_cost then
        new.hidden = true
        new.hidden_in_factoriopedia = true
        new.placeable_by = nil
        new.minable = original.minable
        data:extend { new }
        return new.name
    end
    local new_item = table.deepcopy(item)
    new_item.name = new.name
    new_item.hidden_in_factoriopedia = true
    new_item.icons = Rabbasca.icons({
        { proto = item },
        { proto = data.raw["item"]["harene-ears-core"], scale = 0.5, shift = { 0, 8 } }
    })
    new_item.place_result = new.name
    new_item.subgroup = (new_item.subgroup or "unknown") .. "-with-ears-core"
    new_item.factoriopedia_alternative = original.name


    if not data.raw["item-subgroup"][new_item.subgroup] then
        data:extend { util.merge {
            table.deepcopy(data.raw["item-subgroup"][item.subgroup]),
            { 
                name = new_item.subgroup,
                group = data.raw["item-group"]["rabbasca-extensions"] and "rabbasca-extensions" or nil 
            }
        } }
    end
    local new_recipe = {
        type = "recipe",
        name = new.name,
        enabled = false,
        requires_ingredients_to_unlock_results = true,
        energy_required = 30,
        ingredients = util.merge {
            extra_cost,
            { { type = "item", name = original.name, amount = 1 } },
        },
        results = { { type = "item", name = new.name, amount = 1 } },
        main_product = new.name,
        hide_from_player_crafting = true,
        categories = { "install-ears-core" },
        maximum_productivity = 1
    }
    data:extend {
      new,
      new_item,
      new_recipe
    }
    recycling.generate_recycling_recipe(new_recipe)
    return new.name
end

-- set prototype.no_ears_upgrade = true to skip ears variant creation
-- should be called in data-updates or later to ensure crafter item exists
function Rabbasca.create_ears_variant(thing, tech, extra_cost)
    if thing.energy_source.type ~= "electric" then return end
    local new_thing = create_infused_thing_with_effect(thing, extra_cost)
    if new_thing and data.raw["technology"][tech] then
        local unlocks = data.raw["technology"][tech].effects
        table.insert(unlocks,       
        {
            type = "unlock-recipe",
            recipe = new_thing
        })
        table.insert(unlocks,       
        {
            type = "unlock-recipe",
            recipe = new_thing.."-recycling",
            hidden = true
        })
    end
    return new_thing
end

function Rabbasca.make_complex_machinery(recipe)
  if not recipe then return false end

  -- if not defined, { "crafting" } is default. add explicitly so target still craftable by Hand / AM1-3
  recipe.categories = recipe.categories or { "crafting" }
  table.insert(recipe.categories, "complex-machinery")
  return true
end

function Rabbasca.make_trigger_item(item, effect_id)
    return util.merge {
    {
        type = "item",
        flags = { "ignore-spoil-time-modifier", "not-stackable", "only-in-cursor" },
        hidden = true,
        hidden_in_factoriopedia = true,
        auto_recycle = false,
        stack_size = 1,
        spoil_ticks = 1,
        spoil_to_trigger_result =
        {
        items_per_trigger = 1,
        trigger =
        {
            type = "direct",
            action_delivery =
            {
            type = "instant",
            source_effects =
            {
                {
                type = "script",
                effect_id = effect_id
                }
            }
            }
        }
        },
    },
    item }
end

function Rabbasca.animation_layer(location, data)
    local result = require(location)
    result.filename = location..".png"
    result.frame_count = result.sprite_count
    result.shift = data.shift or result.shift
    local corrected_shift = data.scale and {result.shift[1] * data.scale / result.scale, result.shift[2] * data.scale / result.scale}
    result.shift = data.shift or corrected_shift or result.shift or { 0, 0 }
    return util.merge { result, data }
end

function Rabbasca.icons(data, expected_icon_size)
    local icons = { }
    local expected_icon_size = expected_icon_size or 64
    for _, entry in pairs(data) do
        if entry.icon then
            local icon_size = entry.icon_size or 64
            local default_scale = (expected_icon_size / 2) / icon_size
            local scale = default_scale * (entry.scale or 1)
            table.insert(icons, { icon = entry.icon, icon_size = icon_size, tint = entry.tint, shift = entry.shift, scale = scale, default_scale = default_scale, floating = entry.floating, draw_background = entry.draw_background })
        elseif entry.constant then
            table.insert(icons, { icon = "__core__/graphics/icons/technology/constants/constant-"..entry.constant..".png", icon_size = 128, scale = 0.5, shift = { 12.5, 12.5 }, floating = true })
        elseif entry.proto then 
            if entry.proto.icons then
                for _, icon in pairs(entry.proto.icons) do
                    local icon_size = (icon.icon_size or 64)
                    local default_scale = (expected_icon_size / 2) / icon_size
                    local prev_scale = icon.default_scale or default_scale
                    local scale = default_scale * (icon.scale or prev_scale) / prev_scale * (entry.scale or 1)
                    local shift_a = (entry.shift or {0, 0})
                    local shift_b = (icon.shift or {0, 0})
                    local shift = {shift_a[1] + shift_b[1], shift_a[2] + shift_b[2]}
                    table.insert(icons, { icon = icon.icon, icon_size = icon_size, tint = entry.tint, shift = shift, scale = scale, default_scale = default_scale, floating = icon.floating, draw_background = icon.draw_background })
                end
            elseif entry.proto.icon then
                local icon_size = entry.proto.icon_size or 64
                local default_scale = (expected_icon_size / 2) / icon_size
                local scale = default_scale * (entry.scale or 1)
                table.insert(icons, { icon = entry.proto.icon, icon_size = icon_size, tint = entry.tint, shift = entry.shift, scale = scale, default_scale = default_scale })
            end
        end
    end
    for _, entry in pairs(icons) do
        if entry.shift then
            entry.shift = { entry.shift[1] * expected_icon_size / 64, entry.shift[2] * expected_icon_size / 64 }
            -- entry.scale = (entry.scale or 1) / target_scale
        end
    end
    return icons
end