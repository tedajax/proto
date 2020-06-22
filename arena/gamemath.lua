function modulo(a, b)
    local r = math.fmod(a, b)
    if r < 0 then
        return r + b
    else
        return r
    end
end

function wrap(value, min, max)
    return modulo(value, max - min) + min
end

function wrap_degrees(value)
    return wrap(value, 0, 360)
end

function radians_from_degrees(degrees)
    return degrees * math.pi / 180
end

function degrees_from_radians(radians)
    return radians * 180 / math.pi
end

function clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function parabolic(t)
    return -4 * t * t + 4 * t
end

function norm(x, y)
    local l = math.sqrt(x * x + y * y)
    if l ~= 0 then
        return x / l, y / l
    else
        return 0, 0
    end
end