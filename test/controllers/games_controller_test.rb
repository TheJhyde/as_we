# frozen_string_literal: true

require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def setup
    @game = games(:full_game)
  end

  test "create" do
    assert_difference "Game.count" do
      post games_path
      assert_response :redirect
    end
  end

  test "show" do
    get game_path(@game)
    assert_response :redirect
    assert_redirected_to root_path

    player = player_login
    get game_path(@game)
    assert_response :redirect
    assert_redirected_to player

    host_login
    get game_path(@game)
    assert_response :success
  end

  test "update" do
    patch game_path(@game), params: { game: { state: "running" } }
    assert_response :redirect
    assert_redirected_to root_path

    player = player_login
    patch game_path(@game), params: { game: { state: "running" } }
    assert_response :redirect
    assert_redirected_to player

    host_login
    patch game_path(@game), params: { game: { state: "running" } }
    assert_response :redirect
    assert_redirected_to @game

    @game.reload
    assert_equal "running", @game.state
    assert_enqueued_jobs 12

    patch game_path(@game), params: { game: { state: "running" } }
    assert_enqueued_jobs 12

    patch game_path(@game), params: { game: { state: "end" } }
    @game.reload
    assert_equal "end", @game.state
  end
end
