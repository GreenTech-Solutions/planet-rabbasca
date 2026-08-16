local rabbasca = game.surfaces["rabbasca"]
if not rabbasca then return end 

local new_offset = {1.5, 1.75}

local changed = { }
for _, e in pairs(rabbasca.find_entities_filtered{ name = "rabbasca-vault-crafter" }) do
    if math.abs(math.floor(e.position.y + 0.01) - e.position.y) > 0.25 then
        -- VERY old crafters are placed mid-tile for some reason. should  still fit as bounding box shrank by 0.3
        e.teleport({e.position.x, math.ceil(e.position.y)})
    end
    local inserters = 0
    for _, ins in pairs(rabbasca.find_entities_filtered{type = "inserter", position = e.position, radius = 4}) do
        inserters = inserters + 1
    end
    for _, sp in pairs(rabbasca.find_entities_filtered{name = { "rabbasca-vault-console", "rabbasca-vault-spawner" }, position = e.position, radius = 5}) do
        sp.teleport({ e.position.x + new_offset[1], e.position.y + new_offset[2] })
        table.insert(changed, { sp, inserters })
    end
end

if #changed > 0 then
    game.print("[planet=rabbasca] Version 0.22 adjusted the position of [color=yellow]"..#changed.."[/color] [entity=rabbasca-vault-spawner].")
    local s = ""
    local risks = 0
    for i, c in pairs(changed) do
        if c[2] > 0 then
            s = s .. "#"..tostring(i)..": "..c[1].gps_tag..",  "
            risks = risks + 1
        end
    end
    if risks > 0 then
        s = "These [color=yellow]"..risks.."[/color] locations might need [entity=inserter] adjustments: "..s
        game.print(s)
    end
end
