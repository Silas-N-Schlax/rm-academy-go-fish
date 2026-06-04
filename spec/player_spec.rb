require_relative '../lib/player'
require_relative '../lib/card'

describe Player do
  describe '#initialize' do
    let!(:player) { described_class.new('Player1') }
    it 'has a name' do
      expect(player.name).to eq 'Player1'
    end
    it 'has a empty hand' do
      expect(player.hand).to be_empty
    end
    it 'has no books' do
      expect(player.books).to be_empty
    end
  end
  describe '#add_cards' do
    let(:player) { described_class.new('Player1') }
    let(:card1) { Card.new('A', 'Spades') }
    let(:card2) { Card.new('K', 'Spades') }
    context 'when player has no cards' do
      it 'adds cards to bottom in correct orders' do
        example_hand = [card1, card2]
        player.add_cards(example_hand)
        expect(player.hand).to eq example_hand
        expect(player.hand_size).to eq 2
      end
    end
    context 'when player has cards' do
      let(:card3) { Card.new('2', 'Spades') }
      before do
        player.hand = [card3]
      end
      it 'adds cards to bottom of deck in correct order' do
        example_hand = [card3, card1, card2]
        player.add_cards([card1, card2])
        expect(player.hand).to eq example_hand
        expect(player.hand_size).to eq 3
      end
    end
  end
  describe 'next_card' do
    let(:player) { described_class.new('Player1') }
    context 'when hand is not empty' do
      it 'returns top card and does not remove' do
        card1 = Card.new('A', 'Spades')
        card2 = Card.new('10', 'Spades')

        player.add_cards([card1, card2])
        expect(player.next_card).to eq card1
        expect(player.hand_size).to eq 2
      end
    end
    context 'when hand is empty' do
      it 'return nil' do
        expect(player.next_card).to be nil
        expect(player.hand_size).to eq 0
      end
    end
  end
  describe '#take_top_card' do
    let(:player) { described_class.new('Player1') }
    context 'when hand is not empty' do
      it 'returns top card and removes from hand' do
        card1 = Card.new('A', 'Spades')
        card2 = Card.new('10', 'Spades')

        player.add_cards([card1, card2])
        expect(player.take_top_card).to eq card1
        expect(player.hand_size).to eq 1
      end
    end
    context 'when hand is empty' do
      it 'returns nil' do
        expect(player.take_top_card).to be nil
        expect(player.hand_size).to eq 0
      end
    end
  end
  describe '#hand_size' do
    let(:player) { described_class.new('Player1') }
    it 'returns the current hand size' do
      expect(player.hand_size).to eq 0
    end
    it 'returns current hand size of hand with 1 card' do
      player.add_cards([Card.new('A', 'Spades')])
      expect(player.hand_size).to eq 1
    end
    it 'returns current hand size of hand with 2 cards' do
      player.add_cards([Card.new('A', 'Spades'), Card.new('10', 'Spades')])
      expect(player.hand_size).to eq 2
    end
  end
  # xdescribe '#add_book' do
  #   let(:player) { described_class.new('Player1') }
  # end
  # xdescribe '#book_size' do
    
  # end
end