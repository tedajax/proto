require 'algebra'

Sprite = {}

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

function Sprite:render(dt)
    local ox = self.ognX * self.width
    local oy = self.ognY * self.height

    love.graphics.draw(self.image,
        self.posX, self.posY,
        Math.radians(self.rot),
        self.sclX, self.sclY,
        ox, oy)
end

