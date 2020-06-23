local bit = require 'bit'

function physics_init(meter, gravX, gravY)
    love.physics.setMeter(meter)
    
    physics = {
        world = love.physics.newWorld(gravX, gravY, true),
    }
    
    physics.world:setCallbacks(phyiscs_begin_contact, physics_end_contact, physics_pre_solve, physics_post_solve)
end

function physics_update(dt)
    physics.world:update(dt)
end

function physics_set_body_filter(body, category, mask, group)
    local fixtures = body:getFixtureList()
    local category = category or 1
    local mask = mask or 0xFFFF
    local group = group or 0

    for i, f in ipairs(fixtures) do
        f:setFilterData(category, mask, group)
    end
end

function phyiscs_begin_contact(a, b, contact)
    -- local ao = a:getUserData()
    -- local bo = b:getUserData()

    -- if ao ~= nil and type(ao.onCollEnter) == "function" then
    --     ao:onCollEnter(bo, coll)
    -- end

    -- if bo ~= nil and type(bo.onCollEnter) == "function" then
    --     bo:onCollEnter(ao, coll)
    -- end
end

function physics_end_contact(a, b, contact)
end

function physics_pre_solve(a, b, contact)
end

function physics_post_solve(a, b, contact, normalImpulse, tangentImpulse)
end

function physics_raycast(x, y, angle, distance)
end