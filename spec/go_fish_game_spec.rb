require_relative '../lib/go_fish_game'
require_relative '../lib/card'

describe GoFishGame do
  let(:players) { %w[player1 player2 player3 player4 player5 player6 player7] }
  describe '#initialize' do
    context 'when a game is created with two players' do
      let(:game) { described_class.new(players[0..1]) }
      it 'players are created for each player' do
        expect(game.players.size).to eq 2
      end
      it 'a deck is created' do
        expect(game.deck.cards_left).to eq 52
      end
    end
    context 'when a game is created wth two or more players' do
      let(:game) { described_class.new(players[0..3]) }
      it 'players are created for each player' do
        expect(game.players.size).to eq 4
      end
    end
    context 'when a game is created with more then 6 players' do
      let(:game) { described_class.new(players) }
      it 'only creates a players for the first 6' do
        expect(game.players.size).to eq 6
      end
    end
  end
  describe '#start' do
    context 'when a game is started with two players' do
      let(:game) { described_class.new(players[0..1]) }
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
      let(:game) { described_class.new(players[0..3]) }
      before { game.start }
      it 'deals 5 cards to each player' do
        game.players.each do |player|
          expect(player.hand_size).to eq 5
        end
      end
    end
  end
  describe '#current_player' do
    let(:game) { described_class.new(players[0..1]) }
    it 'returns current player' do
      expect(game.current_player.name).to eq 'player1'
    end
  end
  describe '#run_turn' do
    let(:card1) { Card.new('A') }
    context 'when a turn is run with 2 players' do
      context 'when player1 is asking player2 for a card they have' do
        let(:game) { described_class.new(players[0..1]) }
        let!(:player1) { game.players[0] }
        let!(:player2) { game.players[1] }
        before do
          game.players[1].hand << card1
          game.run_turn('player2', 'A')
        end
        it 'player 1 gets the cards added to their hand' do
          expect(player1.hand_size).to eq 1
        end
        it 'player2 gets the cards removed from their hand' do
          expect(player2.hand_size).to eq 0
        end
        context 'when player1 asks player2 for another card they do not have' do
          before do
            game.run_turn('player2', 'J')
          end
          context 'player1 does not pick up the card' do
            it 'card is added to player1 hand' do
              expect(player1.hand_size).to eq 2
            end
            it 'current player is set to next player in queue' do
              expect(game.current_player.name).to be player2.name
            end
          end
        end
      end
      context 'when player1 asks for a card that they do not have' do
        let(:game) { described_class.new(players[0..1]) }
        let!(:player1) { game.players[0] }
        context 'when they pick up that card' do
          before do
            game.deck.cards.unshift(Card.new('A'))
            game.run_turn('player1', 'A')
          end
          it 'adds card to their hand' do
            expect(player1.hand_size).to eq 1
          end
          it 'they are still current player' do
            expect(game.current_player.name).to eq player1.name
          end
        end
      end
      context 'when player1 asks a player that does not exist' do
        let(:game) { described_class.new(players[0..1]) }
        it 'returns nil' do
          expect(game.run_turn('player3', 'J')).to be nil
        end
      end
      context 'when player1 is asking player2 for a card they do not have' do
        let(:game) { described_class.new(players[0..1]) }
        let!(:player1) { game.players[0] }
        let!(:player2) { game.players[1] }
        context 'when player1 does not pick up that card' do
          before { game.run_turn('player2', 'A') }
          it 'card is added to player1 hand' do
            expect(player1.hand_size).to eq 1
          end
          it 'current player is set to next player in queue' do
            expect(game.current_player.name).to eq player2.name
          end
        end
      end
      context 'when there deck is empty and a player goes fishing' do
        let(:game) { described_class.new(players[0..1]) }
        before do
          game.deck.cards = []
          game.run_turn('player1', 'A')
        end
        it 'does not give the player a card' do
          expect(game.players[1].hand_size).to eq 0
        end
        it 'sets the current player to next player in the queue' do
          expect(game.current_player.name).to eq 'player2'
        end
      end
    end
  end
end
