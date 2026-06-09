require_relative '../lib/player'
require_relative '../lib/card'
require_relative '../lib/books'

describe Player do
  describe '#initialize' do
    let!(:player) { described_class.new('Player1', 1) }
    it 'has a name' do
      expect(player.name).to eq 'Player1'
    end
    it 'has a empty hand' do
      expect(player.hand).to be_empty
    end
    it 'has no books' do
      expect(player.books).to be_empty
    end
    it 'has a player id of 1' do
      expected_player_id = 1
      expect(player.player_id).to eq expected_player_id
    end
  end
  describe '#add_cards' do
    let(:player) { described_class.new('Player1', 1) }
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
      it 'adds cards in correct order and does not create deck' do
        example_hand = [card3, card1, card2]
        player.add_cards([card1, card2])
        expect(player.hand).to eq example_hand
        expect(player.hand_size).to eq example_hand.size
        expect(player.books_size).to be_zero
      end
    end
    context 'when a 4th card of the same rank is added' do
      before do
        player.hand = [card1, card1, card1, card2]
      end
      it 'creates a book with that rank' do
        expected_books_size = 1
        expected_hand_size = 1
        expect(player.add_cards([card1])).to be_a Book
        expect(player.books_size).to eq expected_books_size
        expect(player.hand_size).to eq expected_hand_size
      end
    end
  end
  describe '#hand_size' do
    let(:player) { described_class.new('Player1', 1) }
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
    let(:player) { described_class.new('Player1', 1) }
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
  describe '#format_hand' do
    let(:player) { described_class.new('Player1', 1) }
    before do
      player.add_cards([Card.new('A'), Card.new('K')])
    end
    it 'returns string of current hand' do
      expected_formatted_hand = 'Player1, you have the following cards in your hand:\n- A of Spades\n- K of Spades'
      expect(player.format_hand.join('\n')).to eq expected_formatted_hand
    end
  end
  describe '#books_size' do
    let(:player) { described_class.new('Player1', 1) }
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
