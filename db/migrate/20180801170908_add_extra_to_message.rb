class AddExtraToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :extra, :string, default: "{}"
  end
end
