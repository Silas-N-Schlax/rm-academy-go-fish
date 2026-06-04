# Card Class
class Card
  attr_reader :rank, :suit

  class InvalidRank < StandardError; end
  class InvalidSuit < StandardError; end

  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  SUITS = %w[Spades Hearts Diamonds Clubs].freeze

  def initialize(rank, suit)
    raise InvalidRank unless RANKS.include?(rank)
    raise InvalidSuit unless SUITS.include?(suit)

    @rank = rank
    @suit = suit
  end

  def ==(other)
    rank == other.rank && suit == other.suit
  end
end
