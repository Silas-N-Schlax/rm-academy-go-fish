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
    let(:client) { described_class.new(MockSocketClient.new(@server.port_number), player_id: 0) }
    it 'name and name message set to to nil' do
      expected_name = 'Player 0'
      expect(client.name).to eq expected_name
      expect(client.has_sent_name_message).to be_nil
    end
    it 'has a client socket' do
      expect(client.socket).to_not be_a TCPSocket
    end
    it 'has a host set to false' do
      expect(client.host?).to be false
    end
    it 'has a id number' do
      expect(client.player_id).to be_zero
    end
  end
  describe '#host?' do
    context 'when player is host' do
      let(:client) { described_class.new('socket', host: true, player_id: 0) }
      it 'returns true' do
        expect(client.host?).to be true
      end
    end
    context 'when player is not host' do
      let(:client) { described_class.new('socket', player_id: 0) }
      it 'returns false' do
        expect(client.host?).to be false
      end
    end
  end
  describe '#read_socket' do
    let!(:client) { create_test_client }
    let(:server_client) { Client.new(@server.clients.first.socket, player_id: 0) }
    let(:message) { 'Hello World!' }
    context 'when message exists' do
      before do
        client.provide_input(message)
      end
      it 'returns message' do
        expect(server_client.read_socket.chomp).to eq message
      end
    end
  end

  describe '#write_socket' do
    let!(:client) { create_test_client }
    let(:server_client) { Client.new(@server.clients.first.socket, player_id: 0) }
    let(:message) { 'Hello World!' }
    context 'when a message is sent' do
      before do
        server_client.write_socket(message)
      end
      it 'the client gets the message' do
        expect(client.capture_output.chomp).to eq message
      end
    end
  end
  describe '#ask_socket' do
    let!(:client) { create_test_client }
    let(:server_client) { Client.new(@server.clients.first.socket, player_id: 0) }
    context 'when a message is sent' do
      before do
        message = 'Hello World!'
        server_client.ask_socket(message)
      end
      it 'the client gets the message' do
        regex = /->/i
        expect(client.capture_output.chomp).to match regex
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
