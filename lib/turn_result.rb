# Turn results class
class TurnResult
  attr_accessor :current_player, :opponent, :cards_taken,
                :card_asked_for, :card_picked_up,
                :goes_again

  def initialize(current_player:, opponent:, cards_taken:, card_asked_for:, card_picked_up:, goes_again:)
    @current_player = current_player
    @opponent = opponent
    @cards_taken = cards_taken
    @card_asked_for = card_asked_for
    @card_picked_up = card_picked_up
    @goes_again = goes_again
  end

  def for_current
    message_ary = ["You asked for a #{card_asked_for}, took the following from #{opponent.name}:"]
    cards_taken.each do |card|
      message_ary << "- #{card}"
    end
    message_ary
  end

  def for_opponent
    message_ary = ["#{current_player.name} asked for a #{card_asked_for} and took the following cards from you:"]
    cards_taken.each do |card|
      message_ary << "- #{card}"
    end
    message_ary
  end

  def go_fish
    "You went fishing and picked up a #{card_picked_up}. You#{goes_again ? ' ' : ' do not '}get to go again."
  end

  def went_fishing
    "#{current_player.name} went fishing, they#{goes_again ? ' ' : ' do not '}get to go again."
  end
end
