require 'physics'
require 'input'
require 'gamedebug'
require 'hsv'
require 'camera'
require 'gamestate'
require 'character'

Game = {}

function love.load()
    math.randomseed(os.time())

    local sx, sy = love.graphics.getDimensions()

    physics_init(16, 0, 900)

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

    love.graphics.setLineStyle("rough")

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
    elseif key == "n" then
        attach_capsule(player, make_capsule(player.body, 8, player.capsule.height + 10))
    elseif key == "m" then
        attach_capsule(player, make_capsule(player.body, 8, player.capsule.height - 10))
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

function make_capsule(physicsBody, radius, height)
    height = math.max(height, 0)
    local bodyHeight = math.max(height - radius * 2, 0)
    local halfBodyHeight = bodyHeight / 2
    local feetShape = love.physics.newCircleShape(0, halfBodyHeight, radius)
    local headShape = love.physics.newCircleShape(0, -halfBodyHeight, radius)

    local bodyShape = love.physics.newRectangleShape(0, 0, radius * 2 - 1, math.max(bodyHeight, 1))

    local feet = love.physics.newFixture(physicsBody, feetShape)
    local head = love.physics.newFixture(physicsBody, headShape)
    local body = love.physics.newFixture(physicsBody, bodyShape)

    feet:setFriction(0.1)
    head:setFriction(0)
    body:setFriction(0)

    return {
        physicsBody = physicsBody,
        radius = radius, height = height,
        fixtures = { feet = feet, head = head, body = body },
    }
end

function destroy_capsule(capsule)
    if capsule ~= nil then
        for key, fixture in pairs(capsule.fixtures) do
            fixture:destroy()
            capsule.fixtures[key] = nil
        end
        capsule.radius = 0
        capsule.height = 0
    end
end

function attach_capsule(object, capsule)
    object = object or {}
    destroy_capsule(object.capsule)
    object.capsule = capsule
    return object
end

function play_init()
    Game.camera = Camera:new()

    player = make_character()

    ground = {}
    ground.body = love.physics.newBody(physics.world, 0, 90, "static")
    ground.shape = love.physics.newEdgeShape(-320, 0, 320, 0)
    ground.fixture = love.physics.newFixture(ground.body, ground.shape)
end

function play_update(dt)
    Game.time.elapsed = Game.time.elapsed + dt
    Game.time.dt = dt

    local ix, iy = input_get_axis("horizontal"), input_get_axis("vertical")
    ix, iy = norm(ix, iy)
    local jump = input_get_button_down("jump")

    character_control(player, ix, iy, jump)
    character_move(player)

    physics_update(dt)
end

function play_render(dt)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1)

    camera_push(Game.camera)
        love.graphics.setColor(1, 1, 0)
        local bodies = physics.world:getBodies()
        for _, body in ipairs(bodies) do
            local user = body:getUserData()
            if user and user.capsule then
                -- capsule draw
                local headShape = user.capsule.fixtures.head:getShape()
                local feetShape = user.capsule.fixtures.feet:getShape()
                local angle = body:getAngle()
                local hx, hy = body:getWorldPoints(headShape:getPoint())
                local fx, fy = body:getWorldPoints(feetShape:getPoint())
                local mx, my = norm(fx - hx, fy - hy)
                local rad = headShape:getRadius()
                mx, my = -my * rad, mx * rad
                love.graphics.line(hx + mx, hy + my, fx + mx, fy + my)
                love.graphics.line(hx - mx, hy - my, fx - mx, fy - my)
                love.graphics.arc("line", "open", hx, hy, rad, angle + math.pi, angle + math.pi * 2)
                love.graphics.arc("line", "open", fx, fy, rad, angle, angle + math.pi)
            else
                for _, fixture in ipairs(body:getFixtures()) do
                    local fixtureType = fixture:getType()
                    if fixtureType == "circle" then
                        local shape = fixture:getShape()
                        local px, py = body:getWorldPoints(shape:getPoint())
                        love.graphics.circle("line", px, py, shape:getRadius())
                    elseif fixtureType == "polygon" then
                        local shape = fixture:getShape()
                        love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
                    elseif fixtureType == "edge" or fixtureType == "chain" then
                        love.graphics.line(body:getWorldPoints(fixture:getShape():getPoints()))
                    end
                end
            end
        end    
    camera_pop()
end
