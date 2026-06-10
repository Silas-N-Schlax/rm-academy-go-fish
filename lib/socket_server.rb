require 'socket'
require_relative 'go_fish_game'
require_relative 'client'
require_relative 'server/game_session'

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
      client.write_socket(message_to_users)
    end

    generate_game_session
  end

  def run_game(game_session)
    game_session.play_game
  end

  def stop
    @server&.close
  end

  private

  def generate_game_session
    game = GameSession.new
    game.create_game_session(clients)
    # TODO: Shift bang when creating?
    games << game
    game
  end

  def host?
    clients.empty?
  end

  def create_player_id
    @clients.size + 1
  end
end
