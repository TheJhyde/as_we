# frozen_string_literal: true

require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  test "read" do
    conversation = conversations(:two)
    notif = notifications(:three)
    player = players(:player_1)

    assert conversation.read(player)
    notif.update(seen: false)
    assert_not conversation.read(player)
  end
end
