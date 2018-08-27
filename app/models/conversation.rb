class Conversation < ApplicationRecord
  has_many :messages
  has_many :notifications
  has_many :players, through: :notifications
  has_many :games, through: :players

  def read(player)
    self.notifications.find_by(player: player).seen
  end
end
