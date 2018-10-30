class ChangeGameStateToEnum < ActiveRecord::Migration[5.2]
  def change
    remove_column :games, :state, :string
    add_column :games, :state, :integer, default: 0
  end
end
