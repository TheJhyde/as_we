# frozen_string_literal: true

require "test_helper"

class PlayersControllerTest < ActionDispatch::IntegrationTest
  test "create" do
    assert_difference "Player.count" do
      post players_path(player: { code: games(:one).code })
      assert_response :redirect
    end

    assert_no_difference "Player.count" do
      post players_path(player: { code: "INVALID CODE" })
      assert_response :redirect
      assert_redirected_to root_path
    end
  end

  test "show" do
    player = players(:player_1)
    get player_path(player)
    assert_response :redirect
    assert_redirected_to root_path

    player_login
    get player_path(player)
    assert_response :success

    # You can't see someone else's player page. That's illegal. Go to jail.
    get player_path(players(:player_2))
    assert_response :redirect
    assert_redirected_to player

    player = host_login
    get player_path(player)
    assert_response :redirect
    assert_redirected_to player.game
  end

  test "edit" do
    player = players(:player_1)
    get edit_player_path(player)
    assert_response :redirect
    assert_redirected_to root_path

    player_login
    get edit_player_path(player)
    assert_response :success

    get edit_player_path(players(:player_2))
    assert_response :redirect
    assert_redirected_to player
  end

  test "update" do
    player = players(:player_1)

    patch player_path(player), params: { player: { left: "true", fate: "FATE TEST", change: "CHANGE TEST" } }
    assert_response :redirect
    assert_redirected_to root_path

    player_login
    patch player_path(player), params: { player: { left: "true", fate: "FATE TEST", change: "CHANGE TEST" } }
    assert_response :redirect
    assert_redirected_to player

    player.reload
    assert player.left
    assert_equal "FATE TEST", player.fate
    assert_equal "CHANGE TEST", player.change
  end

  test "login_page" do
    get players_login_path
    assert_response :success

    player = player_login
    get players_login_path
    assert_response :redirect
    assert_redirected_to player
  end

  test "login" do
    player = players(:player_1)
    post players_login_path(id: player)
    assert_response :redirect
    assert_redirected_to player
    assert_equal "#{player.id}", cookies[:current_player]

    post players_login_path(id: 999)
    assert_response :redirect
    assert_redirected_to root_path
  end
end
