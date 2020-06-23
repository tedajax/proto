
function make_character()
    local self = {}

    self.body = love.physics.newBody(physics.world, 0, 0, "dynamic")
    self.body:setUserData(self)

    self.body:setFixedRotation(true)
    attach_capsule(self, make_capsule(self.body, 8, 32))
    self.body:setMass(1)

    self.input = { x = 0, y = 0, jump = false }

    return self
end

function character_control(self, ix, iy, jump)
    self.input.x = ix or 0
    self.input.y = iy or 0
    self.input.jump = jump or false
end

function character_move(self)
    if self.input.x == 0 then
        self.capsule.fixtures.feet:setFriction(0.75)
    else
        self.capsule.fixtures.feet:setFriction(0)
    end

    self.body:applyForce(self.input.x * 800, 0, 0, 0)

    local velX, velY = self.body:getLinearVelocity()

    if velX > 100 then
        velX = 100
    elseif velX < -100 then
        velX = -100
    end

    if self.input.jump then
        velY = 0
        self.body:applyLinearImpulse(0, -700, 0, 0)
    end
    self.body:setLinearVelocity(velX, velY)
end

function character_is_grounded(self)
    
end