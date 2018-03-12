require 'algebra'

Camera = {}

function Camera:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    self.posX = 0
    self.posY = 0
    self.knockX = 0
    self.knockY = 0

    self.knockFrames = 0
    self.shakeFrames = 0
    self.shakeMagnitude = 0
    self.shakeAngle = 0

    self.rot = 0
    self.zoom = 1

    return obj
end

function Camera:move(vx, vy)
    self.posX = self.posX + vx
    self.posY = self.posY + vy
end

function Camera:rotate(ang)
    self.rot = self.rot + ang
end

function Camera:getPosition()
    local px, py = self.posX, self.posY

    if self.knockFrames > 0 then
        px = px + self.knockX
        py = py + self.knockY
    end

    if self.shakeFrames > 0 then
        local sx = math.cos(Math.radians(self.shakeAngle) * 8) * self.shakeMagnitude
        local sy = math.sin(Math.radians(self.shakeAngle) * 4) * self.shakeMagnitude
        px = px + sx
        py = py + sy
    end

    return px, py
end

function Camera:push()
    love.graphics.push()

    local px, py = self:getPosition()

    love.graphics.translate(Game.width / 2, Game.height / 2)
    love.graphics.scale(self.zoom, self.zoom)
    love.graphics.rotate(Math.radians(self.rot))
    love.graphics.translate(-px, -py)
end

function Camera:pop()
    love.graphics.pop()
end

function Camera:update(dt)
    if self.knockFrames > 0 then
        self.knockFrames = self.knockFrames - 1
    end

    if self.shakeFrames > 0 then
        self.shakeFrames = self.shakeFrames - 1
        self.shakeAngle = self.shakeAngle + 25
    end
end

function Camera:knock(kx, ky, frames)
    self.knockX = kx
    self.knockY = ky
    self.knockFrames = frames
end

function Camera:shake(magnitude, frames)
    self.shakeMagnitude = magnitude
    self.shakeFrames = frames
end