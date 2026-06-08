require 'socket'
require_relative 'go_fish_game'
require_relative 'client'

MIN_GAME_SIZE = 2
MAX_GAME_SIZE = 6
INPUT_SYMBOL = ' -> '.freeze

# Socket Server Class
class SocketServer
  attr_accessor :server, :clients, :games, :game_size

  def port_number
    3336
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def games
    @games ||= []
  end

  def clients
    @clients ||= []
  end

  def accept_new_client
    client = @server.accept_nonblock
    clients << Client.new(client, host: host?, player_id: create_player_id)
    client.puts 'Welcome to Go Fish!'
  rescue IO::WaitReadable, Errno::EINTR
    # puts 'No Client to Accept...'
  end

  def create_game_if_possible
    return unless clients.count == MIN_GAME_SIZE

    clients.each do |client|
      message_to_users = 'The Go Fish Game is Starting...'
      write_socket(client.socket, message_to_users)
    end

    create_game
  end

  def run_game(game)
    run_turn(game) until true == false
  end

  def run_turn(game)
    current_player = current_player(game)
    return false unless current_player.ask_for_player
    return false unless current_player.ask_for_rank

    game.run_turn(current_player.selected_player.to_i, current_player.selected_rank)
    @clients.each do |client|
      client.write_socket(game.results.for_current)
    end
  end

  def read_socket(socket, delay = 1)
    sleep(delay)
    socket.read_nonblock(1000)
  rescue IO::WaitReadable
    nil
  end

  def write_socket(socket, message)
    socket.puts message
  end

  def stop
    @server&.close
  end

  private

  def current_player(game)
    current_player_turn = game.current_player.player_id
    clients.select { |client| client.player_id == current_player_turn }.first
  end

  def create_game
    game = GoFishGame.new(create_client_data_hash)
    game.start
    games << game
    send_hands_to_players
    game
  end

  def create_client_data_hash
    data_hash = []
    clients.map do |client|
      data_hash << { name: client.name, player_id: client.player_id }
    end
    data_hash
  end

  def send_hands_to_players
    clients.each do |client|
      player = games.first.find_player(client.player_id)
      client.write_socket(player.format_hand)
    end
  end

  def host?
    clients.empty?
  end

  def create_player_id
    @clients.size + 1
  end
end
