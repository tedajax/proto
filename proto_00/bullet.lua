require 'algebra'
require 'entity'

Bullet = {}

function Bullet:new(posX, posY, rot, lifetime)
    local obj = Game.entities:createEntity()

    setmetatable(obj, self)
    self.__index = self

    obj.sprite = nil
    obj.posX = posX or 0
    obj.posY = posY or 0
    obj.rot = rot or 0
    obj.speed = 200
    obj.lifetime = lifetime or 0
    obj.shouldDestroy = false

    return obj
end

function Bullet:destroy()
    self.shouldDestroy = true
end

function Bullet:update(dt)
    if self.lifetime > 0 then
        self.lifetime = self.lifetime - dt
        if self.lifetime <= 0 then
            self:destroy()
        end
    end

    local vx = math.cos(Math.radians(self.rot)) * self.speed * dt
    local vy = math.sin(Math.radians(self.rot)) * self.speed * dt

    self.posX = self.posX + vx
    self.posY = self.posY + vy

    if self.sprite ~= nil then
        self.sprite.posX = self.posX
        self.sprite.posY = self.posY
        self.sprite.rot = self.rot
    end
end

function Bullet:render(dt)
    if self.sprite ~= nil then
        self.sprite:render(dt)
    end
end