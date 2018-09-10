class AddFateToPlayer < ActiveRecord::Migration[5.2]
  def change
    add_column :players, :fate, :string
    add_column :players, :change, :string
  end
end
