class AddSeenToConversations < ActiveRecord::Migration[5.2]
  def change
    add_column :conversations, :seen, :boolean, default: true
  end
end
