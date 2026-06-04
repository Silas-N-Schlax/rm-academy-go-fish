require_relative '../lib/deck'
require_relative '../lib/card'

describe 'Deck' do
  it 'Should have 52 cards when created' do
    deck = Deck.new
    expect(deck.cards_left).to eq 52
  end

  it 'should top_card the top card' do
    deck = Deck.new
    card = deck.top_card
    expect(card).to_not be_nil
    expect(card).to be_a Card
    expect(card).to respond_to(:rank)
    expect(deck.cards_left).to eq 51
  end

  it 'top_card gives a unique card each time' do
    deck = Deck.new
    card1 = deck.top_card
    card2 = deck.top_card
    expect(card1).not_to eq card2
  end

  describe '#shuffle' do
    it 'shuffles deck' do
      deck1 = Deck.new
      deck2 = Deck.new
      deck2.shuffle_deck

      expect(deck1.cards).to_not eq deck2.cards
    end
  end
end
