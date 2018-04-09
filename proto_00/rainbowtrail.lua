require 'algebra'
require 'hsv'

RainbowTrail = {}

function RainbowTrail:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.trailRad = 80
    obj.lifetime = 0.5
    obj.maxLineWidth = 16
    obj.fillMode = "line"
    obj.dropInterval = 0.01
    obj.dropTimer = 0
    obj.trailChunks = {}
    obj.removeQueue = {}

    return obj
end

-- tx, ty: vector of tracked x, y coordinates used to determine when new trail piece will drop
function RainbowTrail:update(tx, ty, dt)
    self.dropTimer = self.dropTimer - dt
    if self.dropTimer <= 0 then
        self.dropTimer = self.dropTimer + self.dropInterval

        table.insert(self.trailChunks, { x = tx, y = ty, lifetime = self.lifetime })
    end

    for i, v in pairs(self.trailChunks) do
        v.lifetime = v.lifetime - dt
        if v.lifetime <= 0 then
            table.insert(self.removeQueue, i)
        end
    end

    for i, idx in ipairs(self.removeQueue) do
        table.remove(self.trailChunks, idx)
        self.removeQueue[i] = nil
    end
end

function RainbowTrail:render()

    for _, v in ipairs(self.trailChunks) do
        local t = v.lifetime / self.lifetime
        local r, g, b = rgbFromHsv((Game.time.elapsed + v.lifetime * 4) * 60, 1, 1)
        love.graphics.setColor(r, g, b, t * 64)
        love.graphics.setLineWidth(t * self.maxLineWidth)
        love.graphics.circle(self.fillMode, v.x, v.y, self.trailRad * (t * 0.5 + 0.5))
    end
end
