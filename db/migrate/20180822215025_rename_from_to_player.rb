class RenameFromToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_reference :messages, :player, index: true
    remove_column :messages, :from_id
  end
end
