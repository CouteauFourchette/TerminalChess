require_relative 'human_player'
require_relative 'display'
require_relative 'board'
require_relative 'pgn'
require_relative 'fen'

class Game
  def initialize(name1, name2, board, current_player = :white)
    @board = board
    @cursor = Cursor.new([6,4], @board)
    @player1 = HumanPlayer.new(name1, :white, @cursor)
    @player2 = HumanPlayer.new(name2, :black, @cursor)
    @current_player = current_player == :white ? @player1 : @player2
    @display = Display.new(@board, @cursor)
  end

  def switch_player
    @current_player = @current_player == @player1 ? @player2 : @player1
  end

  def play
    @display.render

    until @board.checkmate?(@current_player.color)
      play_turn
    end
    @history.save_as_PGN
    puts "WINNNER IS #{@current_player.name}"
  end

  def play_turn
    begin
    @display.render
    pos = @current_player.get_input

    if pos != nil && !@cursor.selected.empty?
      piece = @board.move_piece(@cursor.selected, pos)
      @cursor.selected = []
      switch_player
      @display.render
    elsif pos!=nil && @board[pos].color == @current_player.color && @cursor.selected.empty?
      @cursor.selected = pos
    end
    rescue ArgumentError
      retry
    end
  end

  def self.load_from_file(filename)
    pgn = Pgn.new(filename, 'Player1', 'Player2')
    pgn.load
    # Game.new('Player1', 'Player2')
  end
end
