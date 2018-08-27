class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :player

  before_save :mark_number
  after_create :mark_unread
  after_create :broadcast

  def extra_info
    JSON.parse(self.extra)
  end

  private
    def mark_number
      numbers = self.contents.scan(/\d{5}/)
      links = numbers.uniq.map do |number|
        # If this message is from HRN, we trust it to only give us players from the correct game
        # HRN is an upstanding resistance network, wouldn't lead us astray
        target = self.player.number == "HRN" ? Player.find_by(number: number) : Player.find_by(number: number, game: self.player.game)
        if target
          {number: number, id: target.id}
        else
          nil
        end
      end

      if links.length > 0
        self.extra = {links: links.find_all {|n| n}}.to_json
      end
    end

    def mark_unread
      self.conversation.notifications.where.not(player: self.player).update(seen: false)
    end

    def broadcast
      broadcast = {message: self.contents, number: self.player.number, player: self.player.id, extra: self.extra, conversation: self.conversation.id, type: "msg"}
      self.conversation.players.each do |player|
        player.broadcast_to(broadcast)
      end
      # ActionCable.server.broadcast("chat_Conversation_#{self.conversation.id}", message: self.contents, number: self.player.number, extra: self.extra)
    end
end
