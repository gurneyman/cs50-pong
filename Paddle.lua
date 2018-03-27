--[[
    Based on
    GD50 2018
    Pong Remake
    -- Paddle Class --
]]

Paddle = Class{}

PADDLE_WIDTH = 5
PADDLE_HEIGHT = 20

function Paddle:init(x, y, controlTable)
    self.x = x
    self.y = y
    self.width = PADDLE_WIDTH
    self.height = PADDLE_HEIGHT
    self.dy = 0

    self.upKey = controlTable.upKey
    self.downKey = controlTable.downKey
    self.isComputer = controlTable.isComputer
end

function Paddle:move(screenHeight, paddleSpeed, ball)
    if (love.keyboard.isDown(self.upKey) or (self.isComputer and self.y > ball.y + 15) and self.y > 0)
        then
        self.dy = -paddleSpeed
    elseif (love.keyboard.isDown(self.downKey) or (self.isComputer and self.y < ball.y - 15) and self.y < screenHeight - self.height)
     then
        self.dy = paddleSpeed
    else 
        self.dy = 0
    end
end

function Paddle:update(dt)
    self.y = self.y + self.dy * dt
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end