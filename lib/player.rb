require_relative 'books'
# Player class
class Player
  attr_reader :name, :player_id
  attr_accessor :hand, :books

  def initialize(name, player_id)
    @name = name
    @player_id = player_id
    @hand = []
    @books = []
  end

  def add_cards(cards)
    cards.each { |card| hand.push(card) }
    create_book_if_possible
  end

  def hand_size
    hand.size
  end

  def format_hand
    message_ary = ["#{name}, you have the following cards in your hand:"]
    hand.each do |card|
      message_ary << "- #{card}"
    end
    message_ary
  end

  def take_cards_of_rank(rank)
    find_by_rank = ->(card) { card.rank == rank }

    cards_of_rank = hand.select(&find_by_rank)
    hand.delete_if(&find_by_rank)

    cards_of_rank
  end

  def books_size
    books.size
  end
  # TODO: #has_card? (check that the player has at least one of the card with the rank given).

  private

  def create_book_if_possible
    hand.group_by(&:rank).each do |group|
      card_group = group.last
      create_book(group.first) if card_group.length == 4
    end
    books.last
  end

  def create_book(book_rank)
    books << Book.new(book_rank)
    take_cards_of_rank(book_rank)
  end
end
