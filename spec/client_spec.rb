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
      expect(client.player_id).to eq 0
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
  describe '#ask_for_player' do
    context 'when player is asked' do
      let!(:client) { create_test_client }
      let(:server_client) { Client.new(@server.clients.first.socket, player_id: 1) }
      before do
        server_client.ask_for_player
      end
      it 'sends message to player' do
        expect(client.capture_output).to match(/who/i)
      end
      it 'does not send message again' do
        client.capture_output
        server_client.ask_for_player
        expect(client.capture_output).to eq ''
      end
      it 'returns nil if no response' do
        expect(server_client.ask_for_player).to be nil
      end
      it 'returns input when gets response' do
        expected_message = '0'
        client.provide_input(expected_message)
        expect(server_client.ask_for_player).to eq expected_message
        expect(server_client.selected_player).to eq expected_message
      end
    end
    context 'when player is asked for a player again' do
      let!(:client) { create_test_client }
      let(:server_client) { Client.new(@server.clients.first.socket, player_id: 1) }
      before do
        client.provide_input('0')
        server_client.ask_for_player
      end
      it 'does not set to nil' do
        server_client.ask_for_player
        expect(server_client.selected_player).to_not be_nil
      end
    end
  end
  describe '#ask_for_rank' do
    context 'when player is asked' do
      let!(:client) { create_test_client }
      let(:server_client) { Client.new(@server.clients.first.socket, player_id: 1) }
      before do
        server_client.ask_for_rank
      end
      it 'sends message to player' do
        expect(client.capture_output).to match(/rank/i)
      end
      it 'does not send message again' do
        client.capture_output
        server_client.ask_for_rank
        expect(client.capture_output).to eq ''
      end
      it 'returns nil if no response' do
        expect(server_client.ask_for_rank).to be nil
      end
      it 'returns input when gets response' do
        expected_message = 'A'
        client.provide_input(expected_message)
        expect(server_client.ask_for_rank).to eq expected_message
        expect(server_client.selected_rank).to eq expected_message
      end
    end
    context 'when player is asked for a rank again' do
      let!(:client) { create_test_client }
      let(:server_client) { Client.new(@server.clients.first.socket, player_id: 1) }
      before do
        client.provide_input('0')
        server_client.ask_for_rank
      end
      it 'does not set to nil' do
        server_client.ask_for_rank
        expect(server_client.selected_rank).to_not be_nil
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
