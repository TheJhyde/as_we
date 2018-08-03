class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :from, class_name: "Player"

  before_save :mark_number
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
        target = self.from.number == "HRN" ? Player.find_by(number: number) : Player.find_by(number: number, game: self.from.game)
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

    def broadcast
      ActionCable.server.broadcast("chat_Conversation_#{self.conversation.id}", message: self.contents, number: self.from.number, extra: self.extra)
    end
end
