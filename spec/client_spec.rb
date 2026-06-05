require_relative '../lib/client'
require_relative 'helpers/mock_socket_client'
require_relative '../lib/socket_server'

PORT_NUMBER = 3336

describe Client do
  before(:each) do
    @clients = []
    @server = SocketServer.new
    @server.start
    sleep 0.1
  end

  after(:each) do
    @server.stop
    @clients.each do |client|
      client.close
    end
  end
  describe 'initial values' do
    let(:client) { described_class.new(MockSocketClient.new(@server.port_number)) }
    it 'name and name message set to to nil' do
      expect(client.name).to be_nil
      expect(client.has_sent_name_message).to be_nil
    end
    it 'has a client socket' do
      expect(client.socket).to_not be_a TCPSocket
    end
    it 'has a host set to false' do
      expect(client.host?).to be false
    end
  end
  describe '#host?' do
    context 'when player is host' do
      let(:client) { described_class.new('socket', host: true) }
      it 'returns true' do
        expect(client.host?).to be true
      end
    end
    context 'when player is not host' do
      let(:client) { described_class.new('socket') }
      it 'returns false' do
        expect(client.host?).to be false
      end
    end
  end
  describe '#read_socket' do
    let!(:client) { Client.new(create_test_client) }
    let(:message) { 'Hello World!' }
    context 'when message exists' do
      before do
        server_client_socket = @server.clients.first.socket
        @server.write_socket(server_client_socket, message)
      end
      it 'returns message' do
        expect(client.read_socket.chomp).to eq message
      end
    end
  end

  describe '#write_socket' do
    let!(:client) { Client.new(create_test_client) }
    let(:message) { 'Hello World!' }
    context 'when a message is sent' do
      before do
        client.write_socket(message)
      end
      it 'the server gets the message' do
        server_client_socket = @server.clients.first.socket
        expect(@server.read_socket(server_client_socket).chomp).to eq message
      end
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
