local util = {}

function util.load_shader(filename)
    local t = {}
    for line in love.filesystem.lines(filename) do
        table.insert(t, line)
    end
    local result = table.concat(t, "\n") .. "\n"
    return result
end

return util