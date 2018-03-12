require 'math'

Input = {}

function Input:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.axes = {}
    obj.buttons = {}
    obj.bindings = {}

    return obj
end

function Input:addAxis(name, ...)
    assert(self.axes[name] == nil)

    self.axes[name] = InputAxis:new(...)
end

function Input:addButton(name, ...)
    assert(self.buttons[name] == nil)

    self.buttons[name] = InputButton:new(...)
end

function Input:addBinding(binding)
    assert(self.bindings[binding.name] == nil)

    if binding.inputType == "axis" then
        assert(self.axes[binding.inputName] ~= nil)
    elseif binding.inputType == "button" then
        assert(self.buttons[binding.inputName] ~= nil)
    end

    table.insert(self.bindings, binding)
end

function Input:getAxis(name)
    return self.axes[name]:get()
end

function Input:getButton(name)
    return self.buttons[name]:get()
end

function Input:getButtonPressed(name)
    return self.buttons[name]:getPressed()
end

function  Input:getButtonReleased(name)
    return self.buttons[name]:getReleased()
end

function Input:update(dt)
    for name, axis in pairs(self.axes) do
        axis:update(dt)
    end

    for name, button in pairs(self.buttons) do
        button:update(dt)
    end

    for _, binding in ipairs(self.bindings) do
        if binding.inputType == "axis" then
            local axis = self.axes[binding.inputName]

            if love.keyboard.isDown(binding.key) then
                axis:addValue(binding.value)
            end
        elseif binding.inputType == "button" then
            local button = self.buttons[binding.inputName]

            if love.keyboard.isDown(binding.key) then
                button.downCount = button.downCount + 1
            end
        end
    end
end


InputAxis = {}

function InputAxis:new(min, max)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.value = 0
    obj.lastValue = 0
    obj.min = min or -1
    obj.max = max or 1

    return obj
end

function InputAxis:addValue(value)
    self.value = self.value + value
    self.value = Math.clamp(self.value, self.min, self.max)
end

function InputAxis:update(dt)
    self.lastValue = self.value
    self.value = 0
end

function InputAxis:get()
    return self.value
end

function InputAxis:getDelta()
    return self.value - self.lastValue
end

InputButton = {}

function InputButton:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.downCount = 0
    obj.lastDownCount = 0

    return obj
end

function InputButton:update(dt)
    self.lastDownCount = self.downCount
    self.downCount = 0
end

function InputButton:get()
    return self.downCount > 0
end

function InputButton:getPressed()
    return self.downCount > 0 and self.lastDownCount == 0
end

function InputButton:getReleased()
    return self.downCount == 0 and self.lastDownCount > 0
end

InputBinding = {}

function InputBinding:new(inputType, inputName, key, value)
    assert(inputType == "axis" or inputType == "button")

    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.inputType = inputType
    obj.inputName = inputName
    obj.key = key

    if inputType == "axis" then
        obj.value = value or 1
    elseif inputType == "button" then
        obj.value = value or true
    end

    return obj
end