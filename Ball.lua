--[[
    Based on
    GD50 2018
    Pong Remake
]]

Ball = Class{}

BALL_DIAMETER = 4

function Ball:init(x, y)
    self.x = x
    self.y = y
    self.startingX = x
    self.startingY = y
    self.width = BALL_DIAMETER
    self.height = BALL_DIAMETER
    self.dy = 0
    self.dx = 0

    self.isMoving = false
end

--[[
    Expects a paddle as an argument and returns true or false, depending
    on whether their rectangles overlap.
]]
function Ball:collides(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end
    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end 
    return true
end

--[[
    Places the ball in the middle of the screen, with no movement.
]]
function Ball:reset()
    self.x = self.startingX
    self.y = self.startingY
end

function Ball:update(dt)
    if(self.isMoving) then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
    end
end

function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, BALL_DIAMETER, BALL_DIAMETER)
end