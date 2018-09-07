class AddFateToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :fate, :string
  end
end
