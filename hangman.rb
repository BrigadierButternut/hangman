require 'json'

#First thing's first: lets load up the wordlist
@wordlist = []
#Note: 'strip' is necessary to remove the linebreaks (\n) in the file; if it were not present, we would get a wordlist including values like "Aaron\r\n"; with it, we get "Aaron"
File.readlines('wordlist.txt').map(&:strip).each do |line|
  if line.length.between?(5,12) #A word will only be pushed to the array if it is between 5 and 12 characters long
    @wordlist.push(line)
  end
end

#end_board defines what the board will look like at the end of the game; this is mostly for my benefit.
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
  end_board
  display_board(@end_board)
  puts "1. NEW GAME"
  puts "2. LOAD GAME"

  player_choice

end

def player_choice
  game_type = gets.chomp
  if game_type == '1'
    select_word
    start_board
    #maintain an array of incorrect player guesses
    @player_guesses = []
    display_board(@board)
  elsif game_type == '2'
    load_game
  else
    puts "Please choose '1' or '2' "
    return player_choice
  end
end



def get_player_choice
  temp = gets.chomp.downcase
  if temp == "save"
    save_game
  elsif temp.length == 1
    @player_guess = temp
  else
    puts "You may only guess one letter at a time; try again, please"
    return get_player_choice
  end

  if @player_guesses.include? @player_guess
    puts "That letter has already been used; please choose another"
    return get_player_choice
  end
end

def correct_guess
  char_array = @word.scan /\w/ #break the word up into a character array
  index_array = [] #index array to keep track of all indices where letter occurs
  #for all locations where the character the player guessed exists in the solution, add the index to the index array
  char_array.each_with_index do |char, index|
    if char == @player_guess
      index_array << index
    end
  end
  #at each index of the solution where the player guessed character occurs, replace the blank with the player guessed character
  index_array.each do |index|
    @word_progress[index] = @player_guess
  end
  puts "That letter is in the solution"
end

def incorrect_guess
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

def save_game
  save_data = {
    player_guesses: @player_guesses,
    board: @board,
    word_progress: @word_progress,
    word: @word
  }.to_json

  puts "Please input a filename"
  file_name = gets.chomp
  File.open("saves/#{file_name}.json","w+") {|save| save.write(save_data)}
end

def load_game
  all_saves = Dir.entries("saves").reject{|entry| entry=~ /^\./}
  puts "Select save file (type any number 1-#{all_saves.length})"
  all_saves.each_with_index do |file, index|
    puts "#{index+1}. #{file}"
  end

  menu_choice = (gets.chomp.to_i)-1

  if all_saves.length < 1
    puts "No files to load from"
    return start_game
  end

  if menu_choice.between?(0,all_saves.length)
    file_selection = all_saves[menu_choice]
  else
    puts "The menu choices only range from 1 to #{all_saves.length}; try again."
    return load_game
  end

  load_data = JSON.load(File.open("saves/#{file_selection}"))

  #reassinging variables based on data from the save file
  @word = load_data["word"]
  @board = load_data["board"]
  @word_progress = load_data["word_progress"]
  @player_guesses = load_data["player_guesses"]

  player_progress

end

def player_progress
  display_board(@board)
  puts ""
  puts @word_progress.capitalize
  puts ""
  puts "Incorrect guesses: #{@player_guesses.join ", "}"
end

def play_hangman

  start_game

  until game_over?

    puts "What's your guess?"

    get_player_choice

    if @word.include? @player_guess #if player guess is correct...
      correct_guess
    else #if player guess is incorrect...
      incorrect_guess
    end

    player_progress

  end #end of until loop
  puts "Answer: #{@word.capitalize}"
end #end of play_hangman definition

play_hangman
