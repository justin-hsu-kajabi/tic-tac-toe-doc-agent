class CreateGameStatistics < ActiveRecord::Migration[7.0]
  def change
    create_table :game_statistics do |t|
      t.integer :total_games, default: 0
      t.integer :total_wins, default: 0
      t.integer :total_draws, default: 0
      t.integer :total_losses, default: 0
      t.integer :multiplayer_games, default: 0
      t.integer :solo_games, default: 0
      t.float :average_game_duration, default: 0.0
      t.integer :fastest_win_moves, default: nil
      t.integer :longest_game_moves, default: 0
      t.date :stat_date, null: false
      t.timestamps
    end
    
    add_index :game_statistics, :stat_date, unique: true
  end
end