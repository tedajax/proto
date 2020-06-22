Debug = {}

Debug.Text = {
    offX = 5,
    offY = 5,
    lineHeight = 20,
    lines = {},

    push = function(self, str)
        assert(type(str) == "string")
        table.insert(self.lines, str)
    end,

    clear = function(self)
        for i, _ in ipairs(self.lines) do
            self.lines[i] = nil
        end
    end,

    render = function(self, dt)
        local x = self.offX
        local y = self.offY

        for i, str in ipairs(self.lines) do
            love.graphics.print(str, x, y + ((i - 1) * self.lineHeight))
        end
    end,
}

Debug.Messages = {
    offX = 5,
    offY = 20,
    lineHeight = 20,
    maxLines = 8,
    messages = {},

    log = function(self, msg, duration)
        local duration = duration or 2
        table.insert(self.messages, { msg = msg, time = duration, flagged = false })
    end,

    update = function(self, dt)
        table.sort(self.messages, function(a, b) return a.time > b.time end)
        for i, m in ipairs(self.messages) do
            m.time = m.time - dt
            if m.time <= 0 then
                table.remove(self.messages, i)
            end
        end
    end,

    render = function(self)
        local len = math.min(table.getn(self.messages), self.maxLines)

        local w, h = love.graphics.getDimensions()

        love.graphics.setColor(255, 0, 0)
        for i = 1, len do
            local msg = self.messages[i]
            if msg == nil then
                break
            end
            local alpha = 1
            if msg.time < 0.5 then
                alpha = msg.time / 0.5
            end
            love.graphics.setColor(255, 0, 0, 255 * alpha)
            love.graphics.print(msg.msg, self.offX, h - self.offY - ((i - 1) * self.lineHeight))
        end
    end,
}
