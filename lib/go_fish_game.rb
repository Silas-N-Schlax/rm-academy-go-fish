require_relative 'player'
require_relative 'deck'
require_relative 'turn_results'

SMALL_HAND = 5
LARGE_HAND = 7
SMALL_GAME_MAX_SIZE = 3
LARGE_GAME_MAX_SIZE = 6

# Go Fish Game Class
class GoFishGame
  attr_accessor :players, :deck, :results

  def initialize(new_players)
    @players = create_players(new_players)
    @deck = Deck.new
  end

  def start
    deck.shuffle_deck
    deal
  end

  def run_turn(player_id, rank)
    return nil unless find_player(player_id)

    # TODO: create a method that validates input that is called
    # by the server returning errors or messages etc...

    player_in_question = find_player(player_id)
    cards = player_in_question.take_cards_of_rank(rank)
    current_player.add_cards(cards) unless cards.empty?
    fishing_card = go_fish(rank) if cards.empty?
    generate_turn_result(player_in_question, rank, cards, fishing_card, false)
    # TODO: update to dynamic
  end

  def current_player
    players.first
  end

  def find_player(player_id_to_find)
    players.each do |player|
      return player if player.player_id == player_id_to_find
    end
    nil
  end

  private

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
    players.rotate! unless card.rank == rank
    card
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
