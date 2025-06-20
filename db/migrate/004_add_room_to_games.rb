class AddRoomToGames < ActiveRecord::Migration[7.0]
  def change
    add_reference :games, :room, null: true, foreign_key: true
    add_column :games, :player_x, :string
    add_column :games, :player_o, :string
  end
end