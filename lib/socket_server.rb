require 'socket'
require_relative 'deck'
require_relative 'player'
require_relative 'client'

# Socket Server Class
class SocketServer
  attr_accessor :server, :clients, :games

  def port_number
    3336
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def clients
    @clients ||= []
  end

  def accept_new_client
    client = @server.accept_nonblock
    clients << Client.new(client)
    client.puts 'Welcome to Go Fish!'
  rescue IO::WaitReadable, Errno::EINTR
    puts 'No Client to Accept...'
  end

  def read_socket(socket, delay = 0.7)
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
end
