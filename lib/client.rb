# Client Socket
class Client
  attr_accessor :name, :has_sent_name_message, :host_message,
                :selected_player, :selected_player_message,
                :selected_rank, :selected_rank_message
  attr_reader :socket, :host, :player_id

  INPUT_SYMBOL = ' -> '.freeze

  def initialize(socket, player_id: nil, host: false)
    @socket = socket
    @host = host
    @host_message = false
    @player_id = player_id
  end

  def host?
    host
  end

  def ask_for_player
    return selected_player if selected_player

    message = 'Who would you like to ask?'
    write_socket(message + INPUT_SYMBOL) unless selected_player_message
    self.selected_player_message = true
    has_message = read_socket
    self.selected_player = has_message&.chomp
  end

  def ask_for_rank
    return selected_rank if selected_rank

    message = 'What rank would you like to ask for?'
    write_socket(message + INPUT_SYMBOL) unless selected_rank_message
    self.selected_rank_message = true
    has_message = read_socket
    self.selected_rank = has_message&.chomp
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
end
