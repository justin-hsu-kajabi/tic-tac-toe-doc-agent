class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :status, default: 'waiting'
      t.integer :max_players, default: 2
      t.timestamps
    end
  end
end