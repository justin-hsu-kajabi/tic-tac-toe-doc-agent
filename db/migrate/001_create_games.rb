class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.text :board
      t.string :current_player, default: 'X'
      t.string :status, default: 'playing'
      t.timestamps
    end
  end
end