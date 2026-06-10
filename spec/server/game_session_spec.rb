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
    let(:game) { game_session.game }
    let(:users) { game_session.users }
    let(:player1) { users.first.player }
    before do
      game_session.create_game_session([server_client1, server_client2])
    end
    it 'updates the current user' do
      game_session.run_turn
      expected_current_user = users.first
      expect(game_session.current_user).to eq expected_current_user
    end
    context 'when player and deck are empty' do
      before do
        game.deck.cards = []
        player1.hand = []
      end
      it 'returns and sends message' do
        client1.capture_output
        client2.capture_output
        expect(game_session.run_turn).to be_nil
        current_message = 'Your turn has been skipped.'
        all_message = 'Player 1\'s turn has been skipped.'
        expect(client2.capture_output.chomp).to eq all_message
        expect(client1.capture_output.chomp).to eq current_message
      end
    end
    context 'when player is asked for input' do
      context 'when no input is provided' do
        it 'returns and sends message once' do
          expect(game_session.run_turn).to be_nil
          player_message_regex = /who would/i
          expect(client1.capture_output).to match player_message_regex
          game_session.run_turn
          expect(client1.capture_output).to be_empty
        end
      end
      context 'when only player selection is provided' do
        it 'returns and sends messages once' do
          rank_message_regex = /what rank/i
          player_id = '2'
          run_and_capture(game_session, client1)
          client1.provide_input(player_id)
          expect(game_session.run_turn).to be_nil
          expect(client1.capture_output).to match rank_message_regex
          expect(run_and_capture(game_session, client1)).to be_empty
        end
      end
      context 'when both inputs are provided' do
        it 'returns true' do
          player_id = '2'
          rank_selection = 'K'
          provide_and_run(game_session, client1, player_id)
          provide_and_run(game_session, client1, rank_selection)
          expect(game.results).to_not be_nil
        end
      end
      context 'when invalid player_id is given' do
        it 'sends message again' do
          player_id = '6'
          provide_and_run(game_session, client1, player_id)
          client1.capture_output
          game_session.run_turn
          player_message_regex = /who would/i
          expect(client1.capture_output).to match player_message_regex
        end
      end
      context 'when invalid then valid player_id is given' do
        it 'does not send message after valid input' do
          player_id = '6'
          provide_and_run(game_session, client1, player_id)
          client1.capture_output
          game_session.run_turn
          client1.capture_output
          player_id = '2'
          provide_and_run(game_session, client1, player_id)
          client1.capture_output
          game_session.run_turn
          expect(client1.capture_output).to be_empty
          # ! Shorten
        end
      end
      context 'when invalid rank is given' do
        let(:player_id) { '2' }
        let(:invalid_rank) { 'l' }
        let(:invalid_rank1) { 'K' }
        let(:valid_rank) { 'J' }
        let(:rank_message_regex) { /what rank/i }
        before do
          player1.hand = [Card.new(valid_rank)]
        end
        it 'sends message again' do
          provide_run_capture(game_session, client1, player_id)
          provide_run_capture(game_session, client1, invalid_rank)
          game_session.run_turn
          expect(client1.capture_output).to match rank_message_regex
        end
        it 'sends message if valid but does not have' do
          provide_run_capture(game_session, client1, player_id)
          provide_run_capture(game_session, client1, invalid_rank)
          game_session.run_turn
          provide_run_capture(game_session, client1, invalid_rank1)
          game_session.run_turn
          expect(client1.capture_output).to match rank_message_regex
        end
        it 'does not send message after valid input' do
          provide_run_capture(game_session, client1, player_id)
          provide_run_capture(game_session, client1, invalid_rank)
          game_session.run_turn
          provide_run_capture(game_session, client1, valid_rank)
          game_session.run_turn
          expect(client1.capture_output).to be_empty
        end
      end
      context 'when a turn is completed' do
        context 'all messages are sent to users' do
          # ^ Init a 3 player game?
        end
        it 'resets state of messages' do
          provide_input_to_pass_turn_checks(game_session, client1)
          expect(game_session.selected_player).to be_nil
          expect(game_session.selected_player_message).to be_nil
          expect(game_session.selected_rank).to be_nil
          expect(game_session.selected_rank_message).to be_nil
        end
      end
    end
  end

  def run_and_capture(session, client)
    session.run_turn
    client.capture_output
  end

  def provide_and_run(session, client, message)
    client.provide_input(message)
    session.run_turn
  end

  def provide_run_capture(session, client, message)
    client.provide_input(message)
    session.run_turn
    client.capture_output
  end

  def provide_input_to_pass_turn_checks(session, client)
    client.provide_input('1')
    session.run_turn
    client.provide_input('Q')
    session.run_turn
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
