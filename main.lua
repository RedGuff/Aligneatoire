-- IF NO WINNER? Echap => exit.
-- Text color = last color drawn, not current player.
-- Dice: sometimes no sound.
-- Graphs: wrong
-- Menu for options?

-- Constants
local gridSize = 6 -- Number of rows and columns -- ONLY SQUARE!
local rowsSize = 6
local columnsSize = 6
local cellSize = 64 -- Size of each cell in pixels
local margin = 64 -- Margin around the grid
local x = 0
local y = 0
local z = 0
local w = 0
local board = {}
local currentPlayer = 1 -- 1 for Player 1, 2 for Player 2, -1 for pebble1, -2 for pebble2.
local turnNumber = 1 
local winner = nil
local message = "Turn: " .. turnNumber
local max = 10
local player1Input = "mouse"
local player2Input = "IA0"


-- Colors
local colors = {
  background = { 1, 1, 1 },
 -- grid = { 0.2, 0.2, 0.2 },
  grid = { 0, 0, 0 },
  player1 = { 0, 0, 0 },
  player2 = { 1, 0, 0 },
  pebble1 = { 0.5, 0.5, 0.5 },
  pebble2 = { 0.5, 0.5, 0.5 },
  highlight = { 0.8, 0.8, 0.8 },
}

function antitriche(param) -- Some people will try to cheat with fake log. This will make cheating harder. If a decisions seems illogic, or remake wrong, it's cheating.
  for dz = 1, param do
    math.random(1, param)
  end
end

function save(data)
  -- print("High score: "..tostring(score))
  local file,err = io.open("Partie.txt",'a')
  if file then
    file:write(data)
    file:close()
  else
    print("error:", err) -- not so hard?
  end
end


function love.load()
  local time = os.time()
  save("                                    New game.\nTime = " .. time .."\n")
      save("\nTurn " .. turnNumber ..":\n")
  math.randomseed(time)

  diceSound = love.audio.newSource("dice-142528.mp3", "static")
  Blue = love.graphics.newImage("Blue.png")
  Red = love.graphics.newImage("Red.png")
  Pebble = love.graphics.newImage("Pebble.png")
  love.window.setMode(
    margin * 2 + gridSize * cellSize, 
    margin * 2 + gridSize * cellSize + 50 -- Ajoute de l'espace pour le texte
  )
  -- Initialize board
  for i = 1, gridSize do
    board[i] = {}
    for j = 1, gridSize do
      board[i][j] = 0
    end
  end
  randPebble(currentPlayer)
end

function love.draw()

  love.graphics.clear(colors.background)

  -- Draw grid
  love.graphics.setColor(colors.grid)

  love.graphics.printf(message, 0, 10, love.graphics.getWidth(), "center")
  for i = 0, gridSize do
    love.graphics.line(margin, margin + i * cellSize, margin + gridSize * cellSize, margin + i * cellSize)
    love.graphics.line(margin + i * cellSize, margin, margin + i * cellSize, margin + gridSize * cellSize)
  end

  -- Draw pieces
  for i = 1, gridSize do
    for j = 1, gridSize do
      if board[i][j] == 1 then
        love.graphics.setColor(colors.player1)
        if graphs then
          love.graphics.draw(Red, margin + (j ) * cellSize, margin + (i ) * cellSize, cellSize / 3, 0, cellSize / 3, cellSize / 3)
        else
          love.graphics.circle("fill", margin + (j - 0.5) * cellSize, margin + (i - 0.5) * cellSize,  cellSize / 3)
        end
      elseif board[i][j] == 2 then
        love.graphics.setColor(colors.player2)
        if graphs then
          love.graphics.draw(Blue, margin + (j ) * cellSize, margin + (i ) * cellSize, cellSize / 3, 0, cellSize / 3, cellSize / 3)
        else
          love.graphics.circle("fill", margin + (j - 0.5) * cellSize, margin + (i - 0.5) * cellSize, cellSize / 3)
        end
      elseif board[i][j] == -2 then
        love.graphics.setColor(colors.pebble2)
        if graphs then
          love.graphics.draw(Pebble,  margin + (j ) * cellSize, margin + (i ) * cellSize, cellSize / 3, 0, cellSize / 3, cellSize / 3)
        else
          love.graphics.circle("fill", margin + (j - 0.5) * cellSize, margin + (i - 0.5) * cellSize,   cellSize / 3)
        end
      elseif board[i][j] == -1 then
        love.graphics.setColor(colors.pebble1)
        if graphs then
          love.graphics.draw(Pebble, margin + (j ) * cellSize, margin + (i ) * cellSize, cellSize / 3, 0, cellSize / 3, cellSize / 3)
        else
          love.graphics.circle("fill", margin + (j - 0.5) * cellSize, margin + (i - 0.5) * cellSize,   cellSize / 3)
        end
      end

    end
  end


  if currentPlayer == player1 then
    love.graphics.setColor(colors.player1)
  elseif currentPlayer == player2 then
    love.graphics.setColor(colors.player2)
  end
  -- Draw winner message
  if winner == 0 then
    love.graphics.printf("It's a draw!", 0, margin + gridSize * cellSize + 10+cellSize, love.graphics.getWidth(), "center")
    save("Draw!\n")
  elseif winner then
    love.graphics.printf("Player " .. winner .. " wins!", 0, margin + gridSize * cellSize + 10+cellSize, love.graphics.getWidth(), "center")
  else
    love.graphics.printf("Player " .. currentPlayer .. "'s turn", 0, margin + gridSize * cellSize + 10+cellSize, love.graphics.getWidth(), "center")
  end
end

function love.mousepressed(x, y, button)
  if button == 1 and not winner then
    local row = math.floor((y - margin) / cellSize) + 1
    local col = math.floor((x - margin) / cellSize) + 1

    if row >= 1 and row <= gridSize and col >= 1 and col <= gridSize and board[row][col] == 0 then
      antitriche(row)
      antitriche(col)
      board[row][col] = currentPlayer
      save("Choice X = " .. row .."\n")
      save("Choice Y = " .. col .."\n")
      if checkWinner(row, col, currentPlayer) then
        winner = currentPlayer
      elseif checkDraw() then
        winner = 0 -- Match nul
      else
        randPebble(currentPlayer)
        currentPlayer = 3 - currentPlayer -- Switch player (1 -> 2, 2 -> 1)
        
      turnNumber = turnNumber + 1
          save("\nTurn " .. turnNumber ..":\n")
        randPebble(currentPlayer)
      end
    end
  end
  if currentPlayer == player1 then
    love.graphics.setColor(colors.player1)
  elseif currentPlayer == player2 then
    love.graphics.setColor(colors.player2)
  end
end

function randPebble(currentPlayer)
  if sound then
    diceSound:play()
  end

  local x = math.random(1, gridSize)
  save("Dice X = " .. x .."\n")
  local y = math.random(1, gridSize)
  save("Dice Y = " .. y .."\n")
  if currentPlayer == player1 then
    love.graphics.setColor(colors.player1)
  elseif currentPlayer == player2 then
    love.graphics.setColor(colors.player2)
  end
--love.graphics.printf("It's a draw!"        , 0, margin + gridSize * cellSize + 10+cellSize, love.graphics.getWidth(), "center")        
--love.graphics.printf("Turn: " .. turnNumber, 0, 10, love.graphics.getWidth(), "center")
  message = "Turn: " .. turnNumber .. "   Dice1 is " .. x .. ".  Dice2 is ".. y .. ".  Dice3 is ".. z .. ".  Dice4 is " .. w

  --love.graphics.printf("Dice2 is " .. y , 0, , love.graphics.getWidth(), "center")
  z=x
  w=y

  if board[x][y]==0 then
    board[x][y] = -currentPlayer
  else
    board[x][y] = 0
  end
  if currentPlayer == player1 then
    love.graphics.setColor(colors.player1)
  elseif currentPlayer == player2 then
    love.graphics.setColor(colors.player2)
  end
end

function checkMax()


  return false
end

function IA0()


end

function checkDraw()
  for i = 1, gridSize do
    for j = 1, gridSize do
      if board[i][j] == 0 then
        return false

      end
    end
  end
  return true
end

function playerColor()


end

function checkWinner(row, col, player)
  local max = 6
  local directions = {
    { 0, 1 },  -- Horizontal
    { 1, 0 },  -- Vertical
    { 1, 1 },  -- Diagonal /
    { 1, -1 }, -- Diagonal \
  }

  for _, dir in ipairs(directions) do
    local count = 1

    -- Check in the positive direction
    for step = 1, max-1 do
      local r, c = row + step * dir[1], col + step * dir[2]
      if r >= 1 and r <= gridSize and c >= 1 and c <= gridSize and board[r][c] == player then
        count = count + 1
      else
        break
      end
    end

    -- Check in the negative direction
    for step = 1, max-1 do
      local r, c = row - step * dir[1], col - step * dir[2]
      if r >= 1 and r <= gridSize and c >= 1 and c <= gridSize and board[r][c] == player then
        count = count + 1
      else
        break
      end
    end

    if count >= max then
      save("Player" .. player .. " is the winner!\n")
      return true
    end
  end

  return false
end
