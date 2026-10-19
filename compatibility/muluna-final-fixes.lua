local muluna_rocket_part = data.raw["recipe"]["rocket-part-muluna"]
if muluna_rocket_part then Rabbasca.not_on_harenic_surface(muluna_rocket_part) end

if data.raw["item"]["interstellar-science-pack"] and data.raw["technology"]["interstellar-science-pack"] then
    table.insert(data.raw["technology"]["interplanetary-construction-3"].unit.ingredients, { "interstellar-science-pack", 1 })
    table.insert(data.raw["technology"]["interplanetary-construction-3"].prerequisites, "interstellar-science-pack")
end