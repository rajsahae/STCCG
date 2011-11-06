require 'player'
require 'drb'

class Game
  include DRbUndumped
  attr_reader :players, :game_start
  
  def initialize(server)
    @server = server
    @players = Array.new
  end
  
  def add_player(name, deck)
    @players << Player.new(name, deck)
    @server.add_player(name) unless @server == :test
  end
  
  def start
    @players.each do |player|
      player.shuffle_deck
      player.shuffle_dilemmas
      7.times {player.draw_top}
    end
    @game_start = true
  end
  
	def begin_mission_attempt(player, mission)
		puts "Player:#{player} is attempting Mission:#{mission}"
	end
  
  def get_player_index(name)
    @server == :test ? 0 : @server.get_player_list_from(@players).index(name)
  end
  
  def num_players
    @players.size
  end
end
