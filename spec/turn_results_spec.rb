require_relative '../lib/turn_results'
require_relative '../lib/card'
require_relative '../lib/player'

describe TurnResults do
  let(:results) { described_class.new }
  before do
    results.opponent = Player.new('Player2', 2)
    results.current_player = Player.new('Player1', 1)
    results.card_asked_for = Card.new('K')
    results.cards_taken = [Card.new('K', 'Hearts')]
    results.card_picked_up = Card.new('J')
    results.goes_again = false
  end

  describe '#for_current' do
    it 'returns the message for the current players' do
      expected_message = 'You asked for a K of Spades, took the following from Player2:\n- K of Hearts'
      expect(results.for_current.join('\n')).to eq expected_message
    end
  end
  describe '#for_opponent' do
    it 'returns message for the opponent' do
      expected_message = 'Player1 asked for a K of Spades and took the following cards from you:\n- K of Hearts'
      expect(results.for_opponent.join('\n')).to eq expected_message
    end
  end
  describe '#go_fish' do
    it 'returns go fish message that reveals cards' do
      expected_message = 'You went fishing and picked up a J of Spades. You do not get to go again.'
      expect(results.go_fish).to eq expected_message
    end
  end
  describe '#went_fishing' do
    it 'returns go fish message that does not reveals cards' do
      expected_message = 'Player1 went fishing, they do not get to go again.'
      expect(results.went_fishing).to eq expected_message
    end
  end
end
