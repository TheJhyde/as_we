class Player < ApplicationRecord
  belongs_to :game
  has_many :messages

  before_create do
    loop do
      self.number = "#{Random.rand(100000)}".rjust(5, "0")
      break unless Player.exists?(left: false, number: self.number)
    end
  end
end
