class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.belongs_to :conversation, index: true
      t.belongs_to :player, index: true
      t.boolean :seen, default: true
      t.timestamps
    end

    remove_column :conversations, :seen, :boolean
    drop_table :conversations_players
  end
end
