require_relative '../lib/deck'
require_relative '../lib/card'

describe Deck do
  it 'should have 52 cards when created' do
    deck = described_class.new
    expect(deck.cards_left).to eq 52
  end

  it 'should top_card the top card' do
    deck = described_class.new
    card = deck.top_card
    expect(card).to_not be_nil
    expect(card).to be_a Card
    expect(card).to respond_to(:rank)
    expect(deck.cards_left).to eq 51
  end

  it 'top_card gives a unique card each time' do
    deck = described_class.new
    card1 = deck.top_card
    card2 = deck.top_card
    expect(card1).not_to eq card2
  end

  describe '#shuffle' do
    it 'shuffles deck' do
      deck1 = described_class.new
      deck2 = described_class.new
      deck2.shuffle_deck

      expect(deck1.cards).to_not eq deck2.cards
    end
  end
  describe '#empty?' do
    let(:deck) { described_class.new }
    it 'returns false if deck is full' do
      expect(deck.empty?).to be false
    end
    it 'returns true if deck is empty' do
      deck.cards = []
      expect(deck.empty?).to be true
    end
  end
end
