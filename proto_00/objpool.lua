local ObjPool = {}
ObjPool.__index = ObjPool

local function new(newFn, resetFn)
    -- local newFn = newFn or function(...) return {} end
    -- local resetFn = resetFn or function(_, ...) end
    return setmetatable({
        new = newFn,
        reset = resetFn,
        pool = {},
        stack = {},
        stackIdx = 0
    }, ObjPool)
end

function ObjPool:acquire(...)
    if self.stackIdx > 0 then
        local r = self.stack[self.stackIdx]
        self.stackIdx = self.stackIdx - 1
        self.reset(r)
        return r
    else
        local r = self.new(...)
        self.reset(r)
        return r
    end
end

function ObjPool:release(obj)
    self.stackIdx = self.stackIdx + 1
    self.stack[self.stackIdx] = obj
end

return setmetatable({ new = new },
    { __call = function(_, ...) return new(...) end })