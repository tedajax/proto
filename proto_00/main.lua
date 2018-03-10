Util = require 'util'

Game = {}

function love.load()
    local sx, sy = love.graphics.getDimensions()

    Game.conf = {}
    Game.conf.pixelSize = 8
    Game.width = sx / Game.conf.pixelSize
    Game.height = sy / Game.conf.pixelSize

    -- Create canvas scaled to appropriate pixel size
    Game.canvas = love.graphics.newCanvas(Game.width, Game.height, "normal", 0)
    Game.canvas:setFilter("nearest", "nearest")

    Game.player = {}
    local player = Game.player
    player.x = Game.width / 2
    player.y = Game.height / 2
    player.size = 2
    player.speed = 100
    player.sprite = love.graphics.newImage("assets/ship.png")
    player.sprite:setFilter("nearest", "nearest")
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
        love.graphics.clear()

        Game:render(dt)
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255)
    love.graphics.setShader(shader)
    love.graphics.draw(Game.canvas,
        0, 0,
        0,
        Game.conf.pixelSize, Game.conf.pixelSize)
    love.graphics.setShader()
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

    Game.player.x = Game.player.x + inputX * dt * Game.player.speed
    Game.player.y = Game.player.y + inputY * dt * Game.player.speed

    Game.player.drawX = math.floor(Game.player.x)
    Game.player.drawY = math.floor(Game.player.y)
end

function Game:render(dt)
    love.graphics.setColor(44, 232, 245)
    love.graphics.rectangle("fill", 0, 0, Game.width, Game.height)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(Game.player.sprite,
        Game.player.drawX, Game.player.drawY,
        0,
        1, 1,
        6, 3)

end
