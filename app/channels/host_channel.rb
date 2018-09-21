# frozen_string_literal: true

class HostChannel < ApplicationCable::Channel
  def subscribed
    stream_from "host_channel_#{params[:room]}"
  end

  def unsubscribed; end
end
