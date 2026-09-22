local carotene_barrel = data.raw["item"]["beta-carotene-barrel"]
local carotene_barrel_2 = data.raw["item"]["beta-carotene-titanium-barrel"]

if carotene_barrel and carotene_barrel_2 then
    carotene_barrel_2.fuel_categories = carotene_barrel.fuel_categories
    carotene_barrel_2.fuel_value = carotene_barrel.fuel_value
end

local carotene_barrel = data.raw["item"]["omega-carotene-barrel"]
local carotene_barrel_2 = data.raw["item"]["omega-carotene-titanium-barrel"]

if carotene_barrel and carotene_barrel_2 then
    carotene_barrel_2.fuel_categories = carotene_barrel.fuel_categories
    carotene_barrel_2.fuel_value = carotene_barrel.fuel_value
end