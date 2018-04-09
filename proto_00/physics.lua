local bit = require 'bit'

local Physics = {}
Physics.__index = Physics

local function new(meter, gx, gy, beginFn, endFn, preFn, postFn, layers, masks)
    love.physics.setMeter(meter)
    local world = love.physics.newWorld(gx, gy, true)
    world:setCallbacks(beginFn, endFn, preFn, postFn)
    return setmetatable({
        world = world,
        layers = layers,
        masks = masks
    }, Physics)
end

function Physics:update(dt)
    self.world:update(dt)
end

function Physics:beginContact(a, b, coll)
    local ao = a:getUserData()
    local bo = b:getUserData()

    if ao ~= nil and type(ao.onCollEnter) == "function" then
        ao:onCollEnter(bo, coll)
    end

    if bo ~= nil and type(bo.onCollEnter) == "function" then
        bo:onCollEnter(ao, coll)
    end
end

function Physics:endContact(a, b, coll)
end

function Physics:preSolve(a, b, coll)
end

function Physics:postSolve(a, b, coll, normImp, tanImp)
end

function Physics:setBodyLayer(body, layer, group)
    local fixtures = body:getFixtureList()
    local mask = self.masks[layer + 1]
    local category = bit.lshift(1, layer)
    local group = group or 0

    for i, f in ipairs(fixtures) do
        if layer == self.layers.DEFAULT then
            f:setFilterData(0, 0, group)
        else
            f:setFilterData(bit.lshift(1, layer), mask, group)
        end
    end
end

return setmetatable( { new = new },
    { __call = function(_, ...) return new(...) end })