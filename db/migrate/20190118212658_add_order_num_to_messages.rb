class AddOrderNumToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :order_num, :integer
  end
end
