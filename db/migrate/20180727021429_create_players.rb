class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string :number
      t.boolean :host, default: false
      t.boolean :left, default: false
      t.belongs_to :game
      t.timestamps
    end
  end
end
