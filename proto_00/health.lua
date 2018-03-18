Health = {}

function Health:new(max)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.max = max or 1
    obj.current = obj.max
    obj.onDeath = nil
    obj.onDamage = nil

    return obj
end

function Health:isDead()
    return self.current <= 0
end

function Health:damage(amt)
    if self:isDead() then
        return
    end

    self.current = math.max(self.current - amt, 0)

    if self.onDamage ~= nil then
        self.onDamage(self, amt)
    end

    if self.current <= 0 then
        self.current = 0
        if self.onDeath ~= nil then
            self.onDeath(self)
        end
    end
end
