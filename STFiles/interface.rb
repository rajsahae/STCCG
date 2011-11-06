require 'fox16'
require 'drb'
require 'dialogs'
include Fox

class Interface < FXMainWindow
  include DRbUndumped
	attr_accessor :game, :name
  attr_reader :this_player, :num_players
	
	#@section_frames index legend
	LABEL_FRAME = 0
	CDV_FRAME = 1
	HISTORY_FRAME = 2
	MISSIONS_FRAME = 3
	ORBITS_FRAME = 4

	#@layer_objects index legend
	NAME_LABEL = 0
	MINI_VIEWER1 = 1
	MINI_VIEWER2 = 2
	CORE_PILE = 3
	DISCARD_PILE = 4
	MINI_VIEWER3 = 5
	HISTORY_WINDOW = 6

	def initialize(theApp, name)		
		super(theApp, name, nil, nil, DECOR_ALL, 50, 100, 1200, 800)

    DRb.start_service
		
    #Image Drag Type
    @image_drag_type = self.getApp().registerDragType(FXGLViewer.objectTypeName)

		FXToolTip.new(self.getApp())
		
		# Make menu bar
		@menubar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X|FRAME_RAISED)
		# GAME menu
		gamemenu = FXMenuPane.new(self)
		FXMenuTitle.new(@menubar, "&Game", nil, gamemenu)
		FXMenuCommand.new(gamemenu, "&Exit").connect(SEL_COMMAND){self.getApp().exit}
    #Create the ACTION menu
    @actionMenu = FXMenuPane.new(self)
    FXMenuTitle.new(@menubar, "&Action", nil, @actionMenu)
    @attPane = FXMenuPane.new(self)
    @selPane = FXMenuPane.new(self)
    @attMenu = FXMenuCascade.new(@actionMenu, "Attempt Mission", nil, @attPane)
    @selMenu = FXMenuCascade.new(@actionMenu, "Select Cards", nil, @selPane)
    
    
		#create the main  frame
		mainFrame = FXHorizontalFrame.new(self,
			LAYOUT_FILL_X|LAYOUT_FILL_Y)
			
		#Split the interface into two sides
		leftMainWindow = FXScrollWindow.new(mainFrame, LAYOUT_FILL_X|LAYOUT_FILL_Y|VSCROLLER_ALWAYS)
		@leftMainframe = FXVerticalFrame.new(leftMainWindow, LAYOUT_FILL_X|LAYOUT_FILL_Y)
		rightMainframe = FXVerticalFrame.new(mainFrame, LAYOUT_FIX_WIDTH|LAYOUT_FILL_Y, 0,0, 390)
			
		#Create the right side frames
		@display_label = FXLabel.new(rightMainframe, nil, nil, LAYOUT_FIX_Y|LAYOUT_FILL_X, 0,0,0, 35)
		stackViewerFrame = FXHorizontalFrame.new(rightMainframe, LAYOUT_FILL_X|LAYOUT_FILL_Y)
		buttonTopFrame = FXHorizontalFrame.new(rightMainframe, LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT, 0, 0, 0, 40)
		buttonBottomFrame = FXHorizontalFrame.new(rightMainframe, LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT, 0, 0, 0, 40)
			
		#create stack viewer
		stackViewerWindow = FXScrollWindow.new(stackViewerFrame, LAYOUT_FILL_X|LAYOUT_FILL_Y)
		@stackViewer = FXVerticalFrame.new(stackViewerWindow, LAYOUT_FIX_WIDTH|LAYOUT_FILL_Y, 0, 0, 357)
		
		#create right side player buttons
		@HandButton = FXButton.new(buttonTopFrame, 'My Hand' , nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
		@StopButton = FXButton.new(buttonTopFrame, '(Un)Stop All' , nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
		@DownloadButton = FXButton.new(buttonTopFrame, 'Download', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
		@DrawTopButton = FXButton.new(buttonTopFrame, 'Draw Top', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
		@DilemmaTopButton = FXButton.new(buttonTopFrame, 'Dil Top', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
		@ClearViewerButton = FXButton.new(buttonBottomFrame, 'Clear Viewer',nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
		@FlipButton = FXButton.new(buttonBottomFrame, 'Flip All', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
		@ExitButton = FXButton.new(buttonBottomFrame, 'Exit', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
		@DrawBottomButton = FXButton.new(buttonBottomFrame, 'Draw Bottom', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
		@DilemmaBottomButton = FXButton.new(buttonBottomFrame, 'Dil Bottom', nil, nil, 0,
			LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 70, 35)
  end

  # make_interface creates the board once the number of players has been determined
  # @game must be set before running make_interface
  # @game must be an instance of the Game Class
	def make_interface
    @num_players = @game.num_players
    @this_player = @game.get_player_index(@name)
    self.title = self.title + " Player #{@name}"

    5.times do |n|
      FXMenuCommand.new(@attPane, "#{n+1}").connect(SEL_COMMAND) do
        @game.begin_mission_attempt(@this_player, @game.players[@this_player].missions[n])
      end
    end
    @num_players.times do |num|
      sub = FXMenuPane.new(self)
      FXMenuCommand.new(sub, "Hand").connect(SEL_COMMAND){self.select_cards(@game.players[num].hand)}
      FXMenuCommand.new(sub, "Mini Viewer").connect(SEL_COMMAND){self.select_cards(@game.players[num].mini_viewer1)}
      FXMenuCascade.new(@selPane, "#{@game.players[num].name}", nil, sub)
    end
    @menubar.create unless $0 == __FILE__

		#Right Side Button SEL_COMMANDs
		@HandButton.connect(SEL_COMMAND) do |sender, sel, event|
      self.display(@game.players[@this_player].hand, @name, sender)
			@stackViewer.recalc
		end
		@ClearViewerButton.connect(SEL_COMMAND) do
			self.remove_previous_images(@stackViewer)
			@display_label.text = "Currently Showing: Nothing"
		end
    @DownloadButton.connect(SEL_COMMAND) do
      self.download_from(@game.players[@this_player].draw_deck)
      self.setFocus
    end
		@DrawTopButton.connect(SEL_COMMAND) do |sender, sel, event|
			@game.players[@this_player].draw
			self.display(@game.players[@this_player].hand, @name, sender)
			@stackViewer.recalc
		end
		@DilemmaTopButton.connect(SEL_COMMAND) do |sender, sel, event|
			@game.players[@this_player].draw_dilemma_top
			self.display(@game.players[@this_player].mini_viewer1, @name, sender)
			@stackViewer.recalc
		end
		@DrawBottomButton.connect(SEL_COMMAND) do |sender, sel, event|
			@game.players[@this_player].draw_bottom
			self.display(@game.players[@this_player].hand, @name, sender)
			@stackViewer.recalc
		end
		@DilemmaBottomButton.connect(SEL_COMMAND) do |sender, sel, event|
			@game.players[@this_player].draw_dilemma_bottom
			self.display(@game.players[@this_player].mini_viewer1, @name, sender)
			@stackViewer.recalc
		end
		@ExitButton.connect(SEL_COMMAND){ exit }
		
		#Right Side Button DND Commands
			#Hand Button
		@HandButton.dropEnable
		@HandButton.connect(SEL_DND_MOTION) do
			@HandButton.setDragRectangle(0,0, @HandButton.width, @HandButton.height, false)
			if @HandButton.offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
				@HandButton.acceptDrop
			end
		end
		@HandButton.connect(SEL_DND_DROP) do
			data = @HandButton.getDNDData(FROM_DRAGNDROP, @image_drag_type)
			@HandButton.dropFinished
			card = ObjectSpace._id2ref(data.to_i)
			@game.players[@this_player].place_card_in_hand(card)
		end
			#Draw from top of Draw Deck Button
		@DrawTopButton.dropEnable	
		@DrawTopButton.connect(SEL_DND_MOTION) do
			@DrawTopButton.setDragRectangle(0,0, @DrawTopButton.width, @DrawTopButton.height, false)
			if @DrawTopButton.offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
				@DrawTopButton.acceptDrop
			end
		end
		@DrawTopButton.connect(SEL_DND_DROP) do
			data = @DrawTopButton.getDNDData(FROM_DRAGNDROP, @image_drag_type)
			@DrawTopButton.dropFinished
			card = ObjectSpace._id2ref(data.to_i)
			@game.players[@this_player].place_card_draw_top(card)
		end
			#Draw from Bottom of Draw Deck Button
		@DrawBottomButton.dropEnable
		@DrawBottomButton.connect(SEL_DND_MOTION) do
			@DrawBottomButton.setDragRectangle(0,0, @DrawBottomButton.width, @DrawBottomButton.height, false)
			if @DrawBottomButton.offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
				@DrawBottomButton.acceptDrop
			end
		end
		@DrawBottomButton.connect(SEL_DND_DROP) do
			data = @DrawBottomButton.getDNDData(FROM_DRAGNDROP, @image_drag_type)
			@DrawBottomButton.dropFinished
			card = ObjectSpace._id2ref(data.to_i)
			@game.players[@this_player].place_card_draw_bottom(card)
		end
			#Draw from top of Dilemma Pile Button
		@DilemmaTopButton.dropEnable
		@DilemmaTopButton.connect(SEL_DND_MOTION) do
			@DilemmaTopButton.setDragRectangle(0,0, @DilemmaTopButton.width, @DilemmaTopButton.height, false)
			if @DilemmaTopButton.offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
				@DilemmaTopButton.acceptDrop
			end
		end
		@DilemmaTopButton.connect(SEL_DND_DROP) do
			data = @DilemmaTopButton.getDNDData(FROM_DRAGNDROP, @image_drag_type)
			@DilemmaTopButton.dropFinished
			card = ObjectSpace._id2ref(data.to_i)
			@game.players[@this_player].place_dilemma_on_top(card)
		end
			#Draw from Bottom of Dilemma Pile Button
		@DilemmaBottomButton.dropEnable
		@DilemmaBottomButton.connect(SEL_DND_MOTION) do
			@DilemmaBottomButton.setDragRectangle(0,0, @DilemmaBottomButton.width, @DilemmaBottomButton.height, false)
			if @DilemmaBottomButton.offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
				@DilemmaBottomButton.acceptDrop
			end
		end
		@DilemmaBottomButton.connect(SEL_DND_DROP) do
			data = @DilemmaBottomButton.getDNDData(FROM_DRAGNDROP, @image_drag_type)
			@DilemmaBottomButton.dropFinished
			card = ObjectSpace._id2ref(data.to_i)
			@game.players[@this_player].place_dilemma_on_bottom(card)
		end
    
		#create left side player frames
		playerFrames = Array.new
		@num_players.times do
			playerFrames << FXHorizontalFrame.new(@leftMainframe,
				LAYOUT_FILL_X|LAYOUT_FIX_HEIGHT|FRAME_RIDGE, 0,0,0, 270)
		end
		
		#create player sections
		section_frames = Array.new(@num_players)
		@num_players.times do |number|
			temp_array = Array.new
			temp_array << FXVerticalFrame.new(playerFrames[number], LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, 0,0, 85, 260)
			temp_array << FXVerticalFrame.new(playerFrames[number], LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, 0,0, 85, 260)
			temp_array << FXScrollWindow.new(playerFrames[number], LAYOUT_FILL_X|LAYOUT_FILL_Y)
			mission_area = FXVerticalFrame.new(playerFrames[number], LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, 0,0, 500, 260)
			temp_array << FXHorizontalFrame.new(mission_area, LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, 0,0, 500, 130)
			temp_array << FXHorizontalFrame.new(mission_area, LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, 0,0, 500, 130)
			section_frames[number] = temp_array	
		end
		
		#create player objects
		player_objects = Array.new(@num_players)
		player_missions = Array.new(@num_players)
		player_orbits = Array.new(@num_players)
		#Player Labels, Core Pile, Discard Pile, and MiniViewer
		@num_players.times do |player|
			temp_array = Array.new
			temp_array << FXLabel.new(section_frames[player][LABEL_FRAME], nil, nil,
        JUSTIFY_CENTER_Y|LAYOUT_FIX_HEIGHT, 0, 0, 80, 80)
			temp_array << FXButton.new(section_frames[player][LABEL_FRAME], "MiniViewer 1", nil, nil, 0,
				LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 80, 80)
			temp_array << FXButton.new(section_frames[player][LABEL_FRAME], "MiniViewer 2", nil, nil, 0,
				LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 80, 80)
				#Player1 Core and Discard Button
			temp_array << FXButton.new(section_frames[player][CDV_FRAME], "Core", nil, nil, 0,
				LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 80, 80)
			temp_array << FXButton.new(section_frames[player][CDV_FRAME], "Discard Pile", nil, nil, 0,
				LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 80, 80)
			temp_array << FXButton.new(section_frames[player][CDV_FRAME], "MiniViewer 3", nil, nil, 0,
				LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0, 0, 80, 80)
			temp_array << FXText.new(section_frames[player][HISTORY_FRAME], nil, 0,
				LAYOUT_FILL_X|LAYOUT_FILL_Y|TEXT_READONLY|TEXT_WORDWRAP)
			player_objects[player] = temp_array
		end
		
		#Player Missions Buttons
		@num_players.times do |player|
			temp_array = Array.new
			5.times do
				temp_array << FXButton.new(section_frames[player][MISSIONS_FRAME], nil, nil, nil, 0,
				LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_TOOLBAR, 0,0, 90, 124)
			end
			player_missions[player] = temp_array
		end
		
		#Player Orbit Buttons
		@num_players.times do |player|
			temp_array = Array.new
			5.times do
				temp_array << FXButton.new(section_frames[player][ORBITS_FRAME], nil, nil, nil, 0,
					LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_TOOLBAR, 0,0, 90, 124)
			end
			player_orbits[player] = temp_array
		end
			
		#player event handling
		@num_players.times do |player|
			player_objects[player][DISCARD_PILE].dropEnable
			player_objects[player][DISCARD_PILE].connect(SEL_COMMAND) do |sender, sel, event|
				self.display(@game.players[player].discard_pile, @name, sender)
        self.set_target(nil)
				@stackViewer.recalc
			end
			player_objects[player][DISCARD_PILE].connect(SEL_DND_MOTION) do
				player_objects[player][DISCARD_PILE].setDragRectangle(0,0, player_objects[player][DISCARD_PILE].width, 
						player_objects[player][DISCARD_PILE].height, false)
				if player_objects[player][DISCARD_PILE].offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
					player_objects[player][DISCARD_PILE].acceptDrop
				end
			end
			player_objects[player][DISCARD_PILE].connect(SEL_DND_DROP) do
				data = player_objects[player][DISCARD_PILE].getDNDData(FROM_DRAGNDROP, @image_drag_type)
				player_objects[player][DISCARD_PILE].dropFinished
        card = ObjectSpace._id2ref(data.to_i)
				@game.players[player].discard_pile.place_card_on(card)
			end
			player_objects[player][CORE_PILE].dropEnable
			player_objects[player][CORE_PILE].connect(SEL_COMMAND) do |sender, sel, event|
				self.display(@game.players[player].core, @name, sender)
        self.set_target(nil)
				@stackViewer.recalc
			end
			player_objects[player][CORE_PILE].connect(SEL_DND_MOTION) do
				if player_objects[player][CORE_PILE].offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
					player_objects[player][CORE_PILE].acceptDrop
				end
			end
			player_objects[player][CORE_PILE].connect(SEL_DND_DROP) do
				data = player_objects[player][CORE_PILE].getDNDData(FROM_DRAGNDROP, @image_drag_type)
				player_objects[player][CORE_PILE].dropFinished
				card = ObjectSpace._id2ref(data.to_i)
        @game.players[player].core.place_card_on(card)
			end
			player_objects[player][MINI_VIEWER1].dropEnable
			player_objects[player][MINI_VIEWER1].connect(SEL_COMMAND) do |sender, sel, event|
				self.display(@game.players[player].mini_viewer1, @name, sender)
				@stackViewer.recalc
			end
			player_objects[player][MINI_VIEWER1].connect(SEL_DND_MOTION) do
				if player_objects[player][MINI_VIEWER1].offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
					player_objects[player][MINI_VIEWER1].acceptDrop
				end
			end
			player_objects[player][MINI_VIEWER1].connect(SEL_DND_DROP) do
				data = player_objects[player][MINI_VIEWER1].getDNDData(FROM_DRAGNDROP, @image_drag_type)
				player_objects[player][MINI_VIEWER1].dropFinished
				card = ObjectSpace._id2ref(data.to_i)
        @game.players[player].mini_viewer1.place_card_on(card)
			end
			player_objects[player][MINI_VIEWER2].dropEnable
			player_objects[player][MINI_VIEWER2].connect(SEL_COMMAND) do |sender, sel, event|
				self.display(@game.players[player].mini_viewer2, @name, sender)
				@stackViewer.recalc
			end
			player_objects[player][MINI_VIEWER2].connect(SEL_DND_MOTION) do
				if player_objects[player][MINI_VIEWER2].offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
					player_objects[player][MINI_VIEWER2].acceptDrop
				end
			end
			player_objects[player][MINI_VIEWER2].connect(SEL_DND_DROP) do
				data = player_objects[player][MINI_VIEWER2].getDNDData(FROM_DRAGNDROP, @image_drag_type)
				player_objects[player][MINI_VIEWER2].dropFinished
				card = ObjectSpace._id2ref(data.to_i)
        @game.players[player].mini_viewer2.place_card_on(card)
			end
			player_objects[player][MINI_VIEWER3].dropEnable
			player_objects[player][MINI_VIEWER3].connect(SEL_COMMAND) do |sender, sel, event|
				self.display(@game.players[player].mini_viewer3, @name, sender)
				@stackViewer.recalc
			end
			player_objects[player][MINI_VIEWER3].connect(SEL_DND_MOTION) do
				if player_objects[player][MINI_VIEWER3].offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
					player_objects[player][MINI_VIEWER3].acceptDrop
				end
			end
			player_objects[player][MINI_VIEWER3].connect(SEL_DND_DROP) do
				data = player_objects[player][MINI_VIEWER3].getDNDData(FROM_DRAGNDROP, @image_drag_type)
				player_objects[player][MINI_VIEWER3].dropFinished
				card = ObjectSpace._id2ref(data.to_i)
        @game.players[player].mini_viewer3.place_card_on(card)
			end
		end
		
		#load the players icons
    iconArray = Array.new()
		@num_players.times do |index|
			5.times do |n|
				iconFile = File.open(@game.players[index].missions[n].face, "rb")
				iconArray[5*index + n] = FXJPGIcon.new(self.getApp(), iconFile.read, 0,
					IMAGE_KEEP|IMAGE_SHMI|IMAGE_SHMP)
				iconFile.close
			end
		end
		
		#Set mission/orbit icons
		iconArray.each {|icon| icon.scale(90, 124)}
		@num_players.times do |player| 
			player_objects[player][NAME_LABEL].text = @game.players[player].name
			player_missions[player].each_index do |button_index|
				player_missions[player][button_index].icon = iconArray[5*player + button_index]
			end
		end
		
		#Mission Button Events
		@num_players.times do |player|
			player_missions[player].each_index do |index|
				player_missions[player][index].connect(SEL_COMMAND) do |sender, sel, event|
					self.display(@game.players[player].missions[index], @name, sender)
					@display_label.text = "Showing: #{@game.players[player].name}'s Mission##{index+1}" + 
            " (#{@game.players[player].missions[index].size-1})"
				end
			end
			5.times do |num|
				player_missions[player][num].dropEnable
				player_missions[player][num].connect(SEL_DND_MOTION) do
					player_missions[player][num].setDragRectangle(0,0, player_missions[player][num].width, 
						player_missions[player][num].height, false)
					if player_missions[player][num].offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
						player_missions[player][num].acceptDrop
					end
				end
				player_missions[player][num].connect(SEL_DND_DROP) do
					data = player_missions[player][num].getDNDData(FROM_DRAGNDROP, @image_drag_type)
					player_missions[player][num].dropFinished
					card = ObjectSpace._id2ref(data.to_i)
          @game.players[player].missions[num].place_card_on(card)
				end
			end
    #Orbital Button Events
      player_orbits[player].each_index do |index|
				player_orbits[player][index].connect(SEL_COMMAND) do |sender, sel, event|
					self.display(@game.players[player].orbits[index], @name, sender)
					@display_label.text = "Showing: #{@game.players[player].name}'s Orbit##{index+1}" + 
            " (#{@game.players[player].orbits[index].size})"
				end
			end
			5.times do |num|
				player_orbits[player][num].dropEnable
				player_orbits[player][num].connect(SEL_DND_MOTION) do
					player_orbits[player][num].setDragRectangle(0,0, player_orbits[player][num].width, 
						player_orbits[player][num].height, false)
					if player_orbits[player][num].offeredDNDType?(FROM_DRAGNDROP, @image_drag_type)
						player_orbits[player][num].acceptDrop
					end
				end
				player_orbits[player][num].connect(SEL_DND_DROP) do |sender, sel, event|
					data = player_orbits[player][num].getDNDData(FROM_DRAGNDROP, @image_drag_type)
					player_orbits[player][num].dropFinished
					card = ObjectSpace._id2ref(data.to_i)
          @game.players[player].orbits[num].place_card_on(card)
          sender.icon = self.set_icon_for(@game.players[player].orbits[num])
          sender.create
        end
			end
		end
    @leftMainframe.create  unless $0 == __FILE__
    self.show_this_players_hand  unless $0 == __FILE__
	end
	
	def show_this_players_hand
		self.display(@game.players[@this_player].hand, @name)
		@stackViewer.recalc
	end
	
	def remove_previous_images(viewer)
		viewer.children.each do |child|
			viewer.removeChild(child)
		end
	end
	
	def display(stack, requesting_player, send = nil)
    self.set_target(stack)
    #set drag type, clear the viewer, prep the stack
		remove_previous_images(@stackViewer)
		cards = stack.cards.flatten
    data_sent = false
    #for each index in the flattened stack, open the file
		cards.each do |card|
      filename = (card.commander == requesting_player or card.face_up?) ? card.face : card.back
			until filename.length >= 4
				filename = '0' + filename
			end
			file = File.open(filename, "rb")
			#create the imageframe and icon from the file
			imageView= FXButton.new(@stackViewer, nil, nil, nil, 0, 
				LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT|BUTTON_NORMAL, 0,0, 357, 497)
			imageView.icon = FXJPGIcon.new(self.getApp(), file.read, IMAGE_KEEP|IMAGE_SHMI|IMAGE_SHMP)
			imageView.tipText =  
"Commanded By: #{card.commander}
Owned By: #{card.owner}
Status: #{card.status}
Stopped: #{card.stopped}"
      imageView.buttonStyle = BUTTON_AUTOGRAY if card.stopped
			#set DND for cards in viewer
			imageView.connect(SEL_LEFTBUTTONPRESS) do
				imageView.grab
				dragTypes = [@image_drag_type]
				imageView.beginDrag(dragTypes)
        false #This made the DND work properly, don't know why
			end
			imageView.connect(SEL_MOTION) do |sender, sel, event|
				if imageView.dragging?
					imageView.handleDrag(event.root_x, event.root_y)
					unless imageView.didAccept == DRAG_REJECT
						imageView.dragCursor = self.getApp().getDefaultCursor(DEF_DNDMOVE_CURSOR)
					else
						imageView.dragCursor = self.getApp().getDefaultCursor(DEF_DNDSTOP_CURSOR)
					end
				end
			end
			imageView.connect(SEL_DND_REQUEST) do |sender, sel, event|
				if event.target == @image_drag_type
          data_sent = true
					imageView.setDNDData(FROM_DRAGNDROP, @image_drag_type, card.__id__.to_s)
				end
			end
			imageView.connect(SEL_LEFTBUTTONRELEASE) do
				imageView.ungrab
				imageView.endDrag
        if data_sent
          stack.remove(card)
          if stack.orbit?
            send.icon = self.set_icon_for(stack)
            send.create
            send.recalc
          end
        end
				self.display(stack, requesting_player, send)
        false #returning false keeps the LEFTBUTTONRELEASE from overriding the SEL_COMMAND
			end
      #set action for selected button
			imageView.connect(SEL_COMMAND) do
        card.flip
				self.display(stack, requesting_player, send)
			end
			imageView.create
		end
    @display_label.text =
    "Showing: #{cards.empty? ? "" : cards[0].commander}'s #{stack.get_class} (#{cards.size})"
    stack
	end
  
  def download_from(stack)
    dw = DownloadWindow.new(self, stack)
    dw.create
    dw.show
  end
  
  def set_target(target)
    @FlipButton.connect(SEL_COMMAND) do |sender, sel, event|
      unless target.nil?
        target.flip_all
        self.display(target, self.name, sender)
      end
    end
		@StopButton.connect(SEL_COMMAND) do |sender, sel, event|
      unless target.nil?
        target.stopped? ? target.unstop_all : target.stop_all
        self.display(target, self.name)
      end
    end
  end
  
  def select_cards(stack)
    cw = ChooserWindow.new(self, stack)
    cw.create
    cw.show
  end
  
  def set_icon_for(stack)
    if stack.top_ship.nil?
      stack.icon.release if stack.icon.kind_of?(FXIcon)
      stack.icon = nil
    else
      File.open(stack.top_ship.face, 'rb') do |file|
        stack.icon = FXJPGIcon.new(FXApp.instance, file.read, 0, IMAGE_KEEP|IMAGE_SHMI|IMAGE_SHMP)
        stack.icon.scale(90, 124)
      end
    end
    stack.icon
  end
end

if $0 == __FILE__
  $: << "./"
  $pic_dir = "../STPics/"
  $pic_type = ".jpg"
  require 'game'
  require 'player'
  require 'stack'
  game = Game.new(:test)
  File.open("../STDecks/infiltrator.txt", 'r'){|file| game.add_player("Raj", file.gets)}
  File.open("../STDecks/borg.txt", 'r'){|file| game.add_player("Eugene", file.gets)}
  game.start
  theApp = FXApp.new
  test = Interface.new(theApp, "test interface")
  test.game = game
  test.name = "Raj"
  test.show
  test.make_interface
  theApp.create
  theApp.run
end