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

  def try_to_find_cards(rank)
    cards = []
    hand.each do |card|
      cards << card if card.rank == rank
    end
    delete_cards(cards)
    cards unless cards.empty?
  end

  def create_book(book_rank)
    books << Book.new(book_rank)
  end

  def books_size
    books.size
  end

  private

  def delete_cards(cards)
    cards.each do |card|
      hand.delete(card)
    end
  end
end
