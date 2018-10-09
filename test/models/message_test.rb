# frozen_string_literal: true

require "test_helper"

class MessageTest < ActiveSupport::TestCase
  def setup
    @conversation = conversations(:two)
    @player = players(:player_1)
  end

  test "can't create a message from a left player" do
    @player.update(left: true)
    assert_no_difference "Message.count" do
      Message.create(conversation: @conversation, player: @player, contents: "TEST TEST")
    end
  end

  test "mark number" do
    other_player = players(:player_2)

    assert_difference "Message.count", 4 do
      msg = Message.create(conversation: @conversation, player: @player, contents: "TEST #{other_player.number} TEST")
      assert_equal "TEST #{other_player.number} TEST", msg.contents
      assert_equal({ links: [{ number: other_player.number, id: other_player.id }] }.to_json(), msg.extra)

      # No links if the number isn't anyone in the game's
      msg2 = Message.create(conversation: @conversation, player: @player, contents: "TEST 99999 TEST")
      assert_equal "{}", msg2.extra

      # No links if specified not too
      msg3 = Message.create(conversation: @conversation, player: @player, contents: "TEST #{other_player.number} TEST", no_links: true)
      assert_equal "{}", msg3.extra

      # No links for players that aren't in this game but are in other games
      msg4 = Message.create(conversation: @conversation, player: @player, contents: "TEST #{players(:one).number} TEST")
      assert_equal "{}", msg4.extra
    end
  end

  # test "mark phone" do
  #   msg = Message.create(conversation: @conversation, player: @player, contents: "TEST 555-555-5555 TEST")
  #   assert_equal({phone: ["555-555-5555"]}.to_json(), msg.extra)
  # end

  test "mark unread" do
    notif = notifications(:four)
    assert notif.seen

    Message.create(conversation: @conversation, player: @player, contents: "TEST TEST")
    notif.reload
    assert_not notif.seen
  end

  test "broadcast" do
    # Not sure how to test this
  end
end
