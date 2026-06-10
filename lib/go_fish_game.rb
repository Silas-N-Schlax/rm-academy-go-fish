require_relative 'player'
require_relative 'deck'
require_relative 'turn_results'
require_relative 'card'

SMALL_HAND = 5
LARGE_HAND = 7
SMALL_GAME_MAX_SIZE = 3
LARGE_GAME_MAX_SIZE = 6

# Go Fish Game Class
class GoFishGame
  attr_accessor :players, :deck, :results, :current_player_idx

  def initialize(new_players)
    @players = create_players(new_players)
    @deck = Deck.new
    @current_player_idx = 0
  end

  def start
    deck.shuffle_deck
    deal
  end

  def run_turn(player_id, rank)
    return if winner
    return nil unless find_player(player_id)

    player_in_question = find_player(player_id)
    cards = player_in_question.take_cards_of_rank(rank)
    current_player.add_cards(cards) unless cards.empty?
    fishing_card = go_fish(rank) if cards.empty?
    generate_turn_result(player_in_question, rank, cards, fishing_card, false)
  end

  def winner
    winning_player if deck.empty? && players.all?(&:empty_hand?)
  end

  def current_player
    players[current_player_idx]
  end

  def find_player(player_id_to_find)
    players.each do |player|
      return player if player.player_id == player_id_to_find
    end
    nil
  end

  def valid_player?(player_id)
    return false if player_id == current_player.player_id
    return true if players.any? { |player| player.player_id == player_id }

    false
  end

  def valid_rank?(rank)
    Card.valid_rank?(rank)
  end

  def cards?(rank)
    current_player.cards?(rank)
  end

  def turn_skipped?
    return true if deck.empty? && current_player.empty_hand?

    false
  end

  private

  def winning_player
    winning_players = []
    players.each do |player|
      winning_players << player if winning_players.empty? || winning_players.first.books_size == player.books_size
      winning_players = [player] if player.books_size > winning_players.first.books_size
    end
    return player_highest_book_rank(winning_players) if winning_players.size > 1

    winning_players.first
  end

  def player_highest_book_rank(tied_players)
    current_winner = [nil, nil]
    tied_players.each do |player|
      player.books.each do |book|
        current_winner = [player, book] if current_winner[1].nil? || book.value > current_winner[1].value
      end
    end
    current_winner.first
  end

  def generate_turn_result(opponent, rank, cards, card_picked_up, goes_again)
    self.results = TurnResults.new(
      {
        current_player: current_player, opponent: opponent,
        card_asked_for: rank, cards_taken: cards,
        card_picked_up: card_picked_up, goes_again: goes_again
      }
    )
  end

  def go_fish(rank)
    card = deck.top_card
    return players.rotate! if card.nil?

    current_player.add_cards([card])
    update_current_player unless card.rank == rank
    card
  end

  def update_current_player
    new_index = current_player_idx + 1
    first_player_idx = 0
    self.current_player_idx = new_index > players.size ? first_player_idx : new_index
  end

  def deal
    number_of_cards_to_deal.times do
      players.each do |player|
        player.add_cards([deck.top_card])
      end
    end
  end

  def number_of_cards_to_deal
    return LARGE_HAND if players.size <= SMALL_GAME_MAX_SIZE

    SMALL_HAND if players.size > SMALL_GAME_MAX_SIZE && players.size <= LARGE_GAME_MAX_SIZE
  end

  def create_players(new_players)
    players = []
    new_players.shift(6).each do |player|
      players << Player.new(player[:name], player[:player_id])
    end
    players
  end
end
