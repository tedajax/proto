require 'entity'
require 'algebra'

ChargeBullet = {}

ChargeBullet.States = {
    CHARGING = 1,
    CHARGED = 2,
    LAUNCHED = 3,
}

function ChargeBullet:new(px, py, r, lifetime)
    local obj = Game.entities:createEntity()
    setmetatable(obj, self)
    self.__index = self

    -- Config
    obj.speed = 40

    -- Runtime
    obj.posX = px or 0
    obj.posY = py or 0
    obj.rot = r or 0
    obj.chargeFrac = 0
    obj.targetEntity = nil
    obj.targetX = 0
    obj.targetY = 0
    obj.lifetime = lifetime or 0
    obj.state = ChargeBullet.States.CHARGING
    obj.spriteBg = Game.images:createSprite("charge_shot_bg")
    obj.spriteFg = Game.images:createSprite("charge_shot_fg")

    return obj
end

function ChargeBullet:setTarget(target)
    assert(type(target.posX) == "number" and type(target.posY) == "number")
    self.targetEntity = target
end

function ChargeBullet:launch()
    self.state = ChargeBullet.States.LAUNCHED
end

function ChargeBullet:destroy()
    self.shouldDestroy = true
end

function ChargeBullet:update(dt)
    if self.state == ChargeBullet.States.LAUNCHED and self.lifetime > 0 then
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
        self.state = ChargeBullet.States.CHARGED
    elseif self.state == ChargeBullet.States.LAUNCHED then
        self.targetX = self.posX + math.cos(Math.radians(self.rot)) * 100
        self.targetY = self.posY + math.sin(Math.radians(self.rot)) * 100

        local deltaX = self.targetX - self.posX
        local deltaY = self.targetY - self.posY

        local dirX, dirY = Vec2.normalize(deltaX, deltaY)

        self.posX = self.posX + dirX * self.speed * dt
        self.posY = self.posY + dirY * self.speed * dt
    end

    self.spriteBg.sclX = self.chargeFrac
    self.spriteBg.sclY = self.chargeFrac

    self.spriteBg.posX = self.posX
    self.spriteBg.posY = self.posY
    self.spriteFg.posX = self.posX
    self.spriteFg.posY = self.posY

    self.spriteBg.rot = self.spriteBg.rot + 180 * dt
    self.spriteFg.rot = self.spriteFg.rot - 180 * dt

    local s = 1 + math.sin(Game.time.elapsed * 10) * 0.2
    self.spriteFg.sclX = s
    self.spriteFg.sclY = s
end

function ChargeBullet:render(dt)
    --love.graphics.setColor(255, 255, 63, 191)

    love.graphics.setColor(255, 255, 255, 255)
    self.spriteBg:render()
    love.graphics.setColor(255, 255, 255, 127)

    if self.chargeFrac >= 1 then
        self.spriteFg:render()
    end

    love.graphics.setColor(255, 255, 255, 255)
end

