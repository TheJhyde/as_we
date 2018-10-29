# frozen_string_literal: true

require "test_helper"

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

    assert_not_nil player.number
  end

  test "set game" do
    player = Player.create(code: @game.code)
    player.reload

    assert_equal @game.id, player.game_id
  end

  test "valid game" do
    assert_not Player.new(code: "invalid code").valid?
    assert Player.new(code: @game.code).valid?

    assert Player.new(game: @game).valid?
    @game.update(state: "running")
    assert_not Player.new(game: @game).valid?
    assert_not Player.new(game: games(:full_game)).valid?
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
    @player.notifications.first.update(seen: false)

    assert_difference "Message.count" do
      @player.leave
    end

    @player.reload

    assert_not @player.change.nil?
    assert_not @player.fate.nil?
    assert @player.notifications.first.seen
  end

  test "player that has already left" do
    @player.update(change: "TEST CHANGE")
    @player.leave
    @player.reload
    assert_equal "TEST CHANGE", @player.change
    assert @player.fate.nil?
  end
end
