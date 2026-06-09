# Client Socket
class Client
  attr_accessor :name, :has_sent_name_message, :host_message
  attr_reader :socket, :host, :player_id

  INPUT_SYMBOL = ' -> '.freeze

  def initialize(socket, player_id: nil, host: false)
    @socket = socket
    @host = host
    @host_message = false
    @player_id = player_id
    @name = "Player #{player_id}"
  end

  def host?
    host
  end

  def read_socket(delay = 0.3)
    sleep(delay)
    socket.read_nonblock(1000)
  rescue IO::WaitReadable
    nil
  end

  def write_socket(message)
    socket.puts message
  end

  def ask_socket(message)
    socket.puts message + INPUT_SYMBOL
  end
end
