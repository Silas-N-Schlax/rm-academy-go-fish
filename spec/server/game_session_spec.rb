require_relative '../helpers/mock_socket_client'
require_relative '../../lib/socket_server'
require_relative '../../lib/server/game_session'
require_relative '../../lib/client'
require_relative '../../lib/player'
require_relative '../../lib/card'

describe GameSession do
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
  let(:clients) { @server.clients }
  let(:server_client1) { Client.new(clients.first.socket, player_id: 1) }
  let(:server_client2) { Client.new(clients.last.socket, player_id: 2) }
  describe '#create_game_session' do
    let!(:client1) { create_test_client }
    let!(:client2) { create_test_client }
    let(:game_session) { described_class.new }
    let(:regex) { /Hearts|Diamonds|Clubs|Spades/i }
    before do
      game_session.create_game_session([server_client1, server_client2])
    end
    it 'starts a game' do
      expected_deck_size = 38
      game_deck = game_session.game.deck
      expect(game_deck.cards_left).to eq expected_deck_size
    end
    it 'sends all users their hands' do
      expect(client1.capture_output).to match regex
      expect(client2.capture_output).to match regex
    end
    context 'when users are created' do
      it 'creates users with matching player and client' do
        user1 = game_session.users.first
        user2 = game_session.users[1]
        expect(user1.client.player_id).to eq user1.player.player_id
        expect(user2.client.player_id).to eq user2.player.player_id
      end
    end
  end
  describe '#run_turn' do
    let!(:client1) { create_test_client }
    let!(:client2) { create_test_client }
    let(:game_session) { described_class.new }
    before do
      game_session.create_game_session([server_client1, server_client2])
    end
    let!(:game) { game_session.game }
    it 'returns false if current player has not selected a player' do
      expect(game_session.run_turn).to be false
    end
    it 'returns if current player has selected a player but not rank' do
      player_rank = '0'
      client1.provide_input(player_rank)
      expect(game_session.run_turn).to be false
    end
    context 'when a turn is played' do
      let(:game) { game_session.game }
      let(:users) { game_session.users }
      let(:player1) { users.first.player }
      let(:player2) { users.last.player }
      before do
        player1.hand = [Card.new('K')]
        player2.hand = [Card.new('Q')]
        game.deck.cards = [Card.new('2')]
      end
      context 'when player has not sent both messages' do
        let(:rank_message_regex) { /what rank/i }
        let(:player_message_regex) { /who would/i }
        let(:rank_input) { 'K' }
        let(:player_id_input) { '2' }
        it 'sends a message asking for a player to ask for' do
          client1.capture_output
          game_session.run_turn
          expect(client1.capture_output).to match player_message_regex
        end
        it 'sends a message asking for a rank to ask for' do
          client1.capture_output
          client1.provide_input(rank_input)
          game_session.run_turn
          expect(client1.capture_output).to match rank_message_regex
        end
        it 'does not ask for player again' do
          game_session.selected_player_message = true
          client1.capture_output
          game_session.run_turn
          expect(client1.capture_output).to_not match player_message_regex
        end
        it 'does not ask for rank again' do
          game_session.selected_player_message = true
          game_session.selected_player = player_id_input
          game_session.selected_rank_message = true
          game_session.selected_rank = rank_input
          client1.capture_output
          game_session.run_turn
          expect(client1.capture_output).to_not match player_message_regex
        end
      end
      it 'starts a plays a turn' do
        client1.provide_input('1')
        game_session.run_turn
        client1.provide_input('Q')
        game_session.run_turn
        expected_hand_size = 2
        expect(player1.hand_size).to eq expected_hand_size
      end
      it 'updates the current player' do
        game_session.run_turn
        expected_current_user = game_session.users.first
        expect(game_session.current_user).to eq expected_current_user
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
