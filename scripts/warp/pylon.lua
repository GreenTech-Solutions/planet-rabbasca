local M = require("__planet-rabbasca__.scripts.warp.warp_chunks")

local status_invalid_target = {
    diode = defines.entity_status_diode.yellow,
    label = { "entity-status.rabbasca-warp-no-target" }
}
local status_no_items = {
    diode = defines.entity_status_diode.yellow,
    label = { "entity-status.rabbasca-warp-no-items" }
}
local status_ok = {
    diode = defines.entity_status_diode.green,
    label = { "entity-status.rabbasca-warp-ok" }
}

local function play_smoke(surface, position, size)
    local frames = 16
    local offset = (frames - (game.tick % frames)) % frames - 1
    rendering.draw_animation{
        animation = "rabbasca-warp-smoke",
        x_scale = 0.25 + size / 4,
        y_scale = 0.25 + size / 4,
        animation_speed = 1,
        render_layer = "smoke",
        time_to_live = 16,
        animation_offset = offset,
        target = position,
        surface = surface
    }
end

local function pylon_pickup_stack(pylon, stack, fallback_spill_position)
    local trash = pylon.get_inventory(defines.inventory.crafter_trash)
    if stack.valid_for_read and M.is_proto_supported(stack.prototype) then
        storage.warp_inventory.transfer_from_stack(stack)
    end
    if stack.valid_for_read then
        trash.transfer_from_stack(stack)
    end
    if stack.valid_for_read then
        pylon.surface.spill_item_stack{ position = fallback_spill_position or {0, 0}, stack = stack, force = pylon.force }
    end
end

local function pylon_pickup_inventory(pylon, from_inventory, fallback_spill_position)
    local trash = pylon.get_inventory(defines.inventory.crafter_trash)
    for i = 1, #from_inventory do
        local stack = from_inventory[i]
        if stack.valid_for_read and M.is_proto_supported(stack.prototype) then
            storage.warp_inventory.transfer_from_stack(stack)
        end
        if stack.valid_for_read then
            trash.transfer_from_stack(stack)
        end
        if stack.valid_for_read then
            pylon.surface.spill_item_stack{ position = fallback_spill_position or {0, 0}, stack = stack, force = pylon.force, drop_full_stack = true }
        end
    end
end

local function try_deconstruct(data, name, quality, inventory, pylon)
    if not data.entity.to_be_deconstructed() then return false, status_invalid_target end
    local entity = data.entity
    if data.name == "item-on-ground" then
        local inv = data.is_trash and pylon.get_inventory(defines.inventory.crafter_trash) or inventory
        local added = inv.insert(entity.stack)
        if added > 0 then play_smoke(entity.surface, data.position, 0.5) end
        entity.stack.count = entity.stack.count - added
        return added > 0
    elseif data.is_belt then
        local temp = game.create_inventory(1)
        for i = 1, entity.get_max_transport_line_index() do
            local line = entity.get_transport_line(i)
            temp.resize(#temp + #line)
            for j = 1, #line do
                temp.insert(line[j])
            end
            line.clear()
        end
        local surface, position = entity.surface, entity.position
        local size = { entity.bounding_box.right_bottom.x - entity.bounding_box.left_top.x, entity.bounding_box.right_bottom.y - entity.bounding_box.left_top.y }
        local result = entity.mine{ inventory = inventory }
        surface.spill_inventory { position = position, inventory = temp, force = pylon.force }
        temp.destroy()
        if result then
            play_smoke(surface, position, math.max(size[1], size[2]))
            return true, status_ok
        else
            return false, status_invalid_target
        end
    elseif not data.is_tile then -- Buildings
        for k = 1, entity.get_max_inventory_index() do 
            local spill_inventory = entity.get_inventory(k)
            if spill_inventory then entity.surface.spill_inventory { position = entity.position, inventory = spill_inventory, force = pylon.force, drop_full_stack = true } end
        end
        if entity.type == "inserter" and entity.held_stack.valid_for_read then
            entity.surface.spill_item_stack{ position = entity.position, stack = entity.held_stack, force = pylon.force }
            entity.held_stack.clear()
        end
        local surface, position = entity.surface, entity.position
        local size = { entity.bounding_box.right_bottom.x - entity.bounding_box.left_top.x, entity.bounding_box.right_bottom.y - entity.bounding_box.left_top.y }
        local result = false
        if ((entity.type == "assembling-machine" or entity.type == "furnace" or entity.type == "rocket-silo") and entity.is_crafting())
        or entity.type == "mining-drill" then
            local temp = game.create_inventory(64)
            result = entity.mine{ inventory = temp }
            surface.spill_inventory { position = position, inventory = temp, force = pylon.force, drop_full_stack = true }
            temp.destroy()
        else
            result = entity.mine{ inventory = inventory }
        end
        if result then
            play_smoke(surface, position, math.max(size[1], size[2]))
            return true, status_ok
        else
            return false, status_invalid_target
        end
    else -- Tiles
        local name, count  = data.name, data.count
        if entity.surface.get_tile(entity.position.x, entity.position.y).name ~= name then
            return false -- prevent deconstructing hidden tiles first
        end
        local c = entity.position
        c = { x = c.x + 0.5, y = c.y + 0.5}
        local objs = entity.surface.find_entities_filtered{ area = {left_top = {c.x - 0.3, c.y - 0.3}, right_bottom = {c.x + 0.3, c.y + 0.3}}, collision_mask = "object" }
        if #objs > 0 then return false end
        local inserted = inventory.insert({name = name, count = count})
        if inserted == count then
            local hidden = entity.hidden_tile
            local hidden_2 = entity.double_hidden_tile
            local surface = entity.surface
            local pos = entity.position
            surface.set_tiles({{position = pos, name = hidden or "out-of-map"}})
            surface.set_hidden_tile(pos, hidden_2)
            surface.set_double_hidden_tile(pos, nil)
            play_smoke(surface, {x = pos.x + 0.5, y = pos.y + 0.5}, 1)
            return true, status_ok
        end
        inventory.remove({name = name, count = inserted})
        return false, status_invalid_target
    end

end

local function clear_plans(request, inventory, index, decon_only)
    if not decon_only then
        local old_plans = request.insert_plan
        for i, plan in pairs(old_plans) do
            for j, ii in pairs(plan.items.in_inventory) do
                if ii.inventory == inventory and ii.stack == index then
                    plan.items.in_inventory[j] = nil
                    table.remove(plan.items.in_inventory, j)
                end
            end
            if #plan.items.in_inventory == 0 then
                old_plans[i] = nil
                table.remove(old_plans, i)
            end
        end
        request.insert_plan = old_plans
    end

    local old_plans = request.removal_plan
    for i, plan in pairs(old_plans) do
        for j, ii in pairs(plan.items.in_inventory) do
            if ii.inventory == inventory and ii.stack == index then
                plan.items.in_inventory[j] = nil
                table.remove(plan.items.in_inventory, j)
            end
        end
        if #plan.items.in_inventory == 0 then
            old_plans[i] = nil
            table.remove(old_plans, i)
        end
    end
    request.removal_plan = old_plans
end

local function try_warp_module(data, name, quality, inventory, pylon)
    local request = data.entity
    local target = request.proxy_target
    if not target then return false, status_invalid_target end
    for _, plan in pairs(request.insert_plan) do
        if plan.items.in_inventory then
            local name, quality = plan.id.name, plan.id.quality or "normal"
            for i, pos in pairs(plan.items.in_inventory) do
                local item_with_quality = { name = name, quality = quality }
                local inventory_id, where, count = pos.inventory, pos.stack, pos.count or 1
                -- TODO: Restrict to modules? Note: inventory defines overlap between type, need to check type as well
                local target_inventory = target.get_inventory(inventory_id)
                if target_inventory and inventory.get_item_count(item_with_quality) >= count then
                    local removed = inventory.remove({name = name, count = count, quality = quality})
                    local temp = game.create_inventory(1)
                    temp.insert({name = name, count = removed, quality = quality})
                    if where + 1 > #target_inventory then -- rocket silo
                        -- TODO: Rocket inventory is weird. gets resized by requests handled via bots but cannot be resized via resize()?
                        -- do nothing for now
                        pylon_pickup_inventory(pylon, temp, target.position)
                        temp.destroy()
                        
                        -- local transferred = target_inventory.transfer_from_inventory(temp)
                        -- inventory.transfer_from_inventory(temp) -- put remaining items back
                        -- if transferred > 0 then
                        --     clear_plans(request, inventory_id, where)
                        --     play_smoke(target.surface, target.position, 1)
                        --     return true, status_ok
                        -- end
                    elseif target_inventory[where + 1].swap_stack(temp[1]) then
                        pylon_pickup_inventory(pylon, temp, target.position)
                        temp.destroy()
                        clear_plans(request, inventory_id, where)
                        play_smoke(target.surface, target.position, 1)
                        return true, status_ok
                    else
                        pylon_pickup_inventory(pylon, temp, target.position)
                        temp.destroy()
                        -- game.print("[ERROR] Could not warp module into target inventory at "..target.gps_tag)
                    end
                end
            end
        end
    end
    for _, plan in pairs(request.removal_plan) do
        if plan.items.in_inventory then
            for i, pos in pairs(plan.items.in_inventory) do
                local inventory_id, where, count = pos.inventory, pos.stack, pos.count or 1
                -- TODO: Restrict to modules? Note: inventory defines overlap between type, need to check type as well
                local target_inventory = target.get_inventory(inventory_id)
                if target_inventory then
                    local stack = target_inventory[where + 1]
                    if stack.valid_for_read then
                        local into_inv = stack.type == "module" and storage.warp_inventory or pylon.get_inventory(defines.inventory.crafter_trash)
                        if into_inv.transfer_from_stack(stack) > 0 then
                            clear_plans(request, inventory_id, where, true)
                            play_smoke(target.surface, target.position, 1)
                            return true, status_ok
                        end
                    else -- item got removed before plan could execute
                        clear_plans(request, inventory_id, where, true)
                    end
                end
            end
        end
    end
    for _, player in pairs(target.force.players) do
        player.add_alert(target, defines.alert_type.no_material_for_construction)
    end
    return false, status_no_items
end

local function try_upgrade(data, name, quality, inventory, pylon)
    local entity, count = data.entity, data.count
    if pylon == entity then return false end -- can not upgrade itself, would invalidate the reference
    local new_proto, new_quality = entity.get_upgrade_target()
    if not new_proto then return false, status_invalid_target end
    if new_proto.name ~= data.name or new_quality.name ~= data.quality then return end -- upgrade changed since indexing?
    local proto_old = entity.prototype
    local to_place_old = proto_old.items_to_place_this and proto_old.items_to_place_this[1]
    if not to_place_old then return false, status_invalid_target end
    local old_name, old_count, old_quality = to_place_old.name, to_place_old.count, entity.quality.name
    local old_item = { name = old_name, count = old_count, quality = old_quality }
    if not inventory.can_insert(old_item) then return false end
    local upgraded, _ = entity.apply_upgrade()
    if upgraded == nil then return false, status_invalid_target end
    inventory.remove({ name = data.name, count = count, quality = data.quality })
    inventory.insert(old_item)
    return true, status_ok
end

local function try_build_ghost(data, name, quality, inventory, pylon)
    local entity, count = data.entity, data.count

    local removed = inventory.remove({name = name, count = count, quality = quality})
    local temp = game.create_inventory(255)
    local surface, position = entity.surface, entity.position
    local bbox = entity.bounding_box
    local result = entity.revive{ raise_revive = true, overflow = temp }
    surface.spill_inventory { position = position, inventory = temp }
    temp.destroy()
    if not result then
        inventory.insert({name = name, count = removed, quality = quality})
        return false -- maybe missing tiles below etc. NOT invalid target
    end
    local size = { bbox.right_bottom.x - bbox.left_top.x, bbox.right_bottom.y - bbox.left_top.y }
    play_smoke(surface, position, math.max(size[1], size[2]))
    return true, status_ok
end

local function remove_entity(queue, name, quality, i)
    table.remove(queue[name][quality], i)
    if next(queue[name][quality]) == nil then
        queue[name][quality] = nil
    end
    if next(queue[name]) == nil then
        queue[name] = nil
    end
end

local function attempt_warp(pylon, q, pdata, inventory, range, f)
    for _, chunkid in pairs(pdata.chunks) do
        local queue = storage.warp_chunks[pylon.surface_index][chunkid].queue[q]
        for name, qq in pairs(queue) do
            for quality, entries in pairs(qq) do
                local has = q == "modules" and 1 or q == "decon" and 1 or inventory.get_item_count({ name = name, quality = quality })
                if has > 0 then
                    for i, data in pairs(entries) do
                        if not data.entity.valid then
                            remove_entity(queue, name, quality, i)
                            M.mark_chunk_dirty(pylon.surface_index, chunkid)
                        else
                            local pos_a = data.position
                            local pos_b = pdata.position
                            local in_range = math.abs(pos_a.x - pos_b.x) <= range and math.abs(pos_a.y - pos_b.y) <= range
                            if has >= data.count and in_range then
                                local result, status = f(data, name, quality, inventory, pylon)
                                pylon.custom_status = status
                                if q ~= "modules" and status ~= nil then remove_entity(queue, name, quality, i) end
                                if result then return true end
                                M.mark_chunk_dirty(pylon.surface_index, chunkid, 30 * 60)
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

function M.attempt_build_ghost(pylon)
    local pdata = storage.warp_storage[pylon.unit_number]
    if not pdata then
        M.register_pylon(pylon) -- register when not caught by an event. i.e. directly after capture without deconstructing it first
        pdata = storage.warp_storage[pylon.unit_number]
        if not pdata then
            game.print("[ERROR] Pylon broken: "..pylon.gps_tag)
            pylon.set_recipe(nil)
            return
        end
    end
    local inventory = storage.warp_inventory
    local range = Rabbasca.get_warp_radius(pylon.quality)
    if  (pylon.force.recipes["rabbasca-warp-sequence-reverse"].enabled and attempt_warp(pylon, "decon", pdata, inventory, range, try_deconstruct)) or
        (pylon.force.recipes["rabbasca-warp-sequence-tile"].enabled and attempt_warp(pylon, "tiles", pdata, inventory, range, try_build_ghost)) or
        (pylon.force.recipes["rabbasca-warp-sequence-building"].enabled and attempt_warp(pylon, "ghosts", pdata, inventory, range, try_build_ghost)) or
        (pylon.force.recipes["rabbasca-warp-sequence-upgrade"].enabled and attempt_warp(pylon, "upgrades", pdata, inventory, range, try_upgrade)) or
        (pylon.force.recipes["rabbasca-warp-sequence-module"].enabled and attempt_warp(pylon, "modules", pdata, inventory, range, try_warp_module))
    then
        pylon.set_recipe("rabbasca-warp-sequence-building")
    else 
        for _, chunkid in pairs(pdata.chunks) do
            for _, queue in pairs(storage.warp_chunks[pylon.surface_index][chunkid].queue) do
                local next_candidate = next(queue) and queue[next_candidate]
                if next_candidate and next_candidate.entity and next_candidate.entity.valid then
                    pylon.set_recipe("rabbasca-warp-sequence")
                    return
                end
            end
            -- confirm actually empty
            M.mark_chunk_dirty(pylon.surface_index, chunkid)
        end
        pylon.set_recipe(nil)
    end
end

return M