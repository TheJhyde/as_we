# frozen_string_literal: true

class NewsUpdateJob < ApplicationJob
  queue_as :default

  def perform(players, message)
    hrn = Player.find_or_create_by(number: "HRN")

    players.each do |player|
      unless player.nil?
        convo = hrn.find_conversation(player)
        msg = Message.create(conversation: convo, player: hrn, contents: message)
      end
    end
  end
end
