# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :conversation
  belongs_to :player
end
