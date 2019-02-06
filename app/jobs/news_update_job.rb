# frozen_string_literal: true

class NewsUpdateJob < ApplicationJob
  queue_as :default

  def perform(hrn, players, message)
    players.each do |player|
      unless player.nil?
        convo = hrn.find_conversation(player)
        Message.create(conversation: convo, player: hrn, contents: message, order_num: convo.last_order_num + 1)
      end
    end
  end
end
