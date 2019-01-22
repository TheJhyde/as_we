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

  test "last_order_num" do
    # A conversation with no messages
    assert_equal 0, conversations(:two).last_order_num
    # A conversation with messages but they're nil
    assert_equal 0, conversations(:one).last_order_num

    messages(:one).update(order_num: 10)
    messages(:two).update(order_num: 11)
    assert_equal 11, conversations(:one).last_order_num
  end
end
