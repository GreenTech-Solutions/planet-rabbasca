require("api")
require("scripts.warp.ui")
local warp = require("__planet-rabbasca__.scripts.warp.events")
local rutil = require("__planet-rabbasca__.scripts.surface-control")
local bunnyhop = require("__planet-rabbasca__.scripts.bunnyhop-control")

local function handle_script_events(event)
  local effect_id = event.effect_id
  if effect_id == "rabbasca_on_warp_attempt" then
    local from = Rabbasca.get_spoiled_in(event)
    if not (from and Rabbasca.warpers.pylons[from.name]) then return end
    warp.attempt_build_ghost(from)
  elseif effect_id == "rabbasca_register_alertable" then
    local from = event.source_entity or event.target_entity
    if not from then return end
    rutil.register_alertable(from)
  elseif effect_id == "rabbasca_on_recalc_evolution" then
    local from = event.source_entity or event.target_entity
    local position = (from and from.position) or event.target_position or event.source_position
    if from and (from.name == "rabbasca-vault-spawner" or from.name == "rabbasca-vault-console") then
      local vaults = from.surface.find_entities_filtered{ name = "rabbasca-vault-crafter", position = position }
      local vault = vaults and vaults[1]
      rutil.rabbasca_udpate_vault_force(vault, from.force)
    end
  elseif effect_id == "rabbasca_on_warp_explosion" then
    local e = event.target_entity
    if not e then return end
    if e.type == "character" or e.type == "car" or e.type == "spider-vehicle" or e.type == "unit" then
      local pos_new = { x = e.position.x + math.random(-286, 286), y = e.position.y + math.random(-286, 286) }
      pos_new = e.surface.find_non_colliding_position(e.name, pos_new, 24, 1, true)
      if pos_new then e.teleport(pos_new, nil, true) end
    elseif not e.has_flag("not-on-map") then
      e.damage(255, event.source_entity and event.source_entity.force or nil, "impact", event.source_entity, event.source_entity)
    end
  elseif effect_id == "rabbasca_on_modulate_vault_security" then
    local from = Rabbasca.get_spoiled_in(event)
    if not (from and from.name == "rabbasca-vault-crafter") then return end
    local recipe, quality = from.get_recipe()
    if not recipe then return end
    if recipe.name == "rabbasca-quality-assurance" then
      rutil.upgrade_vault_quality(from, quality)
    elseif recipe.name == "rabbasca-core-extraction-protocol" then
      from.force.set_script_visible({ type = "tile", name = "harenic-lava" }, true)
      local consoles = from.surface.find_entities_filtered{ name = { "rabbasca-vault-spawner", "rabbasca-vault-console" }, area = from.bounding_box }
      for _, console in pairs(consoles) do
        console.destroy { }
      end
      from.die(from.force, from)
    else
      local max = Rabbasca.alertness_modulation_max() / Rabbasca.alertness_modulation_step()
      local offset = recipe.name == "rabbasca-security-modulation-up" and 1 or -1
      storage.alertness_modulation = math.max(-max, math.min(max, (storage.alertness_modulation or 0) + offset))
      rutil.update_alertness(game.surfaces[event.surface_index], from.position)
    end
  elseif effect_id == "rabbasca_init_spawner" then
    local from = event.source_entity or event.target_entity
    if not from then return end
    from.force = game.forces.rabbascans
  elseif effect_id == "rabbasca_replace_tiles" then
    local pos = event.source_entity and event.source_entity.position or event.target_position
    if not pos then return end
    pos = { x = math.floor(pos.x) - 0.5, y = math.floor(pos.y) - 0.5 }
    local surface = game.surfaces[event.surface_index]
    if not surface then return end
    local tiles = {
      { position = { pos.x,    pos.y - 1}, name = "harenic-lava" },
      { position = { pos.x,    pos.y + 1}, name = "harenic-lava" },
      { position = { pos.x + 1,    pos.y}, name = "harenic-lava" },
      { position = { pos.x - 1,    pos.y}, name = "harenic-lava" },
    }
    local center = { position = {pos.x,    pos.y}, name = "harenic-lava" }
    if math.random() < 0.22 then 
      surface.set_tiles({center})
    else
      table.insert(tiles, center)
    end
    for _, t in pairs(tiles) do
      if surface.can_place_entity{name = "harenic-lava-spreader", position = t.position} or math.random() < 0.21 then
        surface.create_entity {
          name = "harenic-lava-spreader",
          position = t.position,
          create_build_effect_smoke = false,
        } -- this seems to ignore buildability
      end
    end
  elseif effect_id == "rabbasca_init_dormant_pylon" then
    local from = event.source_entity
    if not from then return end
    local pos = { x = from.position.x + math.random(-8, 8), y = from.position.y + math.random(-12, 4) } -- seems to always spawn below, so randomize upwards
    pos = from.surface.find_non_colliding_position("rabbasca-vault-warp-spawner", pos, 6, 1, true)
    if pos then from.teleport(pos) end
  elseif effect_id == "rabbasca_summon_pylon_grid_aligned" then
    local pos = event.source_entity and event.source_entity.position
    if not pos then return end
    local surface = game.surfaces[event.surface_index]
    local quality = event.source_entity and event.source_entity.quality or "normal"
    if event.source_entity then event.source_entity.destroy { } end
    local spawner = surface.create_entity {
      name = "rabbasca-vault-warp-spawner",
      position = pos,
      force = game.forces.rabbascans or game.forces.enemy,
      snap_to_grid = true,
      quality = quality
    }
    if not spawner then return end
    local pos = spawner.position
    local tiles = {
      { position = {pos.x, pos.y}, name = "rabbasca-energetic-concrete" },
      { position = {pos.x- 1, pos.y}, name = "rabbasca-energetic-concrete" },
      { position = {pos.x, pos.y- 1}, name = "rabbasca-energetic-concrete" },
      { position = {pos.x- 1, pos.y- 1}, name = "rabbasca-energetic-concrete" },
    }
    surface.set_tiles(tiles)
    for _, player in pairs(game.connected_players) do
        player.add_custom_alert(spawner, { type = "entity", name = "rabbasca-vault-warp-spawner" }, { "rabbasca-extra.alert-enemy-spawner" }, true)
    end
  elseif effect_id == "rabbasca_teleport" then
    local engine = event.source_entity or event.target_entity
    local player = engine.player or engine.owner_location.player
    if not player then return end
    bunnyhop.attempt_bunnyhop(player)  
  elseif effect_id == "rabbasca_on_pylon_capturing" then
    local e = event.source_entity
    if not e then return end
    local pylon = e.surface.find_entities_filtered{ name ="rabbasca-vault-warp-spawner", position = e.position }
    if not (pylon and #pylon > 0) then 
      return 
    end
    local id, _, _ = script.register_on_object_destroyed(pylon[1])
    storage.captured_pylon_cleanups = storage.captured_pylon_cleanups or {}
    storage.captured_pylon_cleanups[id] = { position = pylon[1].position, quality = pylon[1].quality, surface = pylon[1].surface_index }
  end
end

local function on_pylon_capture_ended(id)
  if not (storage.captured_pylon_cleanups and storage.captured_pylon_cleanups[id]) then return end
  local data = storage.captured_pylon_cleanups[id]
  if not data then return end
  storage.captured_pylon_cleanups[id] = nil
  if not game.surfaces[data.surface] then return end
  local pylon = game.surfaces[data.surface].find_entity({name = "rabbasca-warp-pylon", quality = data.quality}, data.position)
  if pylon then
    warp.register_pylon(pylon)
    if settings.global["rabbasca-deconstruct-captured-pylons"].value then
      pylon.order_deconstruction(pylon.force)
    end
  end
end

script.on_event(defines.events.on_script_trigger_effect, handle_script_events)

script.on_load(function()
  bunnyhop.register_bunnyhop_handler()
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  if event.type == defines.target_type.entity then
    rutil.deregister_alertable(event.registration_number)
    warp.unregister_pylon(event.useful_id)
    on_pylon_capture_ended(event.registration_number)
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name == "rabbasca_open_warp_inventory" then 
    game.players[event.player_index].opened = storage.warp_inventory
  elseif event.element.name == "rabbasca_alertbar_icon" then
    local player = game.get_player(event.player_index)
    if player then
      player.open_factoriopedia_gui(prototypes.entity["rabbasca-vault-spawner"])
    end
  end
end)

script.on_event({
  defines.events.on_player_controller_changed, 
  defines.events.on_player_joined_game
}, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    bunnyhop.clear_bunnyhop_ui(player)
    rutil.update_evolution_bar(player)
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
    local player = game.players[event.player_index]
    rutil.update_evolution_bar(player)
end)

script.on_event(defines.events.on_surface_created, function(event)
  if (game.planets["rabbasca"] and game.planets["rabbasca"].surface and event.surface_index == game.planets["rabbasca"].surface.index) then
    local surface = game.surfaces[event.surface_index]
    surface.create_global_electric_network()
    surface.request_to_generate_chunks({0, 0}, 1)
    surface.force_generate_chunk_requests()
    if surface.no_enemies_mode then
      game.print({ "rabbasca-extra.no-enemies-mode-ignored" })
      surface.no_enemies_mode = false
    end
  end
end)

-- counteract the natural evolution progression over time
script.on_nth_tick(60 * 60 * 5, function(_)
  local surface = game.planets["rabbasca"] and game.planets["rabbasca"].surface
  if not surface then return end
  rutil.update_alertness(surface)
end)

local function give_starter_items()
  if not Rabbasca.is_aps_planet() then return end
  if not remote.interfaces["freeplay"] then return end
  local starter_gear = {
      ["pistol"] = 1,
      ["firearm-magazine"] = 40,
      ["transport-belt"] = 200,
      ["small-electric-pole"] = 1,
      ["burner-mining-drill"] = 2
  }
  if prototypes.item["pistol"].attack_parameters.ammo_categories[1] ~= prototypes.item["vault-access-key"].ammo_category.name then
    starter_gear["submachine-gun"] = 1
  end
  if prototypes.item["kr-shelter"] then
    starter_gear["kr-shelter"] = 1
  end
  remote.call("freeplay", "set_ship_items", 
  {
      ["iron-plate"] = 100,
  })
  remote.call("freeplay", "set_created_items", starter_gear)
  remote.call("freeplay", "set_debris_items", {
      ["iron-plate"] = 15,
  })
end

-- Workaround for robots expanding into biter nests. Also compatibility for castra research
local function create_rabbasca_force()
  if game.forces.rabbascans then 
    log("Force 'rabbascans' already exists")
    return
  end
  log("Creating force 'rabbascans'")
  local force = game.create_force("rabbascans")
  force.ai_controllable = false
  force.share_chart = true
  force.set_cease_fire(game.forces.player, false)
  game.forces.player.set_cease_fire(force, false)
end

script.on_init(function()
  create_rabbasca_force()
  give_starter_items()
  warp.init_storage()
end)