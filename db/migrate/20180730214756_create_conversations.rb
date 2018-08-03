class CreateConversations < ActiveRecord::Migration[5.2]
  def change
    create_table :conversations do |t|
      t.timestamps
    end

    create_table :conversations_players do |t|
      t.belongs_to :player, index: true
      t.belongs_to :conversation, index: true
    end

    add_column :messages, :conversation_id, :integer
    # remove_column :messages, :from_id, :integer
    remove_column :messages, :to_id, :integer
  end
end
