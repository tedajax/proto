require 'entity'
require 'algebra'

ChargeBullet = {}

ChargeBullet.States = {
    charging = 1,
    charged = 2,
    launched = 3,
}

function ChargeBullet:new(px, py, r, lifetime)
    local obj = Game.entities:createEntity()
    setmetatable(obj, self)
    self.__index = self

    obj.posX = px or 0
    obj.posY = py or 0
    obj.rot = r or 0
    obj.chargeFrac = 0
    obj.targetEntity = nil
    obj.targetX = 0
    obj.targetY = 0
    obj.lifetime = lifetime or 0

    obj.state = ChargeBullet.States.charging

    obj.maxRadius = 4
    obj.speed = 40

    return obj
end

function ChargeBullet:setTarget(target)
    assert(type(target.posX) == "number" and type(target.posY) == "number")
    self.targetEntity = target
end

function ChargeBullet:launch()
    self.state = ChargeBullet.States.launched
end

function ChargeBullet:destroy()
    self.shouldDestroy = true
end

function ChargeBullet:update(dt)
    if self.state == ChargeBullet.States.launched and self.lifetime > 0 then
        self.lifetime = self.lifetime - dt
        if self.lifetime <= 0 then
            self:destroy()
        end
    end

    if self.targetEntity ~= nil then
        local dx = self.targetEntity.posX - self.posX
        local dy = self.targetEntity.posY - self.posY

        local targetRot = Vector2.getAngle(dx, dy)
        self.rot = Math.lerpAngle(self.rot, targetRot, 10 * dt)
    end

    if self.state == ChargeBullet.States.charging and self.chargeFrac >= 1 then
        self.state = ChargeBullet.States.charged
    elseif self.state == ChargeBullet.States.launched then
        self.targetX = self.posX + math.cos(Math.radians(self.rot)) * 100
        self.targetY = self.posY + math.sin(Math.radians(self.rot)) * 100

        local deltaX = self.targetX - self.posX
        local deltaY = self.targetY - self.posY

        local dirX, dirY = Vec2.normalize(deltaX, deltaY)

        self.posX = self.posX + dirX * self.speed * dt
        self.posY = self.posY + dirY * self.speed * dt
    end
end

function ChargeBullet:render(dt)
    love.graphics.circle("fill", math.floor(self.posX), math.floor(self.posY), self.maxRadius * Math.clamp01(self.chargeFrac));
end

