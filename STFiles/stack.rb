require 'card'
require 'drb'
require 'fox16'
include Fox

class Fox::FXJPGIcon
  include DRbUndumped
end

class Stack
	attr_accessor :cards, :icon
	include Enumerable
  include DRbUndumped
  
	def initialize(card_array = Array.new, icon = nil)
		@cards = card_array
    @icon = icon #icon representing stack
    @stopped = false
	end
  
	def at(number)
		@cards.at(number)
	end
	
  def each
    @cards.each{|card| yield card}
  end

	def find_card(card)
		if @cards.include?(card)
			@cards.index(card)
		else
			nil
		end
	end
	
	def find_card_id(card_id)
		@cards.each_with_index do |card, index|
			return card if card_id == card.cid
		end
			nil	
	end
	
  def flip(card)
    @cards[@cards.index(card)].flip
  end
  
  def flip_all
    self.each {|card| card.flip}
  end
  
  def get_class
    self.class.to_s
  end
  
  def insert(index, cards)
    @cards.insert(index, cards)
  end
  
	def length
		@cards.length
	end
	
  def orbit?
    self.kind_of?(Orbit)
  end
  
	def place_card_on(card)
    puts "CRAP, card is an array\n#{card}" if card.kind_of?(Array)
    card.location = self
		@cards.unshift(card)
	end
  
	def place_card_under(card)
		@cards << card
	end

	def remove(card)
    @cards.delete(card)
	end
	
	def size
		@cards.length
	end
	
	#Returns an array containing any cards that have the keyword
	def search_for_keyword(keyword)
		temp = Array.new
		@cards.each do |card|
			temp << card if card.keywords.contains(keyword)
		end
		temp
	end
  
	def shuffle
		original_size = @cards.length
		temp_array = Array.new(@cards)
		@cards.clear
		until @cards.length.eql?(original_size)
			@cards << temp_array.slice!(rand(temp_array.length))
		end
		return @cards
	end

  def slice(index)
    @cards.slice(index)
  end
    
  def slice!(index)
    @cards.slice!(index)
  end
  
  def stop(card)
    self.find_card_id(card.cid).stop
  end

  def stopped?
    @stopped
  end
    
  def stop_all
    @stopped = true
    self.each {|card| card.stop}
  end
  
  def top_ship
    @cards.each{|card| return card if card.kind_of? Ship}
    nil
  end
  
  def unstop(card)
    self.find_card_id(card.cid).unstop
  end
  
  def unstop_all
    @stopped = false
    self.each{|card| card.unstop}
  end
  
end


class Deck < Stack
  
	def draw_from_top
		self.cards.shift
	end
  
	def draw_from_bottom
		self.cards.pop
	end
	
	def include?(card)
		self.cards.include?(card)
	end
		
	def download(card)
		self.shuffle
		self.remove(card)
	end	
  
  def [](num)
    @cards[num]
  end
  
end

class Core < Stack
	def place_card_on(card)
    super(card.face_up!)
	end
  
	def place_card_under(card)
    super(card.face_up!)
	end
end

class Hand < Stack
	def discard(card)
		card.face_up!
		self.remove(card)
	end
  
	def draw(deck)
		self.place_card_on(deck.draw_from_top)
	end
end

class Mission < Stack
  attr_reader :mission_index
  
	def initialize(card_array = Array.new)
		super(card_array)
		@mission_index = 0
		@mission = card_array[0]
	end
	
	def face
		@mission.face
	end
  
  def place_card_on(card)
    if card.kind_of?(DilemmaCard)
      card.face_up!
      self.place_card_under(card)
    else
      card.aboard.crew.delete(card) if card.aboard
      card.aboard = nil
      @mission_index += 1
      super(card)
    end
  end
  
  def remove(card)
    @mission_index += (@cards.rindex(card) > @mission_index ? 0 : -1)
    super(card)
  end
  
end

class Orbit < Stack
  
  def each_ship
    @cards.each {|card| yield card if card.kind_of? Ship}
  end
  
  def place_card_on(card)
    if card.kind_of?(Ship)
      card.face_up!
      stack = card.location
      card.crew.each{|member| super(stack.remove(member))}
    elsif self.top_ship and card.class != Ship and card.aboard != self.top_ship
      card.aboard.crew.delete(card) if card.aboard
      self.top_ship.beam(card)
    end
    super(card)
  end
  
  def remove(card)
    super(card)
  end
end

class DiscardPile < Stack
  def place_card_on(card)
    super(card)
    card.face_up!
    card.aboard = nil unless card.kind_of?(Ship)
  end
  
	def place_card_under(card)
		super(card)
    card.face_down!
    card.aboard = nil
	end
  
end

class MiniViewer < Stack
  def place_card_on(card)
    if card.kind_of?(Ship)
      stack = card.location
      card.crew.each{|mem| super(stack.remove(mem))}
    elsif self.top_ship and card.class != Ship and card.aboard != self.top_ship
      self.top_ship.beam(card)
    end
    super(card)
  end
end

if $0 == __FILE__
  mars = Orbit.new
  ship = Ship.new(1221, "Raj", "1221.jpg")
  cards = Array.new(2){Personnel.new(1220, "Raj", "1220.jpg")}
  
  mars.place_card_on(ship)
  cards.each do |card| 
    mars.place_card_on(card)
  end
  puts "Ship is crewed by: #{ship.crew.join(', ')}"
  puts "Around mars: #{mars.cards}"
  
  mission = Mission.new
  mission.place_card_on(mars.remove(ship.crew[0]))
  puts "\nShip is crewed by: #{ship.crew.join(', ')}"
  puts "Around mars: #{mars.cards}"
  puts "At mission: #{mission.cards}"
  
  earth = Orbit.new
  earth.place_card_on(mars.remove(ship))
  puts "\nAround mars: #{mars.cards}"
  puts "Around earth: #{earth.cards}"
  puts "At mission: #{mission.cards}"
  puts "Ship is crewed by: #{ship.crew.join(', ')}"
  
end
