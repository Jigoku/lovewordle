function love.load()
    love.graphics.setBackgroundColor(0.1,0.1,0.1)

    dict = {}
    for line in love.filesystem.lines("dictionary") do
        table.insert(dict, line)
    end
    initgame()
end

function isalpha(key)
    for _,c in ipairs({"a","b","c","d","e","f","g","h","i","j","k","l",
            "m","n","o","p","q","r","s","t","u","v","w","x","y","z"}) do
        if key == c then return true end
    end
    return false
end

function initgame()
    game = {}
    game.title = "WORDLE"
    game.seed = love.math.random(1,#dict)
    game.solution = dict[game.seed]
    game.pos = { x = 0, y = 1 }
    game.rows = 5
    game.cols = 6
    game.cellsize = 64
    game.cellpadding = 10
    game.cellradius = 5
    game.finished = false
    game.solved = false
    game.cellcanvas = love.graphics.newCanvas(
        game.rows*(game.cellsize+game.cellpadding)+game.cellpadding, 
        game.cols*(game.cellsize+game.cellpadding)+game.cellpadding
    )

    game.cells = {}
    for x=1, game.rows do
        game.cells[x] = {}
        for y=1, game.cols do
            game.cells[x][y] = {}
            game.cells[x][y].char = ""
            game.cells[x][y].state= 0
        end
    end

    font = {}
    font.title = love.graphics.newFont(48)
    font.char = love.graphics.newFont(36)
    font.solved = love.graphics.newFont(32)
    font.debug = love.graphics.newFont(14)
end

function love.draw()
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setLineWidth(3)
    love.graphics.setFont(font.title)

    love.graphics.print(game.title, 
        love.graphics.getWidth()/2-font.title:getWidth(game.title)/2, 
        love.graphics.getHeight()/8
    )

    love.graphics.setCanvas(game.cellcanvas)
    love.graphics.clear()

    for x=1, game.rows do
        for y=1, game.cols do
            local cell = game.cells[x][y]

            if cell.state == 0 then
                love.graphics.setColor(0.2, 0.2, 0.2)
            elseif cell.state == 1 then
                love.graphics.setColor(0.2, 0.2, 0.2)
            elseif cell.state == 2 then
                love.graphics.setColor(0.8, 0.7, 0.2)
            elseif cell.state == 3 then
                love.graphics.setColor(0.2, 0.6, 0.2)
            end
    
            local x, y = x*(game.cellsize+game.cellpadding)-game.cellsize, y*(game.cellsize+game.cellpadding)-game.cellsize
            love.graphics.rectangle((cell.state == 0 and "line" or "fill"), x, y, game.cellsize, game.cellsize, game.cellradius)
            love.graphics.setColor(1,1,1)
            love.graphics.setFont(font.char)
            love.graphics.print(string.upper(cell.char), 
                x+game.cellsize/2-font.char:getWidth(cell.char)/2, 
                y+game.cellsize/2-font.char:getHeight(cell.char)/2
            )
        end
    end
    
    love.graphics.setCanvas()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(game.cellcanvas, 
        love.graphics.getWidth()/2-game.cellcanvas:getWidth()/2, 
        love.graphics.getHeight()/2-game.cellcanvas:getHeight()/2
    )

    if game.finished then
        love.graphics.setFont(font.solved)
        local msg = string.upper(game.solution) .. " " .. (game.solved and game.pos.y -1 or "X") .. "/" .. game.cols
        love.graphics.print(msg, 
            love.graphics.getWidth()/2-font.solved:getWidth(msg)/2, 
            love.graphics.getHeight()/2+game.cellcanvas:getHeight()/2 + game.cellpadding
        )
        --love.graphics.print("debug: " .. game.solution .. " (".. game.seed .."/".. #dict ..")", 20,20)
    end
end

function love.update(dt)
    for i,c in ipairs(game.cells) do
        --add cell animation
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
    if key == "backspace" then
        if game.pos.x ~= 0 then
            game.cells[game.pos.x][game.pos.y].char = ""
            game.cells[game.pos.x][game.pos.y].state = 0
            game.pos.x = game.pos.x - 1
            return
        end
    elseif key == "return" then
        if game.finished then initgame() return end
        if game.pos.x == game.rows and game.pos.y <= game.cols then
            if game.pos.x < game.rows then
                return
            else
                local answer = ""
                --split answer into table
                for i=1, game.rows do
                    answer = answer .. game.cells[i][game.pos.y].char
                end

                -- check if word exists
                local isaword = false
                for i,word in ipairs(dict) do
                    if word == answer then 
                        isaword = true
                    end
                end

                if isaword then
                    local result = {}
                    --split result into table
                    for letter in game.solution:gmatch(".") do 
                        table.insert(result, { found = false, char = letter})
                    end

                    --check if chars are found
                    for i=1, game.rows do
                        if game.cells[i][game.pos.y].char == result[i].char then
                            result[i].found = true
                        end
                    end

                    --find matching chars in wrong places
                    for i=1, game.rows do
                        for _,r in ipairs(result) do
                            if game.cells[i][game.pos.y].char == r.char and (not r.found) then
                                game.cells[i][game.pos.y].state = 2
                            end
                        end
                    end

                    --find matching chars in correct place
                    local n = 0
                    for i=1, game.rows do
                        if game.cells[i][game.pos.y].char == result[i].char then
                            game.cells[i][game.pos.y].state = 3
                            n = n +1
                        end
                    end
                    if n >= game.rows then
                        game.solved = true
                        game.finished = true
                    end

                    game.pos.y = game.pos.y + 1
                    game.pos.x = 0

                    if game.pos.y > game.cols then
                        game.finished =  true
                    end
                end
            end
        end
        return
    else
        if not game.finished and game.pos.x < game.rows and game.pos.y <= game.cols and isalpha(key) then
            game.cells[game.pos.x+1][game.pos.y].char = string.lower(key)
            game.cells[game.pos.x+1][game.pos.y].state = 1
            game.pos.x = math.max(1, math.min(game.pos.x + 1, game.rows))
            return
        end
    end
end
