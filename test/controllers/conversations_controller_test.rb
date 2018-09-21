# frozen_string_literal: true

require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @conversation = conversations(:two)
  end

  test "show" do
    get conversation_path(@conversation)
    assert_response :redirect
    assert_redirected_to root_path

    # A player can see their own conversations
    player_correct = player_login
    get conversation_path(@conversation)
    assert_response :success

    # But you can't see other player's conversations
    player_incorrect = player_login(:player_3)
    get conversation_path(@conversation), params: { from: player_correct.id }
    assert_response :redirect
    assert_redirected_to player_incorrect

    # The host can see anyone's conversations
    # But they need to set a "from" param otherwise it doesn't know which notifications to update
    host_login
    get conversation_path(@conversation), params: { from: player_correct.id }
    assert_response :success
  end

  test "create" do
    player_login
    assert_no_difference "Conversation.count" do
      post conversations_path(players: @conversation.players.pluck(:id))
    end
    assert_response :redirect
    assert_redirected_to @conversation

    three = players(:player_3)
    four = players(:player_4)
    assert_difference "Conversation.count" do
      post conversations_path(players: [three.id, four.id])
    end
    assert_response :redirect
  end
end
