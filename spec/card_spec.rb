require_relative '../lib/card'

describe Card do
  it 'has a rank, suit, and value' do
    card = described_class.new('A', 'Spades')
    expect(card.rank).to eq 'A'
    expect(card.suit).to eq 'Spades'
  end

  it 'cards of the same rank and suit are equal' do
    card1 = described_class.new('A', 'Spades')
    card2 = described_class.new('K', 'Spades')
    card3 = described_class.new('A', 'Spades')

    expect(card1).not_to eq card2
    expect(card1).to eq card3
  end

  it 'should allow valid ranks' do
    expect {
      described_class.new('15', 'Spades')
    }.to raise_error Card::InvalidRank
  end

  it 'should allow valid suits' do
    expect {
      described_class.new('3', 'Bulkogi')
    }.to raise_error Card::InvalidSuit
  end
end
