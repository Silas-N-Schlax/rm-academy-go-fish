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
  describe '#run_turn'
end
