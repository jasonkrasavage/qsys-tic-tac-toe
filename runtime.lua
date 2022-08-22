--Global Variables
grid_array = {"","","",
              "","","",
              "","",""}

lines = {
  grid_array[1]..grid_array[2]..grid_array[3], --row 1
  grid_array[4]..grid_array[5]..grid_array[6], --row 2
  grid_array[7]..grid_array[8]..grid_array[9], --row 3
  grid_array[1]..grid_array[4]..grid_array[7], --col 1
  grid_array[2]..grid_array[5]..grid_array[8], --col 2
  grid_array[3]..grid_array[6]..grid_array[9], --col 3
  grid_array[1]..grid_array[5]..grid_array[9], --diag 1
  grid_array[7]..grid_array[5]..grid_array[3], --diag 2

}

letter = "X"
ai_letter = "O"

wins = 0
ai_wins = 0

--Control Shortcuts
grid = Controls.Grid
Controls.Letter.Choices = {"X","O"}
Controls["New Game"].Legend = "New Game"
Controls["New Session"].Legend = "New Session"
Controls["Instructions"].String = "Select a symbol to start the session."

--EventHandlers
for i,x in ipairs(grid) do
  x.EventHandler = function(self)
    if self.Boolean then 
      if self.Legend == "" then
        self.Legend = letter 
        grid_array[i] = letter
        if analyze() == false then
          aiMove()
        end
      end
    end

  end
end


Controls["New Session"].EventHandler = function()
  newSession()
end

Controls["New Game"].EventHandler = function()
  newGame()
end

Controls.Letter.EventHandler = function(self)
  if self.String == "X" then
    letter = "X"
    ai_letter = "O"
  else
    letter = "O"
    ai_letter = "X"
  end
  for i=1, #grid do
    grid[i].IsDisabled = false
  end
  self.IsInvisible = true
  Controls.Instructions.IsInvisible = true
  newGame()
end

--Functions
function moves()
  local num = 0
  for _,i in ipairs(grid_array) do
    if i ~= "" then 
      num = num + 1
     end
  end
  return num
end


function winner(letter, array)
 
  lines = {
    array[1]..array[2]..array[3], --row 1
    array[4]..array[5]..array[6], --row 2
    array[7]..array[8]..array[9], --row 3
    array[1]..array[4]..array[7], --col 1
    array[2]..array[5]..array[8], --col 2
    array[3]..array[6]..array[9], --col 3
    array[1]..array[5]..array[9], --diag 1
    array[7]..array[5]..array[3], --diag 2

}

  for i=1,#lines do

    if lines[i] == letter..letter..letter then
      return true
    else 
    end
  end
  return false
  
end


function analyze(array)
  print("-----------------------")
  for i=1, #grid_array do
    print(grid_array[i])
  end
  print("-----------------------")
  local moves = moves()
  if winner("X", grid_array) == true then 
    if letter == "X" then
      wins = wins + 1
      Controls.Score.String = "Player Wins!"
    else
      ai_wins = ai_wins + 1
      Controls.Score.String = "AI Wins!"
    end
    lockBoard()
    return true
  elseif winner("O", grid_array) == true then 
    if letter == "O" then
      wins = wins + 1
      Controls.Score.String = "Player Wins!"
    else
      ai_wins = ai_wins + 1
      Controls.Score.String = "AI Wins!"
    end
    lockBoard()
    return true 
  elseif moves < 9 then
    return false
  else
    lockBoard()
    Controls.Score.String = "Tie!"
    return true
  end
end

function aiMove()

  local grid_copy = {}
  for i=1,#grid_array do grid_copy[i] = grid_array[i] end
  if letter == "X" then ai_letter = "O" else ai_letter = "X" end
  local move_options = {}
  --first check to see if there is a move that wins the game, and execute
  for i=1,#grid_copy do
    if grid_copy[i] == "" then 
      grid_copy[i] = ai_letter
      if winner(ai_letter, grid_copy) == true then
        grid_array[i] = ai_letter
        grid[i].Legend = ai_letter
        analyze()
        print("ai made a move to win")
        return true
      else
        table.insert(move_options, i)
        for i=1,#grid_array do grid_copy[i] = grid_array[i] end
      end
    end
  end
  --second check to see if there is a move that blocks the player from winning, and execute
  for i=1,#grid_copy do
    if grid_copy[i] == "" then 
      grid_copy[i] = letter
      if winner(letter, grid_copy) == true then
        grid_array[i] = ai_letter
        grid[i].Legend = ai_letter
        analyze()
        print("ai made a move to block player from winning")
        return true
      else
        for i=1,#grid_array do grid_copy[i] = grid_array[i] end
      end
    end
  end
  --lastly, choose one of the available moves and execute them if there are no winning or blocking moves available
  local random_move = move_options[math.random(#move_options)]
  grid_array[random_move] = ai_letter
  grid[random_move].Legend = ai_letter
  analyze()
  print("ai chose one of their available moves")
  return true
end


function newGame()
  updateScore()
  for _,i in ipairs(grid) do i.Legend = "" i.Boolean = false i.IsDisabled = false end
  grid_array = {"","","",
              "","","",
              "","",""}
  Controls.Letter.String = ""
  Controls["New Game"].Boolean = false
  Controls["New Game"].IsInvisible = true
  Controls["New Session"].Boolean = false
  Controls["New Session"].IsInvisible = true
end



function updateScore()
  Controls.Score.String = "Player: "..wins.."  |  ".."AI: "..ai_wins
end

function lockBoard()
  for i=1, #grid do
    grid[i].IsDisabled = true
    Controls["New Game"].IsInvisible = false
    Controls["New Session"].IsInvisible = false
  end
end

function newSession()
  lockBoard()
  wins = 0
  ai_wins = 0
  updateScore()
  Controls["New Game"].IsInvisible = true
  Controls["New Session"].IsInvisible = true
  Controls.Letter.IsInvisible = false
  Controls.Instructions.IsInvisible = false
end

--Runtime

newSession()

