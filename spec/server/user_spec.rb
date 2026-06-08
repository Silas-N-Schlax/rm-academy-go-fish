require 'socket'
require_relative '../../lib/server/user'
require_relative '../../lib/player'
require_relative '../../lib/client'

describe User do
  let(:player) { Player.new('Player', 1) }
  let(:client) { Client.new('socket', player_id: 1, host: true) }
  let(:user) { described_class.new(client, player) }
  it 'has a client' do
    expect(user.client).to be_a Client
  end
  it 'has a player' do
    expect(user.player).to be_a Player
  end
end
