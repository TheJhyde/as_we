# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :game, optional: true

  enum role: [:participant, :host, :hrn]

  has_many :messages
  has_many :notifications
  has_many :conversations, through: :notifications

  attr_accessor :code

  validate :game_exists?, on: :create
  validate :valid_game?, on: :create
  before_create :set_game
  before_create :set_number
  after_create :broadcast_creation

  def broadcast_to(data)
    ActionCable.server.broadcast("game_channel_#{id}", data)
  end

  def channel
    ActionCable.server.remote_connections.where(current_player: self)
  end

  def find_conversation(player)
    convo = conversations
      .eager_load(:players)
      .find_by("players.id = ?", player.id)
    convo = Conversation.create(players: [self, player]) if convo.nil?
    convo
  end

  def any_unread?
    notifications.any? { |n| !n.seen? }
  end

  def leave
    conversations.each do |conversation|
      Message.create(
        contents: "- #{number} has disconnected -",
        conversation: conversation,
        player: self,
        extra: { system_message: true }.to_json,
        no_links: true,
        order_num: conversation.last_order_num + 1
      )
    end

    notifications.update_all(seen: true)

    if change.nil? && fate.nil?
      self.change = game.changes.sample
      self.fate = game.fates.sample
      self.save
    end

    ActionCable.server.broadcast(
      "host_channel_#{game.id}",
      type: "player_leave",
      id: id
    )
  end

  private

    def set_number
      return if number

      loop do
        self.number = Random.rand(100_000).to_s.rjust(5, "0")
        break unless Player.exists?(left: false, number: number)
      end
    end

    def set_game
      return unless game.nil? && !code.nil?

      self.game = Game.find_by(code: code)
    end

    def broadcast_creation
      return unless game

      ActionCable.server.broadcast(
        "host_channel_#{game.id}",
        type: "new_player",
        number: number,
        count: game.players.count,
        id: id
      )
    end

    def game_exists?
      return unless game.nil? && !code.nil? && !Game.exists?(code: code)

      errors.add(:game, "not found.")
    end

    def valid_game?
      return unless game

      if game.state != "before"
        errors.add(:game, "has already started")
      elsif game.players.count >= 5
        errors.add(:game, "is full")
      end
    end
end
