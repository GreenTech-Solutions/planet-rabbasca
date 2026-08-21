local M = { }

function M.default_requirements(planet)
    -- If there is a cargo drop restriction, also forbid to bunnyhop cargo in. Ignored in naked mode
    if settings.startup["rabbasca-bunnyhop-force-naked"].value then return { } end
    return { "planetslib-"..planet.. "-cargo-drops" }
end

function M.get_requirements(name)
    if name == Rabbasca.parent() then return { } end
    return prototypes.mod_data["rabbasca-bunnyhop-requirements"].data[name] or M.default_requirements(name)
end


function M.can_jump_to(planet, force, is_passthrough)
  if not (is_passthrough or game.planets[planet]) or not force.is_space_location_unlocked(planet) then return false end
  local requirements = M.get_requirements(planet)
  local techs = force.technologies
  for _, req in pairs(requirements) do
    if req == "bunnyhop-never" then return false end
    if techs[req] and not techs[req].researched then return false end
  end
  return true
end

-- Initial range is 1000km (Planet <-> Moon / Moon <-> Moon), but can be extended with infinity research, 
--   restricting Planet <-> Planet to very late game usually.
-- Multi-hop: all planets reachable within max_range by summing connection lengths along the path.
-- Intermediate planets must also satisfy can_jump_to (i.e. be unlocked), so you can't reach
-- A -> B -> C if B is locked even if the total distance is within range.
function M.get_connections(from, max_range, force)
  if not (from == "rabbasca" or not settings.startup["rabbasca-bunnyhop-rabbasca-only"].value) then return { } end

  -- Build an adjacency list from all space connections (bidirectional)
  local adj = {}
  for _, conn in pairs(prototypes.space_connection) do
    local a, b = conn.from.name, conn.to.name
    adj[a] = adj[a] or {}
    adj[b] = adj[b] or {}
    table.insert(adj[a], {target = b, length = conn.length})
    table.insert(adj[b], {target = a, length = conn.length})
  end

  -- Dijkstra from `from`, tracking cumulative distance to each reachable planet
  local dist = {[from] = 0}
  local visited = {}
  -- Queue entries: {name, d}
  local queue = {{name = from, d = 0}}

  while #queue > 0 do
    -- Find the unvisited entry with the smallest distance
    local min_i, min_d = 1, queue[1].d
    for i = 2, #queue do
      if queue[i].d < min_d then
        min_i, min_d = i, queue[i].d
      end
    end
    local node = table.remove(queue, min_i)
    local planet, d = node.name, node.d

    if visited[planet] then goto continue end
    visited[planet] = true

    if planet ~= from and not M.can_jump_to(planet, force, true) then goto continue end

    -- Explore neighbours
    for _, edge in pairs(adj[planet] or {}) do
      local nd = d + edge.length
      if nd <= max_range and not visited[edge.target] then
        if not dist[edge.target] or nd < dist[edge.target] then
          dist[edge.target] = nd
          table.insert(queue, {name = edge.target, d = nd})
        end
      end
    end

    ::continue::
  end

  -- Collect every reachable planet (excluding origin) that can be jumped to
  local surfaces = {}
  for planet, _ in pairs(dist) do
    if planet ~= from and M.can_jump_to(planet, force) then
      local display = {"", "[img=space-location/" .. planet .. "] ", game.planets[planet].prototype.localised_name or planet}
      table.insert(surfaces, display)
    end
  end
  return surfaces
end


local function recalc_bunnyhoppers()
  storage.rabbasca_bunnyhopping = 0
  for _, player in pairs(game.connected_players) do
    if player.gui.screen.bunnyhop_ui then
      storage.rabbasca_bunnyhopping = storage.rabbasca_bunnyhopping + 1
    end
  end
end

function M.clear_bunnyhop_ui(player)
    if not (player and player.gui.screen.bunnyhop_ui) then return end
    player.gui.screen.bunnyhop_ui.destroy()
    recalc_bunnyhoppers()
    M.register_bunnyhop_handler()
end

local function get_max_range_and_weight(force)
  local all_techs = force.technologies
  local range = 0
  local weight = 0
  for tech, data in pairs(prototypes.mod_data["rabbasca-bunnyhop-effects"].data) do
    if all_techs[tech] then
      local levels = all_techs[tech].level - all_techs[tech].prototype.level
      if all_techs[tech].researched then levels = levels + 1 end
      range = range + (data.range or 0) * levels
      weight = weight + (data.weight or 0) * levels
    end
  end
  if settings.startup["rabbasca-bunnyhop-force-naked"].value then
    weight = 0
  end
  return range, weight
end

local function get_character_weight_label(character, max_weight) 
  local weight = 0
  for _, inventory in pairs({defines.inventory.character_main, defines.inventory.character_ammo, defines.inventory.character_trash}) do
    weight = weight + (character.get_inventory(inventory).weight or 0)
  end
  local cursor = character.player.cursor_stack
  if cursor.valid_for_read then
    weight = weight + (cursor.prototype.weight or 0) * cursor.count
  end
  weight = math.floor(weight / 1000)
  if weight <= max_weight then
    return true, {"rabbasca-extra.bunnyhop-weight", weight, max_weight}
  else
    return false, {"rabbasca-extra.bunnyhop-weight-too-heavy", weight, max_weight}
  end
  
end

local function on_charge_bunnyhop(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local frame = player.gui.screen.bunnyhop_ui
    if not (frame and frame.valid) then return end
    local pb = frame.bunnyhop_charge
    if not (pb and pb.valid) then return end
    local wl = frame.bunnyhop_weight
    if not (wl and wl.valid) then return end
    
    local character = player.controller_type == defines.controllers.character and player.character
    if not character then 
        M.clear_bunnyhop_ui(player)
        return
    end

    local max_weight = (wl.caption and #wl.caption == 3 and tonumber(wl.caption[3]) or -1)
    if max_weight < 0 then
      player.print({"rabbasca-extra.bunnyhop-error"})
      M.clear_bunnyhop_ui(player)
      return
    end
    is_weight_ok, wl.caption = get_character_weight_label(character, max_weight)
    local is_crafting_ok = character.crafting_queue_size == 0
    if not is_crafting_ok then
      wl.caption = {"rabbasca-extra.bunnyhop-crafting", wl.caption[2], wl.caption[3]}
    end
    -- player.walking_state.walking = true
    local delta = character.effective_speed or 1
    local needed = 100
    local change = (is_weight_ok and is_crafting_ok and delta / needed) or -0.05
    pb.value = math.min(1, math.max(pb.value - change, 0))
    -- player.character.speed = (player.character.speed or 1) * 1.2

    if pb.value > 0 then return end
    
    local list = frame.bunnyhop_surface_list
    local icon = list.get_item(list.selected_index)[2]
    local planet = string.match(icon, "%[img=space%-location/(.-)%]")
    M.clear_bunnyhop_ui(player)

    if not planet or not game.planets[planet] then return end

    local surface = game.planets[planet].surface or game.planets[planet].create_surface()
    if not surface then return end
    local cid = character.unit_number
    storage.last_bunnyhops = storage.last_bunnyhops or { }
    storage.last_bunnyhops[cid] = storage.last_bunnyhops[cid] or {}
    storage.last_bunnyhops[cid][character.surface_index] = character.position
    storage.last_bunnyhops[cid]["next_cooldown"] = settings.global["rabbasca-bunnyhop-cooldown"].value * 60 + game.tick

    local offset = storage.last_bunnyhops[cid][surface.index]
    if not (offset and offset.x and offset.y) then offset = {x = 0, y = 0} end
    local radius = 3
    if not surface.is_chunk_generated({ offset.x / 32, offset.y / 32 }) then
      surface.request_to_generate_chunks(offset, radius / 32)
      surface.force_generate_chunk_requests()
    end
    local start_pos = surface.find_non_colliding_position("character", offset, radius, 1) or {x = 0, y = 0}
    
    -- Teleport player
    if not player.teleport(start_pos, surface) then 
      player.print({"rabbasca-extra.bunnyhop-error"})
    end
end

function M.attempt_bunnyhop(player)
    if not player.character then return end
    local cid = player.character.unit_number
    local last_hops = storage.last_bunnyhops and storage.last_bunnyhops[cid] or { }
    local cooldown_until = last_hops["next_cooldown"] or 0
    local armor = player.get_inventory(defines.inventory.character_armor)[1]
    if armor and armor.valid_for_read and armor.grid then
      for _, eq in pairs(armor.grid.equipment) do
        if eq.name == "bunnyhop-engine-equipment" then
          if cooldown_until > game.tick then
            local seconds = math.ceil((storage.last_bunnyhops[cid]["next_cooldown"] - game.tick) / 60)
            local max_range, max_weight = get_max_range_and_weight(player.force)
            max_weight = max_weight * (eq.quality.default_multiplier or 1)
            local _, weight = get_character_weight_label(player.character, max_weight)
            player.create_local_flying_text { text = { "", { "rabbasca-extra.bunnyhop-on-cooldown", seconds }, "\n", weight }, create_at_cursor = true }
          else
            player.create_local_flying_text { text = { "rabbasca-extra.bunnyhop-initiating" }, create_at_cursor = true }
            M.show_bunnyhop_ui(player, eq)
          end 
          return
        end
      end
    end
    player.create_local_flying_text { text = { "rabbasca-extra.bunnyhop-not-equipped" } , create_at_cursor = true }
end

-- called in on_load: must adhere to https://lua-api.factorio.com/latest/classes/LuaBootstrap.html#on_load
function M.register_bunnyhop_handler()
    if (storage.rabbasca_bunnyhopping or 0) == 0 then
      script.on_event(defines.events.on_player_changed_position, nil)
    else
      script.on_event(defines.events.on_player_changed_position, on_charge_bunnyhop)
    end
end

function M.show_bunnyhop_ui(player, equipment)
    local max_range, max_weight = get_max_range_and_weight(player.force)
    max_weight = max_weight * (equipment.quality.default_multiplier or 1)
    local surface = player.surface
    local reachable_surfaces = M.get_connections(surface.name, max_range, player.force)

    if #reachable_surfaces == 0 then
      if settings.startup["rabbasca-bunnyhop-rabbasca-only"].value then
        player.print({"rabbasca-extra.bunnyhop-not-from-here"})
      else
        player.print({"rabbasca-extra.bunnyhop-no-target", max_range})
      end
      return 
    end

    M.clear_bunnyhop_ui(player)

    local frame = player.gui.screen.add{
        type = "frame",
        name = "bunnyhop_ui",
        caption = { "rabbasca-extra.bunnyhop-range", max_range },
        direction = "vertical"
    }
    frame.auto_center = true
    local pb = frame.add{
        type = "progressbar",
        name = "bunnyhop_charge",
        value = 1
    }
    pb.style.horizontally_stretchable = true
    local _, weight = get_character_weight_label(player.character, max_weight)
    local pb = frame.add{
        type = "label",
        name = "bunnyhop_weight",
        caption = weight
    }

    local list = frame.add{ 
      type = "list-box", 
      name = "bunnyhop_surface_list",
      items = reachable_surfaces
    }
    list.selected_index = 1
    recalc_bunnyhoppers()
    M.register_bunnyhop_handler()
end

return M