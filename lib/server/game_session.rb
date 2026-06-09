require_relative '../../lib/go_fish_game'
require_relative '../../lib/server/user'
# GameSession class
class GameSession
  attr_accessor :game, :current_user, :selected_player,
                :selected_player_message, :selected_rank,
                :selected_rank_message
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
    update_current_user
    return false unless ask_for_player
    return false unless ask_for_rank

    game.run_turn(selected_player.to_i, selected_rank)
    users.each do |users|
      users.client.write_socket(game.results.for_current)
    end
    reset_message_state
  end

  private

  def reset_message_state
    self.selected_player = nil
    self.selected_player_message = nil
    self.selected_rank = nil
    self.selected_rank_message = nil
  end

  def ask_for_player
    return selected_player if selected_player

    client = current_user.client
    message = 'Who would you like to ask?'
    client.ask_socket(message) unless selected_player_message
    self.selected_player_message = true
    has_message = client.read_socket
    self.selected_player = has_message&.chomp
  end

  def ask_for_rank
    return selected_rank if selected_rank

    client = current_user.client
    message = 'What rank would you like to ask for?'
    client.ask_socket(message) unless selected_rank_message
    self.selected_rank_message = true
    has_message = client.read_socket
    self.selected_rank = has_message&.chomp
  end

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
