class AddTypeToPlayers < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :role, :integer, default: 0
    remove_column :players, :host, :boolean
  end
end
