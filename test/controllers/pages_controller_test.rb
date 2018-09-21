# frozen_string_literal: true

require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "basic root request" do
    get root_path
    assert_response :success
  end

  test "root request while logged in as a player" do
    player = players(:player_1)
    post players_login_path(id: player.id)
    get root_path
    assert_response :redirect
    assert_redirected_to player

    player.update(left: true)
    get root_path
    assert_response :success
  end

  test "root request whiled logged in as host" do
    player = players(:player_host)
    post players_login_path(id: player.id)
    get root_path
    assert_response :redirect
    assert_redirected_to player.game
  end
end
