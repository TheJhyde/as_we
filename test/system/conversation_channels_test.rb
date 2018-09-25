# frozen_string_literal: true

require "application_system_test_case"

class ConversationChannelsTest < ApplicationSystemTestCase
  def setup
    # @player_1 = players(:player_1)
    # @player_2 = players(:player_2)
    # @hrn_convo = conversations(:with_hrn)
    # @convo = conversations(:two)
  end

  test "Writing a message in a conversation" do
    # player_login(@player_1)

    # visit conversation_url(@hrn_convo)

    # # Load the page, confirm it's the correct page, confirm we have no notifications
    # assert_selector "#conversation-people", text: "HRN, #{@player_1.number}"
    # assert_no_selector "#nav.notification"

    # # The user can fill out the form and submit a message.
    # # This should create a message on the server side
    # assert_difference 'Message.count' do
    #   find('#message-body').set("TEST TEXT")
    #   find('#message-submit').click

    #   # find('.message-contents')
    #   assert has_selector? ".message-contents", text: "TEST TEXT"
    #   assert_no_selector "#nav.notification"
    # end
    # The message should pass through and be added to the conversation
    # Check if message appeared correct, assigned to the right person
    # Check that notification is still false

    # HRN says something in this conversation, via the job
    # NewsUpdateJob.perform_now([@player_1], "Message from HRN")

    # # No notification, cause we're already here
    # # I need to put in some kind of wait here
    # # I assume that's why the selector isn't revealing anything
    # assert_no_selector "#nav.notification"
    # assert_selector ".message-contents", text: "Message from HRN"

  end
end
