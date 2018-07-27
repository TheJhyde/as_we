class Game < ApplicationRecord
  has_many :players

  before_create do
    self.state = "before"
    self.code = SecureRandom.hex(3).upcase
  end
end
