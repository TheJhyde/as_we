# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :player

  validate :check_player
  before_save :mark_number
  # before_save :mark_phone
  after_create :mark_unread
  after_create :broadcast

  attr_accessor :no_links

  def extra_info
    JSON.parse(self.extra)
  end

  private
    def check_player
      if self.player.left?
        errors.add(:player, "must still be connected")
      end
    end

    def mark_number
      unless no_links
        # Scanning for 5 digit long numbers, I believe
        numbers = self.contents.scan(/\d{5}/)
        links = numbers.uniq.map do |number|
          # If this message is from HRN, we trust it to only give us players from the correct game
          # HRN is an upstanding resistance network, wouldn't lead us astray
          target = self.player.number == "HRN" ? Player.find_by(number: number) : Player.find_by(number: number, game: self.player.game)
          if target
            { number: number, id: target.id }
          else
            nil
          end
        end
        links.compact!

        if links.length > 0
          self.extra = JSON.parse(extra).merge(links: links.find_all { |n| n }).to_json
        end
      end
    end

    # def mark_phone
    #   numbers = self.contents.scan(/^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/)

    #   match = "333-333-3333 blah".match(/^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$/)

    #   if numbers.length > 0
    #     self.extra = JSON.parse(extra).merge(phone: numbers.uniq.to_json)
    #   end
    # end

    def mark_unread
      self.conversation.notifications.where.not(player: self.player).update(seen: false)
    end

    def broadcast
      broadcast = { message: self.contents, number: self.player.number, player: self.player.id, extra: self.extra, conversation: self.conversation.id, type: "msg" }

      players = self.conversation.players
      players.each do |player|
        broadcast[:tab] = players.where.not(id: player.id).pluck(:number).join(", ")
        player.broadcast_to(broadcast)
      end
      # ActionCable.server.broadcast("chat_Conversation_#{self.conversation.id}", message: self.contents, number: self.player.number, extra: self.extra)
    end
end
