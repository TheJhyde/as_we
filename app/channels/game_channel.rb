#frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  def subscribed
    if current_player.host
      stream_from "game_channel_#{params[:room]}"
    else
      stream_from "game_channel_#{current_player.id}"
    end
  end

  def send_message(data)
    Message.create(contents: data['contents'], conversation_id: data['conversation_id'], player_id: data['player_id'])
  end

  def mark_read(data)
    Notification.find_by(conversation_id: data['conversation_id'], player_id: data['player_id']).update(seen: true)
  end

  def unsubscribed; end
end
