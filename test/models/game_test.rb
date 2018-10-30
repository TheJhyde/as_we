# frozen_string_literal: true

require "test_helper"

class GameTest < ActiveSupport::TestCase
  def setup
    @game = games(:full_game)
  end

  test "set state and code before creation" do
    game = Game.create
    game.reload
    assert_not_nil game.code
    assert_equal "before", game.state
  end

  test "has many players" do
    assert_equal 6, @game.players.count
  end

  test "start" do
    @game.start
    @game.reload

    assert_equal "running", @game.state
    # Then a number of activejob & channel things happen, which I'm not sure how to test
  end

  test "end" do
    @game.end
    @game.reload

    assert_equal "end", @game.state
    assert_equal [true], @game.players.pluck(:left).uniq
  end

  test "outcomes" do
    @game.update(start_time: DateTime.now)
    outcomes = @game.outcomes("test_key_1")
    assert_equal 1, outcomes[:fate].length
    assert_equal 1, outcomes[:change].length

    @game.update(start_time: 26.minutes.ago)
    outcomes = @game.outcomes("test_key_2")
    assert_equal 1, outcomes[:fate].length
    assert_equal 3, outcomes[:change].length

    players(:player_1).update(left: true)
    outcomes = @game.outcomes("test_key_3")
    assert_equal 2, outcomes[:fate].length
    assert_equal 2, outcomes[:change].length

    players(:player_2).update(left: true)
    outcomes = @game.outcomes("test_key_4")
    assert_equal 2, outcomes[:fate].length
    assert_equal 2, outcomes[:change].length

    players(:player_3).update(left: true)
    outcomes = @game.outcomes("test_key_5 ")
    assert_equal 3, outcomes[:fate].length
    assert_equal 1, outcomes[:change].length
  end

  test "fates" do
    fates = @game.fates
    player = players(:player_1)
    player.update(left: true, fate: fates[0])
    player.reload

    assert_not @game.fates.include?(player.fate)
    assert_equal fates.length - 1, @game.fates.length
  end

  test "changes" do
    changes = @game.changes
    player = players(:player_1)
    player.update(left: true, change: changes[0])
    player.reload

    assert_not @game.changes.include?(player.change)
    assert_equal changes.length - 1, @game.changes.length
  end
end
