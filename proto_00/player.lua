require 'algebra'
require 'debug'

Player = {}

function Player:new(posX, posY)
    local obj = Game.entities:createEntity()
    setmetatable(obj, self)
    self.__index = self

    self.tag = "player"

    -- config values
    self.accelX = 200
    self.accelY = 200
    self.maxSpeedX = 50
    self.maxSpeedY = 50
    self.frictionX = 200
    self.frictionY = 200
    self.bulletSprite = Game.bulletSprite
    self.burstInterval = 0.33
    self.shotInterval = 0.04
    self.shotsPerBurst = 3
    self.minPosX = -70
    self.maxPosX = 40
    self.minPosY = -35
    self.maxPosY = 35
    self.dashTime = 0.5
    self.dashAccelMult = 1
    self.dashMaxX = 100
    self.dashMaxY = 100

    -- runtime values
    self.posX = posX or 0
    self.posY = posY or 0
    self.velX = 0
    self.velY = 0
    self.rot = 0
    self.sprite = nil
    self.shotTimer = 0
    self.shotsLeftInBurst = 0
    self.dashTimer = 0
    self.dashDirX = 0
    self.dashDirY = 0

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
        self.shotTimer = 0
        self.shotsLeftInBurst = self.shotsPerBurst
    else
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
            end
        end
    end

    -- update sprite positioning
    if self.sprite ~= nil then
        self.sprite.posX = self.posX
        self.sprite.posY = self.posY
        self.sprite.rot = self.rot
    end

    Debug.Text:push(string.format("x: %d, y: %d", self.posX, self.posY))
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

    -- clamp velocity by applying double friction
    local frictionScl = 1
    if self.velX > maxX then
        self.velX = math.max(self.velX - accelX * frictionScl, maxX)
    elseif self.velX < -maxX then
        self.velX = math.min(self.velX + accelX * frictionScl, -maxX)
    end

    if self.velY > maxY then
        self.velY = math.max(self.velY - accelY * frictionScl, maxY)
    elseif self.velY < -maxY then
        self.velY = math.min(self.velY + accelY * frictionScl, -maxY)
    end
end

function Player:fireBullet(isBurstStart)
    local rot = self.rot + math.sin(Game.time.elapsed * 1000) * 0.5
    local bullet = Bullet:new(self.posX, self.posY, rot, 2)
    bullet.sprite = Sprite:clone(self.bulletSprite)

    Game.entities:addEntity(bullet)

    if isBurstStart then
        local kx, ky = Vec2.angleDir(self.rot)
        -- Game.camera:knock(-kx * 1, -ky * 1, 4)
    end
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

function Player:debugRender()

end