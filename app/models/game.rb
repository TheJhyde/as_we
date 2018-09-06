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
    update(state: "running")

    self.players.each do |player|
      player.broadcast_to({type: "state", state: "running"})
    end

    p = self.players.where(host: false).to_a
    host = [self.players.find_by(host: true)]

    if Rails.env.development? && true
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

      NewsUpdateJob.set(wait: 12.minutes).perform_later(p.values_at(1) + host, "UPDATE: We have been able to establish limited text communication. This phone number should connect you to another survivor. Please stay inside. #{p[0].number}")
      NewsUpdateJob.set(wait: 12.minutes+10.seconds).perform_later(p.values_at(2) + host, "UPDATE: We have been able to establish limited text communication. This phone number should connect you to another survivor. Please stay inside. #{p[3].number}")

      NewsUpdateJob.set(wait: 17.minutes).perform_later(players + host, "UPDATE: Aliens have offered 'leniency to any human that surrenders itself peacefully. It will be sterilized and allowed to live its life in captivity.' Please stay inside.")

      NewsUpdateJob.set(wait: 20.minutes).perform_later(p.values_at(2) + host, "UPDATE: We have been able to establish further text communication. This phone number should connect you to another survivor. Please stay inside. #{p[0].number}")

      NewsUpdateJob.set(wait: 25.minutes).perform_later(p.values_at(0, 2, 3) + host, "UPDATE: New safehouse established in Colorado Springs. Fresh food and water available. Only seek it out if you can reach it safely without being followed. Otherwise, please stay inside.")

      NewsUpdateJob.set(wait: 30.minutes).perform_later(p.values_at(0, 3) + host, "UPDATE: We have been able to establish audio communication. Calls are vulnerable to surveillance.")

      NewsUpdateJob.set(wait: 45.minutes).perform_later(p.values_at(1, 2) + host, "UPDATE: Former alien general publicly decries wanton slaughter of humans")

      NewsUpdateJob.set(wait: 55.minutes).perform_later(players + host, "UPDATE: HRN leader assassinated. We are still here and they can not silence us.")

      NewsUpdateJob.set(wait: 60.minutes).perform_later(players + host, "The game is now over.")
    end
  end


  def end
    update(state: "end")
    self.players.update_all(left: true)

    self.players.each do |player|
      player.broadcast_to({type: "state", state: "end"})
    end
  end

  private
    def valid_state
      if state && !["before", "running", "end"].include?(state)
        errors.add(:state, :invalid)
      end
    end
end
