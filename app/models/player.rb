class Player < ApplicationRecord
  belongs_to :game, optional: true

  has_many :messages
  has_many :notifications
  has_many :conversations, through: :notifications

  attr_accessor :code

  validate :valid_game?, on: :create
  before_create :set_game
  before_create :set_number
  after_create :broadcast_creation

  def broadcast_to(data)
    ActionCable.server.broadcast("game_channel_#{self.id}", data)
  end

  def channel
    ActionCable.server.remote_connections.where(current_player: self)
  end

  def find_conversation(player)
    convo = self.conversations.eager_load(:players).find_by('players.id = ?', player.id)
    if convo.nil?
      convo = Conversation.create(players: [self, player])
    end
    convo
  end

  def any_unread?
    notifications.any?{|n| !n.seen?}
  end

  def leave
    self.conversations.each do |conversation|
      msg = Message.create(contents: "- #{self.number} has disconnected -", conversation: conversation, player: self, extra: {system_message: true}.to_json, no_links: true)
      p msg.errors
    end

    ActionCable.server.broadcast("host_channel_#{game.id}", {type: "player_leave", id: id})
  end

  private
    def set_number
      unless self.number
        loop do
          self.number = "#{Random.rand(100000)}".rjust(5, "0")
          break unless Player.exists?(left: false, number: self.number)
        end
      end
    end

    def set_game
      if game.nil? && !code.nil?
        self.game = Game.find_by(code: code)
      end
    end

    def broadcast_creation
      if game
        ActionCable.server.broadcast("host_channel_#{game.id}", {type: "new_player", number: number, count: game.players.count, id: id})
      end
    end

    def valid_game?
      if game.nil? && !code.nil? && !Game.exists?(code: code)
        errors.add(:game, "not found.")
      end

      if game
        if game.state != "before"
          errors.add(:game, "has already started")
        elsif game.players.count >= 5
          errors.add(:game, "is full")
        end
      end      
    end
end
