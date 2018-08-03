class Player < ApplicationRecord
  belongs_to :game, optional: true
  has_and_belongs_to_many :conversations
  has_many :messages

  attr_accessor :code

  before_create :set_number

  private
    def set_number
      unless self.number
        loop do
          self.number = "#{Random.rand(100000)}".rjust(5, "0")
          break unless Player.exists?(left: false, number: self.number)
        end
      end
    end
end
