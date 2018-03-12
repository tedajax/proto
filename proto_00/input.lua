Input = {}

function Input:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.axes = {}
    obj.buttons = {}

    return obj
end


InputAxis = {}

function InputAxis:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.value = 0
    obj.lastValue = 0

    return obj
end

function InputAxis:update()
    self.lastValue = self.value
end

InputButton = {}

function InputButton:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.isDown = false
    obj.wasDown = false

    return obj
end

function InputButton:update()
    self.wasDown = self.isDown
end