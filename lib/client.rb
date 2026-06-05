# Client Socket
class Client
  attr_accessor :name, :has_sent_name_message
  attr_reader :socket, :host

  def initialize(socket, host: false)
    # binding.irb
    @socket = socket
    @host = host
  end

  def host?
    host
  end

  def read_socket(delay = 0.7)
    sleep(delay)
    socket.socket.read_nonblock(1000)
  rescue IO::WaitReadable
    nil
  end

  def write_socket(message)
    socket.socket.puts message
  end
end
