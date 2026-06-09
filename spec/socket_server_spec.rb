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
      it 'sends both players a message and creates a game session' do
        @server.create_game_if_possible
        expected_game_size = 1
        expect(client1.capture_output).to match(/starting/i)
        expect(client2.capture_output).to match(/starting/i)
        expect(@server.games.count).to eq expected_game_size
      end
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
