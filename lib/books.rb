RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze

# Book class
class Book
  attr_reader :rank, :value

  def initialize(rank)
    @rank = rank
    @value = value_of_rank
  end

  def value_of_rank
    RANKS.index(rank)
  end
end
