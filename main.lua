--[[
    Based on 
    GD50 2018
    Pong Remake

    -- Main Program --
    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

-- https://github.com/Ulydev/push
push = require 'push'

-- https://github.com/vrld/hump/blob/master/class.lua
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- size we're trying to emulate with push
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

-- Love game loop funcs
function love.load()
    loadFonts()
    loadSounds()
    setupScreen()
    loadPlayers()
    initBall()
    gameState = 'start'
end

function love.update(dt)
    handleKeyPress()
    updatePlayers(dt)
    updateBalls(dt)
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40, 45, 52, 255)

    if(gameState == 'start') then
        drawStartMessage()
    elseif(gameState == 'player1Scored') or 
            (gameState == 'player2Scored') then
        drawPlayerScoreMessage()
    elseif(gameState == 'player1Won') or 
            (gameState == 'player2Won') then
        drawGameOver()
    elseif(gameState == 'play') then
        drawScoreBoard()
    end

    drawPlayers()
    drawBalls()

    push:apply('end')
end

-- Love game event funcs
function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if(key == 'enter' or key == 'return') then
        toggleGameState()
    end
end

-- Pong game helpers
function loadFonts()
    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
end

function loadSounds()
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
end

function initBall()
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2)
end

function loadPlayers()
    player1 = Paddle(10, 10, {
        upKey = 'w',
        downKey = 's',
        isComputer = false
    })
    player2 = Paddle(VIRTUAL_WIDTH - 10 - player1.width, VIRTUAL_HEIGHT - 10 - player1.height, {
        upKey = 'up',
        downKey = 'down',
        isComputer = true
    })

    player1Score = 0
    player2Score = 0
end

function setupScreen() 
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end

function handleKeyPress()
    player1:move(VIRTUAL_HEIGHT, PADDLE_SPEED, ball)
    player2:move(VIRTUAL_HEIGHT, PADDLE_SPEED, ball)
end

function updatePlayers(dt)
    if(gameState == 'player1Won') or 
            (gameState == 'player2Won') then
        player1Score = 0
        player2Score = 0
    end
    player1:update(dt)
    player2:update(dt)
end

function updateBalls(dt)
    checkGameState()
    checkScreenEdgeCollision()
    checkPaddleCollision()
    ball:update(dt)
end

function checkPaddleCollision()
    collidePlayer1 = ball:collides(player1)
    collidePlayer2 = ball:collides(player2)
    if collidePlayer1 or collidePlayer2 then
        changeBallHorizontalSpeed()
        changeBallVerticalSpeed()
        sounds['paddle_hit']:play()
    end
end

function changeBallHorizontalSpeed()
    ball.dx = -ball.dx * 1.10
    if collidePlayer1 then
        ball.x = player1.x + 5
    elseif collidePlayer2 then
        ball.x = player2.x - 4
    end
end

function changeBallVerticalSpeed()
    if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
    else
        ball.dy = math.random(10, 150)
    end
end

function checkScreenEdgeCollision()
    if(ball.y < 0) then
        ball.y = 0
        ball.dy = -ball.dy
        sounds['wall_hit']:play()
    elseif(ball.y > VIRTUAL_HEIGHT - ball.height) then
        ball.y = VIRTUAL_HEIGHT - ball.height
        ball.dy = -ball.dy
        sounds['wall_hit']:play()
    end

    if(ball.x < 0) then
        player2Score = player2Score + 1
        gameState = 'player2Scored'
        sounds['score']:play()
    elseif(ball.x > VIRTUAL_WIDTH - ball.width) then
        player1Score = player1Score + 1
        gameState = 'player1Scored'
        sounds['score']:play()
    end
end

function checkGameState()
    if(gameState == 'serve') then
        serveBall()
        gameState = 'play'
    elseif(gameState == 'start') or 
            (gameState == 'player1Scored') or 
            (gameState == 'player2Scored') or 
            (gameState == 'player1Won') or 
            (gameState == 'player2Won') then
        ball.isMoving = false
        ball:reset()
    end
end

function serveBall()
    ball.dx = ((math.random(-1, 1) < 0) and -1 or 1) * math.random(50, 100)
    ball.dy = math.random(-50, 50)
    ball.isMoving = true
end

function toggleGameState()
    if(gameState == 'start') or 
        (gameState == 'player1Scored') or 
        (gameState == 'player2Scored') or 
        (gameState == 'player1Won') or 
        (gameState == 'player2Won') then
        gameState = 'serve'
    else
        gameState = 'start'
    end
end

function drawBalls()
    ball:render()
end

function drawGameOver()
    if(gameState == 'player1Won') then
        winningPlayer = 'One'
    else
        winningPlayer = 'Two'
    end

    love.graphics.setFont(smallFont)
    love.graphics.printf('Player ' .. winningPlayer .. ' won!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
end

function drawPlayers()
    player1:render()
    player2:render()
end

function drawScoreBoard()
    love.graphics.setFont(scoreFont)
    love.graphics.printf(player1Score, -40, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(player2Score, 40, 10, VIRTUAL_WIDTH, 'center')
end

function drawPlayerScoreMessage()
    if(gameState == 'player1Scored') then
        scoringPlayer = 'One'
    else
        scoringPlayer = 'Two'
    end

    love.graphics.setFont(smallFont)
    if(player1Score > 2) then
        gameState = 'player1Won'
    elseif(player2Score > 2) then
        gameState = 'player2Won'
    else 
        love.graphics.printf('Player ' .. scoringPlayer .. ' scored!', 0, 30, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 40, VIRTUAL_WIDTH, 'center')
    end
end

function drawStartMessage()
    love.graphics.setFont(smallFont)
    love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
end