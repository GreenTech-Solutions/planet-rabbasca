local M = { }

function M.is_proto_supported(proto)
    if proto.place_result then 
        return storage.inventory_filter[proto.place_result.type] ~= true
    end
    if proto.place_as_tile_result then
        return storage.inventory_filter_tiles[proto.name] ~= true
    end
    return proto.type == "module"
end

function M.logistics_group_name()
    return tostring(settings.global["rabbasca-warp-inventory-name"].value)
end

function M.init_inventory()
    storage.inventory_warpers = { }
    storage.inventory_filter = {
        ["capture-robot"] = true,
        ["combat-robot"] = true,
        ["construction-robot"] = true,
        ["logistic-robot"] = true,
        ["car"] = true,
        ["spider-vehicle"] = true,
        ["unit"] = true,
        ["spider-unit"] = true,
        ["segmented-unit"] = true,
        ["character"] = true,
    }
    storage.inventory_filter_tiles = {
        ["haronite-plate"] = true,
        ["space-platform-foundation"] = true,
        ["low-density-space-platform-foundation"] = true,
    }
    storage.invetory_logistic_section = storage.invetory_logistic_section or { }
    for _, surface in pairs(game.surfaces) do
        for _, e in pairs(surface.find_entities_filtered { name = Rabbasca.warper_names.uplinks }) do
            table.insert(storage.inventory_warpers, e)
        end
    end

    if storage.warp_inventory then
        local recovery_surface = game.surfaces["rabbasca"] or game.surfaces["nauvis"]
        local spilled = 0
        for i = 1, #storage.warp_inventory do
            local stack = storage.warp_inventory[i]
            if stack.valid_for_read and not M.is_proto_supported(stack.prototype) then
                if recovery_surface then 
                    spilled = spilled + stack.count
                    if #recovery_surface.spill_item_stack({position = {0, 0}, stack = stack, drop_full_stack = true }) > 0 then
                        stack.clear()
                    end
                end
            end
        end
        if spilled > 0 and recovery_surface then
            game.print("[planet=rabbasca]: "..tostring(spilled).. " invalid items in [virtual-signal=rabbasca-warp-inventory] were recovered here: [gps=0,0,"..recovery_surface.name.."]")
        end
        return
    end
    storage.warp_inventory = game.create_inventory(512, { "rabbasca-extra.warp-inventory" })
end

function M.clean_leaked_inventories()
    local leaked = 0
    for _, temp_inv in pairs(game.get_script_inventories("planet-rabbasca")["planet-rabbasca"] or { }) do
        if temp_inv and temp_inv ~= storage.warp_inventory then
            leaked = leaked + 1
            temp_inv.destroy()
        end
    end 
    log("Purged "..leaked.." leaked inventories")
end

function M.update_logistic_section()
    local logi = game.forces.player.get_logistic_group(M.logistics_group_name())
    if not logi then
        game.forces.player.create_logistic_group(M.logistics_group_name())
        return
    end
    if #logi.members == 0 then return end
    local l = logi.members[1]
    local filters = { }
    for _, content in pairs(storage.warp_inventory.get_contents()) do
        local f = {
            value = { name = content.name, quality = content.quality },
            min = content.count,
        }
        table.insert(filters, f)
    end
    table.insert(filters, { value = { type = "virtual", name = "signal-black", quality = "normal" }, min = storage.warp_inventory.count_empty_stacks() })
    l.filters = filters
end

remote.add_interface("rabbasca_warp_inventory", {
    get = function() return storage.warp_inventory end
})

return M