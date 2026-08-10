local remote = require("__planet-rabbasca__.scripts.warp.warp_chunks")

function remote.rebuild_network()
    remote.init_storage()
    for _, surface in pairs(game.surfaces) do
        for _, e in pairs(surface.find_entities_filtered{ 
            name = Rabbasca.warper_names.pylons
        }) do
            e.recipe_locked = false
            remote.register_pylon(e)
        end
    end
    remote.mark_all_chunks_dirty(0)
end

return remote
