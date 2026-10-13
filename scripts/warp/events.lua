local M = require("__planet-rabbasca__.scripts.warp.pylon")
local rebuild_network = require("__planet-rabbasca__.scripts.warp.rebuild-warp-network")

local function awake(pylon)
    if pylon.valid and pylon.get_recipe() == nil then
        pylon.set_recipe("rabbasca-warp-sequence")
    end
end

script.on_nth_tick(20, function(event)
  for i, warper in pairs(storage.inventory_warpers) do
    if not warper.valid then table.remove(storage.inventory_warpers, i) 
    else
      local inv = warper.get_inventory(defines.inventory.chest)
      for s = 1,#inv do
        local stack = inv[s]
        if stack.valid_for_read and storage.warp_inventory.can_insert(stack) and M.is_proto_supported(stack.prototype) then
          storage.warp_inventory.insert(stack)
          stack.clear()
        end
      end
    end
  end
  M.update_logistic_section()
  for surface, chunks in pairs(storage.warp_chunks) do
    for i, chunk in pairs(chunks.dirty) do
      if chunks[chunk] then
        -- M.visualize_chunk(chunks[chunk], surface, { 0, 0.15, 0.3, 0.8}, 20)
        chunks[chunk].last_update = event.tick
        local area = chunks[chunk].area
        for qid, _ in pairs(chunks[chunk].queue) do chunks[chunk].queue[qid] = { } end
        local is_empty = true
        if game.surfaces[surface] then
          for _, e in pairs(game.surfaces[surface].find_entities_filtered {
            name = { "entity-ghost", "tile-ghost", "item-request-proxy" },
            area = area,
          }) do M.register(M.get_warp_cache(e), chunks[chunk]) is_empty = false end
          for _, e in pairs(game.surfaces[surface].find_entities_filtered {
            to_be_deconstructed = true,
            area = area,
          }) do M.register(M.get_warp_cache(e), chunks[chunk]) is_empty = false end
          for _, e in pairs(game.surfaces[surface].find_entities_filtered {
            to_be_upgraded = true,
            area = area,
          }) do M.register(M.get_warp_cache(e), chunks[chunk]) is_empty = false end
          if not is_empty then
            for pid, _ in pairs(chunks[chunk].covered_by) do
              awake(storage.warp_storage[pid].entity)
            end
          end
        end
      end
      table.remove(chunks.dirty, i)
      if i > 5 then break end
    end
  end
end)

local function on_built(event)
  local e = event.entity
  if e.name == "entity-ghost"
  or e.name == "tile-ghost" then
    M.mark_chunk_dirty(e.surface_index, M.chunk_id(e.position))
  elseif Rabbasca.warpers.pylons[e.name] then
    M.register_pylon(e)
  elseif Rabbasca.warpers.uplinks[e.name] then
    table.insert(storage.inventory_warpers, e)
    local sections = e.get_logistic_sections()
    if not sections then return end
    for _, section in pairs(sections.sections) do
      if section.group == M.logistics_group_name() then return end
    end
    local new = sections.add_section(M.logistics_group_name())
    if new then new.multiplier = -1 end
  end
end

script.on_event(defines.events.script_raised_teleported, function(event)
  if Rabbasca.warpers.pylons[event.entity.name] then
    M.unregister_pylon(event.entity.unit_number)
    M.register_pylon(event.entity)
  end
end)

script.on_configuration_changed(function(_)
  rebuild_network.rebuild_network()
  M.clean_leaked_inventories()
end)

local module_events = {
  "item-request-proxy-updated",
  "item-request-proxy-created",
  "item-request-proxy-removed"
}

script.on_event(module_events, function(event)
  if not (event.proxy_target and event.proxy_target.valid) then return end
  M.mark_chunk_dirty(event.proxy_target.surface_index, M.chunk_id(event.proxy_target.position))
end)

script.on_event(defines.events.on_marked_for_upgrade, function(event)
  M.mark_chunk_dirty(event.entity.surface_index, M.chunk_id(event.entity.position))
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  M.mark_chunk_dirty(event.entity.surface_index, M.chunk_id(event.entity.position))
end)

local function on_warp_attempt(event)
    M.attempt_build_ghost(event.entity)
end

Rabbasca.events.add_lib({
    events = {
        [prototypes.recipe["rabbasca-warp-sequence"].on_crafted_event] = on_warp_attempt,
        [prototypes.recipe["rabbasca-warp-sequence-building"].on_crafted_event] = on_warp_attempt,
        [prototypes.recipe["rabbasca-warp-sequence-tile"].on_crafted_event] = on_warp_attempt,
        [prototypes.recipe["rabbasca-warp-sequence-module"].on_crafted_event] = on_warp_attempt,
        [prototypes.recipe["rabbasca-warp-sequence-reverse"].on_crafted_event] = on_warp_attempt,
        [prototypes.recipe["rabbasca-warp-sequence-upgrade"].on_crafted_event] = on_warp_attempt,
        [defines.events.on_built_entity] = on_built,
        [defines.events.on_robot_built_entity] = on_built,
        [defines.events.on_space_platform_built_entity] = on_built,
        [defines.events.script_raised_built] = on_built,
        [defines.events.script_raised_revive] = on_built,
    }
})

return M