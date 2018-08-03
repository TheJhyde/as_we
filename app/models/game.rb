class Game < ApplicationRecord
  has_many :players

  before_create do
    self.state = "before"
    self.code = SecureRandom.hex(3).upcase
  end

  def start_game(start_message)
    hrn = Player.find_or_create_by(number: "HRN")
    self.players.each do |player|
      convo = Conversation.create(players: [player, hrn])
      Message.create(conversation: convo, from: hrn, contents: start_message)
    end
  end
end
