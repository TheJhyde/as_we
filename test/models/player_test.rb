require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  def setup
    @game = games(:one)
    @player = players(:one)
  end

  test "has many" do
    assert_equal 1, @player.conversations.count
    assert_equal 1, @player.notifications.count
    assert_equal 1, @player.messages.count
  end

  test "set number" do
    player = Player.create
    player.reload

    refute_nil player.number
  end

  test "set game" do
    player = Player.create(code: @game.code)
    player.reload

    assert_equal @game.id, player.game_id
  end

  test "valid game" do
    refute Player.new(code: "invalid code").valid?
    assert Player.new(code: @game.code).valid?

    assert Player.new(game: @game).valid?
    @game.update(state: "running")
    refute Player.new(game: @game).valid?
    refute Player.new(game: games(:full_game)).valid?
  end

  test "find_conversation" do
    assert_equal conversations(:one), @player.find_conversation(players(:two))
  end

  test "any_unread?" do
    assert_not @player.any_unread?
    @player.notifications.first.update(seen: false)
    assert @player.any_unread?
  end

  test "leave" do
    assert_difference "Message.count" do
      @player.leave
    end
  end
end
