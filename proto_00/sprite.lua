require 'algebra'
local bit = require 'bit'

Sprite = {}
Sprite.Flip = {
    NONE = 0,
    X = 1,
    Y = 2,
}

function Sprite:new(image)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.image = image

    local w, h = obj.image:getDimensions()

    obj.width = w
    obj.height = h
    obj.posX = 0
    obj.posY = 0
    obj.rot = 0
    obj.sclX = 1
    obj.sclY = 1
    obj.ognX = 0.5
    obj.ognY = 0.5
    obj.flip = Sprite.Flip.NONE

    return obj
end

function Sprite:clone(sprite)
    local obj = Sprite:new(sprite.image)

    obj.width = sprite.width
    obj.height = sprite.height
    obj.posX = sprite.posX
    obj.posY = sprite.posY
    obj.rot = sprite.rot
    obj.sclX = sprite.sclX
    obj.sclY = sprite.sclY
    obj.ognX = sprite.ognX
    obj.ognY = sprite.ognY

    return obj
end

function Sprite:render()
    local ox = self.ognX * self.width
    local oy = self.ognY * self.height

    local sx, sy = self.sclX, self.sclY

    if bit.band(self.flip, Sprite.Flip.X) ~= 0 then
        sx = sx * -1
    end

    if bit.band(self.flip, Sprite.Flip.Y) ~= 0 then
        sy = sy * -1
    end

    love.graphics.draw(self.image,
        self.posX, self.posY,
        Math.radians(self.rot),
        sx, sy,
        ox, oy)
end

