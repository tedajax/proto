Entity = {}
EntitySystem = {}

function Entity:new(id)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.id = id
    obj.shouldDestroy = false
    obj.tag = "default"

    return obj
end

function Entity:destroy()
    self.shouldDestroy = true
end

function EntitySystem:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.currentId = 1
    obj.entities = {}
    obj.toDestroyQueue = {}

    return obj
end

function EntitySystem:createEntity()
    local entity = Entity:new(self.currentId)
    self.currentId = self.currentId + 1
    return entity
end

function EntitySystem:addEntity(entity)
    assert(entity.id ~= nil and entity.shouldDestroy ~= nil)

    self.entities[entity.id] = entity
end

function EntitySystem:update(dt)
    for id, e in pairs(self.entities) do
        if type(e.update) == "function" then
            e:update(dt)
        end

        if e.shouldDestroy then
            table.insert(self.toDestroyQueue, e.id)
        end
    end

    for i, id in ipairs(self.toDestroyQueue) do
        if type(self.entities[id].onDestroy) == "function" then
            self.entities[id]:onDestroy()
        end
        self.entities[id] = nil
        self.toDestroyQueue[i] = nil
    end
end

function EntitySystem:render(dt)
    for id, e in pairs(self.entities) do
        if type(e.render) == "function" then
            e:render(dt)
        end
    end
end