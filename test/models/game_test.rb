require 'test_helper'

class GameTest < ActiveSupport::TestCase
  def setup
    @game = games(:one)
  end

  test "set state and code before creation" do
    game = Game.create
    game.reload
    refute_nil game.code
    assert_equal "before", game.state
  end

  test "only allow valid codes" do
    assert_not Game.new(state: "something else").valid?

    assert Game.new(state: "before").valid?
    assert Game.new(state: "running").valid?
    assert Game.new(state: "end").valid?
  end

  test "has many players" do
    assert_equal 2, @game.players.count
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
    assert  [true, true], @game.players.pluck(:left)
  end
end
