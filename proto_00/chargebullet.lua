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
    obj.speed = 640

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
    obj.timeOff = Game.time.elapsed

    obj.spriteFg.rot = 45

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

    local s = (self.chargeFrac * 1.4) - 0.2 + ((math.sin(Game.time.elapsed * 10) + 1) / 2) * 0.2
    self.spriteBg.sclX = s * 8
    self.spriteBg.sclY = s * 8

    self.spriteBg.posX = self.posX
    self.spriteBg.posY = self.posY
    self.spriteFg.posX = self.posX
    self.spriteFg.posY = self.posY

    self.spriteBg.rot = self.spriteBg.rot + 180 * dt
    self.spriteFg.rot = self.spriteFg.rot + 180 * dt

    local s = (self.chargeFrac * 1.4) - 0.2 + ((math.sin(Game.time.elapsed * 25) + 1) / 2) * 0.3
    self.spriteFg.sclX = s * 8
    self.spriteFg.sclY = s * 8
end

function ChargeBullet:render(dt)
    --love.graphics.setColor(255, 255, 63, 191)

    love.graphics.setColor(255, 255, 255, 255)
    local r, g, b = rgbFromHsv((Game.time.elapsed - self.timeOff) * 90, 1, 1)
    love.graphics.setColor(r, g, b)
    self.spriteBg:render()
    love.graphics.setColor(255, 255, 255, 127)

        local r, g, b = rgbFromHsv((Game.time.elapsed - self.timeOff * 2) * 500, 0.2, 1)
        love.graphics.setColor(r, g, b, 127)
        self.spriteFg:render()

    love.graphics.setColor(255, 255, 255, 255)
end

