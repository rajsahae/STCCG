require 'fox16'
require 'drb'
require 'socket'
include Fox

class JoinDialogBox < FXDialogBox
	def initialize(owner)
		super(owner, "Joining Game")
		
		#Create the frames
		mainframe = FXVerticalFrame.new(self, LAYOUT_FILL_X)
		nameframe = FXHorizontalFrame.new(mainframe, 
			LAYOUT_FILL_X|PACK_UNIFORM_WIDTH)
		fileframe = FXHorizontalFrame.new(mainframe, LAYOUT_FILL_X)
		addressframe = FXHorizontalFrame.new(mainframe, LAYOUT_FILL_X,
			LAYOUT_FILL_X|PACK_UNIFORM_WIDTH)
		bottomframe = FXHorizontalFrame.new(mainframe,
			LAYOUT_FILL_X|PACK_UNIFORM_WIDTH)
		ipframe = FXHorizontalFrame.new(mainframe, LAYOUT_FILL_X)
		infoframe = FXHorizontalFrame.new(mainframe, LAYOUT_FILL_X)
		
		#Name label and field
		FXLabel.new(nameframe, "Enter your name:")
		namefield = FXTextField.new(nameframe, 20)
		
		#IP Field and Label
		FXLabel.new(addressframe, "Enter IP Address:")
		ipfield = FXTextField.new(addressframe, 15)
		
		#deckfile label
		FXLabel.new(fileframe, "Enter your deck filename(*.txt):")
		filefield = FXTextField.new(fileframe, 30)
		
		#Create and Cancel buttons
		join = FXButton.new(bottomframe, "Join")
		cancel = FXButton.new(bottomframe, "Cancel")
		
		#IP display and connection label
		connection_label = FXLabel.new(infoframe, "Type in name and ip, then press Join, or press Cancel to exit.")
		
		
		join.connect(SEL_COMMAND) do
			self.hide
			owner.name = namefield.text
			owner.game = DRbObject.new(nil, "druby://#{ipfield.text}:#{$port}")
      File.open($deck_dir + filefield.text.strip, "r"){|file| owner.game.add_player(namefield.text, file.gets)}
      sleep(1) until owner.game.game_start
      owner.make_interface
		end
		
		cancel.connect(SEL_COMMAND) {getApp().exit}
		
		#Place the cursor in the textfield and activate name selection
		namefield.setFocus
	end
end

class DownloadWindow < FXPopup
  CPR = 6 #Cards Per Row
  WIDTH = 180 #Card Width
  HEIGHT = 250 # Card Height
  def initialize(owner, stack)
    super(owner, DECOR_ALL, 20, 20, 1200, 800)
    topframe = FXVerticalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)
    #make a cancel button
    FXButton.new(topframe, "Cancel", nil, nil, 0,
      LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 0, 50) do |button|
      button.connect(SEL_COMMAND) do 
        self.popdown
      end
    end
    #make a vertical scroll window
    window = FXScrollWindow.new(topframe, LAYOUT_FILL_X|LAYOUT_FILL_Y)
    mainframe = FXVerticalFrame.new(window, LAYOUT_FILL_X|LAYOUT_FILL_Y)
    #make a number of rows for the deck
    rows = Array.new
    cards = stack.cards.flatten
    num = cards.size%CPR == 0 ? cards.size / CPR : cards.size / CPR + 1
    num.times{rows << FXHorizontalFrame.new(mainframe, LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT, 0, 0, 0, HEIGHT)}
    #For every card in STACK, make a button
    cards.each_with_index do |card, index|
      #create and scale the icon
      iconFile = File.open(card.face, "rb")
      icon = FXJPGIcon.new(self.getApp(), iconFile.read, 0, IMAGE_KEEP|IMAGE_SHMI|IMAGE_SHMP)
      iconFile.close
      icon.scale(WIDTH, HEIGHT)
      #create the button and set the icon for the button
      FXButton.new(rows[index/CPR], nil , icon, nil, 0,
        LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, WIDTH, HEIGHT) do |button|
        button.connect(SEL_COMMAND) do
          self.download(owner, card)
          self.popdown
        end
      end
    end
  end
  
  def download(owner, card)
    owner.game.players[owner.this_player].download(card)
  end
end

class ChooserWindow < FXPopup
  def initialize(owner, stack)
    super(owner, FRAME_NORMAL, owner.x, owner.y)
    @main = FXVerticalFrame.new(self, LAYOUT_FILL_X|LAYOUT_FILL_Y)
    top = FXHorizontalFrame.new(@main, LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT, 0, 0, 0, 50)
    FXLabel.new(top, "How many cards would you like to select?")
    spinner, spinner.range = FXSpinner.new(top, 1, nil, 0, SPIN_CYCLIC), 0..stack.size
    FXButton.new(top, "Select", nil, nil, 0, LAYOUT_FILL_X|LAYOUT_FILL_Y|BUTTON_NORMAL) do |button|
      button.connect(SEL_COMMAND) do
        results = self.get_cards(stack, spinner.value)
        results.each do |card|
          owner.game.players[owner.this_player].mini_viewer1.place_card_on(card.face_up!)
        end
        owner.display(owner.game.players[owner.this_player].mini_viewer1, owner.game.players[owner.this_player])
        self.popdown
      end
    end
    FXButton.new(top, "Exit", nil, nil, 0, LAYOUT_FILL_X|LAYOUT_FILL_Y|BUTTON_NORMAL) do |button|
      button.connect(SEL_COMMAND){self.popdown}
    end
  end
  
  def get_cards(stack, number)
    stack.shuffle
    temp = Array.new
    number.times{|n| temp << stack.slice!(rand(stack.size))}
    temp
  end
end
