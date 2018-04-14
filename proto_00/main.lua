Util = require 'util'
Physics = require 'physics'
require 'sprite'
require 'player'
require 'camera'
require 'entity'
require 'bullet'
require 'input'
require 'gamedebug'
require 'enemy'
require 'imagemngr'
require 'hsv'

Game = {}

function beginContact(a, b, coll)
    Game.physics:beginContact(a, b, coll)
end

function endContact(a, b, coll)
    Game.physics:endContact(a, b, coll)
end

function preSolve(a, b, coll)
    Game.physics:preSolve(a, b, coll)
end

function postSolve(a, b, coll, normImp, tanImp)
    Game.physics:postSolve(a, b, coll, normImp, tanImp)
end

function love.load()
    math.randomseed(os.time())

    local sx, sy = love.graphics.getDimensions()

    local layers = {
        DEFAULT = 0,
        PLAYER = 1,
        ENEMY = 2,
        PLAYER_ATTACK = 3,
        ENEMY_ATTACK = 4,
    }

    local masks = {
        0,
        bit.bor(1, 4),
        bit.bor(2, 8),
        bit.bor(1, 4, 8),
        bit.bor(2, 4, 8),
    }

    Game.physics = Physics(64, 0, -9.81,
        beginContact, endContact, preSolve, postSolve,
        layers, masks)

    Game.conf = {}
    Game.width = 1280
    Game.height = 720
    Game.scrWidth = sx
    Game.scrHeight = sy
    Game.timescale = 1
    Game.conf.pixelSize = sx / Game.width

    Game.input = Input:new()
    Game.input:addAxis("horizontal", -1, 1)
    Game.input:addAxis("vertical", -1, 1)
    Game.input:addButton("fire")
    Game.input:addButton("dash")

    Game.input:addBinding(InputBinding:new("axis", "horizontal", "left", -1))
    Game.input:addBinding(InputBinding:new("axis", "horizontal", "right", 1))
    Game.input:addBinding(InputBinding:new("axis", "vertical", "up", -1))
    Game.input:addBinding(InputBinding:new("axis", "vertical", "down", 1))
    Game.input:addBinding(InputBinding:new("button", "fire", "z"))
    Game.input:addBinding(InputBinding:new("button", "dash", "x"))

    Input = Game.input

    Game.dbgFont = love.graphics.newFont("assets/prstartk.ttf", 18)
    love.graphics.setFont(Game.dbgFont)

    Game.time = {}
    Game.time.elapsed = 0
    Game.time.dt = 0

    -- Create canvas scaled to appropriate pixel size
    Game.canvas = love.graphics.newCanvas(Game.width, Game.height, "normal", 0)
    Game.canvas:setFilter("nearest", "nearest")

    Game.entities = EntitySystem:new()

    Game.images = ImageMngr:new()
    Game.images:load("player", "assets/space_wizard2.png")
    Game.images:load("bullet", "assets/bullet.png")
    Game.images:load("charge_shot_bg", "assets/charge_shot_bg.png")
    Game.images:load("charge_shot_fg", "assets/charge_shot_fg.png")
    Game.images:load("clown", "assets/giant_clown.png")

    Game.bulletSprite = Game.images:createSprite("bullet")

    local playerSprite = Game.images:createSprite("player")
    Game.player = Player:new(0, 0)
    Game.player.sprite = playerSprite

    Game.entities:addEntity(Game.player)

    Game.debugEnabled = false

    for i = 1, 1 do
        Game.entities:addEntity(Enemy:new((i + 1) * 500, math.random(-30, 30)))
    end

    Game.camera = Camera:new()
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
    Game:update(dt * Game.timescale)
end

function love.draw(dt)
    love.graphics.setCanvas(Game.canvas)
    Game.camera:push()
        love.graphics.clear(7, 0, 25)

        Game:render(dt)
    Game.camera:pop()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(Game.canvas,
        0, 0,
        0,
        Game.conf.pixelSize, Game.conf.pixelSize)

    Game:debugRender()

    local fpsStr = string.format("FPS: %d", love.timer.getFPS())
    local strWidth = Game.dbgFont:getWidth(fpsStr)
    love.graphics.printf(fpsStr, Game.scrWidth - strWidth, 5, strWidth, "right")

    Debug.Messages:render()
end

function Game:update(dt)
    Game.time.elapsed = Game.time.elapsed + dt
    Game.time.dt = dt

    Game.physics:update(dt)

    Input:update(dt)

    Game.scrollSpeed = 16 * 8 * dt
    Game.camera:move(Game.scrollSpeed, 0)
    Game.player.posX = Game.player.posX + Game.scrollSpeed

    Game.camera:update(dt)
    Game.entities:update(dt)
end

function Game:render(dt)
    love.graphics.setColor(0, 0, 0)
    local tw = 16 * 8
    for i = -12, 12 do
        for j = -4, 4 do
            -- local rx = i * tw + math.floor(Game.player.posX / tw * 2) * tw * 2
            local rx = i * tw + math.floor(Game.player.posX / (tw * 2)) * (tw * 2)
            if i % 2 == j % 2 then
                love.graphics.rectangle("fill", rx, j * tw, tw, tw)
            end
        end
    end

    love.graphics.setColor(255, 255, 255, 255)
    Game.entities:render(dt)
end

function Game:debugRender()
    if Game.debugEnabled then
        Debug.Text:render(dt)
    end
end
