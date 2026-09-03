for _, thing in pairs(data.raw["solar-panel"]) do 
  Rabbasca.not_on_harenic_surface(thing)
end
for _, thing in pairs(data.raw["burner-generator"]) do 
  Rabbasca.not_on_harenic_surface(thing)
end
for _, thing in pairs(data.raw["generator"]) do 
  Rabbasca.not_on_harenic_surface(thing)
end
for _, thing in pairs(data.raw["fusion-generator"]) do 
  Rabbasca.not_on_harenic_surface(thing)
end
for _, thing in pairs(data.raw["accumulator"]) do 
  Rabbasca.not_on_harenic_surface(thing)
end
for _, thing in pairs(data.raw["electric-energy-interface"]) do
  if thing.name ~= "rabbasca-energy-source" and thing.name ~= "electric-energy-interface" then
    Rabbasca.not_on_harenic_surface(thing)
  end
end

Rabbasca.not_on_harenic_surface(data.raw["recipe"]["rocket-part"])