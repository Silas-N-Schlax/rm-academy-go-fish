require_relative '../../lib/go_fish_game'
require_relative '../../lib/server/user'
# GameSession class
class GameSession
  attr_accessor :game, :current_user
  attr_reader :clients

  def users
    @users ||= []
  end

  def create_game_session(clients)
    self.game = GoFishGame.new(create_client_data_hash(clients))
    game.start
    create_users(clients)
    send_hands_to_players
    game
  end

  def play_game
    run_turn until true == false
  end

  def run_turn
    current_client = update_current_user.client
    return false unless current_client.ask_for_player
    return false unless current_client.ask_for_rank

    game.run_turn(current_client.selected_player.to_i, current_client.selected_rank)
    users.each do |users|
      users.client.write_socket(game.results.for_current)
    end
  end

  private

  def update_current_user
    current_player = game.current_player
    self.current_user = users.select { |user| user.player.object_id.equal?(current_player.object_id) }.first
  end

  def create_users(clients)
    game_player = game.players
    clients.each do |client|
      player = game_player.select do |player|
        player.player_id == client.player_id
      end
      users << User.new(client, player.first)
    end
  end

  def create_client_data_hash(clients)
    data_hash = []
    clients.map do |client|
      data_hash << { name: client.name, player_id: client.player_id }
    end
    data_hash
  end

  def send_hands_to_players
    users.each do |user|
      user.client.write_socket(user.player.format_hand)
    end
  end
end
