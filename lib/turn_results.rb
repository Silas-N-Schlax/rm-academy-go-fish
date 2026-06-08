# Turn results class
class TurnResults
  attr_accessor :current_player, :opponent, :cards_taken,
                :card_asked_for, :card_picked_up,
                :goes_again
  def initialize(round_data)
    @current_player = round_data[:current_player]
    @opponent = round_data[:opponent]
    @cards_taken = round_data[:cards_taken]
    @card_asked_for = round_data[:card_asked_for]
    @card_picked_up = round_data[:card_picked_up]
    @goes_again = round_data[:goes_again]
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
