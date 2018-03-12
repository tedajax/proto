Vec2 = {}

function Vec2.magnitude(x, y)
    return math.sqrt(x * x + y * y)
end

function Vec2.magnitudeSqr(x, y)
    return x * x + y * y
end

function Vec2.normalize(x, y)
    local l = Vec2.magnitude(x, y)
    if l == 0 then
        return 0, 0
    else
        return x / l, y / l
    end
end

function Vec2.angleDir(angle)
    return math.cos(Math.radians(angle)), math.sin(Math.radians(angle))
end

function Vec2.transform(x, y, matrix)
    local nx = x * matrix[1] + y * matrix[2] + matrix[3]
    local ny = x * matrix[4] + y * matrix[5] + matrix[6]
end

Matrix = {}

function Matrix.identity()
    return { 1, 0, 0,
             0, 1, 0,
             0, 0, 1 }
end

function Matrix.translation(x, y)
    return { 1, 0, x,
             0, 1, y,
             0, 0, 1 }
end

function Matrix.rotation(a)
    local sa = math.sin(a)
    local ca = math.cos(a)

    return { ca, -sa, 0,
             sa,  ca, 0,
              0,   0, 1 }
end

function Matrix.scale(sx, sy)
    return { sx,  0, 0,
              0, sy, 0,
              0,  0, 1 }
end

function Matrix.transform(a, b)

end

Math = {}

Math.min = math.min
Math.max = math.max

function Math.clamp(n, min, max)
    if n < min then
        return min
    elseif n > max then
        return max
    else
        return n
    end
end

Math.PI = math.pi
Math.TWO_PI = math.pi * 2
Math.PI_OVER_2 = math.pi / 2

function Math.degrees(radians)
    return radians * 360 / Math.TWO_PI
end

function Math.radians(degrees)
    return degrees * Math.TWO_PI / 360
end

function Math.lerp(a, b, t)
    return a + (b - a) * t
end