require 'gamemath'

Camera = {
    positionX = 0,
    positionY = 0,
    rotation = 0,
    zoom = 1,
}

function Camera:new(camera)
    camera = camera or {}
    setmetatable(camera, self)
    self.__index = self
    return camera
end

function camera_push(self)
    love.graphics.push()

    love.graphics.translate(Game.width / 2, Game.height / 2)
    love.graphics.scale(self.zoom, self.zoom)
    love.graphics.rotate(radians_from_degrees(self.rotation))
    love.graphics.translate(-self.positionX, -self.positionY)
end

function camera_pop()
    love.graphics.pop()
end
