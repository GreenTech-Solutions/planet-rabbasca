local ASSEMBLED_TYPES = {
    "assembling-machine",
    "furnace",
    "lab",
    "rocket-silo",
    "roboport",
    "inserter",
    "mining-drill",
    "cargo-bay",
    "cargo-landing-pad",
    "asteroid-collector",
    "thruster",
    "agricultural-tower",
    "burner-generator",
    "generator",
    "boiler",
    "reactor",
    "fusion-generator",
    "fusion-reactor",
}
local function is_machine(name)
    for _, category in pairs(ASSEMBLED_TYPES) do
        if data.raw[category] and data.raw[category][name] then return true end
    end
    return false
end

local ASSEMBLED_CATEGORIES = {
    "crafting",
    "advanced-crafting",
    "crafting-with-fluid"
}
local function is_assembled(recipe)
    -- recipe.categories defaults to { "crafting" } if not defined. the case for base game machines
    if not recipe.categories then return true end

    for _, category in pairs(ASSEMBLED_CATEGORIES) do
        for _, add in pairs(recipe.categories) do
            if add == category then return true end
        end
    end
    return false
end

local function produces_placeable(recipe)
    local product = recipe.main_product or (recipe.results and recipe.results[1] and recipe.results[1].name)
    return product and is_machine(product)
end

for _, recipe in pairs(data.raw["recipe"]) do
    if is_assembled(recipe) and produces_placeable(recipe) then
        Rabbasca.make_complex_machinery(recipe)
    end
end

-- non-generalizable things 
Rabbasca.make_complex_machinery(data.raw["recipe"]["space-platform-foundation"])
-- Muluna compatibility
Rabbasca.make_complex_machinery(data.raw["recipe"]["low-density-space-platform-foundation"])