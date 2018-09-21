# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_player

    def connect
      self.current_player = find_player
    end

    private

      def find_player
        if player == Player.find_by(id: cookies[:current_player])
          player
        else
          reject_unauthorized_connection
        end
      end
  end
end
