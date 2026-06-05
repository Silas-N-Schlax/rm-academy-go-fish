require_relative 'player'
require_relative 'deck'

SMALL_HAND = 5
LARGE_HAND = 7
SMALL_GAME_MAX_SIZE = 3
LARGE_GAME_MAX_SIZE = 6

# Go Fish Game Class
class GoFishGame
  attr_accessor :players, :deck

  def initialize(new_players)
    @players = create_players(new_players)
    @deck = Deck.new
  end

  def start
    deck.shuffle_deck
    deal
  end

  def run_turn(player, rank)
    return nil unless find_player(player)

    # TODO: create a method that validates input that is called
    # by the server returning errors or messages etc...

    player_in_question = find_player(player)
    cards = player_in_question.take_cards_of_rank(rank)

    current_player.add_cards(cards) unless cards.empty?
    go_fish(rank) if cards.empty?
  end

  def current_player
    players.first
  end

  private

  def go_fish(rank)
    card = deck.top_card
    return players.rotate! if card.nil?

    current_player.add_cards([card])
    players.rotate! unless card.rank == rank
  end

  def find_player(player_to_find)
    players.each do |player|
      return player if player.name == player_to_find
    end
    nil
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
    new_players.shift(6).map do |player|
      Player.new(player)
    end
  end
end
