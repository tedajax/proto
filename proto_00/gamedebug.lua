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
