require 'fox16'
require 'game'
include Fox

class STCCGServer < FXMainWindow
    attr_reader :player_list, :game, :start

	def initialize(app, name)
    
		super(app, name, nil, nil, DECOR_ALL, 100, 100, 300, 300)
		@player_list = Array.new
		@selection = String.new
    @game = Game.new(self)
    
		
		#Parent Frames
		mainframe = FXVerticalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)
		topframe = FXHorizontalFrame.new(mainframe, LAYOUT_FILL_X|LAYOUT_FILL_Y)
		bottomframe = FXHorizontalFrame.new(mainframe,
			LAYOUT_FILL_X|PACK_UNIFORM_WIDTH)
		
		#Inner Frames
		list = FXScrollWindow.new(topframe, LAYOUT_FILL_X|LAYOUT_FILL_Y)
		player_buttons = FXVerticalFrame.new(topframe, LAYOUT_FILL_Y)
		
		#Buttons
		move_up = FXButton.new(player_buttons, 'Move Up', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 70, 35)
		move_down = FXButton.new(player_buttons, 'Move Down', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 70, 35)
		randomize = FXButton.new(player_buttons, 'Randomize', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 70, 35)
		start_game = FXButton.new(bottomframe, 'Start Game', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 70, 35)
    stop_game = FXButton.new(bottomframe, 'Stop Game', nil, nil, 0,
      LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 70, 35)
			
		#Player Window
		@player_window = FXText.new(list, nil, 0,
			LAYOUT_FILL_X|LAYOUT_FILL_Y|TEXT_READONLY|
			SELECT_LINES|TEXT_SHOWACTIVE)
		
    #Allows selection of a player, so you can change the player order	
		@player_window.connect(SEL_LEFTBUTTONPRESS) do |sender, selector, data|
			pos = @player_window.getPosAt(data.click_x, data.click_y)
			start = @player_window.lineStart(pos)
			finish = @player_window.lineEnd(pos)
			@player_window.setCursorPos(start)
			length = finish - start
			@player_window.setHighlight(start, length)
			@selection = @player_window.text[start ... finish]
		end
		
		#Button Methods
		move_up.connect(SEL_COMMAND) do
			unless @player_window.text.empty?
				index = @player_window.text.line_number_containing(@selection)
				unless index == 0
					@game.players[index-1], @game.players[index] = @game.players[index], @game.players[index-1]
				else
					@game.players << @game.players.slice!(index)
				end
        @player_list = self.get_player_list_from(@game.players)
				self.display_players(@player_list)
			end
		end
		
		move_down.connect(SEL_COMMAND) do
			unless @player_window.text.empty?
				index = @player_window.text.line_number_containing(@selection)
				unless index == @game.players.length-1
					@game.players[index.next], @game.players[index] = @game.players[index], @game.players[index.next]
				else
					@game.players = [@game.players.slice!(index)] + @game.players
				end
        @player_list = self.get_player_list_from(@game.players)
				self.display_players(@player_list)
			end
		end
		
		randomize.connect(SEL_COMMAND) do
			@game.players.shuffle
      @player_list = self.get_player_list_from(@game.players)
			self.display_players(@player_list)
		end
		
		start_game.connect(SEL_COMMAND) do
      @game.start
      @start = true
      start_game.hide
      stop_game.show
    end
    
    stop_game.connect(SEL_COMMAND){exit}
    
	end
	
	def display_players(list)
		@player_window.setText(list.inject {|text, player| text + "\n" + player})
	end
	
	def add_player(name)
    @player_list << name
		display_players(@player_list)
	end
  
  def get_player_list_from(player_array)
    new_array = Array.new
    player_array.each{|player| new_array << player.name}
    new_array
  end
  
end
