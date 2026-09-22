data.raw["item"]["beta-carotene-barrel"].fuel_categories = { "carotene" }
data.raw["item"]["beta-carotene-barrel"].fuel_value = "27.35MJ"

data.raw["item"]["omega-carotene-barrel"].fuel_categories = { "carotene" }
data.raw["item"]["omega-carotene-barrel"].fuel_value = "12.3GJ"

for _, lab in pairs(data.raw["lab"]) do
  for _, input in pairs(lab.inputs) do
    if input == "automation-science-pack" then
      table.insert(lab.inputs, "athletic-science-pack")
      break
    end
  end
end

if not Rabbasca.is_aps_planet() then
  local gleba = Rabbasca.parent()
  if data.raw["technology"]["planet-discovery-"..gleba] and data.raw["technology"]["planet-discovery-rabbasca"] then
    table.insert(data.raw["technology"]["planet-discovery-rabbasca"].prerequisites, "planet-discovery-"..gleba)
  end
end

local flamethrower_fluids = data.raw["fluid-turret"]["flamethrower-turret"].attack_parameters.fluids
table.insert(flamethrower_fluids, {type = "energetic-residue", damage_modifier = 0.15})
table.insert(flamethrower_fluids, {type = "harenic-lava", damage_modifier = 2})

if settings.startup["rabbasca-harene-easy-mode"].value then
  data.raw["recipe"]["harene"].surface_conditions = nil
  data.raw["recipe"]["harene-cryo-container-empty"].surface_conditions = nil
  data.raw["recipe"]["harene-cryo-container-filled"].surface_conditions = nil
end

require("scripts.not-on-my-lawn")
require("scripts.machine-assembly-updates")

require("compatibility.crushing-industry-updates")
require("compatibility.carna-updates")