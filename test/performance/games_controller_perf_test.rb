require 'test_helper'
require 'rails/performance_test_help'

class GamesControllerPerfTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }

  def setup
    @game = games(:full_game)
  end

  # test "create" do
  #   post games_path
  # end

  test 'show' do
    host_login
    get game_path(@game)
  end

  # test 'start game' do
  #   host_login
  #   patch game_path(@game), params: {game: {state: "running"}}
  # end

  # test 'end game' do
  #   host_login
  #   patch game_path(@game), params: {game: {state: "end"}}
  # end
end
