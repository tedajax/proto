require 'algebra'

HSV_INDEX_LOOKUP = {
    { c = 1, x = 2 },
    { c = 2, x = 1 },
    { c = 2, x = 3 },
    { c = 3, x = 2 },
    { c = 3, x = 1 },
    { c = 1, x = 3 },
}

HSV_RGB_BUFFER = { 0, 0, 0 }

-- h in range 0-360
-- s in range 0-1
-- v in range 0-1
-- a in range 0-255
function rgbFromHsv(h, s, v, a)
    h = Math.wrapDegrees(h) or 0
    s = s or 0
    v = v or 0
    a = a or 255

    local hh = h / 60

    local c = v * s
    local x = (1 - math.abs((hh % 2) - 1)) * c
    local m = v - c
    local rgb = HSV_RGB_BUFFER
    rgb[1], rgb[2], rgb[3] = 0, 0, 0

    local hi = math.floor(hh)
    local hueTable = HSV_INDEX_LOOKUP[hi + 1]
    rgb[hueTable.c] = (c + m) * 255
    rgb[hueTable.x] = (x + m) * 255

    return rgb[1], rgb[2], rgb[3], a
end

