require 'entity'

Enemy = {}

function Enemy:new(posX, posY)
    local obj = Game.entities:createEntity()
    setmetatable(obj, self)
    self.__index = self

    obj.tag = "enemy"

    obj.posX = posX or 0
    obj.posY = posY or 0
    obj.rot = 0

    return obj
end

function Enemy:update(dt)
end

function Enemy:render(dt)
    local hw = self.size / 2
    love.graphics.rectangle("fill", self.posX - hw, self.posY - hw, hw, hw)
end