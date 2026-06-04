require_relative 'card'
# Deck class
class Deck
  attr_accessor :cards

  def initialize
    @cards = Card::RANKS.flat_map do |rank|
      Card::SUITS.map do |suit|
        Card.new(rank, suit)
      end
    end
  end

  def cards_left
    cards.size
  end

  def top_card
    cards.shift
  end

  def shuffle_deck
    new_deck = cards.dup.shuffle!
    shuffle_deck if new_deck == cards

    self.cards = new_deck
  end
end
