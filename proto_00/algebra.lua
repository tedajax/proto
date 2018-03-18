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

function Vec2.fromAngle(angle)
    return math.cos(Math.radians(angle)), math.sin(Math.radians(angle))
end

function Vec2.getAngle(x, y)
    return Math.wrapDegrees(Math.degrees(math.atan2(y, x)))
end

function Vec2.transform(x, y, matrix)
    local nx = x * matrix[1] + y * matrix[2] + matrix[3]
    local ny = x * matrix[4] + y * matrix[5] + matrix[6]
end

function Vec2.translate(x, y, tx, ty)
    return x + tx, y + ty
end

function Vec2.rotate(x, y, a)
    local ar = Math.radians(a)
    local nx = x * math.cos(ar) - y * math.sin(ar)
    local ny = x * math.sin(ar) + y * math.cos(ar)
    return nx, ny
end

function Vec2.scale(x, y, sx, sy)
    return x * sx, y * sy
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

function Math.clamp01(n)
    return Math.clamp(n, 0, 1)
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

function Math.wrap(a, min, max)
    return Math.mod(a, max - min) + min
end

function Math.wrapDegrees(a)
    return Math.wrap(a, 0, 360)
end

function Math.wrapRadians(a)
    return Math.wrap(a, 0, Math.TWO_PI)
end

function Math.mod(a, b)
    local r = math.fmod(a, b)
    if r < 0 then
        return r + b
    else
        return r
    end
end

function Math.lerpDegrees(a, b, t)
    local ar, br = Math.radians(a), Math.radians(b)

    local ax, ay = math.cos(ar), math.sin(ar)
    local bx, by = math.cos(br), math.sin(br)

    local cx = Math.lerp(ax, bx, t)
    local cy = Math.lerp(ay, by, t)

    return Vec2.getAngle(cx, cy)
end
