class Message < ApplicationRecord
  belongs_to :from, class_name: "Player"
  belongs_to :to, class_name: "Player"
end
