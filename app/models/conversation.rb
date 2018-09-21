# frozen_string_literal: true

class Conversation < ApplicationRecord
  has_many :messages
  has_many :notifications
  has_many :players, through: :notifications
  has_many :games, through: :players

  def read(player)
    self.notifications.find_by(player: player).seen
  end

  def game
    game_ids = self.players.pluck(:game_id).compact
    return Game.find(game_ids[0]) unless game_ids[0].nil?
    nil
  end
end
