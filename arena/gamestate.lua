function gamestates_init(states)
    gamestates = {
        states = states,
        active = nil,
    }
end

function gamestates_update(dt)
    if gamestates.active and gamestates.active.update then
        gamestates.active.update(dt)
    end
end

function gamestates_render(dt)
    if gamestates.active and gamestates.active.render then  
        gamestates.active.render(dt)
    end
end

function gamestate_switch(stateName)
    if stateName == nil then
        gamestates.active = nil
        return
    end

    local state = gamestates.states[stateName]
    if gamestates.active ~= state then
        gamestates.active = state
        gamestates.active.init()
    end
end
