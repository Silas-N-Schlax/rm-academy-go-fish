# User class
class User
  attr_accessor :player, :client

  def initialize(client, player)
    @client = client
    @player = player
  end
end
