# frozen_string_literal: true

# I don't think ChatChannel is actually being used for anything. GameChannel does most everything
# Leaving it in for the moment thoguh

class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    Message.create(contents: data["contents"], conversation_id: data["conversation_id"], player_id: data["from_id"], order_num: data["order_num"])
  end

  def receive(data); end
end
