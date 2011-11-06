require 'drb'
require 'yaml'

# The card class is the most basic class implemented for the STCCG.
# Implements a card, initialized with the cards cid, the name of the owner of the card
# and the image file that holds the picture of the cardface.
class Card
  include DRbUndumped
  attr_reader :cost, :title, :text, :face, :stopped
	attr_accessor :cid, :owner, :commander, :location

	def initialize(id, owner, face)
    @@cardback = "#{$pic_dir}cardback#{$pic_type}"
		@cid = id
		@commander = @owner = owner
		@face = face
		@status = :face_down
		@in_play = false
    @stopped = false
    @location = nil
	end
	
	#Returns the status as a string
	def status
		@status.to_s
	end
	
	#Sets IN_PLAY to TRUE
	def in_play!
		@in_play = true
		self
	end
  
	#Sets IN_PLAY to FALSE
	def not_in_play!
		@in_play = false
		self
	end
  
	# Returns TRUE if the card is in play
	def in_play?
		@in_play
	end
  
	#Returns TRUE if card is not in play
	def not_in_play?
		not @in_play
	end
  
	# Returns TRUE if the card is FACE_UP
	def face_up?
		if @status == :face_up
			true
		elsif @status == :face_down
			false
		else
			puts "Big problem with face_up"
		end		
	end
  
	# Returns TRUE if the card is FACE_DOWN
	def face_down?
		not face_up?
	end
  
	#Sets card STATUS to FACE_UP
	def face_up!
		@status = :face_up
		self
	end
	  
	#Sets card STATUS to FACE_DOWN
	def face_down!
		@status = :face_down
		self
	end
	
	#Changes the commander of the card
	def change_commander_to!(commander)
		@commander = commander
	end
  
	def Card.back
    @@cardback
  end
  
  #returns the card's back image
	def back
		@@cardback
	end
	
  def flip
    @status = self.face_up? ? :face_down : :face_up
  end
  
  def stop
    @stopped = true
  end
  
  def unstop
    @stopped = false
  end
  
  def to_s
    "#{self.class} ID:#{@cid} Owner:#{@owner} Commander:#{@commander} Location:#{@location}"
  end
	
  def to_yaml_properties
    %w{@cid @owner @face @commander @status @in_play @location}
  end
end

class Array
  #shuffles an array
	def shuffle
		original_size = self.length
		temp_array = Array.new(array)
		self.clear
		until self.length.eql?(original_size)
			self << temp_array.slice!(rand(temp_array.length))
		end
		self
	end
  
  #circular NEXT method for arrays
  def next(index)
    index.next unless index == self.length
    0
  end

  def delete_first_if
    self.each_with_index do |element, index|
      if yield element
        return self.delete_at(index)
      end
    end
  end
  
  def delete_last_if
    self.reverse_each do |element|
      if yield element
        return self.delete_at(self.rindex(element))
      end
    end
  end
end

class String  
  #returns the line number that contains str, or returns nil if str is not in String
	def line_number_containing(str)
		number = 0
		if self.include?(str)
			self.each_line do |line|
				if line.include?(str)
					return number
				else
					number = number.next
				end
			end
		else
			return nil
		end
	end
end

class Placeable < Card
  attr_accessor :aboard
  def initialize(id, owner, face)
    super(id, owner, face)
    @aboard = nil
  end
  
  def to_s
    super + " Aboard:#{@aboard}"
  end
  
  def to_yaml_properties
    super.concat(%w{@aboard})
  end
end


#For all cards that are Dilemmas
class DilemmaCard < Placeable
  attr_reader :type
	def initialize(id, owner, face)
    super(id, owner, face)
    @type = nil
  end

	#Returns the dilemma type
	def type
		@type
	end
	
end

# For all cards that are Events
#Plays_in may contain [:core, :planet, :space, :ship]
class Event < Placeable
  
end

# For all cards that are Personnel
# KEYWORDS and SKILLS are arrays
# Keyword (include all affiliations, and species) - :alpha, :gamma, :delta,
# :alternate, :ds9, :earth, :maquis, :terok_nor, :tng, :command, :staff
# Affiliation types - :bajoran, :borg, :cardassian, :dominion, 
# :federation, :ferengi, :klingon, :non_aligned, :romulan
class Personnel < Placeable
end


#For all cards that are Missions
class MissionCard<Card
  def initialize(id, owner, face)
    super(id, owner, face)
    @status = :face_up
  end
  
  def flip
    @status = :face_up
  end
  
  def stop
    @stopped = false
  end
  
  def unstop
    @stopped = false
  end
    
end

class Headquarters < MissionCard
end

class Ship < Card
  attr_accessor :crew
  
  def initialize(id, owner, face)
    super(id, owner, face)
    @crew = []
  end
  
  def beam(card)
    puts "CRAP, card is an array\n#{card}" if card.kind_of?(Array)
    card.aboard = self
    @crew.concat([card].flatten)
    self
  end
  
  def to_yaml_properties
    super.concat(%w{@crew})
  end
  
end

class Equipment < Placeable
end

class ST_Interrupt < Placeable
end
