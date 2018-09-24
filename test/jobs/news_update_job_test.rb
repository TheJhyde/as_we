# frozen_string_literal: true

require "test_helper"

class NewsUpdateJobTest < ActiveJob::TestCase
  test "perform" do
    assert_difference 'Message.count', 2 do
      NewsUpdateJob.perform_now([players(:player_2), players(:player_3)], "TEST MESSAGE")
    end

    player = players(:player_2)
    convo = player.find_conversation(players(:hrn))
    message = convo.messages.order(:created_at).last
    assert_equal "TEST MESSAGE", message.contents
  end
end
