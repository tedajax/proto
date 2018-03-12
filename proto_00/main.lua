Util = require 'util'
require 'sprite'
require 'player'
require 'camera'
require 'entity'
require 'bullet'

Game = {}
Input = {
    horizontal = 0,
    vertical = 0,
}

function love.load()
    local sx, sy = love.graphics.getDimensions()

    Game.conf = {}
    Game.conf.pixelSize = 8
    Game.width = sx / Game.conf.pixelSize
    Game.height = sy / Game.conf.pixelSize

    Game.dbgFont = love.graphics.newFont("assets/prstartk.ttf", 32)
    love.graphics.setFont(Game.dbgFont)

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
    local left = love.keyboard.isScancodeDown("left")
    local right = love.keyboard.isScancodeDown("right")
    local up = love.keyboard.isScancodeDown("up")
    local down = love.keyboard.isScancodeDown("down")

    local inputX, inputY = 0, 0
    if left then inputX = inputX - 1 end
    if right then inputX = inputX + 1 end
    if up then inputY = inputY - 1 end
    if down then inputY = inputY + 1 end

    Input.horizontal = inputX
    Input.vertical = inputY
    Input.fire = love.keyboard.isScancodeDown("z")

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
    Game.player:debugRender()
end