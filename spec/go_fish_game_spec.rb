require_relative '../lib/go_fish_game'
require_relative '../lib/card'

describe GoFishGame do
  let(:player1) { { name: 'player1', player_id: 1 } }
  let(:player2) { { name: 'player2', player_id: 2 } }
  let(:player3) { { name: 'player3', player_id: 3 } }
  let(:player4) { { name: 'player4', player_id: 4 } }
  describe '#initialize' do
    context 'when a game is created with two players' do
      let(:game) { described_class.new([player1, player2]) }
      it 'players are created for each player' do
        expect(game.players.size).to eq 2
      end
      it 'a deck is created' do
        expect(game.deck.cards_left).to eq 52
      end
      it 'each player has a unique id' do
        player1 = game.players.first
        player2 = game.players.last
        expect(player1.player_id).to_not eq player2.player_id
      end
    end
    context 'when a game is created wth two or more players' do
      let(:game) { described_class.new([player1, player2, player3, player4]) }
      it 'players are created for each player' do
        expect(game.players.size).to eq 4
      end
    end
    context 'when a game is created with more then 6 players' do
      let(:player5) { { name: 'player5', player_id: 5 } }
      let(:player6) { { name: 'player6', player_id: 6 } }
      let(:game) { described_class.new([player1, player2, player3, player4, player5, player6]) }
      it 'only creates a players for the first 6' do
        expect(game.players.size).to eq 6
      end
    end
  end
  describe '#start' do
    context 'when a game is started with two players' do
      let(:game) { described_class.new([player1, player2]) }
      before { game.start }
      it 'deals 7 cards to each player' do
        game.players.each do |player|
          expect(player.hand_size).to eq 7
        end
      end
      it 'cards are not in order' do
        default_hand1 = [Card.new('2'), Card.new('4'), Card.new('6'), Card.new('8'), Card.new('10')]
        default_hand2 = [Card.new('3'), Card.new('5'), Card.new('7'), Card.new('9'), Card.new('J')]
        expect(game.players[0].hand).to_not eq default_hand1
        expect(game.players[0].hand).to_not be_empty
        expect(game.players[1].hand).to_not eq default_hand2
        expect(game.players[1].hand).to_not be_empty
      end
    end
    context 'when a game is started with 4 players' do
      let(:game) { described_class.new([player1, player2, player3, player4]) }
      before { game.start }
      it 'deals 5 cards to each player' do
        game.players.each do |player|
          expect(player.hand_size).to eq 5
        end
      end
    end
  end
  describe '#current_player' do
    let(:game) { described_class.new([player1, player2]) }
    it 'returns current player' do
      expect(game.current_player.name).to eq 'player1'
    end
  end
  describe '#find_player' do
    let(:game) { described_class.new([player1, player2]) }
    it 'returns player1' do
      player1_id = 1
      result = game.find_player(player1_id)
      expect(result.name).to eq player1[:name]
    end
    it 'returns nil if player does not exist' do
      player3_id = 3
      result = game.find_player(player3_id)
      expect(result).to be nil
    end
  end
  describe '#run_turn' do
    let(:card1) { Card.new('A') }
    context 'when a turn is run with 2 players' do
      context 'when player1 is asking player2 for a card they have' do
        let(:game) { described_class.new([player1, player2]) }
        let!(:player1_data) { game.players.first }
        let!(:player2_data) { game.players.last }
        before do
          player2_data.hand << card1
          game.run_turn(2, 'A')
        end
        it 'player 1 gets the cards added to their hand' do
          expected_hand_size = 1
          expect(player1_data.hand_size).to eq expected_hand_size
        end
        it 'player2 gets the cards removed from their hand' do
          expect(player2_data.hand_size).to be_zero
        end
        context 'when player1 asks player2 for another card they do not have' do
          before do
            game.run_turn(2, 'J')
          end
          context 'player1 does not pick up the card' do
            it 'card is added to player1 hand' do
              expected_hand_size = 2
              expect(player1_data.hand_size).to eq expected_hand_size
            end
            it 'current player is set to next player in queue' do
              expect(game.current_player.name).to be player2_data.name
            end
          end
        end
        it 'returns a valid round result' do
          expected_message = ''
          expect(game.results).to be_a TurnResults
        end
      end
      context 'when player1 asks for a card that they do not have' do
        let(:game) { described_class.new([player1, player2]) }
        let!(:player1_data) { game.players.first }
        context 'when they pick up that card' do
          before do
            game.deck.cards.unshift(Card.new('A'))
            game.run_turn(2, 'A')
          end
          it 'adds card to their hand' do
            expected_hand_size = 1
            expect(player1_data.hand_size).to eq expected_hand_size
          end
          it 'they are still current player' do
            expect(game.current_player.name).to eq player1_data.name
          end
        end
      end
      context 'when player1 asks a player that does not exist' do
        let(:game) { described_class.new([player1, player2]) }
        it 'returns nil' do
          expect(game.run_turn(3, 'J')).to be nil
        end
      end
      context 'when player1 is asking player2 for a card they do not have' do
        let(:game) { described_class.new([player1, player2]) }
        let!(:player1_data) { game.players.first }
        let!(:player2_data) { game.players.last }
        context 'when player1 does not pick up that card' do
          before { game.run_turn(2, 'A') }
          it 'card is added to player1 hand' do
            expected_hand_size = 1
            expect(player1_data.hand_size).to eq expected_hand_size
          end
          it 'current player is set to next player in queue' do
            expect(game.current_player.name).to eq player2_data.name
          end
        end
      end
      context 'when there deck is empty and a player goes fishing' do
        let(:game) { described_class.new([player1, player2]) }
        let!(:player2_data) { game.players.last }
        before do
          game.deck.cards = []
          game.run_turn(1, 'A')
        end
        it 'does not give the player a card' do
          expect(player2_data.hand_size).to be_zero
        end
        it 'sets the current player to next player in the queue' do
          expect(game.current_player.name).to eq player2_data.name
        end
      end
      # TODO: Not just hand size, but that it includes the card
      # ^ I.e hand.include(card) or something similar.
      # TODO: check that there are enough cards to make a book
      # TODO: check the size of the deck has been changed?
      # ^ use constants
      # and that it removes all cards from hand and adds new
      # book to players books.
    end
  end
end
