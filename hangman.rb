#Game should select a word between 5-12 characters long ✓
#Game should build a word ✓
#Player should select a letter ✓
#Game will then check if the letter exists wihtin the chosen word ✓
#If the letter is present, the game should print out a string representing the current state of the string with guessed letters ✓
#If the letter is not present, the game should log the letter in a bank of incorrect guesses
#After logging an incorrect guess, the board should be redrawn to include an additional limb of the hangman
#If the incorrect letter wordbank exceeds six letters, the game is over and the player has lost
#If the player has successfully guessed every letter, the game is over and the player has won


#First thing's first: lets load up the wordlist
@wordlist = []
#Note: 'strip' is necessary to remove the linebreaks (\n) in the file; if it were not present, we would get a wordlist including values like "Aaron\r\n"; with it, we get "Aaron"
File.readlines('wordlist.txt').map(&:strip).each do |line|
  if line.length.between?(5,12) #A word will only be pushed to the array if it is between 5 and 12 characters long
    @wordlist.push(line)
  end
end

#end_board defines what the board will look like at the end of the game
def end_board
  @end_board = []
  @end_board.push("|-------")
  @end_board.push("|     |")
  @end_board.push("|     O")
  @end_board.push("|    /|\\")
  @end_board.push("|    / \\")
  @end_board.push("|")
end

#start_board will initialize the board - starting from empty gallows
def start_board
  @board = []
  @board.push("|-------")
  5.times do
    @board.push("|")
  end
end

def display_board(board)
  board.each do |row|
    print "#{row} \n"
  end
end

def select_word
  #sample chooses a random item from an array; turning it downcase in order to make guesses case insensitive
  @word = @wordlist.sample.downcase
  #word_progress will replace all characters with underscores at the start of the game so the player knows the length of the word and how correct guesses fit into the word
  @word_progress = @word.gsub(/[a-z]/, '_')
end

def winner?
  if @word == @word_progress
    puts "Winner!"
    return true
  end
end

def loser?
  if @player_guesses.length == 7
    puts "Better luck next time!"
    return true
  end
end

def game_over?
  winner? || loser?
end

def start_game
  puts "HANGMAN"
  select_word
  start_board
  end_board
  display_board(@board)
  #maintain an array of incorrect player guesses
  @player_guesses = []
end

def get_player_choice
  @player_guess = gets.chomp
  if @player_guesses.include? @player_guess
    puts "That letter has already been used; please choose another"
    return get_player_choice
  end
end

def play_hangman

  start_game

  until game_over?

    puts "What's your guess?"

    get_player_choice

    if @word.include? @player_guess #if player guess is correct...
      char_array = @word.scan /\w/
      char_index = char_array.index{|char| char == @player_guess}
      @word_progress[char_index] = @player_guess
      puts "That letter is in the solution"
    else #if player guess is incorrect...
      @player_guesses << @player_guess
      puts "That letter is not in the solution"

      if @player_guesses.length == 1
        @board[1] = @end_board[1]
      elsif @player_guesses.length == 2
        @board[2] = @end_board[2]
      elsif @player_guesses.length == 3
        @board[3] ="|     |"
      elsif @player_guesses.length == 4
        @board[3] = "|    /|"
      elsif @player_guesses.length == 5
        @board[3] = @end_board[3]
      elsif @player_guesses.length == 6
        @board[4] = "|    / "
      elsif @player_guesses.length == 7
        @board[4] = @end_board[4]
      end

    end

    display_board(@board)
    puts ""
    puts @word_progress
    puts ""
    puts "Incorrect guesses: #{@player_guesses.join ", "}"

  end #end of until loop
end #end of play_hangman definition

play_hangman
