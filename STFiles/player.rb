require 'drb'
require 'stack'
require 'card'

class Player
  
  include DRbUndumped
  
	attr_accessor :name, :draw_deck, :dilemma_deck, :core, 
		:discard_pile, :mini_viewer1, :mini_viewer2, :mini_viewer3,
    :hand, :missions, :orbits, :dilemma_stack, :deckfile
	
	def initialize(name, deckstring)
		@draw_deck, @dilemma_deck = Deck.new, Deck.new
		@missions, @orbits = Array.new, Array.new(5){Orbit.new}
		@core, @discard_pile = Core.new, DiscardPile.new
    @mini_viewer1, @mini_viewer2, @mini_viewer3 = MiniViewer.new, MiniViewer.new, MiniViewer.new
		@hand = Hand.new
    @name = name
		self.load_decks(deckstring)
	end
	
	#Loads the players deck
	def load_decks(deckstring)
		cardlist = deckstring.gsub(",", "\n").to_a
		cardlist.each do |card|
			card = card.to_s.strip.gsub(".", "\n").to_a.collect{|element| element.strip}
			card_type, card_id, card_num = card[0].to_i, card[1].to_i.to_s, card[2].to_i
      card_id = '0' + card_id until card_id.length >= 4
			if card_type.eql?(0)
				card_num.times do
					@dilemma_deck.place_card_on(DilemmaCard.new(card_id, @name, $pic_dir + card_id + $pic_type).face_down!)
				end
      elsif card_type.eql?(1)
        card_num.times do
          @draw_deck.place_card_on(Equipment.new(card_id, @name, $pic_dir + card_id + $pic_type).face_down!)
        end
			elsif card_type.eql?(2)
				card_num.times do
					@draw_deck.place_card_on(Event.new(card_id, @name, $pic_dir + card_id + $pic_type).face_down!)
				end
      elsif card_type.eql?(3)
        @draw_deck.place_card_on(ST_Interrupt.new(card_id, @name, $pic_dir + card_id + $pic_type).face_down!)
      elsif card_type.eql?(5)
        @draw_deck.place_card_on(Personnel.new(card_id, @name, $pic_dir + card_id + $pic_type).face_down!)
      elsif card_type.eql?(6)
        card_num.times do
          @draw_deck.place_card_on(Ship.new(card_id, @name, $pic_dir + card_id + $pic_type).face_down!)
        end
			elsif card_type.eql?(4)
				@missions << Mission.new([MissionCard.new(card_id, @name, $pic_dir + card_id + $pic_type).face_up!])
      elsif card_type.eql?(7)
        @missions << Mission.new([Headquarters.new(card_id, @name, $pic_dir + card_id + $pic_type).face_up!])
			else puts "This card type:#{card_type} doesn't exist.  That's BAD!"
			end
		end
		puts "#{@name}, you don't have 5 missions!" unless @missions.length == 5
	end
	
	def download(card)
		@mini_viewer1.place_card_on(@draw_deck.download(card))
	end
	
	def shuffle_deck
		@draw_deck.shuffle
	end
		
	def shuffle_dilemmas
		@dilemma_deck.shuffle
	end
	
	def draw_top
		@hand.place_card_on(@draw_deck.draw_from_top)
	end
	
	def draw_dilemma_top
    if @dilemma_deck.cards.first.face_up?
      self.shuffle_dilemmas
      @dilemma_deck.each {|card| card.face_down!}
    end
		@mini_viewer1.place_card_on(@dilemma_deck.draw_from_top)
	end
	
	def draw_bottom
		@hand.place_card_on(@draw_deck.draw_from_bottom)
	end
	
	def draw_dilemma_bottom
		@mini_viewer1.place_card_on(@dilemma_deck.draw_from_bottom)
	end
	
	def discard(card)
		@discard_pile.place_card_on(@hand.discard(card)) unless @hand.size == 0
	end
	
	def place_dilemma_on_top(card)
    @dilemma_deck.place_card_on(card)
	end
	
	def place_dilemma_on_bottom(card)
		card.face_up!
		@dilemma_deck.place_card_under(card.location.remove(card))
	end
	
	def place_card_draw_top(card)
		@draw_deck.place_card_on(card.face_down!)
	end
	
	def place_card_draw_bottom(card)
		card.face_down!
		@draw_deck.place_card_under(card.location.remove(card))
	end
	
	def place_card_in_hand(card)
		@hand.place_card_on(card.face_down!)
	end
	
  def draw
    self.draw_top
  end
  
end

if $0 == __FILE__
  require 'stack'
  $pic_dir = './STPics/'
  $pic_type = ".jpg"
  Player.new("Raj", File.open("borg.txt", "r"))
end
  