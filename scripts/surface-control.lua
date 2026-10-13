local output = { }

function output.rabbasca_udpate_vault_force(e, force)
  if (not e) or e.name ~= "rabbasca-vault-crafter" then return end
  e.force = force
  e.disabled_by_script = force == game.forces.rabbascans
end

function output.upgrade_vault_quality(vault, quality)
  if not quality then return end
  if quality.level <= vault.quality.level then return end
  for _, e in pairs(vault.surface.find_entities_filtered { 
    name = { "rabbasca-vault-spawner", "rabbasca-vault-console" },
    area = vault.bounding_box
  }) do
    e.destroy { }
  end
  local up = vault.surface.create_entity {
      name = vault.name,
      quality = quality,
      position = vault.position,
      force = game.forces.rabbascans,
      source = vault,
      fast_replace = true,
  }

  if up and vault and vault.valid then
      for k = 1, vault.get_max_inventory_index() do 
          local spill_inventory = vault.get_inventory(k)
          local to_inventory = up.get_inventory(k)
          if spill_inventory and to_inventory then
            for i = 1,#spill_inventory do
              if #to_inventory >= i then
                spill_inventory[i].swap_stack(to_inventory[i])
              else
                vault.surface.spill_item_stack{ stack = spill_inventory[i], position = vault.position }
              end
            end
          end
      end
      vault.destroy { }
  end
end

function output.deregister_alertable(id)
  if not storage.alertness_data then return end
  local sp = storage.alertness_data.vaults[id] or storage.alertness_data.meltdowns[id]
  storage.alertness_data.vaults[id] = nil
  storage.alertness_data.meltdowns[id] = nil
  if sp then output.update_alertness(sp[1], sp[2]) end
end

function output.register_alertable(entity)
  if not storage.alertness_data then
    local v = entity.surface.find_entities_filtered { name = "rabbasca-vault-console", force = game.forces.player }
    local m = entity.surface.find_entities_filtered { name = "rabbasca-vault-meltdown" }
    storage.alertness_data = {
        vaults = { },
        meltdowns = { }
    }
    for _, vault in pairs(v) do
      local id, _, _ = script.register_on_object_destroyed(vault)
      storage.alertness_data.vaults[id] = { entity.surface, entity.position }
    end
    for _, md in pairs(m) do
      local id, _, _ = script.register_on_object_destroyed(md)
      storage.alertness_data.meltdowns[id] = { entity.surface, entity.position }
    end
  end
  if entity.name == "rabbasca-vault-console" then
    local id, _, _ = script.register_on_object_destroyed(entity)
    storage.alertness_data.vaults[id] = { entity.surface, entity.position }
  elseif entity.name == "rabbasca-vault-meltdown" then
    local id, _, _ = script.register_on_object_destroyed(entity)
    storage.alertness_data.meltdowns[id] = { entity.surface, entity.position }
  end
  output.update_alertness(entity.surface, entity.position)
end

function output.update_alertness(surface, position)
  if not surface.valid then return end
  local data = storage.alertness_data or { vaults = { }, meltdowns = { } }
  local active_vaults_count = 0
  for _, _ in pairs(data.vaults) do
    active_vaults_count = active_vaults_count + 1
  end
  local is_meltdown = next(data.meltdowns) ~= nil
  local modulation = storage.alertness_modulation or 0
  local new_evo = active_vaults_count * settings.global["rabbasca-evolution-per-vault"].value / 100 + modulation * Rabbasca.alertness_modulation_step() / 100
  new_evo = math.max(0, math.min(1, new_evo))
  if is_meltdown then
    new_evo = 1
    for _, e in pairs(surface.find_entities_filtered { name = "rabbasca-vault-console" }) do
      e.die()
    end
  end
  game.forces.rabbascans.set_evolution_factor(new_evo, surface)
  game.forces.enemy.set_evolution_factor(new_evo, surface) -- make sure factoriopedia evolution ui shows correct value
  storage.hacked_vaults = active_vaults_count
  if not position then return end
  local new_evo_text = string.format("%.1f", game.forces.rabbascans.get_evolution_factor(surface) * 100)
  for _, player in pairs(game.players) do
    player.create_local_flying_text { text = {"rabbasca-extra.alertness-floating", new_evo_text}, surface = surface, position = position }
    output.update_evolution_bar(player)
  end
end

local function create_evolution_bar(player)
    if player.gui.top.rabbasca_alertness then
        player.gui.top.rabbasca_alertness.destroy()
    end
    if not settings.get_player_settings(player)["rabbasca-show-alertness-ui"].value then return end
    
    local vaults = storage.hacked_vaults or 0
    local is_meltdown = storage.alertness_data and next(storage.alertness_data.meltdowns) ~= nil
    local modulation = storage.alertness_modulation or 0
    local evo = game.forces["rabbascans"].get_evolution_factor("rabbasca")
    local color = { 0, 1, 0 }
    if evo > 0.9 then color = { 1, 0, 0 } 
    elseif evo > 0.5  then color = { 0.75, 0.25, 0 }
    elseif evo > 0.4  then color = { 1, 0.75, 0 }
    elseif evo > 0.25 then color = { 1, 1, 0 }
    elseif evo > 0.1  then color = { 0.5, 1, 0 }
    end

    local frame = player.gui.top.add{
        type = "frame",
        name = "rabbasca_alertness",
        direction = "horizontal",
        style = "slot_window_frame",
    }
    frame.style.vertically_stretchable = false
    frame.add{
        type = "sprite-button",
        sprite= "entity/rabbasca-vault-crafter",
        style = "inventory_slot",
        name = "rabbasca_alertbar_icon",
        number = vaults,
        tooltip = {
          "rabbasca-extra.alertness-ui-tooltip", 
          vaults, 
          settings.global["rabbasca-evolution-per-vault"].value, 
          modulation, 
          Rabbasca.alertness_modulation_step(),
          string.format("%i", evo * 100) 
        }
    }
    local right = frame.add {
        type = "flow",
        direction = "vertical",
        name = "right",
    }
    right.style.top_padding = 1
    local bar = right.add{
        type = "progressbar",
        name = "evolution_bar",
        value = evo,
        style = "production_progressbar",
        caption = is_meltdown and { "rabbasca-extra.alertness-ui-meltdown" } or { "rabbasca-extra.alertness-ui", string.format("%i", evo * 100) }
      }
    bar.style.horizontal_align = is_meltdown and "center" or "right"
    bar.style.minimal_width = 96
    bar.style.natural_width = 96
    bar.style.horizontally_stretchable = true
    bar.style.vertically_stretchable = true
    -- bar.style.height = 0
    -- bar.style.vertical_align = "center"
    bar.style.color = color
    if not is_meltdown then
      local mod_max = Rabbasca.alertness_modulation_max() / Rabbasca.alertness_modulation_step()
      local bottom = right.add {
          type = "flow",
          direction = "horizontal",
          name = "bottom"
      }
      bottom.style.horizontally_stretchable = true
      bottom.style.horizontal_spacing = 2
      for i = -mod_max, -1 do
        local bar2 = bottom.add{
          type = "progressbar",
          name = "modulation_bar_neg_"..tostring(-i),
          value = modulation <= i and 1 or 0,
          style = "bonus_progressbar",
        }
        bar2.style.horizontally_stretchable = true
        bar2.style.minimal_width = 8
        bar2.style.natural_width = 8
        bar2.style.color = { 0, 1, 0 }
      end
      for i = 1, mod_max do
        local bar2 = bottom.add{
          type = "progressbar",
          name = "modulation_bar_pos_"..tostring(i),
          value = modulation >= i and 1 or 0,
          style = "bonus_progressbar",
        }
        bar2.style.horizontally_stretchable = true
        bar2.style.minimal_width = 8
        bar2.style.natural_width = 8
        bar2.style.color = { 1, 0, 0 }
      end
    end
end

function output.update_evolution_bar(player)
    local is_on_rabbasca = player.surface and player.surface.name == "rabbasca"
    local ui = player.gui.top.rabbasca_alertness
    if ui and not is_on_rabbasca then
        ui.destroy()
    elseif is_on_rabbasca then
        create_evolution_bar(player)
    end
end

return output