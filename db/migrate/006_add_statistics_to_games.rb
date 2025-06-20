class AddStatisticsToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :move_count, :integer, default: 0
    add_column :games, :started_at, :datetime
    add_column :games, :finished_at, :datetime
    add_column :games, :game_type, :string, default: 'solo'
    add_column :games, :winner_player, :string
    
    add_index :games, :game_type
    add_index :games, :finished_at
  end
end