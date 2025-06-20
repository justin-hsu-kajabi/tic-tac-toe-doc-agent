class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.references :room, null: false, foreign_key: true
      t.string :name, null: false
      t.string :session_id, null: false, index: { unique: true }
      t.string :symbol, null: false
      t.timestamps
    end
  end
end