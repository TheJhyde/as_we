# frozen_string_literal: true

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

    if Player.exists?(number: "HRN", left: true)
      Player.find_by(number: "HRN").update(left: false)
    end

    self.players.each do |player|
      player.broadcast_to(type: "state", state: "running")
    end

    p = self.players.where(host: false).order(:created_at).to_a
    host = [self.players.find_by(host: true)]

    if Rails.env.development? && false
      NewsUpdateJob.set(wait: 15.seconds).perform_later(p + host, "UPDATE: Yo what up")
      NewsUpdateJob.set(wait: 30.seconds).perform_later(p + host, "UPDATE: Just two regular updates")
      NewsUpdateJob.set(wait: 1.minutes).perform_later(p, "Here's the host's number: #{host[0].number}")
    else
      # TODO: Move all this into an external file, like a locale or something, for easier updates

      # This assumes there is exactly 4 players.
      # If there are more than 4 players, player 5+ won't receive any news
      NewsUpdateJob.set(wait: 9.minutes).perform_later(p + host, "This is the Humanity Resistance Network. Alien forces claim to have eliminated all human life, but they’re wrong. Attempts are currently being made to establish new lines of communication. If you can read this message, please monitor your phone for further updates and stay inside.")

      NewsUpdateJob.set(wait: 12.minutes).perform_later(p.values_at(0, 1, 2) + host, "HRN UPDATE: If you have reason to believe")

      NewsUpdateJob.set(wait: 12.minutes + 15.seconds).perform_later(p.values_at(1, 2, 3) + host, "Please stay inside")

      NewsUpdateJob.set(wait: 15.minutes).perform_later(p.values_at(1, 3) + host, "HRN UPDATE: Aliens found a human safe house. Most humans killed, some taken captive. Please stay inside.")

      # ------ SEND NUMBERS
      NewsUpdateJob.set(wait: 18.minutes).perform_later(p.values_at(0, 2, 3) + host, "HRN UPDATE: We have been able to establish limited text communication. This code number should connect you to another survivor. Please stay inside.")

      if !p[1].nil?
        NewsUpdateJob.set(wait: 18.minutes + 10.seconds).perform_later(p.values_at(0), "#{p[1].number}")
      end

      if !p[2].nil?
        NewsUpdateJob.set(wait: 18.minutes + 20.seconds).perform_later(p.values_at(3), "#{p[2].number}")
      end

      NewsUpdateJob.set(wait: 18.minutes + 30.seconds).perform_later(p.values_at(1), "#{host[0].number}")
      # -------------

      NewsUpdateJob.set(wait: 25.minutes).perform_later(p + host, "HRN UPDATE: Aliens have offered 'leniency to any human that surrenders itself peacefully. It will be sterilized and allowed to live its life in captivity.' Please stay inside.")


      # ------------ SEND NUMBERS, PART 2


      if !p[1].nil?
        NewsUpdateJob.set(wait: 32.minutes).perform_later(host, "Attention Host: You may have the Imposter contact player #{p[1].number} now.")
      end

      NewsUpdateJob.set(wait: 45.minutes).perform_later(p + host, "HRN UPDATE: We have been able to establish a wider network for communication. This code should connect you to another survivor. Please stay inside.")

      if !p[2].nil?
        NewsUpdateJob.set(wait: 45.minutes + 10.seconds).perform_later(p.values_at(0), "#{p[2].number}")
      end

      NewsUpdateJob.set(wait: 52.minutes).perform_later(p.values_at(0, 2, 3) + host, "HRN UPDATE: New safehouse established in Colorado Springs. Fresh food and water available. Only seek it out if you can reach it safely without being followed. Otherwise, please stay inside.")

      NewsUpdateJob.set(wait: 58.minutes).perform_later(p.values_at(0, 3) + host, "HRN UPDATE: We have been able to establish audio communication. You may call other survivors if you exchange numbers. Be careful. Calls are vulnerable to surveillance.")

      NewsUpdateJob.set(wait: 70.minutes).perform_later(p.values_at(1, 2) + host, "HRN UPDATE: Former alien general publicly decries wanton slaughter of humans")

      NewsUpdateJob.set(wait: 75.minutes).perform_later(p + host, "HRN UPDATE: HRN leader assassinated. We are still here and they can not silence us.")

      NewsUpdateJob.set(wait: 90.minutes).perform_later(p + host, "The game is now over.")
    end
  end


  def end
    update(state: "end")

    self.players.each do |player|
      player.leave unless player.left?
      player.broadcast_to(type: "state", state: "end")
    end
    Player.find_by(number: "HRN").notifications.update_all(seen: true)

    self.players.update_all(left: true)
  end

  def outcomes(key)
    # MAGIC NUMBER - how long you have to stay inside for the game to not just kills you
    Rails.cache.fetch(key, expires_in: 1.minute) do
      if start_time > 25.minutes.ago
        { fate: ["You were spotted by an alien. They killed you. You are dead. You will no longer be able to play this game."], change: ["NA"] }
      else
        players_left = players.where(left: true).count
        if players_left == 0
          { fate: fates.sample(1), change: changes.sample(3) }
        elsif players_left < 3
          { fate: fates.sample(2), change: changes.sample(2) }
        else
          { fate: fates.sample(3), change: changes.sample(1) }
        end
      end
    end
  end

  def fates
    [
        "you are killed by an alien militia in less than a week.",
        "you see so many of your fellow humans suffer horrible fates that you decide to take your own life within a month.",
        "you surrender or are captured by the alien government. they chemically sterilize you, and you live out your days as a servant in alien society.",
        "you spend your days on the run. you have no home and no source of clean water or food. you might survive, barely.",
        "you find a safe place to live with a human companion. you produce a single child.",
        "you publicly join the resistance and are assassinated. humanity is inspired by your sacrifice. you are remembered."
      ] - self.players.where(left: true).pluck(:fate)
  end

  def changes
    [
      "in less than a year, a human territory is established.",
      "laws are passed banning maltreatment of humans.",
      "enough humans survive so that the species will not die out.",
      "alien entertainment portrays a human character. it is inaccurate.",
      "a human learns alien law. they are allowed to practice as lawyer.",
      "humans are legally allowed to reproduce."
    ] - self.players.where(left: true).pluck(:change)
  end

  private
    def valid_state
      if state && !["before", "running", "end"].include?(state)
        errors.add(:state, :invalid)
      end
    end
end
