require 'socket'
require_relative '../lib/socket_server'
require_relative 'helpers/mock_socket_client'

describe SocketServer do
  before(:each) do
    @clients = []
    @server = SocketServer.new
    @server.start
    sleep 0.1 # Ensure server is ready for clients
  end

  after(:each) do
    @server.stop
    @clients.each do |client|
      client.close
    end
  end

  it 'is not listening on a port before it is started' do
    @server.stop
    expect { MockSocketClient.new(@server.port_number) }.to raise_error(Errno::ECONNREFUSED)
  end
  it 'clients get a welcome message' do
    client1 = MockSocketClient.new(@server.port_number)
    @clients.push client1
    @server.accept_new_client
    expect(client1.capture_output).to match(/welcome/i)
  end

  describe '#read_socket' do
    let!(:client) { create_test_client }
    it 'gets message sent to server' do
      @server.write_socket(@server.clients.first, 'message')
      expect(@server.read_socket(client.socket)).to match(/message/i)
    end
  end

  describe '#write_socket' do
    let!(:client) { create_test_client }
    it 'sends a message to the socket' do
      # binding.irb
      @server.write_socket(@server.clients.first, 'test')
      expect(client.capture_output).to match(/test/i)
    end
  end

  def create_test_client
    client = MockSocketClient.new(@server.port_number)
    @clients.push(client)
    @server.accept_new_client
    client.capture_output
    client
  end
end
