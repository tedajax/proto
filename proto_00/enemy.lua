require 'entity'
require 'health'

Enemy = {}

function Enemy:new(posX, posY)
    local obj = Game.entities:createEntity()
    setmetatable(obj, self)
    self.__index = self

    obj.tag = "enemy"

    obj.size = 64
    obj.dmgTime = 0.05

    obj.health = Health:new(40)
    obj.health.onDamage = function(h, amt) obj.dmgTimer = obj.dmgTime end
    obj.health.onDeath = function(h) obj:destroy() end

    obj.posX = 0
    obj.posY = 0
    obj.rot = 0

    obj.dmgTimer = 0

    obj.shape = love.physics.newRectangleShape(obj.size, obj.size)
    obj.body = love.physics.newBody(Game.physics.world, 0, 0)
    obj.fixture = love.physics.newFixture(obj.body, obj.shape)

    obj.body:setType("dynamic")
    obj.body:setGravityScale(0)
    obj.body:setBullet(false)
    obj.body:setFixedRotation(true)
    obj.body:setPosition(posX or 0, posY or 0)

    obj.fixture:setUserData(obj)

    Game.physics:setBodyLayer(obj.body, Game.physics.layers.ENEMY)

    obj.sprite = Game.images:createSprite("clown")
    obj.move = false

    return obj
end

function Enemy:destroy()
    self.shouldDestroy = true
end

function Enemy:onDestroy()
    self.fixture:destroy()
    self.body:destroy()
end

function Enemy:update(dt)
    if self.dmgTimer > 0 then
        self.dmgTimer = self.dmgTimer - dt
    end

    self.posX, self.posY = self.body:getPosition()
    self.rot = self.body:getAngle()

    if self.posX < Game.camera.posX + 350 then
        self.move = true
    end

    if self.move then
        self.posX = self.posX + Game.scrollSpeed
    end

    self.posY = math.sin(Game.time.elapsed * 2) * 50

    self.body:setPosition(self.posX, self.posY)

    self.sprite.sclX = 8
    self.sprite.sclY = 8
    self.sprite.posX = self.posX
    self.sprite.posY = self.posY
end

function Enemy:onCollEnter(other, coll)
    if self.dmgTimer <= 0 then
        self.health:damage(1)
    end
end

function Enemy:render()
    local hw = self.size / 2
    if self.dmgTimer > 0 then
        love.graphics.setColor(255, 0, 0)
    else
        love.graphics.setColor(255, 255, 255)
    end
    self.sprite:render()
    --love.graphics.rectangle("fill", self.posX - hw, self.posY - hw, self.size, self.size)
end
