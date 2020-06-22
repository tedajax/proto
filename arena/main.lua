require 'physics'
require 'input'
require 'gamedebug'
require 'hsv'
require 'camera'
require 'gamestate'

Game = {}

function love.load()
    math.randomseed(os.time())

    local sx, sy = love.graphics.getDimensions()

    physics_init(64, 0, 300)

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

    debug_init(love.graphics.newFont("assets/prstartk.ttf", 18))

    Game.time = {}
    Game.time.elapsed = 0
    Game.time.dt = 0

    -- Create canvas scaled to appropriate pixel size
    Game.canvas = love.graphics.newCanvas(Game.width, Game.height,
        { format = "normal", msaa = 0 })
    Game.canvas:setFilter("nearest", "nearest")

    gamestates_init({
        play = {
            init = play_init,
            update = play_update,
            render = play_render
        }
    })

    gamestate_switch("play")
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "=" then
        Game.timescale = 1
    elseif key == "-" then
        Game.timescale = 0.1
    elseif key == "f12" then
        Debug.enabled = not Debug.enabled
    elseif key == "l" then
        debug_log_clear()
    elseif key == "j" then
        debug_log(tostring(love.math.random(0, 10)), 5)
    elseif key == "~" then
        debug.debug()
    end
end

function love.keyreleased(key)
end

function love.update(dt)
    debug_update(dt)
    input_update()
    gamestates_update(dt * Game.timescale)
    
    debug_watch(string.format("FPS: %d", love.timer.getFPS()))
end

function love.draw()
    love.graphics.setCanvas(Game.canvas)
    gamestates_render()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(Game.canvas,
        0, 0,
        0,
        4, 4)

    debug_render()
end

function play_init()
    Game.camera = Camera:new()
    player = {}
    player.body = love.physics.newBody(physics.world, 0, 0, "dynamic")
    player.footShape = love.physics.newCircleShape(8)
    player.footFixture = love.physics.newFixture(player.body, player.footShape)
    player.bodyShape = love.physics.newRectangleShape(0, -6, 16, 18)
    player.bodyFixture = love.physics.newFixture(player.body, player.bodyShape)

    ground = {}
    ground.body = love.physics.newBody(physics.world, 0, 90, "static")
    ground.shape = love.physics.newEdgeShape(-320, 0, 320, 0)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
end

function play_update(dt)
    Game.time.elapsed = Game.time.elapsed + dt
    Game.time.dt = dt

    physics_update(dt)

    local ix, iy = input_get_axis("horizontal"), input_get_axis("vertical")
    ix, iy = norm(ix, iy)
end

function play_render(dt)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1)

    camera_push(Game.camera)
        love.graphics.setColor(1, 1, 0)
        
        for i, fixture in ipairs(player.body:getFixtureList()) do
            local fixtureType = fixture:getType()
            if fixtureType == "circle" then
                local shape = fixture:getShape()
                local px, py = player.body:getWorldPoints(shape:getPoint())
                love.graphics.circle("line", px, py, shape:getRadius())
            elseif fixtureType == "polygon" then
                local shape = fixture:getShape()
                love.graphics.polygon("line", player.body:getWorldPoints(shape:getPoints()))
            end
        end    
    camera_pop()
end
