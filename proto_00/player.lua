require 'algebra'
require 'debug'
require 'chargebullet'

Player = {}

function Player:new(posX, posY)
    local obj = Game.entities:createEntity()
    setmetatable(obj, self)
    self.__index = self

    obj.tag = "player"

    -- config values
    obj.accelX = 200
    obj.accelY = 200
    obj.maxSpeedX = 50
    obj.maxSpeedY = 50
    obj.frictionX = 200
    obj.frictionY = 200
    obj.bulletSprite = Game.bulletSprite
    obj.burstInterval = 0.53
    obj.shotInterval = 0.07
    obj.shotsPerBurst = 3
    obj.burstPerHold = 1
    obj.chargeShotDelay = 0.2
    obj.fullChargeTime = 0.33
    obj.minPosX = -70
    obj.maxPosX = 40
    obj.minPosY = -35
    obj.maxPosY = 35
    obj.dashTime = 0.5
    obj.dashAccelMult = 1
    obj.dashMaxX = 100
    obj.dashMaxY = 100

    -- runtime values
    obj.posX = posX or 0
    obj.posY = posY or 0
    obj.velX = 0
    obj.velY = 0
    obj.rot = 0
    obj.sprite = nil
    obj.shotTimer = 0
    obj.shotsLeftInBurst = 0
    obj.burstsLeftInHold = 0
    obj.chargeTimer = 0
    obj.chargeDelayTimer = 0
    obj.chargeBullet = nil
    obj.dashTimer = 0
    obj.dashDirX = 0
    obj.dashDirY = 0
    obj.shotOffX = 8
    obj.shotOffY = -6

    return obj
end

function Player:update(dt)
    local h = Input:getAxis("horizontal")
    local v = Input:getAxis("vertical")

    local inputLen = math.sqrt(h * h + v * v)
    if inputLen > 0 then
        h = h / inputLen
        v = v / inputLen
    end

    if Input:getButton("dash") then
        self.dashDirX = h
        self.dashDirY = v
        self.dashTimer = self.dashTime
    end

    if self.dashTimer <= 0 then
        local accelX = h * self.accelX * dt
        local accelY = v * self.accelY * dt
        local frictionX = self.frictionX * dt
        local frictionY = self.frictionY * dt

        self:updateVel(accelX, accelY,
            self.maxSpeedX, self.maxSpeedY,
            frictionX, frictionY)
    else
        self.dashTimer = self.dashTimer - dt

        local accelX = self.dashDirX * self.accelX * self.dashAccelMult * dt
        local accelY = self.dashDirY * self.accelY * self.dashAccelMult * dt

        self:updateVel(accelX, accelY, self.dashMaxX, self.dashMaxY, 0, 0)
    end

    self.posX = self.posX + self.velX * dt
    self.posY = self.posY + self.velY * dt

    -- clamp player to screen bounds
    local lb = self.minPosX + Game.camera.posX
    local rb = self.maxPosX + Game.camera.posX
    local tb = self.minPosY + Game.camera.posY
    local bb = self.maxPosY + Game.camera.posY

    if self.posX < lb then
        self.posX = lb
        if self.velX < 0 then
            self.velX = 0
        end
    end

    if self.posX > rb then
        self.posX = rb
        if self.velX > 0 then
            self.velX = 0
        end
    end

    if self.posY < tb then
        self.posY = tb
        if self.velY < 0 then
            self.velY = 0
        end
    end

    if self.posY > bb then
        self.posY = bb
        if self.velY > 0 then
            self.velY = 0
        end
    end

    -- update rotation based on y velocity
    self.rot = Math.lerp(self.rot, Math.clamp(self.velY / self.maxSpeedY, -1, 1) * 45, 20 * dt)

    -- shooting
    if not Input:getButton("fire") then
        if self.chargeBullet ~= nil then
            if self.chargeTimer / self.fullChargeTime > 0.95 then
                self.chargeBullet.chargeFrac = 1
                self.chargeBullet:launch()
            else
                self.chargeBullet.shouldDestroy = true
            end
            self.chargeBullet = nil
        end

        self.shotTimer = 0
        self.shotsLeftInBurst = self.shotsPerBurst
        self.burstsLeftInHold = self.burstPerHold
        self.chargeDelayTimer = self.chargeShotDelay
        self.chargeTimer = 0
    elseif self.burstsLeftInHold > 0 then
        if self.shotTimer > 0 then
            self.shotTimer = self.shotTimer - dt
        end

        if self.shotTimer <= 0 then
            self:fireBullet(self.shotsLeftInBurst == self.shotsPerBurst)

            self.shotsLeftInBurst = self.shotsLeftInBurst - 1
            if self.shotsLeftInBurst > 0 then
                self.shotTimer = self.shotTimer + self.shotInterval
            else
                self.shotTimer = self.shotTimer + self.burstInterval
                self.shotsLeftInBurst = self.shotsPerBurst
                self.burstsLeftInHold = self.burstsLeftInHold - 1
            end
        end
    else
        if self.chargeDelayTimer > 0 then
            self.chargeDelayTimer = self.chargeDelayTimer - dt
        end

        if self.chargeDelayTimer <= 0 then
            if self.chargeBullet == nil then
                self.chargeBullet = self:createChargedBullet()
            end
            self.chargeTimer = math.min(self.chargeTimer + dt, self.fullChargeTime)
        end
    end

    if self.chargeBullet ~= nil then
        self.chargeBullet.chargeFrac = self.chargeTimer / self.fullChargeTime
        local sx, sy = self:getShotPos()
        self.chargeBullet.posX = sx
        self.chargeBullet.posY = sy
        self.chargeBullet.rot = self.rot
    end

    -- update sprite positioning
    if self.sprite ~= nil then
        self.sprite.sclX = 1
        self.sprite.sclX = 1
        self.sprite.posX = self.posX
        self.sprite.posY = self.posY
        -- self.sprite.rot = self.rot
    end

    Debug.Text:push(string.format("charge: %f", self.chargeTimer / self.fullChargeTime))
    Debug.Text:push(string.format("x: %f, y: %f", self.posX, self.posY))
    Debug.Text:push(string.format("vx: %d, vy: %d", self.velX, self.velY))
    Debug.Text:push(string.format("maxX: %d, maxY: %d", self.maxSpeedX, self.maxSpeedY))
end

function Player:updateVel(accelX, accelY, maxX, maxY, frictionX, frictionY)
    -- apply friction when no input present
    -- friction will not allow the velocity to change direction
    if accelX == 0 then
        if self.velX > 0 then
            self.velX = math.max(self.velX - frictionX, 0)
        elseif self.velX < 0 then
            self.velX = math.min(self.velX + frictionX, 0)
        end
    end

    if accelY == 0 then
        if self.velY > 0 then
            self.velY = math.max(self.velY - frictionY, 0)
        elseif self.velY < 0 then
            self.velY = math.min(self.velY + frictionY, 0)
        end
    end

    -- Update velocity and position
    self.velX = self.velX + accelX
    self.velY = self.velY + accelY

    -- clamp velocity
    self.velX = Math.clamp(self.velX, -maxX, maxX)
    self.velY = Math.clamp(self.velY, -maxY, maxY)
end

function Player:createBullet(bulletType, px, py, r, lifetime)
    if bulletType == "bullet" then
        return Bullet:new("bullet", px, py, r, lifetime)
    elseif bulletType == "charged" then
        return ChargeBullet:new(px, py, r, lifetime)
    end
end

function Player:getShotPos()
    local sx, sy = Vec2.rotate(self.shotOffX, self.shotOffY, self.rot)
    return self.posX + sx, self.posY + sy
end

function Player:fireBullet(isBurstStart)
    local rot = self.rot + math.sin(Game.time.elapsed * 1000) * 0.5
    local sx, sy = self:getShotPos()
    local bullet = self:createBullet("bullet", sx, sy, rot, 2)

    Game.entities:addEntity(bullet)

    if isBurstStart then
        local kx, ky = Vec2.fromAngle(self.rot)
        -- Game.camera:knock(-kx * 1, -ky * 1, 4)
    end
end

function Player:createChargedBullet()
    local bullet = self:createBullet("charged", self.posX, self.posY, self.rot, 5)
    Game.entities:addEntity(bullet)
    return bullet
end

function Player:render(dt)
    if self.sprite ~= nil then
        self.sprite:render(dt)
    end

end

-- should always return true hehehe...
function Player:isDashing()
    return self.dashTimer > 0
end