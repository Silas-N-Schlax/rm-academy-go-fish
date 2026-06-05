require_relative 'books'
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

  def take_cards_of_rank(rank)
    find_by_rank = ->(card) { card.rank == rank }

    cards_of_rank = hand.select(&find_by_rank)
    hand.delete_if(&find_by_rank)

    cards_of_rank
  end

  # TODO: #has_card? (check that the player has at least one of the card with the rank given).

  def create_book(book_rank)
    books << Book.new(book_rank)
  end

  def books_size
    books.size
  end

  private

  def delete_cards(cards)
    # ! Remove?
    cards.each do |card|
      hand.delete(card)
    end
  end
end
