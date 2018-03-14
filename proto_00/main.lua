Util = require 'util'
require 'sprite'
require 'player'
require 'camera'
require 'entity'
require 'bullet'
require 'input'
require 'gamedebug'

Game = {}

function love.load()
    local sx, sy = love.graphics.getDimensions()

    Game.conf = {}
    Game.width = 160
    Game.height = 90
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

    Game.images = {}
    Game.images["player"] = love.graphics.newImage("assets/ship.png")
    Game.images["bullet"] = love.graphics.newImage("assets/bullet.png")

    for k, v in pairs(Game.images) do
        v:setFilter("nearest", "nearest")
    end

    Game.bulletSprite = Sprite:new(Game.images["bullet"])

    local playerSprite = Sprite:new(Game.images["player"])
    Game.player = Player:new(0, 0)
    Game.player.sprite = playerSprite

    Game.entities:addEntity(Game.player)

    Game.camera = Camera:new()
end

function love.keypressed(keypressed)
    if keypressed == "escape" then
        love.event.quit()
    end
end

function love.keyreleased(keypressed)
end

function love.update(dt)
    Debug.Text:clear()
    Game:update(dt)
end

function love.draw(dt)
    love.graphics.setCanvas(Game.canvas)
    Game.camera:push()
        love.graphics.clear(44, 232, 245)

        Game:render(dt)
    Game.camera:pop()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(Game.canvas,
        0, 0,
        0,
        Game.conf.pixelSize, Game.conf.pixelSize)

    Game:debugRender()
end

function Game:update(dt)
    Game.time.elapsed = Game.time.elapsed + dt
    Game.time.dt = dt

    Input:update(dt)

    local scrollSpeed = 16 * dt
    Game.camera:move(scrollSpeed, 0)
    Game.player.posX = Game.player.posX + scrollSpeed

    Game.camera:update(dt)
    Game.entities:update(dt)
end

function Game:render(dt)
    love.graphics.setColor(54, 0, 255)
    for i = -12, 12 do
        for j = -4, 4 do
            local rx = i * 16 + math.floor(Game.player.posX / 32) * 32
            if i % 2 == j % 2 then
                love.graphics.rectangle("fill", rx, j * 16, 16, 16)
            end
        end
    end

    love.graphics.setColor(255, 255, 255, 255)
    Game.entities:render(dt)
end

function Game:debugRender()
    --Game.player:debugRender()
    Debug.Text:render(dt)
end