Physics = require 'physics'
require 'algebra'
require 'entity'
require 'rainbowtrail'

Bullet = {}

function Bullet:new(sprName, posX, posY, rot, lifetime)
    local obj = Game.entities:createEntity()

    setmetatable(obj, self)
    self.__index = self

    obj.sprite = Game.images:createSprite(sprName)
    obj.speed = 1600
    obj.lifetime = lifetime or 0
    obj.shouldDestroy = false
    obj.tag = "player_bullet"
    obj.timeOff = Game.time.elapsed

    obj.shape = love.physics.newRectangleShape(6 * 8, 6 * 8)
    obj.body = love.physics.newBody(Game.physics.world, 4, 1)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape)

    obj.body:setType("dynamic")
    obj.body:setGravityScale(0)
    obj.body:setBullet(true)
    obj.body:setFixedRotation(true)

    obj.fixture:setSensor(true)
    obj.fixture:setUserData(obj)

    obj.body:setPosition(posX, posY)
    obj.body:setAngle(Math.radians(rot))

    Game.physics:setBodyLayer(obj.body, Game.physics.layers.PLAYER_ATTACK, -100)

    obj.trail = RainbowTrail:new()
    obj.trail.trailRad = 50
    obj.trail.maxLineWidth = 8
    obj.trail.fillMode = "line"
    obj.trail.lifetime = 0.2

    return obj
end

function Bullet:onDestroy()
    self.fixture:destroy()
    self.body:destroy()
end

function Bullet:destroy()
    self.shouldDestroy = true
end

function Bullet:setPosition(px, py)
    self.body:setPosition(self.posX, self.posY)
end

function Bullet:update(dt)
    if self.lifetime > 0 then
        self.lifetime = self.lifetime - dt
        if self.lifetime <= 0 then
            self:destroy()
        end
    end

    self.rot = self.body:getAngle()

    local vx = math.cos(self.rot) * self.speed
    local vy = math.sin(self.rot) * self.speed
    self.body:setLinearVelocity(vx, vy)

    self.posX, self.posY = self.body:getPosition()

    self.trail:update(self.posX, self.posY, dt)

    if self.sprite ~= nil then
        self.sprite.sclX = 5
        self.sprite.sclY = 6 + Math.nsin((Game.time.elapsed - self.timeOff) * 50) * 3
        self.sprite.posX = self.posX
        self.sprite.posY = self.posY
        self.sprite.rot = Math.degrees(self.rot)
    end
end

function Bullet:onCollEnter(other, coll)
    self:destroy()
end


function Bullet:render()
    self.trail:render()

    if self.sprite ~= nil then
        local r, g, b = rgbFromHsv((Game.time.elapsed - self.timeOff) * 720, 1, 1)
        love.graphics.setColor(r, g, b)
        self.sprite:render(dt)
    end
end