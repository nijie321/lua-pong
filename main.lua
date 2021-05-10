
VIRTUAL_WIDTH = 384
VIRTUAL_HEIGHT = 216
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

PADDLE_HEIGHT = 32
PADDLE_WIDTH = 8
PADDLE_SPEED = 140

push = require 'push'

LARGE_FONT = love.graphics.newFont(32)
SMALL_FONT = love.graphics.newFont(16)

BALL_SIZE = 4

PADDLE_INITIAL_POS_X = 10
PADDLE_INITIAL_POS_Y = 10

player1 = {
    x = PADDLE_INITIAL_POS_X,
    y = PADDLE_INITIAL_POS_Y,
    score = 0
}

player2 = {
    x = VIRTUAL_WIDTH - PADDLE_INITIAL_POS_X - PADDLE_WIDTH,
    y = VIRTUAL_HEIGHT - PADDLE_INITIAL_POS_Y - PADDLE_HEIGHT,
    score = 0
}

BALL_INITIAL_X = VIRTUAL_WIDTH / 2 - BALL_SIZE / 2
BALL_INITIAL_Y = VIRTUAL_HEIGHT / 2 - BALL_SIZE / 2
ball = {
    x = BALL_INITIAL_X,
    y = BALL_INITIAL_Y,
    dx = 0,
    dy = 0
}

GAME_POINT = 3

gameState = 'title'

winner = ''

function random_x_y()
    x = 60 + math.random(60)
    if math.random(2) == 1 then
        x = -x
    end
    y = 30 + math.random(60)
    if math.random(2) == 1 then
        y = -y
    end
    return x , y 
end

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT)

    ball.dx, ball.dy = random_x_y()
end


function love.update(dt)
    if love.keyboard.isDown('w') and player1.y >= 0 then
        player1.y = player1.y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('s') and player1.y <= VIRTUAL_HEIGHT - PADDLE_HEIGHT then
        player1.y = player1.y + PADDLE_SPEED * dt
    end

    if love.keyboard.isDown('up') and player2.y >= 0 then
        player2.y = player2.y - PADDLE_SPEED * dt
    elseif love.keyboard.isDown('down') and player2.y <= VIRTUAL_HEIGHT - PADDLE_HEIGHT then
        player2.y = player2.y + PADDLE_SPEED * dt
    end

    if gameState == 'play' then
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt


        ball_upper_y = ball.y - BALL_SIZE / 2
        ball_lower_y = ball.y + BALL_SIZE / 2
        if ball_upper_y <= 0 or ball_lower_y >= VIRTUAL_HEIGHT then
            ball.dy = -ball.dy 
        end
        
        ball_left_x = ball.x + BALL_SIZE / 2
        ball_right_x =  ball.x - BALL_SIZE / 2
        if ball_left_x <= 0 then
            player2.score = player2.score + 1
            reset_ball()
            gameState = 'serve'
        elseif ball_right_x >= VIRTUAL_WIDTH then
            player1.score = player1.score + 1
            reset_ball()
            gameState = 'serve'
        end
        is_game_over()
        
        if collides(player1, ball) then
            reverse_ball_velocity("player1")
        elseif collides(player2, ball) then
            reverse_ball_velocity("player2")
        end

        -- if (ball.x <= player1.x + PADDLE_WIDTH) and (ball.y >= player1.y and ball.y <= player1.y + PADDLE_HEIGHT) then
        --     reverse_ball_velocity()

        -- elseif (ball.x >= player2.x) and (ball.y >= player2.y and ball.y <= player2.y + PADDLE_HEIGHT) then
        --     reverse_ball_velocity()
        -- end
    end
end

function is_game_over()
    if player1.score == GAME_POINT then
        winner = "player1"
        gameState = "final"
    elseif player2.score == GAME_POINT then
        winner = "player2"
        gameState = "final"
    end
end

function collides(p, b)
   return not(p.x > b.x + BALL_SIZE or p.y > b.y + BALL_SIZE or b.x > p.x + PADDLE_WIDTH or b.y > p.y + PADDLE_HEIGHT) 
end

function reset_player()
    player1.score = 0
    player2.score = 0
end

function reverse_ball_velocity(player)
    
    ball.dx = -ball.dx
    if player == "player1" then
        ball.x = player1.x + PADDLE_WIDTH

    elseif player == "player2" then
        ball.x = player2.x - BALL_SIZE
    end
    ball.dy = -ball.dy
end

function reset_ball()
    ball.x = BALL_INITIAL_X
    ball.y = BALL_INITIAL_Y
    ball.dx , ball.dy = random_x_y()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'title' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'final' then
            reset_player()
            gameState = 'title'
        end
    end

end

function love.draw()
    push:start()
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    if gameState == 'title' then
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf('Pre50 Pong', 0, 10, VIRTUAL_WIDTH , 'center')
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf('Press Enter', 0, VIRTUAL_HEIGHT - 32, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'serve' then
        love.graphics.setFont(SMALL_FONT)
        love.graphics.printf("Press Enter to Serve!", 0, 10, VIRTUAL_WIDTH, 'center')
    end

    if gameState == 'final' then
        love.graphics.setFont(LARGE_FONT)
        love.graphics.printf(winner .. " WIN!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SMALL_FONT)
    end

    love.graphics.rectangle("fill", player1.x, player1.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle("fill", player2.x, player2.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.circle("fill", ball.x, ball.y, BALL_SIZE, BALL_SIZE)

    love.graphics.setFont(LARGE_FONT)
    love.graphics.print(player1.score, VIRTUAL_WIDTH / 2 - 36, VIRTUAL_HEIGHT / 2 - 16)
    love.graphics.print(player2.score, VIRTUAL_WIDTH / 2 + 16, VIRTUAL_HEIGHT / 2 - 16)
    love.graphics.setFont(SMALL_FONT)

    push:finish()
end

