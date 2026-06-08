require 'socket'
require_relative '../lib/socket_server'
require_relative 'helpers/mock_socket_client'
require_relative '../lib/card'

describe SocketServer do
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

  it 'is not listening on a port before it is started' do
    @server.stop
    expect { MockSocketClient.new(@server.port_number) }.to raise_error(Errno::ECONNREFUSED)
  end

  describe '#accept_new_client' do
    context 'when the first player joins' do
      let(:client1) { MockSocketClient.new(@server.port_number) }
      before do
        @clients.push client1
        @server.accept_new_client
        sleep 0.3
      end
      it 'clients get a welcome message' do
        expect(client1.capture_output).to match(/welcome/i)
      end
      it 'adds client to clients array' do
        expected_clients = 1
        expect(@server.clients.size).to eq expected_clients
      end
      it 'is defined as host' do
        client = @server.clients.first
        expect(client.host).to be true
      end
      it 'has an id of 0' do
        client = @server.clients.first
        expected_player_id = 1
        expect(client.player_id).to eq expected_player_id
      end
    end
  end
  describe '#run_turn' do
    let!(:client1) { create_test_client }
    let!(:client2) { create_test_client }
    before do
      @server.create_game_if_possible
    end
    let!(:game) { @server.games.first }
    it 'returns false if current player has not selected a player' do
      expect(@server.run_turn(game)).to be false
    end
    it 'returns if current player has selected a player but not rank' do
      client1.provide_input('0')
      expect(@server.run_turn(game)).to be false
    end
    context 'when a turn is played' do
      let(:game) { @server.games.first }
      let(:player1) { game.players.first }
      let(:player2) { game.players.last }
      before do
        player1.hand = [Card.new('K')]
        player2.hand = [Card.new('Q')]
        game.deck.cards = [Card.new('2')]
      end
      it 'starts a plays a turn' do
        client1.provide_input('1')
        @server.run_turn(game)
        client1.provide_input('Q')
        @server.run_turn(game)
        expected_hand_size = 2
        expect(player1.hand_size).to eq expected_hand_size
      end
    end
  end

  describe '#create_game_if_possible' do
    context 'when 1 player' do
      let!(:client) { create_test_client }
      it 'does not create game' do
        @server.create_game_if_possible
        expect(@server.games.count).to be_zero
      end
    end
    context 'when 2 players' do
      let!(:client1) { create_test_client }
      let!(:client2) { create_test_client }
      let(:regex) { /Hearts|Diamonds|Clubs|Spades/i }
      it 'sends both players a message and creates game' do
        @server.create_game_if_possible
        expected_game_size = 1
        expect(client1.capture_output).to match(/starting/i)
        expect(client2.capture_output).to match(/starting/i)
        expect(@server.games.count).to eq expected_game_size
      end
      it 'sends all users their hands' do
        @server.create_game_if_possible
        expect(client1.capture_output).to match regex
        expect(client2.capture_output).to match regex
      end
    end
  end
  describe '#read_socket' do
    let!(:client) { create_test_client }
    it 'gets message sent to server' do
      server_client = @server.clients.first
      @server.write_socket(server_client.socket, 'message')
      expect(@server.read_socket(client.socket)).to match(/message/i)
    end
  end

  describe '#write_socket' do
    let!(:client) { create_test_client }
    it 'sends a message to the socket' do
      server_client = @server.clients.first
      @server.write_socket(server_client.socket, 'test')
      expect(client.capture_output).to match(/test/i)
    end
  end

  def create_test_client
    client = MockSocketClient.new(@server.port_number)
    @clients.push(client)
    @server.accept_new_client
    sleep 0.1
    client.capture_output
    client
  end
end
