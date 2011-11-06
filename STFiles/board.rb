=begin
Implements an STCCG Board, representing the data storage needed
to keep during a game of STCCG.  The board holds the players,
keeps track of the current player, and currentShase
=end

require 'drb'

class Board
  include DRbUndumped
  attr_reader :current_player, :current_phase, :players
  
  def initialize(players)
    @players = players
    @current_player = @players.first
  end
  
  #start the next players turn
  def next_turn
    @current_player = @players.next(@players.index(@current_player))
  end
  
  
end
