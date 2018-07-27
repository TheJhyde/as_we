class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :contents
      t.belongs_to :from
      t.belongs_to :to
      t.timestamps
    end
  end
end
