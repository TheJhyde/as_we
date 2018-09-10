# Valid Game States:
# "before" - before the game
# "running" - during the game
# "end" - game is over

class Game < ApplicationRecord
  has_many :players
  validate :valid_state

  before_create do
    self.state = "before"
    self.code = SecureRandom.hex(3).upcase
  end

  def start
    update(state: "running", start_time: DateTime.now)

    self.players.each do |player|
      player.broadcast_to({type: "state", state: "running"})
    end

    p = self.players.where(host: false).to_a
    host = [self.players.find_by(host: true)]

    if Rails.env.development? && false
      NewsUpdateJob.set(wait: 15.seconds).perform_later(p + host, "UPDATE: Yo what up")
      NewsUpdateJob.set(wait: 30.seconds).perform_later(p + host, "UPDATE: Just two regular updates")
      NewsUpdateJob.set(wait: 1.minutes).perform_later(p, "Here's the host's number: #{host[0].number}")
    else
      # TODO: Move all this into an external file, like a locale or something, for easier updates
      
      # This assumes there is exactly 4 players.
      # If there are less than 4 players, the updates with numbers will break
      # If there are more than 4 players, player 5+ won't receive any news
      NewsUpdateJob.set(wait: 5.minutes).perform_later(p + host, "UPDATE: This is the Humanity Resistance Network. Alien forces claim to have eliminated all human life, but they’re wrong. Attempts are currently being made to establish new lines of communication. If you can read this message, please monitor your phone for further updates and stay inside.")

      NewsUpdateJob.set(wait: 7.minutes).perform_later(p.values_at(0, 1, 2) + host, "UPDATE: If you see :) ==+ sas 294301-23 /line;; immediately =P jkjkjk Please stay inside.")

      NewsUpdateJob.set(wait: 10.minutes).perform_later(p.values_at(2, 3) + host, "UPDATE: Aliens found a human safe house. Most humans killed, some taken captive. Please stay inside")

      if p[0]
        NewsUpdateJob.set(wait: 12.minutes).perform_later(p.values_at(1) + host, "UPDATE: We have been able to establish limited text communication. This phone number should connect you to another survivor: #{p[0].number}. Please stay inside.")
      end

      if p[3]
        NewsUpdateJob.set(wait: 12.minutes+10.seconds).perform_later(p.values_at(2) + host, "UPDATE: We have been able to establish limited text communication. This phone number should connect you to another survivor: #{p[3].number}. Please stay inside.")
      end

      NewsUpdateJob.set(wait: 17.minutes).perform_later(players + host, "UPDATE: Aliens have offered 'leniency to any human that surrenders itself peacefully. It will be sterilized and allowed to live its life in captivity.' Please stay inside.")

      if p[0]
        NewsUpdateJob.set(wait: 20.minutes).perform_later(p.values_at(2) + host, "UPDATE: We have been able to establish further text communication. This phone number should connect you to another survivor: #{p[0].number}. Please stay inside.")
      end

      NewsUpdateJob.set(wait: 25.minutes).perform_later(p.values_at(0, 2, 3) + host, "UPDATE: New safehouse established in Colorado Springs. Fresh food and water available. Only seek it out if you can reach it safely without being followed. Otherwise, please stay inside.")

      NewsUpdateJob.set(wait: 30.minutes).perform_later(p.values_at(0, 3) + host, "UPDATE: We have been able to establish audio communication. Calls are vulnerable to surveillance.")

      NewsUpdateJob.set(wait: 45.minutes).perform_later(p.values_at(1, 2) + host, "UPDATE: Former alien general publicly decries wanton slaughter of humans")

      NewsUpdateJob.set(wait: 55.minutes).perform_later(players + host, "UPDATE: HRN leader assassinated. We are still here and they can not silence us.")

      NewsUpdateJob.set(wait: 60.minutes).perform_later(players + host, "The game is now over.")
    end
  end


  def end
    update(state: "end")

    self.players.each do |player|
      player.leave unless player.left?
      player.broadcast_to({type: "state", state: "end"})
    end

    self.players.update_all(left: true)
  end

  def outcomes
    # MAGIC NUMBER - how long you have to stay inside for the game to not just kills you
    if start_time > 17.minutes.ago
      {fate: ["You were spotted by an alien. They killed you. You are dead. You will no longer be able to play this game."], change: ["NA"]}
    else
      players_left = players.where(left: true).count
      if players_left == 0
        {fate: fates.sample(1), change: changes.sample(3)}
      elsif players_left < 3
        {fate: fates.sample(2), change: changes.sample(2)}
      else
        {fate: fates.sample(3), change: changes.sample(1)}
      end
    end
  end

  def fates
    fates = [
        "You are killed by an alien militia in less than a week.", 
        "You see so many of your fellow humans suffer horrible fates that you decide to take your own life within a month.",
        "You surrender or are captured by the alien government. They chemically sterilize you, and you live out your days as a servant in alien society.", 
        "You spend your days on the run. you have no home and no source of clean water or food. You might survive, barely.", 
        "You find a safe place to live with a human companion. You might be able to produce a single child.", 
        "You publicly join the resistance and are assassinated. Humanity is inspired by your sacrifice. You are remembered."
      ] - self.players.where(left: true).pluck(:fate)
  end

  def changes
    changes = [
      "In less than a year, a human territory is established.",
      "Laws are passed banning maltreatment of humans.",
      "Enough humans survive so that the species will not die out.",
      "Alien entertainment portrays a human character. It is inaccurate.",
      "A human learns alien law. they are allowed to practice as lawyer.",
      "Humans are allowed to reproduce."
    ] - self.players.where(left: true).pluck(:change)
  end

  private
    def valid_state
      if state && !["before", "running", "end"].include?(state)
        errors.add(:state, :invalid)
      end
    end
end
