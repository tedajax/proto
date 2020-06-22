K_HSV_INDEX_LOOKUP = {
    { 1, 2, 3 },
    { 2, 1, 3 },
    { 2, 3, 1 },
    { 3, 2, 1 },
    { 3, 1, 2 },
    { 1, 3, 2 },
}

G_HSV_RGB_BUFFER = { 0, 0, 0 }

-- h in range 0-360
-- s in range 0-1
-- v in range 0-1
-- a in range 0-1
function rgb_from_hsv(h, s, v, a)
    h = wrap_degrees(h) or 0
    s = s or 0
    v = v or 0
    a = a or 1

    if s <= 0 then
        return v, v, v, a
    end

    local hh = h / 60

    local c = v * s
    local x = (1 - math.abs((hh % 2) - 1)) * c
    local m = v - c
    local rgb = G_HSV_RGB_BUFFER
    rgb[1], rgb[2], rgb[3] = 0, 0, 0

    local hi = math.floor(hh)
    local hueTable = K_HSV_INDEX_LOOKUP[hi + 1]

    rgb[hueTable[1]] = (c + m)
    rgb[hueTable[2]] = (x + m)
    rgb[hueTable[3]] = m

    return rgb[1], rgb[2], rgb[3], a
end

