class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    msg = Message.create(contents: data["contents"], conversation_id: data["conversation_id"], from_id: data["from_id"])
  end

  def receive(data)
  end
end