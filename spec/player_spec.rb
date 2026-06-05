require_relative '../lib/player'
require_relative '../lib/card'
require_relative '../lib/books'

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
  describe '#take_cards_of_rank' do
    let(:player) { described_class.new('Player1') }
    context 'when player does not have the correct card' do
      it 'returns nil' do
        expect(player.take_cards_of_rank('A')).to be_empty
      end
    end
    context 'when player has one of the correct card' do
      let(:card) { Card.new('A') }
      before do
        player.hand = [card, Card.new('K'), Card.new('J')]
      end
      it 'returns array of card and remove card from hand' do
        expect(player.take_cards_of_rank('A')).to eq [card]
        expect(player.hand_size).to eq 2
      end
    end
    context 'when player has two of the correct card' do
      let(:card1) { Card.new('K') }
      let(:card2) { Card.new('K') }
      before do
        player.hand = [card1, Card.new('A'), card2]
      end
      it 'returns array of cards and remove cards from hand' do
        expect(player.take_cards_of_rank('K')).to eq [card1, card2]
        expect(player.hand_size).to eq 1
      end
    end
  end
  describe '#create_book' do
    let(:player) { described_class.new('Player1') }
    it 'creates a book and adds to books array' do
      expect(player.create_book('K').first).to be_a Book
      expect(player.books_size).to eq 1
    end
  end
  xdescribe '#try_create_books' do
    let(:player) { described_class.new('Player1') }
  end
  describe '#books_size' do
    let(:player) { described_class.new('Player1') }
    it 'returns the current hand size' do
      expect(player.books_size).to eq 0
    end
    it 'returns current hand size of hand with 1 card' do
      player.books = ([Book.new('A')])
      expect(player.books_size).to eq 1
    end
    it 'returns current hand size of hand with 2 cards' do
      player.books = ([Book.new('A'), Book.new('K')])
      expect(player.books_size).to eq 2
    end
  end
end
