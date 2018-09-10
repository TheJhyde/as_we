class AddStartToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :start_time, :datetime
  end
end
