function debug_init(font, enabled)
    Debug = {
        enabled = enabled or true,
        font = font,
        watch_config = {
            offsetX = 5, offsetY = 5,
            lineHeight = 20
        },
        watches = {},
        log_config = {
            offsetX = -5, offsetY = 5,
            lineHeight = 20, maxLines = 8
        },
        logs = {}
    }
end

function debug_update(dt)
    if not Debug.enabled then
        return
    end

    local n = #Debug.watches
    for i = n, 1, -1 do
        Debug.watches[i] = nil
    end

    local n = #Debug.logs
    for i = n, 1, -1 do
        local log = Debug.logs[i]
        log.time = log.time - dt
        if log.time <= 0 then
            for j = i, n do
                Debug.logs[j] = Debug.logs[j + 1]
            end
        end
    end
end

function debug_render()
    if not Debug.enabled then
        return
    end

    love.graphics.setFont(Debug.font)

    love.graphics.setColor(0, 1, 0)
    for i, watch in ipairs(Debug.watches) do
        local offsetX = Debug.watch_config.offsetX
        local offsetY = Debug.watch_config.offsetY
        love.graphics.print(watch, 
            offsetX,
            (i - 1) * Debug.watch_config.lineHeight + offsetY)
    end

    local screenWidth, _ = love.graphics.getDimensions()

    love.graphics.setColor(1, 0, 0)
    for i, log in ipairs(Debug.logs) do
        local alpha = 1
        if log.time < 0.5 then
            alpha = log.time / 0.5
        end
        local width = Debug.font:getWidth(log.message)
        local offsetX = Debug.log_config.offsetX
        local offsetY = Debug.log_config.offsetY
        love.graphics.setColor(1, 0, 0, alpha)
        love.graphics.print(log.message,
            offsetX + screenWidth - width,
            offsetY + (i - 1) * Debug.log_config.lineHeight)
    end
end

function debug_watch(message)
    table.insert(Debug.watches, tostring(message))
end

function debug_log(message, duration)
    duration = duration or math.huge
    table.insert(Debug.logs, { message = tostring(message), time = duration})
end

function debug_log_clear()
    local n = #Debug.logs
    for i = n, 1, -1 do
        Debug.logs[i] = nil
    end
end