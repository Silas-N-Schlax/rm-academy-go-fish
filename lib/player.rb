# Player class
class Player
  attr_reader :name
  attr_accessor :hand, :books

  def initialize(name)
    @name = name
    @hand = []
    @books = []
  end

  def add_cards(cards)
    cards.each { |card| hand.push(card) }
  end

  def next_card
    hand.first
  end

  def take_top_card
    hand.shift
  end

  def hand_size
    hand.size
  end
end
