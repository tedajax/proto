require 'physics'
require 'input'
require 'gamedebug'
require 'hsv'
require 'camera'

Game = {}

function love.load()
    math.randomseed(os.time())

    local sx, sy = love.graphics.getDimensions()

    physics_init(64, 0, -9.81)

    Game.conf = {}
    Game.width = 320
    Game.height = 180
    Game.scrWidth = sx
    Game.scrHeight = sy
    Game.timescale = 1

    input_init({
        controls = {
            { id = "horizontal",    type = "axis", min = -1, max = 1 },
            { id = "vertical",      type = "axis", min = -1, max = 1 },
            { id = "jump",          type = "button" },
        },
        bindings = {
            { controlId = "horizontal",  key = "left",       value = -1 }, 
            { controlId = "horizontal",  key = "right",      value =  1 },
            { controlId = "vertical",    key = "up",         value = -1 },
            { controlId = "vertical",    key = "down",       value =  1 },
            { controlId = "jump",        key = "z" },
        }
    })

    Game.dbgFont = love.graphics.newFont("assets/prstartk.ttf", 18)
    love.graphics.setFont(Game.dbgFont)

    Game.time = {}
    Game.time.elapsed = 0
    Game.time.dt = 0

    -- Create canvas scaled to appropriate pixel size
    Game.canvas = love.graphics.newCanvas(Game.width, Game.height, { format = "normal", msaa = 0 })
    Game.canvas:setFilter("nearest", "nearest")

    Game.debugEnabled = false

    Game.camera = Camera:new()

    player = { x = 0, y = 0 }
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "=" then
        Game.timescale = 1
    elseif key == "-" then
        Game.timescale = 0.1
    elseif key == "f12" then
        Game.debugEnabled = not Game.debugEnabled
    end
end

function love.keyreleased(key)
end

function love.update(dt)
    Debug.Text:clear()
    Debug.Messages:update(dt)
    input_update()
    game_update(dt * Game.timescale)
    
    Debug.Text:push(string.format("FPS: %d", love.timer.getFPS()));
end

function love.draw(dt)
    love.graphics.setCanvas(Game.canvas)
    game_render(dt)
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(Game.canvas,
        0, 0,
        0,
        4, 4)

    if Game.debugEnabled then
        Debug.Text:render(dt)
    end


    Debug.Text:render()
    Debug.Messages:render()
end

function game_update(dt)
    Game.time.elapsed = Game.time.elapsed + dt
    Game.time.dt = dt

    physics_update(dt)

    local ix, iy = input_get_axis("horizontal"), input_get_axis("vertical")

    local norm = function(x, y)
        local l = math.sqrt(x * x + y * y)
        if l ~= 0 then
            return x / l, y / l
        else
            return 0, 0
        end
    end

    ix, iy = norm(ix, iy)

    player.x = player.x + ix * 100 * dt
    player.y = player.y + iy * 100 * dt
end

function game_render(dt)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1)

    local t = math.fmod(Game.time.elapsed, 1)
    local height = 100
    local dist = 200
    
    local calc = function(x)
        return x * x * -4 + x * 4
    end

    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", t * dist, Game.height - calc(t) * height, 4)

    camera_push(Game.camera)

        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("fill", player.x - 3, player.y - 3, 8, 8)

    camera_pop()
end
