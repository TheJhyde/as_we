ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def player_login(p = :player_1)
    player = players(p)
    post players_login_path(id: player.id)
    player
  end

  def host_login
    player = players(:player_host)
    post players_login_path(id: player.id)
    player
  end
end
