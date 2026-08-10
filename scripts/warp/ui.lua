local GUI_NAME = "rabbasca_warp_queue"
local BUTTON_NAME = "rabbasca_warp_inventory"

local function destroy_gui(player)
    if player.gui.relative[BUTTON_NAME] then
        player.gui.relative[BUTTON_NAME].destroy()
    end
    if player.gui.relative[GUI_NAME] then
        player.gui.relative[GUI_NAME].destroy()
    end
end

local function create_gui(player, pylon)
    destroy_gui(player)
    local is_debugging = settings.global["rabbasca-debug-mode"].value == true
    local anchor = 
        pylon.type == "assembling-machine" and (pylon.get_recipe() and defines.relative_gui_type.assembling_machine_gui or defines.relative_gui_type.assembling_machine_select_recipe_gui)
        or defines.relative_gui_type.container_gui
    local inventory_frame = player.gui.relative.add{
        type = "frame",
        name = BUTTON_NAME,
        direction = "vertical",
        caption = { is_debugging and "rabbasca-extra.warp-inventory" or "rabbasca-extra.warp-inventory-nodebug" },
        anchor = {
            gui = anchor,
            position = defines.relative_gui_position.right
        }
    }.add{type = "frame", style = "entity_frame"}

    local inv = inventory_frame.add{
        type = "inventory",
        slots_per_row = 8,
        handle_cursor_transfer = is_debugging,
        handle_cursor_split = is_debugging,
        handle_open_item = is_debugging,
        handle_open_mod_item = is_debugging,
        handle_send_stack_to_trash = is_debugging,
        handle_send_stacks_to_trash = is_debugging,
    }
    inv.inventory = storage.warp_inventory
    inv.style.natural_height = 5 * 64
    inv.style.vertically_stretchable = false

    if storage.warp_inventory then
        storage.warp_inventory.sort_and_merge()
    end

    local items = { }
    local id = pylon.unit_number
    local pdata = storage.warp_storage[id]
    if not (pdata and is_debugging) then return end
    for _, chunkid in pairs(pdata.chunks) do
        for qname, queue in pairs(storage.warp_chunks[pylon.surface_index][chunkid].queue) do 
            for name, qq in pairs(queue) do
                for quality, entries in pairs(qq) do
                    for _, entry in pairs(entries) do
                        local key = qname == "modules" and "[img=entity/entity-ghost][entity="..name..",quality="..quality.."]" or "[img=entity/entity-ghost][item="..name..",quality="..quality.."]"
                        items[key] = (items[key] or 0) + entry.count
                    end
                end
            end
        end
    end

    local items_aggregated = { }
    for k, v in pairs(items) do
        table.insert(items_aggregated, { "", k, " x ", v })
    end

    if #items_aggregated == 0 then return end

    local frame = player.gui.relative.add{
        type = "frame",
        name = GUI_NAME,
        caption = "Warp Queue",
        direction = "vertical",
        anchor = {
            gui = anchor,
            position = defines.relative_gui_position.right
        }
    }

    frame.add {
      type = "list-box",
      items = items_aggregated
    }
end

script.on_event(defines.events.on_gui_opened, function(event)
    if event.gui_type ~= defines.gui_type.entity then return end
    if not event.entity or not event.entity.valid then return end

    local entity = event.entity
    if not(entity.valid and (Rabbasca.warpers.uplinks[entity.name] or Rabbasca.warpers.pylons[entity.name])) then return end

    local player = game.get_player(event.player_index)
    if not player then return end

    create_gui(player, entity)
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.gui_type == defines.gui_type.entity then
        local player = game.get_player(event.player_index)
        if player then
            destroy_gui(player)
        end
    end
end)